locals {
  global_vars                   = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars                  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars                   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars              = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  aws_account_id                = local.account_vars.locals.aws_account_id
  account_type                  = local.account_vars.locals.account_type
  aws_region                    = local.region_vars.locals.aws_region
  aws_region_cd                 = local.region_vars.locals.aws_region_cd
  terraform_state_s3_bucket     = "gpt-nx-terraform-state-${local.account_type}"
  terraform_lock_dynamodb_table = "my-lock-table"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "rancher-desktop"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = local.terraform_state_s3_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = local.terraform_lock_dynamodb_table
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# DRY common params
inputs = merge( 
  local.global_vars.locals,
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals
)