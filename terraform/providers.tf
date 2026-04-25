terraform {
  required_version = ">= 1.14.9"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.61"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
