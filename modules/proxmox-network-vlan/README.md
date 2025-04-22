# proxmox-network-vlan

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.76.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_network_linux_bridge.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_network_linux_bridge) | resource |
| [proxmox_virtual_environment_network_linux_vlan.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_network_linux_vlan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bridge_address"></a> [bridge\_address](#input\_bridge\_address) | Bridge address | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name (dev, prod, etc.) | `string` | n/a | yes |
| <a name="input_proxmox_node_name"></a> [proxmox\_node\_name](#input\_proxmox\_node\_name) | Proxmox node name | `string` | n/a | yes |
| <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id) | VLAN ID | `number` | n/a | yes |
| <a name="input_vlan_interface"></a> [vlan\_interface](#input\_vlan\_interface) | Network interface name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vlan_id"></a> [vlan\_id](#output\_vlan\_id) | VLAN ID |
<!-- END_TF_DOCS -->
