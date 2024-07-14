variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Name        = "project-timing-1"
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.11.0/24"
}

variable "database_subnet_cidr_block" {
  description = "The CIDR block for the database subnet"
  type        = string
  default     = "10.0.21.0/24"
}


variable "public_subnet_az" {
  description = "The availability zone for the public subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "private_subnet_az" {
  description = "The availability zone for the private subnet"
  type        = string
  default     = "ap-south-1b"
}

variable "database_subnet_az" {
  description = "The availability zone for the database subnet"
  type        = string
  default     = "ap-south-1c"
}

