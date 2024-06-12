
# Set Some Locals
locals {
  project_id      = lower(trimspace(coalesce(var.project_id, var.host_project_id)))
  host_project_id = lower(trimspace(coalesce(var.host_project_id, var.project_id)))
  network         = lower(trimspace(var.network))
  region          = lower(trimspace(var.region))
}

# Query Shared VPC Host Project for network information
data "google_compute_network" "shared_vpc" {
  name    = local.network
  project = local.host_project_id
}

# Filter subnets down to the specific region
locals {
  subnets = [for i, v in data.google_compute_network.shared_vpc.subnetworks_self_links :
    v if strcontains(v, "/regions/${local.region}/subnetworks/")
  ]
}

