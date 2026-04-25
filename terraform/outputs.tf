output "server_id" {
  description = "The Hetzner server ID."
  value       = hcloud_server.this.id
}

output "server_name" {
  description = "The Hetzner server name."
  value       = hcloud_server.this.name
}

output "server_ipv4_address" {
  description = "The public IPv4 address assigned to the server."
  value       = hcloud_server.this.ipv4_address
}

output "server_status" {
  description = "The current server status reported by Hetzner Cloud."
  value       = hcloud_server.this.status
}

output "admin_username" {
  description = "The non-root Linux user created for SSH access."
  value       = var.admin_username
}

output "ssh_command" {
  description = "Example SSH command for connecting to the server as the non-root admin user."
  value       = "ssh ${var.admin_username}@${hcloud_server.this.ipv4_address}"
}
