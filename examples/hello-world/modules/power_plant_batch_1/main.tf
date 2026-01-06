# Auto-generated from powerplant.json blueprint
# Entities grouped by type for easier management

locals {
  boiler_entities = [
    { x = -1.5, y = 3 },
    { x = -1.5, y = 8, direction = "north" },
    { x = -10.5, y = 3 },
    { x = -10.5, y = 8, direction = "north" },
    { x = -13.5, y = 3 },
    { x = -13.5, y = 8, direction = "north" },
    { x = -16.5, y = 3 },
    { x = -16.5, y = 8, direction = "north" },
    { x = -19.5, y = 3 },
    { x = -19.5, y = 8, direction = "north" },
    { x = -22.5, y = 3 },
    { x = -22.5, y = 8, direction = "north" },
    { x = -25.5, y = 3 },
    { x = -25.5, y = 8, direction = "north" },
    { x = -4.5, y = 3 },
    { x = -4.5, y = 8, direction = "north" },
    { x = -7.5, y = 3 },
    { x = -7.5, y = 8, direction = "north" },
    { x = 1.5, y = 3 },
    { x = 1.5, y = 8, direction = "north" },
    { x = 10.5, y = 3 },
    { x = 10.5, y = 8, direction = "north" },
    { x = 13.5, y = 3 },
    { x = 13.5, y = 8, direction = "north" },
    { x = 16.5, y = 3 },
    { x = 16.5, y = 8, direction = "north" },
    { x = 19.5, y = 3 },
    { x = 19.5, y = 8, direction = "north" },
    { x = 22.5, y = 3 },
    { x = 22.5, y = 8, direction = "north" },
    { x = 25.5, y = 3 },
    { x = 25.5, y = 8, direction = "north" },
    { x = 28.5, y = 3 },
    { x = 28.5, y = 8, direction = "north" },
    { x = 31.5, y = 3 },
    { x = 31.5, y = 8, direction = "north" },
    { x = 34.5, y = 3 },
    { x = 34.5, y = 8, direction = "north" },
    { x = 37.5, y = 3 },
    { x = 37.5, y = 8, direction = "north" },
    { x = 4.5, y = 3 },
    { x = 4.5, y = 8, direction = "north" },
    { x = 40.5, y = 3 },
    { x = 40.5, y = 8, direction = "north" },
    { x = 7.5, y = 3 },
    { x = 7.5, y = 8, direction = "north" },
  ]

  burner_inserter_entities = [
    { x = -1.5, y = 4.5, direction = "north" },
    { x = -1.5, y = 6.5, direction = "south" },
    { x = -10.5, y = 4.5, direction = "north" },
    { x = -10.5, y = 6.5, direction = "south" },
    { x = -13.5, y = 4.5, direction = "north" },
    { x = -13.5, y = 6.5, direction = "south" },
    { x = -16.5, y = 4.5, direction = "north" },
    { x = -16.5, y = 6.5, direction = "south" },
    { x = -19.5, y = 4.5, direction = "north" },
    { x = -19.5, y = 6.5, direction = "south" },
    { x = -22.5, y = 4.5, direction = "north" },
    { x = -22.5, y = 6.5, direction = "south" },
    { x = -25.5, y = 4.5, direction = "north" },
    { x = -25.5, y = 6.5, direction = "south" },
    { x = -4.5, y = 4.5, direction = "north" },
    { x = -4.5, y = 6.5, direction = "south" },
    { x = -7.5, y = 4.5, direction = "north" },
    { x = -7.5, y = 6.5, direction = "south" },
    { x = 1.5, y = 4.5, direction = "north" },
    { x = 1.5, y = 6.5, direction = "south" },
    { x = 10.5, y = 4.5, direction = "north" },
    { x = 10.5, y = 6.5, direction = "south" },
    { x = 13.5, y = 4.5, direction = "north" },
    { x = 13.5, y = 6.5, direction = "south" },
    { x = 16.5, y = 4.5, direction = "north" },
    { x = 16.5, y = 6.5, direction = "south" },
    { x = 19.5, y = 4.5, direction = "north" },
    { x = 19.5, y = 6.5, direction = "south" },
    { x = 22.5, y = 4.5, direction = "north" },
    { x = 22.5, y = 6.5, direction = "south" },
    { x = 25.5, y = 4.5, direction = "north" },
    { x = 25.5, y = 6.5, direction = "south" },
    { x = 28.5, y = 4.5, direction = "north" },
    { x = 28.5, y = 6.5, direction = "south" },
    { x = 31.5, y = 4.5, direction = "north" },
    { x = 31.5, y = 6.5, direction = "south" },
    { x = 34.5, y = 4.5, direction = "north" },
    { x = 34.5, y = 6.5, direction = "south" },
    { x = 37.5, y = 4.5, direction = "north" },
    { x = 37.5, y = 6.5, direction = "south" },
    { x = 4.5, y = 4.5, direction = "north" },
    { x = 4.5, y = 6.5, direction = "south" },
    { x = 40.5, y = 4.5, direction = "north" },
    { x = 40.5, y = 6.5, direction = "south" },
    { x = 7.5, y = 4.5, direction = "north" },
    { x = 7.5, y = 6.5, direction = "south" },
  ]

  medium_electric_pole_entities = [
    { x = -13.5, y = -5.5 },
    { x = -16.5, y = 16.5 },
    { x = -22.5, y = -5.5 },
    { x = -23.5, y = 16.5 },
    { x = -4.5, y = -5.5 },
    { x = -7.5, y = 16.5 },
    { x = 1.5, y = 16.5 },
    { x = 10.5, y = 16.5 },
    { x = 13.5, y = -5.5 },
    { x = 19.5, y = 16.5 },
    { x = 22.5, y = -5.5 },
    { x = 28.5, y = 16.5 },
    { x = 31.5, y = -5.5 },
    { x = 37.5, y = -5.5 },
    { x = 37.5, y = 16.5 },
    { x = 4.5, y = -5.5 },
    { x = 42.5, y = 13.5 },
    { x = 42.5, y = 20.5 },
  ]

  offshore_pump_entities = [
    { x = 45.5, y = 3.5, direction = "east" },
  ]

  pipe_entities = [
    { x = -22.5, y = -7.5 },
    { x = -22.5, y = -6.5 },
    { x = -23.5, y = -6.5 },
    { x = -14.5, y = -6.5 },
    { x = -13.5, y = -6.5 },
    { x = -13.5, y = -7.5 },
    { x = -5.5, y = -6.5 },
    { x = -4.5, y = -6.5 },
    { x = -4.5, y = -7.5 },
    { x = 3.5, y = -6.5 },
    { x = 4.5, y = -6.5 },
    { x = 4.5, y = -7.5 },
    { x = 12.5, y = -6.5 },
    { x = 13.5, y = -6.5 },
    { x = 13.5, y = -7.5 },
    { x = 21.5, y = -6.5 },
    { x = 22.5, y = -6.5 },
    { x = 22.5, y = -7.5 },
    { x = 30.5, y = -6.5 },
    { x = 31.5, y = -6.5 },
    { x = 31.5, y = -7.5 },
    { x = 36.5, y = -6.5 },
    { x = 37.5, y = -6.5 },
    { x = 37.5, y = -7.5 },
    { x = -23.5, y = -5.5 },
    { x = -23.5, y = -4.5 },
    { x = -22.5, y = -4.5 },
    { x = -14.5, y = -4.5 },
    { x = -14.5, y = -5.5 },
    { x = -13.5, y = -4.5 },
    { x = -4.5, y = -4.5 },
    { x = -5.5, y = -4.5 },
    { x = -5.5, y = -5.5 },
    { x = 3.5, y = -4.5 },
    { x = 3.5, y = -5.5 },
    { x = 4.5, y = -4.5 },
    { x = 13.5, y = -4.5 },
    { x = 12.5, y = -4.5 },
    { x = 12.5, y = -5.5 },
    { x = 21.5, y = -4.5 },
    { x = 21.5, y = -5.5 },
    { x = 22.5, y = -4.5 },
    { x = 31.5, y = -4.5 },
    { x = 30.5, y = -4.5 },
    { x = 30.5, y = -5.5 },
    { x = 37.5, y = -4.5 },
    { x = 36.5, y = -4.5 },
    { x = 36.5, y = -5.5 },
    { x = -22.5, y = -3.5 },
    { x = -13.5, y = -3.5 },
    { x = -4.5, y = -3.5 },
    { x = 4.5, y = -3.5 },
    { x = 13.5, y = -3.5 },
    { x = 22.5, y = -3.5 },
    { x = 31.5, y = -3.5 },
    { x = 37.5, y = -3.5 },
    { x = 43.5, y = 3.5 },
    { x = 42.5, y = 3.5 },
    { x = 44.5, y = 3.5 },
    { x = 42.5, y = 7.5 },
    { x = -22.5, y = 14.5 },
    { x = -22.5, y = 15.5 },
    { x = -21.5, y = 15.5 },
    { x = -16.5, y = 14.5 },
    { x = -16.5, y = 15.5 },
    { x = -15.5, y = 15.5 },
    { x = -7.5, y = 14.5 },
    { x = -7.5, y = 15.5 },
    { x = -6.5, y = 15.5 },
    { x = 1.5, y = 14.5 },
    { x = 1.5, y = 15.5 },
    { x = 2.5, y = 15.5 },
    { x = 10.5, y = 14.5 },
    { x = 10.5, y = 15.5 },
    { x = 11.5, y = 15.5 },
    { x = 19.5, y = 14.5 },
    { x = 19.5, y = 15.5 },
    { x = 20.5, y = 15.5 },
    { x = 28.5, y = 14.5 },
    { x = 28.5, y = 15.5 },
    { x = 29.5, y = 15.5 },
    { x = 37.5, y = 14.5 },
    { x = 37.5, y = 15.5 },
    { x = 38.5, y = 15.5 },
    { x = -22.5, y = 17.5 },
    { x = -21.5, y = 16.5 },
    { x = -21.5, y = 17.5 },
    { x = -16.5, y = 17.5 },
    { x = -15.5, y = 16.5 },
    { x = -15.5, y = 17.5 },
    { x = -6.5, y = 16.5 },
    { x = -7.5, y = 17.5 },
    { x = -6.5, y = 17.5 },
    { x = 1.5, y = 17.5 },
    { x = 2.5, y = 16.5 },
    { x = 2.5, y = 17.5 },
    { x = 11.5, y = 16.5 },
    { x = 10.5, y = 17.5 },
    { x = 11.5, y = 17.5 },
    { x = 19.5, y = 17.5 },
    { x = 20.5, y = 16.5 },
    { x = 20.5, y = 17.5 },
    { x = 29.5, y = 16.5 },
    { x = 28.5, y = 17.5 },
    { x = 29.5, y = 17.5 },
    { x = 37.5, y = 17.5 },
    { x = 38.5, y = 16.5 },
    { x = 38.5, y = 17.5 },
    { x = -22.5, y = 18.5 },
    { x = -16.5, y = 18.5 },
    { x = -7.5, y = 18.5 },
    { x = 1.5, y = 18.5 },
    { x = 10.5, y = 18.5 },
    { x = 19.5, y = 18.5 },
    { x = 28.5, y = 18.5 },
    { x = 37.5, y = 18.5 },
  ]

  pipe_to_ground_entities = [
    { x = 42.5, y = 4.5 },
    { x = 42.5, y = 6.5, direction = "north" },
  ]

  steam_engine_entities = [
    { x = -25.5, y = -10.5 },
    { x = -22.5, y = -10.5 },
    { x = -19.5, y = -10.5 },
    { x = -16.5, y = -10.5 },
    { x = -13.5, y = -10.5 },
    { x = -10.5, y = -10.5 },
    { x = -7.5, y = -10.5 },
    { x = -4.5, y = -10.5 },
    { x = -1.5, y = -10.5 },
    { x = 1.5, y = -10.5 },
    { x = 4.5, y = -10.5 },
    { x = 7.5, y = -10.5 },
    { x = 10.5, y = -10.5 },
    { x = 13.5, y = -10.5 },
    { x = 16.5, y = -10.5 },
    { x = 19.5, y = -10.5 },
    { x = 22.5, y = -10.5 },
    { x = 25.5, y = -10.5 },
    { x = 28.5, y = -10.5 },
    { x = 31.5, y = -10.5 },
    { x = 34.5, y = -10.5 },
    { x = 37.5, y = -10.5 },
    { x = 40.5, y = -10.5 },
    { x = -25.5, y = -5.5 },
    { x = -19.5, y = -5.5 },
    { x = -16.5, y = -5.5 },
    { x = -10.5, y = -5.5 },
    { x = -7.5, y = -5.5 },
    { x = -1.5, y = -5.5 },
    { x = 1.5, y = -5.5 },
    { x = 7.5, y = -5.5 },
    { x = 10.5, y = -5.5 },
    { x = 16.5, y = -5.5 },
    { x = 19.5, y = -5.5 },
    { x = 25.5, y = -5.5 },
    { x = 28.5, y = -5.5 },
    { x = 34.5, y = -5.5 },
    { x = 40.5, y = -5.5 },
    { x = -25.5, y = -0.5 },
    { x = -22.5, y = -0.5 },
    { x = -19.5, y = -0.5 },
    { x = -16.5, y = -0.5 },
    { x = -13.5, y = -0.5 },
    { x = -10.5, y = -0.5 },
    { x = -7.5, y = -0.5 },
    { x = -4.5, y = -0.5 },
    { x = -1.5, y = -0.5 },
    { x = 1.5, y = -0.5 },
    { x = 4.5, y = -0.5 },
    { x = 7.5, y = -0.5 },
    { x = 10.5, y = -0.5 },
    { x = 13.5, y = -0.5 },
    { x = 16.5, y = -0.5 },
    { x = 19.5, y = -0.5 },
    { x = 22.5, y = -0.5 },
    { x = 25.5, y = -0.5 },
    { x = 28.5, y = -0.5 },
    { x = 31.5, y = -0.5 },
    { x = 34.5, y = -0.5 },
    { x = 37.5, y = -0.5 },
    { x = 40.5, y = -0.5 },
    { x = -25.5, y = 11.5 },
    { x = -22.5, y = 11.5 },
    { x = -19.5, y = 11.5 },
    { x = -16.5, y = 11.5 },
    { x = -13.5, y = 11.5 },
    { x = -10.5, y = 11.5 },
    { x = -7.5, y = 11.5 },
    { x = -4.5, y = 11.5 },
    { x = -1.5, y = 11.5 },
    { x = 1.5, y = 11.5 },
    { x = 4.5, y = 11.5 },
    { x = 7.5, y = 11.5 },
    { x = 10.5, y = 11.5 },
    { x = 13.5, y = 11.5 },
    { x = 16.5, y = 11.5 },
    { x = 19.5, y = 11.5 },
    { x = 22.5, y = 11.5 },
    { x = 25.5, y = 11.5 },
    { x = 28.5, y = 11.5 },
    { x = 31.5, y = 11.5 },
    { x = 34.5, y = 11.5 },
    { x = 37.5, y = 11.5 },
    { x = 40.5, y = 11.5 },
    { x = -25.5, y = 16.5 },
    { x = -19.5, y = 16.5 },
    { x = -13.5, y = 16.5 },
    { x = -10.5, y = 16.5 },
    { x = -4.5, y = 16.5 },
    { x = -1.5, y = 16.5 },
    { x = 4.5, y = 16.5 },
    { x = 7.5, y = 16.5 },
    { x = 13.5, y = 16.5 },
    { x = 16.5, y = 16.5 },
    { x = 22.5, y = 16.5 },
    { x = 25.5, y = 16.5 },
    { x = 31.5, y = 16.5 },
    { x = 34.5, y = 16.5 },
    { x = 40.5, y = 16.5 },
    { x = -25.5, y = 21.5 },
    { x = -22.5, y = 21.5 },
    { x = -19.5, y = 21.5 },
    { x = -16.5, y = 21.5 },
    { x = -13.5, y = 21.5 },
    { x = -10.5, y = 21.5 },
    { x = -7.5, y = 21.5 },
    { x = -4.5, y = 21.5 },
    { x = -1.5, y = 21.5 },
    { x = 1.5, y = 21.5 },
    { x = 4.5, y = 21.5 },
    { x = 7.5, y = 21.5 },
    { x = 10.5, y = 21.5 },
    { x = 13.5, y = 21.5 },
    { x = 16.5, y = 21.5 },
    { x = 19.5, y = 21.5 },
    { x = 22.5, y = 21.5 },
    { x = 25.5, y = 21.5 },
    { x = 28.5, y = 21.5 },
    { x = 31.5, y = 21.5 },
    { x = 34.5, y = 21.5 },
    { x = 37.5, y = 21.5 },
    { x = 40.5, y = 21.5 },
  ]

  transport_belt_entities = [
    { x = -24.5, y = 5.5 },
    { x = -25.5, y = 5.5 },
    { x = -22.5, y = 5.5 },
    { x = -23.5, y = 5.5 },
    { x = -20.5, y = 5.5 },
    { x = -21.5, y = 5.5 },
    { x = -18.5, y = 5.5 },
    { x = -19.5, y = 5.5 },
    { x = -16.5, y = 5.5 },
    { x = -17.5, y = 5.5 },
    { x = -14.5, y = 5.5 },
    { x = -15.5, y = 5.5 },
    { x = -12.5, y = 5.5 },
    { x = -13.5, y = 5.5 },
    { x = -10.5, y = 5.5 },
    { x = -11.5, y = 5.5 },
    { x = -8.5, y = 5.5 },
    { x = -9.5, y = 5.5 },
    { x = -6.5, y = 5.5 },
    { x = -7.5, y = 5.5 },
    { x = -4.5, y = 5.5 },
    { x = -5.5, y = 5.5 },
    { x = -2.5, y = 5.5 },
    { x = -3.5, y = 5.5 },
    { x = -0.5, y = 5.5 },
    { x = -1.5, y = 5.5 },
    { x = 1.5, y = 5.5 },
    { x = 0.5, y = 5.5 },
    { x = 3.5, y = 5.5 },
    { x = 2.5, y = 5.5 },
    { x = 5.5, y = 5.5 },
    { x = 4.5, y = 5.5 },
    { x = 7.5, y = 5.5 },
    { x = 6.5, y = 5.5 },
    { x = 9.5, y = 5.5 },
    { x = 8.5, y = 5.5 },
    { x = 11.5, y = 5.5 },
    { x = 10.5, y = 5.5 },
    { x = 13.5, y = 5.5 },
    { x = 12.5, y = 5.5 },
    { x = 15.5, y = 5.5 },
    { x = 14.5, y = 5.5 },
    { x = 17.5, y = 5.5 },
    { x = 16.5, y = 5.5 },
    { x = 19.5, y = 5.5 },
    { x = 18.5, y = 5.5 },
    { x = 21.5, y = 5.5 },
    { x = 20.5, y = 5.5 },
    { x = 23.5, y = 5.5 },
    { x = 22.5, y = 5.5 },
    { x = 25.5, y = 5.5 },
    { x = 24.5, y = 5.5 },
    { x = 27.5, y = 5.5 },
    { x = 26.5, y = 5.5 },
    { x = 29.5, y = 5.5 },
    { x = 28.5, y = 5.5 },
    { x = 31.5, y = 5.5 },
    { x = 30.5, y = 5.5 },
    { x = 33.5, y = 5.5 },
    { x = 32.5, y = 5.5 },
    { x = 35.5, y = 5.5 },
    { x = 34.5, y = 5.5 },
    { x = 37.5, y = 5.5 },
    { x = 36.5, y = 5.5 },
    { x = 39.5, y = 5.5 },
    { x = 38.5, y = 5.5 },
    { x = 41.5, y = 5.5 },
    { x = 40.5, y = 5.5 },
  ]

}

