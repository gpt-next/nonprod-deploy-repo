terraform {
  source = "git::git@github.com:gpt-next/infra-modules.git//s3"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment      = local.environment_vars.locals.environment
  aws_region_cd    = local.region_vars.locals.aws_region_cd
  aws_region       = local.region_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
  project_id = local.global_vars.locals.project_id
}

inputs = {
  bucket_name = "${local.project_id}-my-bucket-edit"
  environment = local.environment
}