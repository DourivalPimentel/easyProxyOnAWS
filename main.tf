# Get the latest Ubuntu 18.04
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "easyProxyKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "easyProxyKey"
  public_key = tls_private_key.easyProxyKey.public_key_openssh
}

resource "aws_security_group" "sg" {
  name          = "easyProxySG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.latest-ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  tags = {
    Name       = "easyProxy"
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.ec2.id
  tags = {
    Name = "easyProxyIP"
  }
}

output "instances" {
  value = {
    public_ips = aws_eip.ip.public_ip
  }
}

output "ssh_private_key" {
  value = {
    ssh_private_key = tls_private_key.easyProxyKey.private_key_pem
  }
}

output "ssh_public_key" {
  value = {
    ssh_public_key = tls_private_key.easyProxyKey.public_key_openssh
  }
}