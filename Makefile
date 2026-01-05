.PHONY: help build build-clean setup sync run run-detached clean clean-tf clean-all terraform-init terraform-plan terraform-apply terraform-destroy tf stop disable-dlc

# Default target
.DEFAULT_GOAL := build

# Detect OS and set Factorio mods directory
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	FACTORIO_MODS_DIR := $(HOME)/.factorio/mods
else ifeq ($(UNAME_S),Darwin)
	FACTORIO_MODS_DIR := $(HOME)/Library/Application Support/factorio/mods
else
	FACTORIO_MODS_DIR := $(HOME)/.factorio/mods
endif

# Paths (relative to repo root)
PROVIDER_DIR := provider
EXAMPLE_DIR := examples/hello-world
SCRIPTS_DIR := $(EXAMPLE_DIR)/scripts
MOD_DIR := mod/terraform-crud-api
FACTORIO_VOLUME := $(SCRIPTS_DIR)/factorio-volume
RCON_PW := SOMEPASSWORD
PROVIDER_BINARY := $(PROVIDER_DIR)/terraform-provider-factorio

# Remote sync settings (set SYNC_HOST and SYNC_PATH to sync to a peer computer)
# Example: make sync SYNC_HOST=user@192.168.1.100 SYNC_PATH=/home/user/.factorio/mods
SYNC_HOST :=
SYNC_PATH :=

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Terraform provider binary
	@echo "Building Terraform provider..."
	@cd $(PROVIDER_DIR) && go build -o terraform-provider-factorio
	@echo "Provider built successfully: $(PROVIDER_BINARY)"

build-clean: ## Remove the built provider binary
	@echo "Removing provider binary..."
	@rm -f $(PROVIDER_BINARY)
	@echo "Cleanup complete!"

sync: ## Sync mod to Factorio installation (local or remote via SYNC_HOST/SYNC_PATH)
	@if [ -n "$(SYNC_HOST)" ] && [ -n "$(SYNC_PATH)" ]; then \
		echo "Syncing mod to remote Factorio installation..."; \
		echo "Host: $(SYNC_HOST)"; \
		echo "Path: $(SYNC_PATH)"; \
		rsync -avz --delete $(MOD_DIR)/ $(SYNC_HOST):$(SYNC_PATH)/terraform-crud-api/ || \
		scp -r $(MOD_DIR) $(SYNC_HOST):$(SYNC_PATH)/terraform-crud-api; \
		echo "Mod synced successfully to $(SYNC_HOST):$(SYNC_PATH)/terraform-crud-api"; \
	else \
		echo "Syncing mod to local Factorio installation..."; \
		echo "Detected OS: $(UNAME_S)"; \
		echo "Factorio mods directory: $(FACTORIO_MODS_DIR)"; \
		mkdir -p "$(FACTORIO_MODS_DIR)"; \
		echo "Removing existing mod (if present)..."; \
		rm -rf "$(FACTORIO_MODS_DIR)/terraform-crud-api"; \
		echo "Copying mod to client mods folder..."; \
		cp -r $(MOD_DIR) "$(FACTORIO_MODS_DIR)/"; \
		echo "Mod synced successfully to $(FACTORIO_MODS_DIR)/terraform-crud-api"; \
	fi

