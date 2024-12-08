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
  availability_zone = "ap-south-1a" # Ensure this is a valid AZ
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

  role     = aws_iam_role.lambda_exec.arn
  filename = "autoscale_function.zip" # Ensure the zip file exists
}

# Generate a random ID for the Lambda IAM Role to ensure uniqueness
resource "random_id" "unique_suffix" {
  byte_length = 8
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecutionRole-${random_id.unique_suffix.hex}" # Use a unique suffix
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

# Attach the basic execution policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
