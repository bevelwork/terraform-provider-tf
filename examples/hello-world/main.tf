data "factorio_players" "all" {}

resource "factorio_entity" "defense_turrets" {
  for_each = merge([
    for player_index, player in data.factorio_players.all.players : {
      for direction, offset in {
        #         "north" = { x = 0, y = -3 }
        # "south" = { x = 0, y = 3 }
        # "east"  = { x = 3, y = 0 }
        # "west"  = { x = -3, y = 0 }
        } : "${player_index}_${direction}" => {
        x = player.position[0].x + offset.x
        y = player.position[0].y + offset.y
      }
    }
  ]...)

  name = "gun-turret"
  position {
    x = each.value.x
    y = each.value.y
  }
  lifecycle {
    ignore_changes = [position]
  }

  # Load with advanced ammo (piercing rounds)
  contents {
    kind = "piercing-rounds-magazine"
    qty  = 200 # Full stack of advanced ammo
  }
}

module "iron_extractor_farm" {
  source = "./modules/coal_extractor_farm"
  for_each = { for idx, vals in [
    { x = -42, y = 48 },
    { x = -37, y = 48 },
    { x = -32, y = 48 },
  ] : idx => vals }
  x      = each.value.x
  y      = each.value.y
  height = 30
}

# resource "factorio_entity" "assembler_3x3" {
#   for_each = { for i, val in [
#     { x = -41.5, y = 30.5 },
#     { x = -38.5, y = 30.5 },
#     { x = -35.5, y = 30.5 },
# 
#     { x = -41.5, y = 33.5 },
#     { x = -38.5, y = 33.5 },
#     { x = -35.5, y = 33.5 },
# 
#     { x = -41.5, y = 36.5 },
#     { x = -38.5, y = 36.5 },
#     { x = -35.5, y = 36.5 },
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




# module "iron_furnace" {
#   source = "./modules/furnace_stack"
#   x      = -38.5
#   y      = 31.5
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

# module "joiner" {
#   source = "./modules/joiner"
#   x      = -41
#   y      = 34
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

