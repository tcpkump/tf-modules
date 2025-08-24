# Terraform Module README

## Proxmox LXC Container

This Terraform module creates a Proxmox LXC container with the specified configuration.

### Usage

To use this module, include the following code in your Terraform script:

```terraform
module "proxmox_lxc_container" {
  source           = "example.com/terraform/modules/proxmox_lxc_container"
  container_count  = 1
  name             = "mycontainer"
  id               = [100]
  cpu              = 2
  mem              = 2048
  lxc_image        = "proxmox/lxc/ubuntu-20.04-standard_20.04-1_amd64.tar.xz"
  ssh_keys         = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."]
  start            = true
  target_node      = "proxmox1"
  unprivileged     = true
  disk_size        = 32
  disk_location    = ["local-zfs", "local-lvm"]
  ip               = ["192.168.0.10"]
  internal_domain  = "internal.example.com"
}

output "container_ip" {
  value = module.proxmox_lxc_container.container_ip
}
```

### Inputs

The following inputs are required:

- `container_count`: (int) the number of containers to create.
- `name`: (string) the name of the container.
- `id`: (list of ints) the unique ID of the container.
- `cpu`: (int) the number of CPU cores to allocate to the container.
- `mem`: (int) the amount of memory to allocate to the container in MB.
- `lxc_image`: (string) the name of the LXC image to use for the container.
- `ssh_keys`: (list of strings) a list of SSH public keys to add to the container.
- `start`: (bool) whether to start the container automatically when the host starts.
- `target_node`: (string) the name of the Proxmox node where the container should be created.
- `unprivileged`: (bool) whether to create an unprivileged container.
- `disk_size`: (int) the size of the root disk in GB.
- `disk_location`: (list of strings) the list of storage locations where the root disk will be created.
- `ip`: (list of strings) the IP address of the container.
- `internal_domain`: (string) the internal domain of the container.

### Outputs

The following output is available:

- `container_ip`: the IP address of the container.

### Examples

Basic configuration with one container:

```terraform
module "proxmox_lxc_container" {
  source           = "example.com/terraform/modules/proxmox_lxc_container"
  container_count  = 1
  name             = "mycontainer"
  id               = [100]
  cpu              = 2
  mem              = 2048
  lxc_image        = "proxmox/lxc/ubuntu-20.04-standard_20.04-1_amd64.tar.xz"
  ssh_keys         = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."]
  start            = true
  target_node      = "proxmox1"
  unprivileged     = true
  disk_size        = 32
  disk_location    = ["local-zfs", "local-lvm"]
  ip               = ["192.168.0.10"]
  internal_domain  = "internal.example.com"
}

output "container_ip" {
  value = module.proxmox_lxc_container.container_ip
}
```

Multiple containers:

```terraform
module "proxmox_lxc_container" {
  source           = "example.com/terraform/modules/proxmox_lxc_container"
  container_count  = 2
  name             = "mycontainer"
  id               = [100, 101]
  cpu              = 2
  mem              = 2048
  lxc_image        = "proxmox/lxc/ubuntu-20.04-standard_20.04-1_amd64.tar.xz"
  ssh_keys         = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."]
  start            = true
  target_node      = "proxmox1"
  unprivileged     = true
  disk_size        = 32
  disk_location    = ["local-zfs", "local-lvm"]
  ip               = ["192.168.0.10", "192.168.0.11"]
  internal_domain  = "internal.example.com"
}

output "container_ip_1" {
  value = module.proxmox_lxc_container[0].container_ip
}

output "container_ip_2" {
  value = module.proxmox_lxc_container[1].container_ip
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.82.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_container.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_count"></a> [container\_count](#input\_container\_count) | Number of containers to deploy | `number` | `1` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of CPU cores | `number` | `1` | no |
| <a name="input_disk_location"></a> [disk\_location](#input\_disk\_location) | List of datastore IDs for container storage | `list(string)` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of container disk (e.g., '20G') | `string` | `"8G"` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Network gateway IP address | `string` | `null` | no |
| <a name="input_host_node"></a> [host\_node](#input\_host\_node) | Proxmox node name where containers will be deployed | `string` | n/a | yes |
| <a name="input_id"></a> [id](#input\_id) | (Optional) List of VM IDs for containers, must match container\_count length | `list(number)` | `null` | no |
| <a name="input_ip"></a> [ip](#input\_ip) | List of IP addresses or 'dhcp' for containers | `list(string)` | n/a | yes |
| <a name="input_mem"></a> [mem](#input\_mem) | Amount of RAM in MB | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Base hostname for containers | `string` | n/a | yes |
| <a name="input_nesting"></a> [nesting](#input\_nesting) | Enable nesting feature for containers | `bool` | `true` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge name | `string` | `"vmbr0"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type (e.g., 'ubuntu', 'debian') | `string` | `"ubuntu"` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | List of SSH public keys to add to containers | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to containers | `list(string)` | `[]` | no |
| <a name="input_template_file_id"></a> [template\_file\_id](#input\_template\_file\_id) | Template file ID for the container OS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_hostnames"></a> [container\_hostnames](#output\_container\_hostnames) | List of container hostnames |
| <a name="output_container_ids"></a> [container\_ids](#output\_container\_ids) | List of container VM IDs |
| <a name="output_container_ip_addresses"></a> [container\_ip\_addresses](#output\_container\_ip\_addresses) | List of container IP addresses |
| <a name="output_container_names"></a> [container\_names](#output\_container\_names) | List of container resource names |
<!-- END_TF_DOCS -->
