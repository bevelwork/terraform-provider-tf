.PHONY: help build build-clean setup sync run clean clean-tf clean-all terraform-init terraform-plan terraform-apply terraform-destroy tf stop

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
	@if [ -d "$(FACTORIO_VOLUME)" ]; then \
		echo "Fixing ownership of factorio-volume directory (may require sudo)..."; \
		sudo chown -R $$(whoami):$$(whoami) $(FACTORIO_VOLUME) 2>/dev/null || true; \
	fi
	@mkdir -p $(FACTORIO_VOLUME)/config
	@if [ -d "$(FACTORIO_VOLUME)/mods" ]; then \
		echo "Removing existing mods directory..."; \
		rm -rf $(FACTORIO_VOLUME)/mods 2>/dev/null || sudo rm -rf $(FACTORIO_VOLUME)/mods; \
	fi
	@mkdir -p $(FACTORIO_VOLUME)/mods
	@echo "Copying mod to server mods directory..."
	@cp -r $(MOD_DIR) $(FACTORIO_VOLUME)/mods/
	@echo "$(RCON_PW)" > $(FACTORIO_VOLUME)/config/rconpw
	@echo "Setup complete!"
	@echo ""
	@echo "To start the server, run: make run"
	@echo "To connect your client, use: 127.0.0.1:34197"

run: setup ## Start the Factorio server in Docker
	@echo "Starting Factorio server..."
	@echo "Server accessible on: 0.0.0.0:34197 (all network interfaces)"
	@echo "Connect your client to: $(shell hostname -I | awk '{print $$1}'):34197 or 127.0.0.1:34197"
	@docker run -it -p 0.0.0.0:34197:34197/udp -p 0.0.0.0:27015:27015/tcp -v "$(shell pwd)/$(FACTORIO_VOLUME):/factorio" factoriotools/factorio:latest

stop: ## Stop running Factorio containers
	@echo "Stopping Factorio containers..."
	@docker ps -q --filter ancestor=factoriotools/factorio:latest | xargs -r docker stop

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
	@rm -rf $(FACTORIO_VOLUME)
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
