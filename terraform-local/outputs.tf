output "frontend_ecr_url" {
  value = module.ecr.frontend_repo_url
}

output "backend_ecr_url" {
  value = module.ecr.backend_repo_url
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}
