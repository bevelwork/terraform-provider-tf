# one lane assembler

variable "x" {
  type = number
}
variable "y" {
  type = number
}
variable "kind" {
  type = string
}
variable "qty" {
  type = number
}

locals {
  assember_offsets = [
    { x = var.x + 3, y = var.y - 1 },
  ]
  assember_positions = merge([
    for i in range(0, var.qty) : { for j, val in local.assember_offsets : "${i}_${j}" =>
      {
        x = val.x
        y = val.y - i * 3,
      }
  }]...)
}

resource "factorio_entity" "assembler" {
  for_each = local.assember_positions
  name     = "assembling-machine-1"
  position {
    x = each.value.x
    y = each.value.y
  }
  contents {
    kind = var.kind
    qty  = 1
  }
}

resource "factorio_entity" "left_belt" {
  count = 3 * var.qty + 1
  name  = "express-transport-belt"
  position {
    x = var.x
    y = var.y - count.index
  }
  direction = "north"
}


resource "factorio_entity" "right_belt" {
  count = 3 * var.qty
  name  = "express-transport-belt"
  position {
    x = var.x + 6
    y = var.y - count.index - 1
  }
  direction = "north"
}

locals {
  inserter_offsets = [
    { x = var.x + 1, y = var.y - 1 },
    { x = var.x + 5, y = var.y - 1 },
    { x = var.x + 1, y = var.y - 2 },
    { x = var.x + 5, y = var.y - 2 },
  ]
  inserter_positions = merge([
    for i in range(0, var.qty) : { for j, val in local.inserter_offsets : "${i}_${j}" =>
      {
        x = val.x
        y = val.y - i * 3,
      }
  }]...)
}

resource "factorio_entity" "inserters" {
  for_each = local.inserter_positions
  name     = "fast-inserter"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = "west"
}
locals {
  electric_pole_offsets = [
    { x = var.x + 1, y = var.y },
  ]
  electric_pole_positions = merge([
    for i in range(0, var.qty) : { for j, val in local.electric_pole_offsets : "${i}_${j}" =>
      {
        x = val.x
        y = val.y - i * 3,
      }
  }]...)
}

resource "factorio_entity" "electric_pole" {
  for_each = { for i, val in local.electric_pole_positions : i => val }
  name     = "small-electric-pole"
  position {
    x = each.value.x
    y = each.value.y
  }
}

