data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "qemu",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  count = length(data.talos_image_factory_extensions_versions.this.extensions_info) > 0 ? 1 : 0
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = one(talos_image_factory_schematic.this[*].id) # Corrected from previous version
  platform      = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = var.proxmox_iso_datastore_id
  node_name    = var.proxmox_node_name
  url          = data.talos_image_factory_urls.this.urls.iso
  file_name    = local.iso_file_name
}
