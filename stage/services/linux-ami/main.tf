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
  security_groups = [aws_security_group.allow-ssh.name]
  key_name        = aws_key_pair.generated_key.key_name

  tags = {
    Name = "Ubuntu-Docker"
  }
}

# Init my default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow-ssh" {
  name        = "Allow_Inbound_SSH_Allow_All_Egress"
  description = "Allow inbound SSH on TCP port 22"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound/unset
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow_Inbound_SSH_Allow_All_Egress"
  }
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
