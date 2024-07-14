module "vpc" {
  source = "./vpc_module"

  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.11.0/24"
  database_subnet_cidr_block = "10.0.21.0/24"

  tags = {
    Name        = "project-timing-1"
    Terraform   = "true"
    Environment = "dev"
  }
}
