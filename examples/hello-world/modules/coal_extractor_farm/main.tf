module "coal_chest" {
  source = "../full_chest"

  kind = "coal"
  x    = 10
  y    = 10
}

resource "factorio_entity" "output_chest" {
  surface = var.surface
  name    = "steel-chest"
  position {
    x = local.chest_location.x
    y = local.chest_location.y
  }
  direction = "north"
  force     = var.force
  lifecycle {
    ignore_changes = [
      contents,
    ]
  }
}

variable "direction" {
  type        = string
  description = "North or South belt output direction"
  default     = "north"
  validation {
    condition     = contains(["north", "south"], var.direction)
    error_message = "Valid directions are 'north' or 'south'."
  }
}

locals {
  # Generate positions for mining drills (vertical column)
  belt_length = 10
  chest_location = {
    x = var.x + 1
    y = var.y - local.belt_length - 2
  }
  drill_positions = [
    for i in range(var.height) : {
      x = var.x
      y = var.y + i
    }
  ]
}

# Burner mining drills in a vertical column
resource "factorio_entity" "mining_drill_west" {
  for_each = { for idx, pos in local.drill_positions : idx => pos }

  surface = var.surface
  name    = "burner-mining-drill"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = "east"
  force     = var.force

  # Pre-fill with coal for fuel
  contents {
    kind = "coal"
    qty  = 50
  }
}

# Burner mining drills in a vertical column
resource "factorio_entity" "mining_drill_east" {
  for_each = { for idx, pos in local.drill_positions : idx => pos }

  surface = var.surface
  name    = "burner-mining-drill"
  position {
    x = each.value.x + 3
    y = each.value.y
  }
  direction = "west"
  force     = var.force

  # Pre-fill with coal for fuel
  contents {
    kind = "coal"
    qty  = 50
  }
}

# Advanced belts running between the two columns of mining drills
resource "factorio_entity" "belt" {
  for_each = { for i in range(local.belt_length + var.height) : i => i }
  surface  = var.surface
  name     = "express-transport-belt"
  position {
    x = var.x + 1
    y = var.y + each.value - local.belt_length
  }
  direction = var.direction
  force     = var.force
}

# Inserter to move coal from belt to chest
resource "factorio_entity" "output_inserter" {
  surface = var.surface
  name    = "burner-inserter" # Coal-powered inserter
  position {
    x = local.chest_location.x
    y = local.chest_location.y + 1
  }
  direction = "south"
  force     = var.force

  # Pre-fill inserter with coal for fuel
  contents {
    kind = "coal"
    qty  = 20
  }
}

