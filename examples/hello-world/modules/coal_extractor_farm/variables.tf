variable "x" {
  type        = number
  description = "X coordinate of the top-left corner of the farm"
}

variable "y" {
  type        = number
  description = "Y coordinate of the top-left corner of the farm"
}

variable "height" {
  type        = number
  description = "Number of mining drills in the column (vertical count)"
}

variable "width" {
  type        = number
  description = "Number of belt segments extending from each drill (horizontal length)"
}

variable "surface" {
  type        = string
  default     = "nauvis"
  description = "The surface on which to place the farm"
}

variable "force" {
  type        = string
  default     = "player"
  description = "The force to assign to the entities"
}
