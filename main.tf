provider "aws" {
  region = "us-east-1"
}

variable "alert_email" {
  description = "Email address to receive alerts (unused for now)"
  type        = string
  default     = ""
}

resource "aws_sns_topic" "health_topic" {
  name = "dev-health-check-topic"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-health-check-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-health-check-profile"
  role = aws_iam_role.ec2_role.name
}

locals {
  config_yaml         = templatefile("${path.module}/config.yaml.tmpl", {
    sns_topic_arn = aws_sns_topic.health_topic.arn
  })
  health_check_script = file("${path.module}/health_check.py")
}

resource "aws_instance" "ec2" {
  ami                         = "ami-085386e29e44dacd7" # Amazon Linux 2
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/userdata.sh", {
    config_yaml         = local.config_yaml
    health_check_script = local.health_check_script
  })

  tags = {
    Name = "health-check-ec2"
  }
}
