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
  drill_positions = [
    for i in range(var.height) : {
      x = var.x
      y = var.y + i
    }
  ]
  # Generate positions for belts (horizontal column)
  belt_positions = [
    for i in range(var.height) : {
      x = var.x + i
      y = var.y
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

# Belts running between the two columns of mining drills
resource "factorio_entity" "belt" {
  for_each = { for i in range(10 + var.height) : i => i }
  surface  = var.surface
  name     = "transport-belt"
  position {
    x = var.x + 1
    y = var.y + each.value - 10
  }
  direction = var.direction
  force     = var.force
}

