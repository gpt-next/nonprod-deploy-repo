terraform {
  source = "git::git@github.com:gpt-next/infra-modules.git//s3?ref=feature/s3"
}

include {
  path = find_in_parent_folders()
}


inputs = {
  bucket_name = "my-bucket!"
}