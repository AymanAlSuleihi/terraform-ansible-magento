#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
terraform_dir="$repo_root/terraform"
inventory_file="$repo_root/ansible/inventory.yml"

server_name=$(cd "$terraform_dir" && terraform output -raw server_name)
server_ip=$(cd "$terraform_dir" && terraform output -raw server_ipv4_address)
admin_user=$(cd "$terraform_dir" && terraform output -raw admin_username)

cat > "$inventory_file" <<EOF
all:
  children:
    magento_servers:
      hosts:
        ${server_name}:
          ansible_host: ${server_ip}
          ansible_user: ${admin_user}
          ansible_become: true
EOF

printf 'Wrote %s for %s (%s)\n' "$inventory_file" "$server_name" "$server_ip"