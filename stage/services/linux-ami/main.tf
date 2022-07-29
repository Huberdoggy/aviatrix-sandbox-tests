terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "development"
}

resource "aws_instance" "ubuntu-docker" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.kyle-sg.name]
  key_name        = aws_key_pair.generated_key.key_name

  user_data = data.template_file.user_data.rendered // Point to my external Bash script.

  tags = {
    Name = "Ubuntu-Docker"
  }
}

# Init my default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "kyle-sg" {
  name        = "kyle-sg"
  description = "Custom defined rules for SSH and inbound web access"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "kyle-sg"
  }
}

resource "aws_security_group_rule" "allow-ssh" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kyle-sg.id
}

resource "aws_security_group_rule" "allow-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kyle-sg.id
}

// Dynamically generate key pairs on instance deployment. I prefer RSA out of habit..
resource "tls_private_key" "auto" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" { // The pub param will be derived from the above private instantiation
  key_name   = "kyle-generated-key"
  public_key = tls_private_key.auto.public_key_openssh
}

// Create .pem file of priv key directly to my host VM
// Overwrite each 'apply' so that the file stays updated w/ the instance
// REMINDER: For Ubuntu EC2, the default username is 'ubuntu'
resource "local_sensitive_file" "pem_file" {
  filename        = "${path.cwd}/kyle-key.pem"
  content         = tls_private_key.auto.private_key_pem
  file_permission = 400 // chmod 400 on the output key, else, will recieve error that it is too worldy readable for security purposes
}

// Now, get the pub key (for convenience). Basically identical to running 'ssh-keygen -y -f '<path to pem>' > '<path to pub>'
// Chmod perms can be more relaxed
resource "local_file" "pub_file" {
  filename        = "${path.cwd}/kyle-key.pub"
  content         = tls_private_key.auto.public_key_openssh
  file_permission = 644
}

data "template_file" "user_data" {
  template = file("setup.sh")
  // Has 1 attrib called 'rendered' aka the result of rendering defined 'template', which includes
  // interpolated syntax. Therefore, we need to explicitly re-define var values here to become available and used by the script:
  # vars {

  # }
}
