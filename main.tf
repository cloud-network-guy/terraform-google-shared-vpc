
# Set Some Locals
locals {
  service_project_id = lower(trimspace(coalesce(var.project_id, var.host_project_id)))
  host_project_id    = lower(trimspace(coalesce(var.host_project_id, var.project_id)))
  network            = lower(trimspace(var.network))
  region             = lower(trimspace(var.region))
  query_folder       = var.folder_id != null ? true : false
}

data "google_projects" "active_projects" {
  count  = local.query_folder ? 1 : 0
  filter = "parent.id:${var.folder_id} lifecycleState:ACTIVE"
}

locals {
  active_projects = local.query_folder ? one(data.google_projects.active_projects).projects : [local.service_project_id]
}

# For each active project, get project details by looking up project ID
data "google_project" "service_projects" {
  for_each   = toset(local.active_projects)
  project_id = each.key
}

locals {
  gke_enabled = true
  projects = {
    for _ in data.google_project.service_projects :
    _.project_id => {
      name   = lookup(_, "name", "unknown")
      number = lookup(_, "number", 000000000)
      labels = lookup(_, "labels", {})
      compute_sa_accounts = [
        "serviceAccount:${_.number}-compute@developer.gserviceaccount.com",
        "serviceAccount:${_.number}@cloudservices.gserviceaccount.com",
        local.gke_enabled ? "serviceAccount:${_.number}@container-engine-robot.iam.gserviceaccount.com" :
        null,
      ]
    }
  }
}

# Configure Beta provider for quota account
provider "google-beta" {
  user_project_override = true
  billing_project       = local.host_project_id
}

# Get Project Service Accounts from Cloud Asset Resources
data "google_cloud_asset_resources_search_all" "service_accounts" {
  provider = google-beta
  scope    = "projects/${local.service_project_id}"
  asset_types = [
    "iam.googleapis.com/ServiceAccount"
  ]
}

# Query Shared VPC Host Project for network information
data "google_compute_network" "shared_vpc" {
  name    = local.network
  project = local.host_project_id
}

# Filter subnets down to the specific region
locals {
  subnet_self_links = [
    for i, v in data.google_compute_network.shared_vpc.subnetworks_self_links :
    v if strcontains(v, "/regions/${local.region}/subnetworks/")
  ]
  all_subnets = {
    for k, v in local.subnet_self_links :
    replace(v, "https://www.googleapis.com/compute/v1/", "") => {
      name   = element(reverse(split("/", v)), 0)
      region = element(reverse(split("/", v)), 2)
    }
  }
}

# Get all subnets for a given region from the Host network project
data "google_compute_subnetwork" "subnets" {
  for_each = { for k, v in local.all_subnets : k => v }
  name     = each.value.name
  region   = each.value.region
  project  = local.host_project_id
}

locals {
  subnets = [for _ in data.google_compute_subnetwork.subnets : _]
}