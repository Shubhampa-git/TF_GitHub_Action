
provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "ap-south-1a"
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "Terraform-EC2"
  }
}

# Lambda Function for Auto-Scaling
resource "aws_lambda_function" "autoscale" {
  function_name = "AutoScalingFunction"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  role = aws_iam_role.lambda_exec.arn
  filename = "autoscale_function.zip" # Assume your function is packaged as ZIP
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
