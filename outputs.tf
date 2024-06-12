# Output
output "network" {
  value = {
    name = lookup(data.google_compute_network.shared_vpc, "name", null)
    id   = lookup(data.google_compute_network.shared_vpc, "id", null)
  }
}
output "subnets" {
  value = [for i, v in local.subnets :
    {
      id     = "${replace(v, "https://www.googleapis.com/compute/v1/", "")}"
      name   = element(reverse(split("/", v)), 0)
      region = element(reverse(split("/", v)), 2)
    }
  ]
}
