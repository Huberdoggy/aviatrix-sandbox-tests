variable "aws_region" {
  description = "My default deployment region"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "AMI of my desired Ubuntu 20.04 instance"
  type        = string
  default     = "ami-0070c5311b7677678"
}

variable "instance_type" {
  type    = string
  default = "t2.micro" # For free tier compliance
}

variable "ssh_port" {
  description = "For use with security group allow"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "For use with security group allow"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "For use with security group allow. Access Aviatrix CoPilot web UI"
  type        = number
  default     = 443
}

variable "syslog_port" {
  description = "For use with security groupe allow. Accessing Aviatrix Syslog (UDP)"
  type        = number
  default     = 5000
}

variable "flowiq_port" {
  description = "For use with security groupe allow. Accessing Aviatrix FlowIQ (UDP)"
  type        = number
  default     = 31283
}
