data "factorio_players" "all" {}

#  resource "factorio_entity" "defense_turrets" {
#   for_each = merge([
#     for player_index, player in data.factorio_players.all.players : {
#       for direction, offset in {
#         "north" = { x = 0, y = -3 }
#         "south" = { x = 0, y = 3 }
#         "east"  = { x = 3, y = 0 }
#         "west"  = { x = -3, y = 0 }
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

module "iron_extractor_farm" {
  for_each = { for idx, vals in [
    { x = -42, y = 48 },
  ] : idx => vals }
  source = "./modules/coal_extractor_farm"
  x      = each.value.x
  y      = each.value.y
  height = 30
  width  = 5
}

