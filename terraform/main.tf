terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        region = var.aws_region
    }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

data "aws_availability_zones" "available_zones" {
  
}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

resource "aws_security_group" "allow_mssql" {
  name_prefix = "allow_mssql_"
  
  ingress {
    from_port = 1433
    to_port = 1433
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "testdatabaseinstance" {
  identifier = var.db_instance_identifier
  engine = "sqlserver-ex"
  engine_version = "15.00.4415.2.v1"
  instance_class = "db.t3.micro"
  allocated_storage = 10
  storage_type = "gp2"
  publicly_accessible = true
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.allow_mssql.id]
  tags = {
    Name = var.db_instance_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
        sqlcmd -S ${replace(self.endpoint, ":", ",")} -U ${self.username} -P '${self.password}' -C -Q "CREATE DATABASE ${var.db_name};";
        EOT
        interpreter = [ "pwsh","-Command" ] 
    }
}

output "db_host" {
  value = aws_db_instance.testdatabaseinstance.endpoint
  description = "The endpoint of the SQL Server RDS instance"
}

output "db_name" {
  value = var.db_name
  description = "The database name"
}