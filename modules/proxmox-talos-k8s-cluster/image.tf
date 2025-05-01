locals {
  version      = var.image.version
  schematic    = file("${path.root}/${var.image.schematic_path}")
  schematic_id = jsondecode(data.http.schematic_id.response_body)["id"]

  update_version        = coalesce(var.image.update_version, var.image.version)
  update_schematic_path = coalesce(var.image.update_schematic_path, var.image.schematic_path)
  update_schematic      = file("${path.root}/${local.update_schematic_path}")
  update_schematic_id   = jsondecode(data.http.updated_schematic_id.response_body)["id"]

  image_id        = "${local.schematic_id}_${local.version}"
  update_image_id = "${local.update_schematic_id}_${local.update_version}"

  # Comment the above 2 lines and un-comment the below 2 lines to use the provider schematic ID instead of the HTTP one
  # ref - https://github.com/vehagn/homelab/issues/106
  # image_id = "${talos_image_factory_schematic.this.id}_${local.version}"
  # update_image_id = "${talos_image_factory_schematic.updated.id}_${local.update_version}"
}

data "http" "schematic_id" {
  url          = "${var.image.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic
}

data "http" "updated_schematic_id" {
  url          = "${var.image.factory_url}/schematics"
  method       = "POST"
  request_body = local.update_schematic
}

resource "talos_image_factory_schematic" "this" {
  schematic = local.schematic
}

resource "talos_image_factory_schematic" "updated" {
  schematic = local.update_schematic
}

locals {
  # 1. Does *any* node in the entire configuration require an update?
  any_node_needs_update = anytrue([
    for k, v in var.nodes : v.update == true
  ])

  # 2. Determine the single version and schematic to use globally
  effective_version   = local.any_node_needs_update ? local.update_version : local.version
  effective_schematic = local.any_node_needs_update ? talos_image_factory_schematic.updated.id : talos_image_factory_schematic.this.id

  # 3. Get the set of unique host nodes
  # (Adjust syntax if var.nodes is a list: toset([for v in var.nodes : v.host_node]))
  unique_host_nodes = toset([for k, v in var.nodes : v.host_node])
}

resource "proxmox_virtual_environment_download_file" "this" {
  # Iterate directly over the unique host node names
  for_each = local.unique_host_nodes

  node_name    = each.key # The Proxmox node where the download happens
  content_type = "iso"
  datastore_id = var.image.proxmox_datastore

  # Use the globally determined version/schematic for all hosts
  file_name               = "${var.cluster.name}-${local.effective_schematic}-${local.effective_version}-${var.image.platform}-${var.image.arch}.img"
  url                     = "${var.image.factory_url}/image/${local.effective_schematic}/${local.effective_version}/${var.image.platform}-${var.image.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}
