# proxmox-talos-k8s-cluster

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.76.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.8.0-alpha.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

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
| [proxmox_virtual_environment_vm.control_plane](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.worker](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_urls) | data source |
| [talos_machine_configuration.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Unique name for the Talos cluster (used in VM names and Talos config). | `string` | n/a | yes |
| <a name="input_control_plane_nodes"></a> [control\_plane\_nodes](#input\_control\_plane\_nodes) | Configuration for the control plane nodes. | <pre>object({<br/>    count = number<br/>    vm_config = object({<br/>      cores        = number<br/>      memory       = number # In MiB<br/>      boot_disk_gb = number<br/>      cpu_type     = optional(string, "x86-64-v2-AES")<br/>    })<br/>    # List of static IP configurations. MUST match the count.<br/>    ip_configs = list(object({<br/>      ip      = string # e.g., "192.168.1.10/24"<br/>      gateway = string # e.g., "192.168.1.1"<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_control_plane_vip"></a> [control\_plane\_vip](#input\_control\_plane\_vip) | Optional: The Virtual IP address for the control plane API server. If provided, kube-vip will be configured. | `string` | `null` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to use for the VMs (e.g., 'vmbr0'). | `string` | n/a | yes |
| <a name="input_proxmox_iso_datastore_id"></a> [proxmox\_iso\_datastore\_id](#input\_proxmox\_iso\_datastore\_id) | The Proxmox storage ID where the Talos ISO will be downloaded/stored. | `string` | n/a | yes |
| <a name="input_proxmox_node_name"></a> [proxmox\_node\_name](#input\_proxmox\_node\_name) | The Proxmox node where VMs will be created. | `string` | n/a | yes |
| <a name="input_proxmox_vm_datastore_id"></a> [proxmox\_vm\_datastore\_id](#input\_proxmox\_vm\_datastore\_id) | The Proxmox storage ID where VM disks will be created. | `string` | n/a | yes |
| <a name="input_talos_config_patches"></a> [talos\_config\_patches](#input\_talos\_config\_patches) | List of YAML strings to patch the machine configs (applied to ALL nodes). | `list(string)` | `[]` | no |
| <a name="input_talos_config_patches_control_plane"></a> [talos\_config\_patches\_control\_plane](#input\_talos\_config\_patches\_control\_plane) | List of YAML strings to patch ONLY the control plane machine configs. | `list(string)` | `[]` | no |
| <a name="input_talos_config_patches_worker"></a> [talos\_config\_patches\_worker](#input\_talos\_config\_patches\_worker) | List of YAML strings to patch ONLY the worker machine configs. | `list(string)` | `[]` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version to use (e.g., 'v1.7.5'). | `string` | n/a | yes |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | List of tags to apply to the Proxmox VMs. | `list(string)` | `[]` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Configuration for the worker nodes. | <pre>object({<br/>    count = number<br/>    vm_config = object({<br/>      cores           = number<br/>      memory          = number # In MiB<br/>      boot_disk_gb    = number<br/>      storage_disk_gb = number<br/>      cpu_type        = optional(string, "x86-64-v2-AES")<br/>    })<br/>    use_dhcp = optional(bool, true)<br/>    # Only provide if use_dhcp is false. MUST match the count.<br/>    ip_configs = optional(list(object({<br/>      ip      = string # e.g., "192.168.1.100/24"<br/>      gateway = string # e.g., "192.168.1.1"<br/>    })), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes client configuration (kubeconfig). Uses VIP endpoint if configured. |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | Talos client configuration (talosconfig). |
<!-- END_TF_DOCS -->
