terraform {
  backend "s3" {
    bucket         = "terraform-state-73cea43c7d6aa30e" # Replace with your bucket name
    key            = "reverse-proxy/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock-73cea43c7d6aa30e" # Replace with your table name
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}



provider "aws" {
  region = "us-west-2"
}


module "k3s" {
  source = "../nixos-asg-module"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-west-2a", "us-west-2b"]

  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9tjvxDXYRrYX6oDlWI0/vbuib9JOwAooA+gbyGG/+Q robertwendt@Roberts-Laptop.local"

  ami = "ami-095c0a8aee00e80bd"
}


# elastic ip
resource "aws_eip" "eip" {
}

output "autoscaling_group_name" {
  value = module.k3s.autoscaling_group_name
}
output "app_launch_template_id" {
  value = module.k3s.app_launch_template_id
}

output "eip" {
  value = aws_eip.eip.public_ip
}