resource "factorio_entity" "boiler" {
  for_each = { for v in local.boiler_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "boiler"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
  lifecycle {
    ignore_changes = [
      position,
    ]
  }
}

resource "factorio_entity" "burner_inserter" {
  for_each = { for v in local.burner_inserter_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "burner-inserter"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
}

resource "factorio_entity" "medium_electric_pole" {
  for_each = { for v in local.medium_electric_pole_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "medium-electric-pole"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
}

resource "factorio_entity" "offshore_pump" {
  for_each = { for v in local.offshore_pump_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "offshore-pump"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
}

resource "factorio_entity" "pipe" {
  for_each = { for v in local.pipe_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "pipe"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
}

resource "factorio_entity" "pipe_to_ground" {
  for_each = { for v in local.pipe_to_ground_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "pipe-to-ground"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
}

resource "factorio_entity" "steam_engine" {
  for_each = { for v in local.steam_engine_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "steam-engine"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = try(each.value.direction, null)
  force     = var.force
  lifecycle {
    ignore_changes = [
      contents,
    ]
  }
}

resource "factorio_entity" "transport_belt" {
  for_each = { for v in local.transport_belt_entities : "${v.x}_${v.y}" => v }
  surface  = var.surface
  name     = "express-transport-belt"
  position {
    x = var.base_x + each.value.x
    y = var.base_y + each.value.y
  }
  direction = var.belt_direction
  force     = var.force
}

