data "factorio_players" "all" {}

# Power generation
# Note x,y should be the last land square
# resource "factorio_entity" "pump" {
#   name      = "offshore-pump"
#   direction = "north"
#   position {
#     x = -7
#     y = -50
#   }
# }
# 
# resource "factorio_entity" "pump_pipes" {
#   count     = 24
#   name      = "pipe"
#   direction = "north"
#   position {
#     x = -7
#     y = -49 + count.index
#   }
# }
# 
# locals {
#   boiler_offsets = [
#     { x = 2, y = 0, direction = "south" },
#     { x = 2, y = 3, direction = "north" },
#     { x = 2, y = 6, direction = "south" },
#     { x = 2, y = 9, direction = "north" },
#     { x = 2, y = 12, direction = "south" },
#     { x = 2, y = 15, direction = "north" },
#   ]
#   boiler_locs = [
#     for idx, offset in local.boiler_offsets : {
#       x         = -7 + offset.x
#       y         = -42 + offset.y
#       direction = offset.direction
#     }
#   ]
# }
# 
# resource "factorio_entity" "boiler" {
#   for_each  = { for idx, loc in local.boiler_locs : idx => loc }
#   name      = "boiler"
#   direction = each.value.direction
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   contents {
#     kind = "coal"
#     qty  = 20
#   }
# }
# resource "factorio_entity" "pipe_bus_bar" {
#   count = length(local.boiler_locs) * 3
#   name  = "pipe"
#   position {
#     x = -2
#     y = -42 + count.index
#   }
#   direction = "north"
# }
# 
# locals {
#   steam_base_locations = [
#     { x = -5, y = -40 },
#     { x = -5, y = -34 },
#     { x = -5, y = -28 },
#   ]
#   pipe_run = 3
#   computed_steam_locations = merge([
#     for idx, offset in local.steam_base_locations : {
#       for i in range(0, local.pipe_run) : "${idx}_${i}" => {
#         x = offset.x + i
#         y = offset.y
#       }
#     }
#   ]...)
# }
# 
# 
# 
# 
# resource "factorio_entity" "steam_to_bus" {
#   for_each = { for idx, val in local.computed_steam_locations : idx => val }
#   name     = "pipe"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   direction = "north"
# }
# 
# locals {
#   steam_offsets = [
#     { x = 6, y = 0, direction = "east" },
#     { x = 6, y = 2, direction = "east" },
#     { x = 6, y = 4, direction = "east" },
#     { x = 6, y = 6, direction = "east" },
#     { x = 6, y = 8, direction = "east" },
#     { x = 6, y = 10, direction = "east" },
#     { x = 6, y = 12, direction = "east" },
#     { x = 6, y = 14, direction = "east" },
#     { x = 6, y = 16, direction = "east" },
#   ]
#   steam_locs = [
#     for idx, offset in local.steam_offsets : {
#       x         = -5 + offset.x
#       y         = -42 + offset.y
#       direction = offset.direction
#     }
#   ]
# }
# 
# resource "factorio_entity" "steam_engines" {
#   for_each  = { for idx, loc in local.steam_locs : idx => loc }
#   name      = "steam-engine"
#   direction = each.value.direction
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
# }
# 
# locals {
#   powerline_space = 7
# }
# 
# resource "factorio_entity" "power_pole_south" {
#   count = 7
#   name  = "small-electric-pole"
#   position {
#     x = 5
#     y = -42 + count.index * local.powerline_space
#   }
# }
# 
# resource "factorio_entity" "power_pole_east" {
#   count = 12
#   name  = "small-electric-pole"
#   position {
#     x = 79 - count.index * local.powerline_space
#     y = 6
#   }
# }

locals {
  copper_output_locations = [
    # Go up
    { x = 33, y = 13, direction = "north" },
    { x = 33, y = 12, direction = "north" },
    { x = 44, y = 13, direction = "north" },
    { x = 44, y = 12, direction = "north" },

    # Middle up
    { x = 38, y = 12, direction = "north" },
    { x = 38, y = 11, direction = "north" },
    { x = 38, y = 10, direction = "north" },

    # go right
    { x = 33, y = 11, direction = "east" },
    { x = 34, y = 11, direction = "east" },
    { x = 35, y = 11, direction = "east" },
    { x = 36, y = 11, direction = "east" },
    { x = 37, y = 11, direction = "east" },

    # go left
    { x = 44, y = 11, direction = "west" },
    { x = 43, y = 11, direction = "west" },
    { x = 42, y = 11, direction = "west" },
    { x = 41, y = 11, direction = "west" },
    { x = 40, y = 11, direction = "west" },
    { x = 39, y = 11, direction = "west" },


  ]
}

resource "factorio_entity" "copper_output_merge" {
  for_each = { for idx, val in local.copper_output_locations : idx => val }
  name     = "express-transport-belt"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = each.value.direction
}


# resource "factorio_entity" "defense_turrets" {
#   for_each = merge([
#     for player_index, player in data.factorio_players.all.players : {
#       for direction, offset in {
#         "a" = { x = 0, y = 3 }
#         "b" = { x = 3, y = 3 }
#         "c" = { x = 3, y = 3 }
#         "d" = { x = 0, y = 0 }
#         } : "${player_index}_${direction}" => {
#         x = player.position[0].x + offset.x
#         y = player.position[0].y + offset.y
#       }
#     }
#   ]...)
# 
#   name = "gun-turret"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
# 
#   # Load with advanced ammo (piercing rounds)
#   contents {
#     kind = "piercing-rounds-magazine"
#     qty  = 200 # Full stack of advanced ammo
#   }
# }
# 

# module "iron_extractor_farm" {
#   source = "./modules/coal_extractor_farm"
#   for_each = { for idx, vals in [
#     { x = 55, y = 63 },
#     { x = 60, y = 63 },
#     { x = 66, y = 63 },
#     { x = 71, y = 63 },
#   ] : idx => vals }
#   x      = each.value.x
#   y      = each.value.y
#   height = 20
# }
# 
# module "iron_joiner" {
#   source = "./modules/joiner"
#   for_each = { for idx, vals in [
#     { x = 56, y = 49 },
#     { x = 67, y = 49 },
#   ] : idx => vals }
#   x = each.value.x
#   y = each.value.y
# }
# 
# module "iron_furnace" {
#   source = "./modules/furnace_stack"
#   for_each = { for idx, vals in [
#     { x = 58, y = 46 },
#     { x = 69, y = 46 },
#   ] : idx => vals }
#   x   = each.value.x
#   y   = each.value.y
#   qty = 5
# }

module "copper_extractor_farm" {
  source = "./modules/coal_extractor_farm"
  for_each = { for idx, vals in [
    { x = 35, y = 40 },
    { x = 40, y = 40 },
  ] : idx => vals }
  x      = each.value.x
  y      = each.value.y
  height = 20
}

module "copper_joiner" {
  source = "./modules/joiner"
  for_each = { for idx, vals in [
    { x = 36, y = 26 },
  ] : idx => vals }
  x = each.value.x
  y = each.value.y
}

module "copper_furnace" {
  source = "./modules/furnace_stack"
  for_each = { for idx, vals in [
    { x = 38, y = 23 },
  ] : idx => vals }
  x   = each.value.x
  y   = each.value.y
  qty = 5
}

module "one_lane_assembler" {
  source = "./modules/one_lane_assembler"
  for_each = { for idx, vals in [
    { x = 53, y = 36 },
    { x = 64, y = 36 },
    { x = 75, y = 36 },
  ] : idx => vals }
  x = each.value.x
  y = each.value.y

  kind = "iron-gear-wheel"
  qty  = 10
}

resource "factorio_entity" "cog_output_belt_west" {
  count = 48
  name  = "express-transport-belt"
  position {
    x = 82 - count.index
    y = 4
  }
  direction = "west"
}
resource "factorio_entity" "copper_underground_belt" {
  for_each = { for idx, val in [
    { x = 38, y = 9, direction = "north" },
    { x = 38, y = 3, direction = "south" },
  ] : idx => val }
  name = "express-underground-belt"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = each.value.direction
}

resource "factorio_entity" "copper_turnaround_belt" {
  for_each = { for idx, val in [
    { x = 38, y = 2, direction = "east" },
    { x = 39, y = 2, direction = "south" },
    { x = 39, y = 3, direction = "south" },
  ] : idx => val }
  name = "express-transport-belt"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = each.value.direction
}





# resource "factorio_entity" "assembler_3x3" {
#   for_each = { for i, val in [
#     { x = 55, y = 28 },
#   ] : i => val }
#   name = "assembling-machine-3"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   contents {
#     kind = "coal"
#     qty  = 20
#   }
# }
# resource "factorio_entity" "stone_furnace3x3" {
#   for_each = { for i, val in [
#     { x = -41.5, y = 30.5 },
#     { x = -39.5, y = 30.5 },
#     { x = -37.5, y = 30.5 },
# 
#     { x = -41.5, y = 32.5 },
#     { x = -39.5, y = 32.5 },
#     { x = -37.5, y = 32.5 },
# 
#     { x = -41.5, y = 34.5 },
#     { x = -39.5, y = 34.5 },
#     { x = -37.5, y = 34.5 },
#   ] : i => val }
#   name = "stone-furnace"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   contents {
#     kind = "coal"
#     qty  = 20
#   }
# }

# module "copper_extractor_farm" {
#   source = "./modules/coal_extractor_farm"
#   for_each = { for idx, vals in [
#     { x = -95, y = 25 },
#     { x = -90, y = 25 },
#     { x = -86, y = 25 },
#     { x = -82, y = 25 },
#     { x = -78, y = 25 },
#   ] : idx => vals }
#   x      = each.value.x
#   y      = each.value.y
#   height = 23
# }
# 
# module "coal_extractor_farm" {
#   source = "./modules/coal_extractor_farm"
#   for_each = { for idx, vals in [
#     { x = -4, y = 74 },
#     { x = 1, y = 74 },
#     { x = 6, y = 74 },
#     { x = 11, y = 74 },
#     { x = 16, y = 74 },
#     { x = 21, y = 74 },
#     { x = 26, y = 74 },
#   ] : idx => vals }
#   x      = each.value.x
#   y      = each.value.y
#   height = 23
# }
# 
# module "stone_extractor_farm" {
#   source = "./modules/coal_extractor_farm"
#   for_each = { for idx, vals in [
#     { x = -6, y = 31 },
#     { x = 1, y = 31 },
#     { x = 6, y = 31 },
#   ] : idx => vals }
#   x      = each.value.x
#   y      = each.value.y
#   height = 13
# }


## JOINER
# resource "factorio_entity" "feed_joiner" {
#   for_each = { for idx, vals in [
#     { x = -41, y = 34, direction = "east" },
#     { x = -40, y = 34, direction = "east" },
#     { x = -39, y = 34, direction = "north" },
#     { x = -38, y = 34, direction = "north" },
#     { x = -37, y = 34, direction = "west" },
#     { x = -36, y = 34, direction = "west" },
#     { x = -39, y = 33, direction = "north" },
#     { x = -38, y = 33, direction = "north" },
#     { x = -39, y = 32, direction = "north" },
#     { x = -38, y = 32, direction = "north" },
#   ] : idx => vals }
#   name      = "express-transport-belt"
#   direction = each.value.direction
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
# }


# module "full_chest" {
#   source = "./modules/full_chest"
#   x      = data.factorio_players.all.players[0].position[0].x
#   y      = data.factorio_players.all.players[0].position[0].y - 5
#   kind   = "grenade"
#   qty    = 200
# }

