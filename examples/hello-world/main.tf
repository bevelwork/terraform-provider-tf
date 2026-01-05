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
resource "factorio_entity" "a-furnace" {
  surface = "nauvis"
  name    = "stone-furnace"
  position {
    x = 1
    y = 2
  }
  direction = "north"
  force     = "player"
}

# Creating a ghost, requires entity_specific_parameters
resource "factorio_entity" "a-ghost-furnace" {
  surface = "nauvis"
  name    = "entity-ghost"
  position {
    x = 3
    y = 2
  }
  direction = "north"
  force     = "player"
  entity_specific_parameters = {
    inner_name = "stone-furnace"
    expires    = false
  }
}

// Example of using a Factorio infrastructure module (inlined)
locals {
  // Offsets place the text with the center
  offset_x = -23
  offset_y = -10
  text = [
    [
      "X  X  XXX  X    X     XX ",
      "X  X  X    X    X    X  X",
      "XXXX  XXX  X    X    X  X",
      "X  X  X    X    X    X  X",
      "X  X  XXX  XXX  XXX   XX ",
    ],
    [
      "XXX  XXX    XX   X   X",
      "X    X  X  X  X  XX XX",
      "XXX  XXX   X  X  X X X",
      "X    X X   X  X  X   X",
      "X    X  X   XX   X   X",
    ],
    [
      "XXX  XXX  XXX   XXX    XX   XXX   XX   XXX   X   X",
      " X   X    X  X  X  X  X  X  X    X  X  X  X  XX XX",
      " X   XXX  XXX   XXX   XXXX  XXX  X  X  XXX   X X X",
      " X   X    X X   X X   X  X  X    X  X  X X   X   X",
      " X   XXX  X  X  X  X  X  X  X     XX   X  X  X   X",
    ],
  ]

  flat_text = flatten([
    for text_line in local.text :
    # Add 3 empty lines between each text line
    concat(text_line, ["", "", ""])
  ])

  pixels = flatten([
    for pixel_line_index, pixel_line in local.flat_text : [
      for pixel_index, pixel in regexall(".", pixel_line) :
      {
        x = pixel_index
        y = pixel_line_index
      } if pixel == "X"
    ]
  ])

  belt_map = { for pixel in local.pixels :
    "_${pixel.x}_${pixel.y}" => pixel
  }
}

resource "factorio_entity" "hello_belt" {
  for_each = merge([
    for player_index, player in data.factorio_players.all.players : {
      for belt_key, belt_value in local.belt_map :
      "${player_index}_${belt_key}" => {
        x = belt_value.x + local.offset_x + player.position.0.x
        y = belt_value.y + local.offset_y + player.position.0.y
      }
    }
  ]...)
  surface = "nauvis"
  name    = "transport-belt"
  position {
    x = each.value.x
    y = each.value.y
  }
  direction = "east"
  force     = "player"
}

