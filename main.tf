terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_instance" "zapier" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t2.micro"
  key_name      = "zapier"
  vpc_security_group_ids = ["sg-02a83ab53fe1a45c6"]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update and install Docker
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
                | tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io

              # Allow ubuntu user to run docker
              usermod -aG docker ubuntu || true

              # Pull images
              docker pull vishnusai1/containit:backend
              docker pull vishnusai1/containit:frontend

              # Run containers (adjust env vars as needed)
              docker run -d --name containit-backend -p 5000:5000 \
                -e MONGO_URI="${var.mongo_uri}" \
                -e FRONTEND_URL="${var.frontend_url}" \
                vishnusai1/containit:backend

              docker run -d --name containit-frontend -p 8000:8000 \
                -e BACKEND_URL="http://localhost:5000" \
                vishnusai1/containit:frontend
              EOF
              
  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "zapier" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}