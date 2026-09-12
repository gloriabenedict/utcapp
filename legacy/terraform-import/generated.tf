resource "aws_instance" "web" {
  ami                                  = "ami-0332d564d76dbd8d6"
  associate_public_ip_address          = true
  availability_zone                    = "us-east-1c"
  instance_type                        = "t3.micro"
  key_name                             = "ec2key2"
  security_groups                      = ["launch-wizard-3"]
  subnet_id                            = "subnet-0844d51757bc3a8f3"
  tags = {
    Name = "dev-app-server-test"
  }
  tags_all = {
    Name = "dev-app-server"
  }
}
