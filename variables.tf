
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-053b12d3152c0cc71" # Replace with a valid AMI ID
}

variable "instance_type" {
  default = "t2.micro"
}
