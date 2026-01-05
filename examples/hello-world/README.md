# Hello World Example

## Quick start

### 1. Provider

The provider is automatically downloaded from the [Terraform registry](https://registry.terraform.io/providers/efokschaner/factorio/latest).
If you wish to use a locally built version see [the provider readme](../../provider/README.md) for building from source and installing the provider.

### 2. Factorio Client + Server Setup

This example uses the official [factoriotools/factorio](https://github.com/factoriotools/factorio-docker) Docker image with Space Age DLC disabled.

#### Option A: Using Docker Compose (Recommended)

```bash
# Start the server
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the server
docker-compose down
```

#### Option B: Using the run script

**Linux/macOS:**
```bash
./scripts/run.sh
```

**Windows:**
```powershell
./scripts/run.ps1
```

The script installs the mod to the current machine's Factorio client mods and sets up a headless Factorio server using the official `factoriotools/factorio:stable` image with Space Age DLC disabled.

**Note:** On Linux, you may need to set proper ownership for the volume:
```bash
sudo chown -R 845:845 scripts/factorio-volume
```

To connect your client to the server choose "Multiplayer" > "Connect to address" > Use `127.0.0.1:34197` as the "IP address and port"

### 3. Terraform Run

[Get Terraform](https://www.terraform.io/downloads.html)

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Cleanup

To wipe files created by the above operations you can use:

- `scripts/clean-tf.sh` / `scripts/clean-tf.ps1`: Deletes just the terraform state.
- `scripts/clean-all.sh` / `scripts/clean-all.ps1`: Deletes the server state, and also removes the mod from your own Factorio client install.

If using docker-compose:
```bash
docker-compose down -v  # Removes container and volumes
```
