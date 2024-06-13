# Output
output "project" {
  description = "Service Projects Information"
  value       = local.active_projects
}

output "network" {
  description = "Shared VPC Network Information"
  value = {
    id          = lookup(data.google_compute_network.shared_vpc, "id", null)
    name        = lookup(data.google_compute_network.shared_vpc, "name", null)
    num_subnets = length(local.subnets)
  }
}
output "subnets" {
  description = "Shared VPC available subnets"
  value = [for i, v in local.subnets :
    {
      name   = v.name
      region = v.region
    }
  ]
}
output "all_subnets" {
  value = data.google_compute_subnetwork.subnets
}
output "compute_sa_accounts" {
  value = { for k, v in local.projects : k => v.compute_sa_accounts }
}