module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "ec2" {
  source        = "./modules/ec2"
  instance_type = var.instance_type
  key_name      = var.key_name
}
