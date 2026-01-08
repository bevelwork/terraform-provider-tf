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
  drill_positions = [
    for i in range(var.height / 2) : {
      x = var.x
      y = var.y + i * 2
    }
  ]
}

# Burner mining drills in a vertical column
resource "factorio_entity" "mining_drill_west" {
  for_each = { for idx, pos in local.drill_positions : idx => pos }

  name = "burner-mining-drill"
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

  name = "burner-mining-drill"
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
resource "factorio_entity" "belt_for_drills" {
  count = var.height + local.belt_length
  name  = "express-transport-belt"
  position {
    x = var.x + 1
    y = var.y + count.index - 1 + 0.5 - local.belt_length
  }
  direction = var.direction
  force     = var.force
}

# Inserter to move coal from belt to chest
resource "factorio_entity" "output_inserter" {
  name = "burner-inserter" # Coal-powered inserter
  position {
    x = var.x + 1
    y = var.y + 0.5 - local.belt_length - 2
  }
  direction = "south"
  force     = var.force

  # Pre-fill inserter with coal for fuel
  contents {
    kind = "coal"
    qty  = 20
  }
}

resource "factorio_entity" "output_chest" {
  name = "steel-chest"
  position {
    x = var.x + 1
    y = var.y + 0.5 - local.belt_length - 3
  }
  direction = "south"
  force     = var.force
}

