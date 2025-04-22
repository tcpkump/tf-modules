# proxmox-talos-k8s-cluster

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.76.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.8.0-alpha.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.76.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | >= 0.8.0-alpha.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.talos_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.control](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/image_factory_schematic) | resource |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_urls) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_count"></a> [control\_plane\_count](#input\_control\_plane\_count) | Number of control plane nodes | `number` | `3` | no |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Number of CPU cores for the VM | `number` | `2` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for the VM in GB | `number` | `20` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name (dev, prod, etc.) | `string` | n/a | yes |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to use for the VM | `string` | n/a | yes |
| <a name="input_proxmox_iso_datastore_id"></a> [proxmox\_iso\_datastore\_id](#input\_proxmox\_iso\_datastore\_id) | Proxmox datastore ID | `string` | n/a | yes |
| <a name="input_proxmox_node_name"></a> [proxmox\_node\_name](#input\_proxmox\_node\_name) | Proxmox node name | `string` | n/a | yes |
| <a name="input_proxmox_vm_datastore_id"></a> [proxmox\_vm\_datastore\_id](#input\_proxmox\_vm\_datastore\_id) | Proxmox datastore ID | `string` | n/a | yes |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | List of SSH public keys to add to the VM | `list(string)` | `[]` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_node_ids"></a> [control\_node\_ids](#output\_control\_node\_ids) | Control node IDs |
<!-- END_TF_DOCS -->
