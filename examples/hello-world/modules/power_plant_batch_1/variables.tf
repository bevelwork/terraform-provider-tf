variable "belt_direction" {
  type        = string
  default     = "east"
  description = "The direction of the belt"
  validation {
    condition     = contains(["east", "west", "north", "south"], var.belt_direction)
    error_message = "Belt direction must be one of: east, west, north, south."
  }
}

variable "surface" {
  type        = string
  default     = "nauvis"
  description = "The surface on which to place the entities"
}

variable "force" {
  type        = string
  default     = "player"
  description = "The force to assign to the entities"
}

variable "base_x" {
  type        = number
  default     = 0
  description = "Base X coordinate offset for the entities"
}

variable "base_y" {
  type        = number
  default     = 0
  description = "Base Y coordinate offset for the entities"
}
