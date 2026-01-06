terraform {
  required_providers {
    factorio = {
      version = "~> 0.1"
      source  = "efokschaner/factorio"
    }
  }
}

provider "factorio" {
  rcon_host = "127.0.0.1:27015"
  rcon_pw   = "SOMEPASSWORD"
}

# Example of state fetching
data "factorio_players" "all" {}

# Example of resource creating
# resource "factorio_entity" "a-furnace" {
#   surface = "nauvis"
#   name    = "stone-furnace"
#   position {
#     x = 1
#     y = 2
#   }
#   direction = "north"
#   force     = "player"
# }
# 
# # Creating a ghost, requires entity_specific_parameters
# resource "factorio_entity" "a-ghost-furnace" {
#   surface = "nauvis"
#   name    = "entity-ghost"
#   position {
#     x = 3
#     y = 2
#   }
#   direction = "north"
#   force     = "player"
#   entity_specific_parameters = {
#     inner_name = "stone-furnace"
#     expires    = false
#   }
# }
# 
# # Example of creating an entity with contents (burner mining drill with wood fuel)
# resource "factorio_entity" "burner_mining_drill" {
#   surface = "nauvis"
#   name    = "burner-mining-drill"
#   position {
#     x = 5
#     y = 2
#   }
#   direction = "north"
#   force     = "player"
# 
#   contents {
#     kind = "wood"
#     qty  = 50
#   }
# }
# 
# # Example of a steel chest with various raw resources and items
# resource "factorio_entity" "steel_chest" {
#   surface = "nauvis"
#   name    = "steel-chest"
#   position {
#     x = 7
#     y = 2
#   }
#   direction = "north"
#   force     = "player"
# 
#   contents {
#     kind = "coal"
#     qty  = 50
#   }
#   contents {
#     kind = "stone"
#     qty  = 50
#   }
#   contents {
#     kind = "iron-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "copper-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "uranium-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "iron-gear-wheel"
#     qty  = 200
#   }
#   contents {
#     kind = "iron-plate"
#     qty  = 100
#   }
#   contents {
#     kind = "copper-plate"
#     qty  = 100
#   }
# }
# 
# Example of using the coal extractor farm module
module "coal_extractor_farm" {
  source = "./modules/coal_extractor_farm"

  direction = "north"
  x         = 20
  y         = 0
  height    = 5  # 5 mining drills in a column
  width     = 10 # 10 belt segments extending from each drill
}
# 
# // Example of using a Factorio infrastructure module (inlined)
# locals {
#   // Offsets place the text with the center
#   offset_x = -23
#   offset_y = -10
#   text = [
#     [
#       "X  X  XXX  X    X     XX ",
#       "X  X  X    X    X    X  X",
#       "XXXX  XXX  X    X    X  X",
#       "X  X  X    X    X    X  X",
#       "X  X  XXX  XXX  XXX   XX ",
#     ],
#     [
#       "XXX  XXX    XX   X   X",
#       "X    X  X  X  X  XX XX",
#       "XXX  XXX   X  X  X X X",
#       "X    X X   X  X  X   X",
#       "X    X  X   XX   X   X",
#     ],
#     [
#       "XXX  XXX  XXX   XXX    XX   XXX   XX   XXX   X   X",
#       " X   X    X  X  X  X  X  X  X    X  X  X  X  XX XX",
#       " X   XXX  XXX   XXX   XXXX  XXX  X  X  XXX   X X X",
#       " X   X    X X   X X   X  X  X    X  X  X X   X   X",
#       " X   XXX  X  X  X  X  X  X  X     XX   X  X  X   X",
#     ],
#   ]
# 
#   flat_text = flatten([
#     for text_line in local.text :
#     # Add 3 empty lines between each text line
#     concat(text_line, ["", "", ""])
#   ])
# 
#   pixels = flatten([
#     for pixel_line_index, pixel_line in local.flat_text : [
#       for pixel_index, pixel in regexall(".", pixel_line) :
#       {
#         x = pixel_index
#         y = pixel_line_index
#       } if pixel == "X"
#     ]
#   ])
# 
#   belt_map = { for pixel in local.pixels :
#     "_${pixel.x}_${pixel.y}" => pixel
#   }
# }
# 
# resource "factorio_entity" "hello_belt" {
#   for_each = merge([
#     for player_index, player in data.factorio_players.all.players : {
#       for belt_key, belt_value in local.belt_map :
#       "${player_index}_${belt_key}" => {
#         x = belt_value.x + local.offset_x + player.position[0].x
#         y = belt_value.y + local.offset_y + player.position[0].y
#       }
#     }
#   ]...)
#   surface = "nauvis"
#   name    = "transport-belt"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   direction = "east"
#   force     = "player"
# }
# 
# # 5 steel chests to the east of the hello world text
# resource "factorio_entity" "steel_chests" {
#   for_each = merge([
#     for player_index, player in data.factorio_players.all.players : {
#       for i in range(5) : "${player_index}_${i}" => {
#         x = 10 + player.position[0].x          # 10 tiles to the east of text center (text width ~25, offset -23, so center is around 0)
#         y = (i * 2) - 4 + player.position[0].y # Spaced 2 tiles apart vertically, centered around y=0
#       }
#     }
#   ]...)
#   surface = "nauvis"
#   name    = "steel-chest"
#   position {
#     x = each.value.x
#     y = each.value.y
#   }
#   direction = "north"
#   force     = "player"
# 
#   contents {
#     kind = "coal"
#     qty  = 50
#   }
#   contents {
#     kind = "stone"
#     qty  = 50
#   }
#   contents {
#     kind = "iron-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "copper-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "uranium-ore"
#     qty  = 50
#   }
#   contents {
#     kind = "iron-gear-wheel"
#     qty  = 200
#   }
#   contents {
#     kind = "iron-plate"
#     qty  = 100
#   }
#   contents {
#     kind = "copper-plate"
#     qty  = 100
#   }
# }
