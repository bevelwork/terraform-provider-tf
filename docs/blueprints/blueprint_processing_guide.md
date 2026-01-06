# Blueprint Processing Guide

This guide instructs agents on how to parse JSON blueprints and convert them into Terraform modules.

## Overview

A blueprint is a JSON structure that defines a collection of entities with their positions, types, and optional properties. The goal is to parse this blueprint and generate a Terraform module that represents these entities as infrastructure resources.

**Important:** When processing blueprints, discard icon information (`blueprint.icons`). Icons are visual markers used in the Factorio game interface and are not needed for Terraform module generation.

## Blueprint Schema

A complete JSON schema for blueprint validation is available in `blueprint_schema.json`. This schema can be used to validate blueprint JSON structures before processing.

### Root Structure

```json
{
  "blueprint": {
    "icons": [Icon],
    "entities": [Entity],
    "wires": [Wire],
    "item": "blueprint",
    "version": number
  }
}
```

### Icon Schema

**IMPORTANT: Discard icon information during processing.**

Icons are visual markers for the blueprint used for identification in the Factorio game interface. They are not needed for Terraform module generation and should be ignored.

```json
{
  "signal": {
    "name": "string"
  },
  "index": number
}
```

**Processing Instruction:** When parsing blueprints, completely ignore the `icons` field. Do not include icon information in the generated Terraform modules.

### Entity Schema

Each entity represents a resource or component in the blueprint:

```json
{
  "entity_number": number,
  "name": "string",
  "position": {
    "x": number,
    "y": number
  },
  "direction": number  // Optional: 0-7 (see Direction Mapping below)
}
```

**Required Fields:**
- `entity_number`: Unique identifier for the entity
- `name`: Type/name of the entity (e.g., "steam-engine", "boiler", "pipe")
- `position`: Object containing `x` and `y` coordinates

**Optional Fields:**
- `direction`: Orientation of the entity (0-7, see Direction Mapping)

### Wire Schema

Wires represent connections between entities (typically for electrical or logical connections):

```json
[
  entity_number_1,
  circuit_id_1,
  entity_number_2,
  circuit_id_2
]
```

### Direction Mapping

The `direction` property is optional and uses values 0-7 to represent cardinal and diagonal directions:

| Value | Direction | Description |
|-------|-----------|-------------|
| 0 | North | Default orientation (up) |
| 1 | Northeast | Diagonal |
| 2 | East | Right |
| 3 | Southeast | Diagonal |
| 4 | South | Down |
| 5 | Southwest | Diagonal |
| 6 | West | Left |
| 7 | Northwest | Diagonal |

**Default Behavior:**
- If `direction` is not specified, assume `0` (North)
- Direction affects entity placement and orientation in the Terraform representation

## Processing Steps

### 1. Parse the Blueprint JSON

1. Load and validate the JSON structure
2. **Discard icon information**: Ignore the `blueprint.icons` field completely - it is not needed for Terraform module generation
3. Verify required fields are present:
   - `blueprint.entities` must be an array
   - Each entity must have `entity_number`, `name`, and `position`
4. Handle optional fields gracefully (missing `direction` defaults to 0)

### 2. Normalize Entity Data

For each entity in `blueprint.entities`:

1. Extract required fields:
   - `entity_number` → use as unique identifier
   - `name` → map to Terraform resource type
   - `position.x` and `position.y` → use for placement coordinates

2. Handle direction:
   - If `direction` is present, use the value (0-7)
   - If `direction` is missing, default to `0` (North)
   - Convert direction to appropriate Terraform attribute if needed

3. Group entities by type (optional, for organization):
   - Group all entities with the same `name` together
   - This can help with resource organization in Terraform

### 3. Generate Terraform Module Structure

Create a Terraform module with the following structure:

```
module/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variables
├── outputs.tf      # Output values
└── README.md       # Module documentation
```

### 4. Map Entities to Terraform Resources

For each entity, create a Terraform resource block:

```hcl
resource "entity_type" "entity_<entity_number>" {
  name     = "<entity_name>"
  position = {
    x = <position.x>
    y = <position.y>
  }
  
  # Include direction if specified (and if the resource type supports it)
  direction = <direction_value>  # Optional, defaults to 0
}
```

**Key Considerations:**
- Use `entity_number` to create unique resource identifiers
- Map entity `name` to appropriate Terraform resource types
- Preserve position coordinates exactly as specified
- Include direction attribute if the resource type supports orientation

### 5. Handle Wires (Optional)

If `wires` are present and need to be represented:

1. Parse wire connections from the `wires` array
2. Create Terraform resources or data structures to represent connections
3. Link entities using their `entity_number` values

