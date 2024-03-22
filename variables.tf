variable "projectname" {
  type        = string
  description = "This variable indicates project name"
}
variable "region" {
  description = "This variable declares region"
  type = string
  
}
variable "vpc_cidr" {
  type        = string
  description = "Public Subnet vpc cidr value"
}

variable "cidr_public_subnet" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = string
  description = "Private Subnet CIDR values"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zones"
}
variable "key_name" {
  description = "The name of the SSH key pair."
}

variable "public_key" {
  description = "The public key content."
}

variable "ami_id" {
  description = "This variable indicates ami id"
  type = string
}
variable "instance_type" {
  description = "This variable indicates Instance type"
  type = string
}
variable "config" {
   default = {}
   }
