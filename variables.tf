variable "folder_id" {
  description = "Folder ID containing list of Projects to examine"
  type        = string
  default     = null
}
variable "project_id" {
  description = "Specific Project ID of the GCP Project"
  type        = string
  default     = null
}
variable "host_project_id" {
  description = "For Shared VPC, Project ID of the Host Network Project"
  type        = string
  default     = null
}
variable "network" {
  description = "Name of the VPC Network"
  type        = string
  default     = "default"
}
variable "region" {
  description = "Default GCP region name"
  type        = string
  default     = "us-central1"
}
variable "special_subnets" {
  description = "Substrings to ignore in subnets list"
  default     = []
}
