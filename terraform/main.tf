locals {
  default_labels = {
    managed-by = "terraform"
    project    = "terraform-ansible-magento"
  }

  ssh_key_ids = toset([for key in var.ssh_keys : key if can(tonumber(key))])

  ssh_key_names = toset([for key in var.ssh_keys : key if !can(tonumber(key))])

  authorized_ssh_keys = concat(
    [for key in sort(tolist(local.ssh_key_ids)) : data.hcloud_ssh_key.by_id[key].public_key],
    [for key in sort(tolist(local.ssh_key_names)) : data.hcloud_ssh_key.by_name[key].public_key],
  )

  base_cloud_config = {
    package_update  = true
    package_upgrade = true
    ssh_pwauth      = false
    disable_root    = true
    users = [
      {
        name                = var.admin_username
        gecos               = "Primary admin user"
        groups              = ["sudo"]
        shell               = "/bin/bash"
        sudo                = "ALL=(ALL) NOPASSWD:ALL"
        lock_passwd         = true
        ssh_authorized_keys = local.authorized_ssh_keys
      }
    ]
    packages = [
      "fail2ban",
      "unattended-upgrades",
    ]
    write_files = [
      {
        path        = "/etc/ssh/sshd_config.d/99-terraform-hardening.conf"
        owner       = "root:root"
        permissions = "0644"
        content = join("\n", [
          "PasswordAuthentication no",
          "KbdInteractiveAuthentication no",
          "ChallengeResponseAuthentication no",
          "PermitRootLogin no",
          "PermitEmptyPasswords no",
          "PubkeyAuthentication yes",
          "X11Forwarding no",
          "AllowUsers ${var.admin_username}",
          "",
        ])
      },
      {
        path        = "/etc/apt/apt.conf.d/20auto-upgrades"
        owner       = "root:root"
        permissions = "0644"
        content = join("\n", [
          "APT::Periodic::Update-Package-Lists \"1\";",
          "APT::Periodic::Unattended-Upgrade \"1\";",
          "",
        ])
      },
    ]
    runcmd = [
      "systemctl enable --now fail2ban",
      "systemctl reload ssh || systemctl restart ssh || systemctl restart sshd",
    ]
  }

  base_user_data = join("\n", [
    "#cloud-config",
    yamlencode(local.base_cloud_config),
  ])

  has_extra_user_data = var.user_data != null && trimspace(var.user_data) != ""

  extra_user_data_content_type = local.has_extra_user_data ? (
    startswith(trimspace(var.user_data), "#cloud-config") ? "text/cloud-config" : "text/x-shellscript"
  ) : null

  effective_user_data = local.has_extra_user_data ? join("\n", [
    "MIME-Version: 1.0",
    "Content-Type: multipart/mixed; boundary=\"tf-user-data\"",
    "",
    "--tf-user-data",
    "Content-Type: text/cloud-config; charset=\"us-ascii\"",
    "",
    trimspace(local.base_user_data),
    "",
    "--tf-user-data",
    "Content-Type: ${local.extra_user_data_content_type}; charset=\"us-ascii\"",
    "",
    trimspace(var.user_data),
    "",
    "--tf-user-data--",
  ]) : trimspace(local.base_user_data)
}

data "hcloud_ssh_key" "by_id" {
  for_each = local.ssh_key_ids

  id = tonumber(each.value)
}

data "hcloud_ssh_key" "by_name" {
  for_each = local.ssh_key_names

  name = each.value
}

resource "hcloud_server" "this" {
  name               = var.server_name
  server_type        = var.server_type
  image              = var.image
  location           = var.location
  ssh_keys           = var.ssh_keys
  user_data          = local.effective_user_data
  backups            = var.backups
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  labels             = merge(local.default_labels, var.labels)

  public_net {
    ipv4_enabled = true
    ipv6_enabled = var.enable_ipv6
  }
}
