# ---------------------------------------------------------------------------
# State backend
# ---------------------------------------------------------------------------
# For this single-operator lab the state is kept locally (terraform.tfstate,
# git-ignored). In a team or production setting, uncomment the block below to
# store state remotely in an encrypted, versioned S3 bucket with native S3
# state locking, so that state is shared, backed up and never committed to Git.
#
# terraform {
#   backend "s3" {
#     bucket       = "mn521-enterprise-tfstate-<unique-suffix>"
#     key          = "partc/terraform.tfstate"
#     region       = "ap-southeast-2"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
