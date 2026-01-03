# Terraform Provider for Factorio

"Infrastructure as Code" for your factory.

https://user-images.githubusercontent.com/1409112/119280384-0a067680-bbe6-11eb-8610-10a3f5a9eeb5.mp4

_Current Status:_ Barely functional and mostly useless.

Inspired by the likes of:

- https://github.com/abesto/codetorio
- https://github.com/Redcrafter/verilog2factorio/

Only works with factorio multiplayer server, as it depends on remote control via RCON.
See [./examples/hello-world](./examples/hello-world) for more information on how to use.

## Repository Overview

- [`examples`](./examples): Examples using the provider
- [`mod`](./mod): The mod for factorio which provides an API for the provider.
- [`provider`](./provider): The Terraform provider.

---

## Detailed Application Breakdown

### Architecture Overview

This project implements a Terraform provider that allows you to manage Factorio game entities using Infrastructure as Code principles. The system consists of three main components:

1. **Terraform Provider** (Go) - The client-side Terraform plugin
2. **Factorio Mod** (Lua) - The server-side API that executes game operations
3. **RCON Protocol** - The communication layer between provider and game server

The architecture follows a client-server model where Terraform (via the provider) sends CRUD operations to a Factorio server through RCON, which are then executed by a custom Lua mod.

### Component Breakdown

#### 1. Terraform Provider (`provider/`)

The provider is a Go application built using the HashiCorp Terraform Plugin SDK v2. It implements the standard Terraform provider interface.

**Key Files:**

- **`main.go`**: Entry point that registers the provider with Terraform's plugin system
- **`internal/provider.go`**: Defines the provider schema and configuration
  - Requires `rcon_host` and `rcon_pw` (password) for authentication
  - Registers resources: `factorio_entity`, `factorio_hello`
  - Registers data sources: `factorio_players`
- **`client/factorio_client.go`**: High-level client for communicating with Factorio
  - Implements JSON-RPC style protocol over RCON
  - Provides CRUD operations: `Read()`, `Create()`, `Update()`, `Delete()`
  - Handles handshake protocol (ping/pong) to verify connection
- **`client/rcon.go`**: RCON client implementation
  - Wraps the RCON codec for executing commands
  - Provides `Execute()` and `Authenticate()` methods
