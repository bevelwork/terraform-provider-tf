terraform {
  required_providers {
    factorio = {
      source = "efokschaner/factorio"
    }
  }
}

variable "x" {
  type = number
}

variable "y" {
  type = number
}

resource "factorio_entity" "furnace" {
  for_each = { for i, val in [
    { x = var.x - 2, y = var.y },
    { x = var.x + 4, y = var.y },
  ] : i => val }
  name = "stone-furnace"
  position {
    x = each.value.x
    y = each.value.y
  }
}

resource "factorio_entity" "inserters" {
  for_each = { for i, val in [
    { x = var.x - 1, y = var.y, direction = "east" },
    { x = var.x + 2, y = var.y, direction = "west" },
    { x = var.x - 4, y = var.y, direction = "east" },
    { x = var.x + 5, y = var.y, direction = "west" },

    { x = var.x - 1, y = var.y - 1, direction = "east" },
    { x = var.x + 2, y = var.y - 1, direction = "west" },
    { x = var.x - 4, y = var.y - 1, direction = "east" },
    { x = var.x + 5, y = var.y - 1, direction = "west" },
  ] : i => val }
  name      = "burner-inserter"
  direction = each.value.direction
  position {
    x = each.value.x
    y = each.value.y
  }
  contents {
    kind = "coal"
    qty  = 20
  }
}

resource "factorio_entity" "belt" {
  for_each = { for i, val in [
    { x = var.x, y = var.y },
    { x = var.x + 1, y = var.y },
    { x = var.x, y = var.y + 1 },
    { x = var.x + 1, y = var.y + 1 },
  ] : i => val }

  name = "express-transport-belt"
  position {
    x = var.x + 1 - each.value.x
    y = var.y + 1 - each.value.y
  }
  direction = "north"
}