setup: sync ## Set up Factorio server (copy mods, create volume, configure RCON)
	@echo "Setting up Factorio server..."
	@echo "Creating server volume directory..."
	@mkdir -p $(FACTORIO_VOLUME)/config
	@mkdir -p $(FACTORIO_VOLUME)/saves
	@mkdir -p $(FACTORIO_VOLUME)/mods
	@echo "Fixing ownership of volume directories (if needed)..."
	@if [ ! -w "$(FACTORIO_VOLUME)" ]; then \
		sudo chown -R $$(id -u):$$(id -g) $(FACTORIO_VOLUME) 2>/dev/null || true; \
	fi
	@if [ -d "$(FACTORIO_VOLUME)/mods/terraform-crud-api" ]; then \
		echo "Removing existing mod directory..."; \
		rm -rf $(FACTORIO_VOLUME)/mods/terraform-crud-api 2>/dev/null || \
		(sudo rm -rf $(FACTORIO_VOLUME)/mods/terraform-crud-api 2>/dev/null || \
		echo "Warning: Could not remove existing mod directory. Continuing anyway..."); \
	fi
	@echo "Copying mod to server mods directory..."
	@cp -r $(MOD_DIR) $(FACTORIO_VOLUME)/mods/ || \
	(sudo cp -r $(MOD_DIR) $(FACTORIO_VOLUME)/mods/ || \
	(echo "Error: Could not copy mod directory. Please check permissions." && exit 1))
	@echo "Removing existing saves (they may have DLC mods enabled)..."
	@rm -f $(FACTORIO_VOLUME)/saves/*.zip 2>/dev/null || true
	@echo "Creating mod-list.json to disable DLC mods..."
	@printf '{\n  "mods": [\n    {"name": "base", "enabled": true},\n    {"name": "terraform-crud-api", "enabled": true},\n    {"name": "space-age", "enabled": false},\n    {"name": "elevated-rails", "enabled": false},\n    {"name": "quality", "enabled": false}\n  ]\n}\n' > $(FACTORIO_VOLUME)/mods/mod-list.json
	@echo "$(RCON_PW)" > $(FACTORIO_VOLUME)/config/rconpw
	@echo "Creating server-settings.json..."
	@if [ ! -f "$(FACTORIO_VOLUME)/config/server-settings.json" ]; then \
		printf '{\n  "name": "Terraform Provider Factorio Server",\n  "description": "Server for testing terraform-provider-factorio",\n  "tags": ["terraform", "testing"],\n  "max_players": 0,\n  "visibility": {\n    "public": false,\n    "lan": true\n  },\n  "username": "",\n  "password": "",\n  "token": "",\n  "game_password": "",\n  "require_user_verification": false,\n  "max_upload_in_kilobytes_per_second": 0,\n  "max_upload_slots": 5,\n  "minimum_latency_in_ticks": 0,\n  "max_heartbeats_per_second": 60,\n  "ignore_player_limit_for_returning_players": false,\n  "allow_commands": "admins-only",\n  "autosave_interval": 10,\n  "autosave_slots": 5,\n  "afk_autokick_interval": 0,\n  "auto_pause": true,\n  "auto_pause_when_players_connect": false,\n  "only_admins_can_pause_the_game": true,\n  "autosave_only_on_server": true,\n  "non_blocking_saving": false,\n  "minimum_segment_size": 25,\n  "minimum_segment_size_peer_count": 20,\n  "maximum_segment_size": 100,\n  "maximum_segment_size_peer_count": 10\n}\n' > $(FACTORIO_VOLUME)/config/server-settings.json; \
	fi
	@echo "DLC mods (space-age, elevated-rails, quality) are now disabled in mod-list.json"
	@echo "Setup complete!"
	@echo ""
	@echo "To start the server, run: make run"
	@echo "To connect your client, use: 127.0.0.1:34197"

run: setup ## Start the Factorio server using docker compose (foreground)
	@echo "Starting Factorio server with docker compose..."
	@echo "Server accessible on: 0.0.0.0:34197 (all network interfaces)"
	@echo "Connect your client to: $(shell hostname -I | awk '{print $$1}'):34197 or 127.0.0.1:34197"
	@echo ""
	@RCON_PASSWORD=$(RCON_PW) docker compose up

run-detached: setup ## Start the Factorio server using docker compose (detached/background)
	@echo "Starting Factorio server with docker compose in detached mode..."
	@echo "Server accessible on: 0.0.0.0:34197 (all network interfaces)"
	@echo "Connect your client to: $(shell hostname -I | awk '{print $$1}'):34197 or 127.0.0.1:34197"
	@echo ""
	@RCON_PASSWORD=$(RCON_PW) docker compose up -d
	@echo "Server started in background. Use 'make stop' to stop it or 'docker compose logs -f' to view logs."

stop: ## Stop running Factorio containers
	@echo "Stopping Factorio containers..."
	@docker compose down

disable-dlc: ## Disable DLC mods in mod-list.json (run after server starts)
	@echo "Disabling DLC mods in mod-list.json..."
	@if [ -f "$(FACTORIO_VOLUME)/mods/mod-list.json" ]; then \
		printf '{\n  "mods": [\n    {"name": "base", "enabled": true},\n    {"name": "terraform-crud-api", "enabled": true},\n    {"name": "space-age", "enabled": false},\n    {"name": "elevated-rails", "enabled": false},\n    {"name": "quality", "enabled": false}\n  ]\n}\n' > $(FACTORIO_VOLUME)/mods/mod-list.json; \
		echo "DLC mods disabled. Restart the server for changes to take effect."; \
	else \
		echo "Error: mod-list.json not found. Run 'make setup' first."; \
		exit 1; \
	fi

clean-tf: ## Remove Terraform state files
	@echo "Removing Terraform state files..."
	@cd $(EXAMPLE_DIR) && rm -rf .terraform.lock.hcl
	@cd $(EXAMPLE_DIR) && rm -rf .terraform
	@cd $(EXAMPLE_DIR) && rm -rf terraform.tfstate
	@cd $(EXAMPLE_DIR) && rm -rf terraform.tfstate.backup

clean-all: clean-tf ## Remove all generated files (Terraform state, client mod, server volume)
	@echo "Removing local client mod..."
	@rm -rf "$(FACTORIO_MODS_DIR)/terraform-crud-api"
	@echo "Removing server persistent volume..."
	@if [ -d "$(FACTORIO_VOLUME)" ]; then \
		echo "Removing server volume..."; \
		rm -rf $(FACTORIO_VOLUME) 2>/dev/null || (echo "Warning: Some files may have been created by Docker container. Trying with sudo..."; sudo rm -rf $(FACTORIO_VOLUME) 2>/dev/null || echo "Note: Some files may require manual cleanup."); \
	fi
	@echo "Cleanup complete!"

clean: clean-all ## Alias for clean-all

terraform-init: ## Initialize Terraform
	@cd $(EXAMPLE_DIR) && terraform init

terraform-plan: ## Run Terraform plan
	@cd $(EXAMPLE_DIR) && terraform plan

terraform-apply: ## Apply Terraform configuration
	@cd $(EXAMPLE_DIR) && terraform apply -auto-approve

terraform-destroy: ## Destroy Terraform resources
	@cd $(EXAMPLE_DIR) && terraform destroy

tf: terraform-plan terraform-apply ## Run full Terraform workflow (plan, apply)
	@echo "Terraform workflow complete!"