- **`client/rcon_codec.go`**: Low-level RCON protocol implementation
  - Implements Source RCON Protocol (Valve's protocol used by Factorio)
  - Adapts RCON to Go's `net/rpc` interface
  - Handles packet serialization/deserialization
  - Manages authentication flow and command execution

**Resources:**

- **`internal/resource_entity.go`**: Manages Factorio entities (buildings, items, etc.)
  - Supports creating entities with position, direction, force, and surface
  - Uses `unit_number` as the unique identifier
  - Supports updating direction and force
  - Handles entity-specific parameters (e.g., for creating ghosts)
- **`internal/resource_hello.go`**: Demo resource that creates "HELLO WORLD" text using conveyor belts
  - Demonstrates custom resource implementation
  - Shows how to manage multiple entities as a single resource

**Data Sources:**

- **`internal/data_source_players.go`**: Fetches list of all players in the game
  - Returns player names and positions
  - Useful for dynamic resource placement

**Supporting Code:**

- **`client/entity.go`**: Entity-specific client methods and data structures
  - `Entity`, `EntityCreateOptions`, `EntityUpdateOptions` types
  - Helper functions for parsing unit numbers
- **`client/direction.go`**: Direction enumeration and parsing
  - Maps between string directions (north, east, etc.) and integer values
- **`internal/shared_schemas.go`**: Reusable Terraform schema definitions
  - Position schema (x, y coordinates)
  - Direction schema with validation
  - Integer position handling with diff suppression

#### 2. Factorio Mod (`mod/terraform-crud-api/`)

The mod is a Lua script that runs inside Factorio and provides a CRUD API for managing game resources.

**Key Files:**

- **`info.json`**: Mod metadata
  - Name: `terraform-crud-api`
  - Version: `0.0.1`
  - Compatible with Factorio 1.1+
- **`control.lua`**: Main mod entry point
  - Exposes `terraform-crud-api` remote interface
  - Implements JSON-RPC handler
  - Routes requests to appropriate resource handlers
  - Handles serialization/deserialization with special handling for Lua's empty object/array quirk
  - Provides `ping` method for connection verification
- **`resource_db.lua`**: Simple in-memory database for tracking resources
  - Stores resource references by type and ID
  - Persists across game saves via `global.resource_db`
- **`resources/entity.lua`**: Entity resource implementation
  - `read()`: Retrieves entity by unit_number, validates entity still exists
  - `create()`: Creates entities using `LuaSurface.create_entity()`
  - `update()`: Updates entity direction and force
  - `delete()`: Destroys entities and cleans up resource database
- **`resources/hello.lua`**: Demo resource implementation
  - Creates ASCII art "HELLO WORLD" using transport belts
  - Manages multiple entities as a collection
  - Demonstrates ghost entity creation

**Communication Protocol:**

The mod receives JSON-RPC requests via RCON commands. The provider sends commands like:
```
/silent-command rcon.print(remote.call('terraform-crud-api', 'call', '{...json-rpc-request...}'))
```

The mod processes these requests and returns JSON-RPC responses that are captured by RCON.

#### 3. Communication Flow

```
Terraform CLI
    ↓
Terraform Provider (Go)
    ↓
FactorioClient (JSON-RPC over RCON)
    ↓
RCON Client (Source RCON Protocol)
    ↓
TCP Connection to Factorio Server
    ↓
Factorio RCON Handler
    ↓
Lua Console Command Execution
    ↓
terraform-crud-api Mod (Lua)
    ↓
Factorio Game API (LuaEntity, LuaSurface, etc.)
```

**Request Flow Example (Creating an Entity):**

1. User runs `terraform apply` with `factorio_entity` resource
2. Provider calls `EntityCreate()` with entity configuration
3. `FactorioClient` marshals JSON-RPC request: `{"method": "create", "params": ["entity", {...config...}]}`
4. RCON client wraps request in RCON command and sends over TCP
5. Factorio executes Lua command, calling the mod's remote interface
6. Mod deserializes JSON, routes to `resources.entity.create()`
7. Mod calls `surface.create_entity()` with provided parameters
8. Mod stores entity reference in `resource_db` and returns result
9. Response flows back through the same chain
10. Provider updates Terraform state with created entity's `unit_number`

### Key Design Decisions

1. **RCON Protocol**: Uses Factorio's built-in RCON support, avoiding need for custom network protocols
2. **JSON-RPC**: Standardized request/response format makes it easy to add new resource types
3. **Unit Number as ID**: Factorio's `unit_number` provides stable, unique identifiers for entities
4. **Resource Database**: In-memory tracking allows the mod to validate entity existence and handle cleanup
5. **Remote Interface**: Uses Factorio's mod-to-mod communication system for clean API boundaries
6. **Silent Commands**: Uses `/silent-command` to avoid cluttering game chat with RCON output

### Limitations & Known Issues

1. **Multiplayer Only**: Requires RCON, which is only available in multiplayer servers
2. **Entity Validation**: Entities can be destroyed in-game, requiring validation on read operations
3. **Position Precision**: Uses integer positions to avoid floating-point drift issues
4. **Empty Object Handling**: Lua's inability to distinguish empty objects from empty arrays requires workarounds
5. **RCON Command Escaping**: Single quotes in JSON requests could cause issues (noted in TODO)
6. **Limited Entity Support**: Only basic entity properties are supported (many `create_entity` parameters unimplemented)

### Development Setup

See [`provider/README.md`](./provider/README.md) for detailed build and installation instructions.

**Quick Start:**

1. Build the provider for your platform
2. Install to Terraform plugins directory
3. Install the mod to Factorio's mods directory
4. Configure provider with RCON credentials
5. Use Terraform to manage your factory!

### Example Usage

```hcl
provider "factorio" {
  rcon_host = "127.0.0.1:27015"
  rcon_pw   = "your-rcon-password"
}

# Fetch all players
data "factorio_players" "all" {}

# Create a stone furnace
resource "factorio_entity" "furnace" {
  surface = "nauvis"
  name    = "stone-furnace"
  position {
    x = 0
    y = 0
  }
  direction = "north"
  force     = "player"
}
```

### Future Enhancements

Potential areas for expansion:

- Support for more entity types (inserters, assemblers, etc.)
- Circuit network configuration
- Blueprint management
- Train schedule management
- Logistic network configuration
- Research management
- More comprehensive entity parameter support

