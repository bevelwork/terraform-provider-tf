# Steel chest filled with the specified item
resource "factorio_entity" "chest" {
  surface = var.surface
  name    = "steel-chest"
  position {
    x = var.x
    y = var.y
  }
  direction = "north"
  force     = var.force

  contents {
    kind = var.kind
    qty  = var.qty
  }
}
