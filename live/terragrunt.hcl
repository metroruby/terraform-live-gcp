locals {
  # Load any configured variables
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  common = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
}

# Configure Terragrunt to store state in GCP buckets
remote_state {
  backend = "gcs"

  config = {
    bucket      = join("-", [local.common.org, local.env.env, "--terraform-state"])
    prefix      = "${path_relative_to_include()}"
    credentials = local.env.credentials_path
    location    = local.env.region
    project     = local.env.project
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate an GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">=0.13"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.10.0, < 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.43, < 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
provider "google" {
  credentials = "${local.env.credentials_path}"
  project     = "${local.env.project}"
  region      = "${local.env.region}"
}

# For access to Google Beta features
provider "google-beta" {
  credentials = "${local.env.credentials_path}"
  project     = "${local.env.project}"
  region      = "${local.env.region}"
}
  EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.env,
  local.common,
)