data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# =============================
# SECURITY GROUP (SAFE)
# =============================
resource "aws_security_group" "app_sg" {
  name_prefix = "ecommerce-sg-"   # 👈 duplicate issue fix
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-sg"
  }
}

# =============================
# EC2 INSTANCE
# =============================
resource "aws_instance" "app" {
  ami           = "ami-02b8269d5e85954ef" # Ubuntu 22.04 (ap-south-1)
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    apt update -y

    # Install Docker
    apt install -y docker.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu

    # Install Docker Compose v2
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # Install AWS CLI v2
    apt install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Verify installs
    docker --version
    docker compose version
    aws --version
  EOF

  tags = {
    Name = "ecommerce-ec2"
  }
}