### 6. Generate Module Variables

Create variables for configurable aspects:

```hcl
variable "base_position" {
  description = "Base position offset for all entities"
  type = object({
    x = number
    y = number
  })
  default = {
    x = 0
    y = 0
  }
}

variable "entity_config" {
  description = "Configuration overrides for specific entities"
  type = map(any)
  default = {}
}
```

### 7. Generate Module Outputs

Create outputs for important information:

```hcl
output "entity_count" {
  description = "Total number of entities in the blueprint"
  value       = length(var.entities)
}

output "entity_positions" {
  description = "Map of entity numbers to positions"
  value = {
    for entity in var.entities : entity.entity_number => entity.position
  }
}
```

## Example Processing

### Input Blueprint

```json
{
  "blueprint": {
    "entities": [
      {
        "entity_number": 1,
        "name": "steam-engine",
        "position": {
          "x": -25.5,
          "y": -10.5
        }
      },
      {
        "entity_number": 2,
        "name": "steam-engine",
        "position": {
          "x": -22.5,
          "y": -10.5
        }
      },
      {
        "entity_number": 154,
        "name": "transport-belt",
        "position": {
          "x": -24.5,
          "y": 5.5
        },
        "direction": 4
      }
    ],
    "item": "blueprint",
    "version": 562949956501504
  }
}
```

### Generated Terraform (main.tf)

```hcl
resource "steam_engine" "entity_1" {
  name     = "steam-engine"
  position = {
    x = -25.5
    y = -10.5
  }
  direction = 0  # Default (North)
}

resource "steam_engine" "entity_2" {
  name     = "steam-engine"
  position = {
    x = -22.5
    y = -10.5
  }
  direction = 0  # Default (North)
}

resource "transport_belt" "entity_154" {
  name     = "transport-belt"
  position = {
    x = -24.5
    y = 5.5
  }
  direction = 4  # South
}
```

## Best Practices

1. **Validation**: Always validate the JSON structure before processing
2. **Discard Icons**: Ignore and discard all icon information from blueprints - it is not needed for Terraform modules
3. **Error Handling**: Handle missing or malformed entities gracefully
4. **Uniqueness**: Ensure `entity_number` values are unique within the blueprint
5. **Coordinate System**: Preserve the exact coordinate system from the blueprint
6. **Direction Defaults**: Always default to `0` (North) when direction is not specified
7. **Resource Naming**: Use consistent naming conventions for Terraform resources
8. **Modularity**: Organize related entities into logical groups when possible
9. **Documentation**: Include comments explaining entity types and their purposes

## Common Entity Types

Based on the example blueprint, common entity types include:

- `steam-engine`: Power generation entities
- `boiler`: Heating/processing entities
- `pipe`: Fluid transport entities
- `transport-belt`: Item transport entities
- `burner-inserter`: Item manipulation entities
- `medium-electric-pole`: Power distribution entities
- `pipe-to-ground`: Underground fluid transport
- `offshore-pump`: Fluid source entities

Map these to appropriate Terraform resource types based on your infrastructure needs.

## Validation Checklist

Before finalizing the Terraform module, verify:

- [ ] All entities from the blueprint are represented
- [ ] Entity numbers are unique and correctly mapped
- [ ] Positions are preserved exactly
- [ ] Directions are correctly applied (or defaulted to 0)
- [ ] Resource types are appropriate for each entity name
- [ ] Module variables and outputs are defined
- [ ] Documentation is complete
- [ ] Terraform syntax is valid

## Troubleshooting

### Missing Direction Property
- **Issue**: Entity doesn't have a `direction` property
- **Solution**: Default to `0` (North) and continue processing

### Invalid Entity Number
- **Issue**: Duplicate or missing `entity_number`
- **Solution**: Generate unique identifiers or skip invalid entities with a warning

### Unknown Entity Name
- **Issue**: Entity `name` doesn't map to a known Terraform resource type
- **Solution**: Use a generic resource type or create a custom mapping

### Coordinate System Issues
- **Issue**: Coordinates seem incorrect or out of bounds
- **Solution**: Preserve coordinates as-is unless there's a specific transformation requirement

## Schema Reference

A complete JSON Schema for blueprint validation is provided in `blueprint_schema.json`. Use this schema to:

- Validate blueprint JSON structure before processing
- Understand required vs. optional fields
- Reference the direction mapping values
- Ensure data integrity

You can use JSON schema validators (such as `ajv` for JavaScript/Node.js or `jsonschema` for Python) to validate blueprints against this schema.

## Additional Resources

- Terraform Resource Documentation
- JSON Schema Validation
- Coordinate System Reference
- `blueprint_schema.json` - Complete JSON schema for validation
