locals {
  # Extract just the IP addresses for easier use in talos config
  control_plane_node_ips = [for ip_conf in var.control_plane_nodes.ip_configs : split("/", ip_conf.ip)[0]]
  # Use the first control plane node's IP for bootstrapping
  bootstrap_node_ip = local.control_plane_node_ips[0]

  # Use VIP if provided, otherwise fall back to the first control plane node IP for the cluster endpoint
  effective_cluster_endpoint_ip = var.control_plane_vip != null ? var.control_plane_vip : local.bootstrap_node_ip
  effective_cluster_endpoint    = "https://${local.effective_cluster_endpoint_ip}:6443"

  # This method supports both DHCP and Static IPs
  worker_node_ips = [
    for vm in proxmox_virtual_environment_vm.worker : # Iterate through all worker VM resources
    [
      # Inner loop: find the first non-localhost IP for the current VM
      for ip in flatten(vm.ipv4_addresses) : ip
      if ip != "127.0.0.1"
    ][0] # Select the first valid IP found
  ]

  common_vm_tags = concat(["talos", "kubernetes", var.cluster_name], var.vm_tags)

  # --- Configuration Patches ---
  # Define the kube-vip patch only if a VIP is provided
  kube_vip_patch = var.control_plane_vip != null ? yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            # Selects the primary physical network interface.
            # Assumes there's at least one physical interface.
            deviceSelector = {
              physical = true
            }
            dhcp = false
            vip = {
              ip = var.control_plane_vip
            }
          }
        ]
      }
    }
  }) : "" # Return an empty string if no VIP is configured (var.control_plane_vip is null)

  # Merge common, role-specific, and VIP patches for control plane
  # Use compact() to remove empty strings (like the kube_vip_patch if VIP is null)
  control_plane_patches = compact(concat(
    var.talos_config_patches,
    var.talos_config_patches_control_plane,
    [local.kube_vip_patch] # Add the VIP patch here
  ))

  # Worker patches do not include the VIP config patch
  worker_patches = compact(concat(var.talos_config_patches, var.talos_config_patches_worker))

  # Define file name for the downloaded ISO
  iso_file_name = "talos-${var.cluster_name}-${var.talos_version}.iso"
}
