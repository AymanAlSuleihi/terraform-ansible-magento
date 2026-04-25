variable "hcloud_token" {
  description = "Hetzner Cloud API token. Leave null to use the HCLOUD_TOKEN environment variable."
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}

variable "server_name" {
  description = "Name of the Hetzner Cloud server."
  type        = string
  default     = "magento-node-01"
}

variable "server_type" {
  description = "Hetzner server type, for example cx23 or cax11."
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Hetzner location code such as fsn1, nbg1, or hel1."
  type        = string
  default     = "fsn1"
}

variable "image" {
  description = "Server image name or ID. Ubuntu 24.04 is the default baseline."
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_keys" {
  description = "Existing Hetzner Cloud SSH key IDs or names to inject into the server and authorize for the admin user."
  type        = list(string)

  validation {
    condition     = length(var.ssh_keys) > 0
    error_message = "Provide at least one existing Hetzner Cloud SSH key name or ID in ssh_keys."
  }
}

variable "admin_username" {
  description = "Non-root Linux user created during first boot for SSH access and sudo."
  type        = string
  default     = "magento"

  validation {
    condition     = lower(var.admin_username) != "root" && can(regex("^[a-z_][a-z0-9_-]*[$]?$", var.admin_username))
    error_message = "admin_username must be a valid non-root Linux username."
  }
}

variable "labels" {
  description = "Additional labels to apply to the server."
  type        = map(string)
  default     = {}
}

variable "enable_ipv6" {
  description = "Whether to enable public IPv6 on the server."
  type        = bool
  default     = true
}

variable "backups" {
  description = "Whether to enable Hetzner backups for the server."
  type        = bool
  default     = false
}

variable "delete_protection" {
  description = "Whether to enable delete and rebuild protection on the server."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional extra cloud-init content or shell script appended after the built-in hardening steps."
  type        = string
  default     = null
  nullable    = true
}
