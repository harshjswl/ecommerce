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
apt update -y
apt install -y docker.io docker-compose awscli
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
EOF


  tags = {
    Name = "ecommerce-ec2"
  }
}
