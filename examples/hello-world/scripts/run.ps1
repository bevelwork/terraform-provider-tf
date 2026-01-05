
& $PSScriptRoot\clean-all.ps1

# Copy the mod to your client mods folder
cp -r ../../mod/terraform-crud-api $env:APPDATA/Factorio/mods
# Create a folder to store the Factorio server data
New-Item -ItemType Directory -Force -Path factorio-volume | Out-Null
# Copy the factorio mod to the mods directory
New-Item -ItemType Directory -Force -Path factorio-volume/mods | Out-Null
cp -r ../../mod/terraform-crud-api factorio-volume/mods
# Configure the rcon pw
New-Item -ItemType Directory -Force -Path factorio-volume/config | Out-Null
Write-Output "SOMEPASSWORD" | Out-File -Encoding ASCII -NoNewLine factorio-volume/config/rconpw

# Run factorio server using the official factoriotools/factorio image
# DLC_SPACE_AGE=false disables Space Age DLC
# Using --restart=unless-stopped for better container management
docker run -d `
  --name factorio `
  --restart=unless-stopped `
  -p 127.0.0.1:34197:34197/udp `
  -p 127.0.0.1:27015:27015/tcp `
  -v "${PWD}/factorio-volume:/factorio" `
  -e DLC_SPACE_AGE=false `
  factoriotools/factorio:stable

Write-Host "Factorio server started. Use 'docker logs -f factorio' to view logs."
Write-Host "Use 'docker stop factorio' to stop the server."
