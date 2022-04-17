include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  common = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
}

terraform {
  source = "../../..//modules/gcp-gke"
}

inputs = {
  project_id = local.env.project

  cluster_name = join("-", [local.common.org, local.env.env])
  region       = local.env.region
  zones        = ["asia-southeast1-b"]
  vpc_cidr_main = "10.110.0.0/16"
  vpc_secondary_cidr_pods = "10.120.0.0/16"
  vpc_secondary_cidr_services = "10.130.0.0/16"

  machine_type = "e2-medium"
  max_nodes    = 6

  disk_size = 30

  preemptible = true
}