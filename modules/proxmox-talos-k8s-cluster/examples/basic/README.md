# basic

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.4.5 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.76.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.8.0-alpha.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example_cluster"></a> [example\_cluster](#module\_example\_cluster) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token, only set this via env variable (ex: TF\_VAR\_proxmox\_api\_token) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | Talos client configuration (talosconfig). |
<!-- END_TF_DOCS -->
