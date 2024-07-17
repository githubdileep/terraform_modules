# Module for creating VPC and subnets
module "vpc_module" {
  source = "./vpc_module"

  # Configuration for the VPC module
  vpc_cidr_block        = "10.0.0.0/16"
  public_subnet_count   = 2
  private_subnet_count  = 2
  database_subnet_count = 2
  create_nat_gateway    = true

  # Tags to apply to resources created by the VPC module
  tags = {
    Name        = "project-timing-1"
    Terraform   = "true"
    Environment = "dev"
  }
}
