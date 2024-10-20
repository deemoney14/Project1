provider "aws" {
  
  region = "us-west-1"

}

# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }

}

#subnet
resource "aws_subnet" "webpress" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1"
  }
  
}

#Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet gateway"
  }
  }

  #Route Table
resource "aws_route_table" "routetabel" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block ="0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
}

#Route Table association 
resource "aws_route_table_association" "webpress" {
  subnet_id = aws_subnet.webpress.id
  route_table_id = aws_route_table.routetabel.id
  
}


#ec2 
resource "aws_instance" "web" {
  ami           = "ami-04fdea8e25817cd69"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  subnet_id = aws_subnet.webpress.id
  

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              yum install -y php php-mysqlnd
              amazon-linux-extras install -y php7.4
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "presser"
  }

  
}

output "instance_ip" {
  value = aws_instance.web.public_ip
  
}

#Secuirty Group

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress_sg"
  description = "Allow inbound traffic for WordPress"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wordpress"

  }
  ingress {
    from_port   = 80
    to_port     = 80
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
  protocol    = "-1" # This allows all protocols
  cidr_blocks = ["0.0.0.0/0"]
}
}






  
  
