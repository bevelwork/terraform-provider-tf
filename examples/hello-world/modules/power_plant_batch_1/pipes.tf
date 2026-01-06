resource "factorio_entity" "pipe_to_ground_244" {
  surface = var.surface
  name    = "pipe-to-ground"
  position {
    x = var.base_x + 42.5
    y = var.base_y + 4.5
  }
  direction = "north"
  force     = var.force
}

resource "factorio_entity" "pipe_to_ground_269" {
  surface = var.surface
  name    = "pipe-to-ground"
  position {
    x = var.base_x + 42.5
    y = var.base_y + 6.5
  }
  direction = "south"
  force     = var.force
}

locals {
  missings = [
    { x = var.base_x + 42.5, y = var.base_y + 7.5 },
    { x = var.base_x + 42.5, y = var.base_y + 8.5 },
  ]
}

resource "factorio_entity" "pipe_missing" {
  for_each = { for i, v in local.missings : i => v }
  surface  = var.surface
  name     = "pipe"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = "north"
  force     = var.force
}
