variable "x" {
  type = number
}
variable "y" {
  type = number
}


resource "factorio_entity" "feed_joiner" {
  for_each = { for idx, vals in [
    { x = var.x, y = var.y, direction = "east" },
    { x = var.x + 1, y = var.y, direction = "east" },
    { x = var.x + 2, y = var.y, direction = "north" },
    { x = var.x + 3, y = var.y, direction = "north" },
    { x = var.x + 4, y = var.y, direction = "west" },
    { x = var.x + 5, y = var.y, direction = "west" },
    { x = var.x + 2, y = var.y - 1, direction = "north" },
    { x = var.x + 3, y = var.y - 1, direction = "north" },
    { x = var.x + 2, y = var.y - 2, direction = "north" },
    { x = var.x + 3, y = var.y - 2, direction = "north" },
  ] : idx => vals }
  name      = "express-transport-belt"
  direction = each.value.direction
  position {
    x = each.value.x
    y = each.value.y
  }
}

