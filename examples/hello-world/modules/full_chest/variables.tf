variable "kind" {
  type        = string
  description = "The item type to fill the chest with (e.g., 'coal', 'iron-ore', 'iron-plate')"
}

variable "x" {
  type        = number
  description = "X coordinate for the chest position"
}

variable "y" {
  type        = number
  description = "Y coordinate for the chest position"
}

variable "surface" {
  type        = string
  default     = "nauvis"
  description = "The surface on which to place the chest"
}

variable "force" {
  type        = string
  default     = "player"
  description = "The force to assign to the chest"
}

variable "qty" {
  type        = number
  default     = 2400
  description = "Quantity of items to place in the chest (default 2400 = full steel chest stack)"
}
