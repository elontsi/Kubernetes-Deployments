locals {
  ssh_user    = "ubuntu"
  key_name    = "emmanuel-eolab-project"
  private_key_path = "/Users/emmanuellontsi/Documents/Project/emmanuel-eolab-project.pem"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "emmanuel_vpc"
  }
}

resource "aws_subnet" "emmanuel_subnet1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.16.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "emmanuel_subnet1"
  }
}

resource "aws_subnet" "emmanuel_subnet2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.16.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "emmanuel_subnet2"
  }
}

resource "aws_network_interface" "net" {
  subnet_id = aws_subnet.emmanuel_subnet1.id

  tags = {
      Name = "primary_network_interface"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "emmanuel_gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "emmanuel_rt"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.emmanuel_subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.emmanuel_subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_tls_ssh" {
  name = "Allow inbound traffic"
  description = "Allow SSH and TLS traffic"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow https traffic"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow http traffic"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }
  ingress {
    cidr_blocks  = [ "0.0.0.0/0" ]
    description  = "Allow SSH traffic"
    protocol     = "tcp"
    from_port    = 22
    to_port      = 22
  }

  ingress {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = [ "0.0.0.0/0"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_inbound"
  }
}

resource "aws_instance" "web" {
  ami                    = var.AMI.eu-west-2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.allow_tls_ssh.id ]
  private_ip             = "10.16.1.15"
  subnet_id              = aws_subnet.emmanuel_subnet1.id
  availability_zone      = "us-west-2a"
  key_name               = local.key_name

  credit_specification {
    cpu_credits = "unlimited"
  }

  provisioner "remote-exec" {
      inline = ["echo 'wait until SSH is ready'"]

      connection {
          type = "ssh"
          user = local.ssh_user
          private_key = file(local.private_key_path)
          host        = aws_instance.web.public_ip
      }
  }
  provisioner "local-exec" {
      command = "ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${local.private_key_path} apache2.yaml"
  }
}