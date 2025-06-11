#!/bin/bash

set -e

# --- CONFIGURATION ---
CONFIG_DIR="/etc/recyclarr"
CONFIG_URL="https://gist.githubusercontent.com/RetroTrigger/081fef5ed7032196199286ee5af9892b/raw/ec53dc7f3a642b9df0a9e7a4d412fbec9e51b252/recyclarr.yml"  # <-- CHANGE THIS
RECYCLARR_BIN="/usr/local/bin/recyclarr"
CRON_JOB="0 4 * * 0 $RECYCLARR_BIN sync"
TMP_DIR="/tmp/recyclarr_install"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Functions ---
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Start ---
echo -e "${GREEN}
██████  ███████  ██████ ██    ██ ██       █████  ██████  ██████  
██   ██ ██      ██      ██    ██ ██      ██   ██ ██   ██ ██   ██ 
██████  █████   ██      ██    ██ ██      ███████ ██████  ██   ██ 
██   ██ ██      ██      ██    ██ ██      ██   ██ ██      ██   ██ 
██   ██ ███████  ██████  ██████  ███████ ██   ██ ██      ██████  
${NC}"

info "Starting Recyclarr deluxe installer..."

# --- Install Dependencies ---
info "Installing required system packages..."
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y curl unzip wget cron || error "Failed to install dependencies."
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y curl unzip wget cronie || error "Failed to install dependencies."
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y curl unzip wget cronie || error "Failed to install dependencies."
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm curl unzip wget cronie || error "Failed to install dependencies."
elif command -v zypper >/dev/null 2>&1; then
  sudo zypper install -y curl unzip wget cron || error "Failed to install dependencies."
elif command -v apk >/dev/null 2>&1; then
  sudo apk add --no-cache curl unzip wget cron || error "Failed to install dependencies."
else
  error "No compatible package manager found. Please install curl, unzip, wget, and cron manually."
fi

# --- Install Recyclarr ---
if [ ! -f "$RECYCLARR_BIN" ]; then
  info "Downloading Recyclarr release..."
  mkdir -p "$TMP_DIR"
  
  # Hardcode a specific version that we know works
  VERSION="5.0.0"
  DOWNLOAD_URL="https://github.com/recyclarr/recyclarr/releases/download/v$VERSION/recyclarr-linux-x64.zip"
  
  info "Using version $VERSION"
  info "Downloading from: $DOWNLOAD_URL"
  
  # Add verbose output for wget to debug any issues
  wget --verbose "$DOWNLOAD_URL" -O "$TMP_DIR/recyclarr.zip" || error "Failed to download Recyclarr zip file."
  
  # Check file exists and has content
  ls -la "$TMP_DIR" || error "Cannot list temp directory"
  
  # Verify the download was successful
  if [ ! -s "$TMP_DIR/recyclarr.zip" ]; then
    error "Downloaded file is empty. Download failed."
  fi

  info "Installing Recyclarr..."
  unzip "$TMP_DIR/recyclarr.zip" -d "$TMP_DIR"
  sudo mv "$TMP_DIR/recyclarr/recyclarr" "$RECYCLARR_BIN"
  sudo chmod +x "$RECYCLARR_BIN"

  rm -rf "$TMP_DIR"
  success "Recyclarr installed successfully."
else
  success "Recyclarr already installed. Skipping install."
fi

# --- Setup Config Directory ---
info "Setting up config directory at $CONFIG_DIR..."
sudo mkdir -p "$CONFIG_DIR"
sudo chown "$USER:$USER" "$CONFIG_DIR"

# --- Download Config File ---
info "Downloading recyclarr.yml from $CONFIG_URL..."
curl -L "$CONFIG_URL" -o "$CONFIG_DIR/recyclarr.yml" || error "Failed to download recyclarr.yml."

success "Config file placed at $CONFIG_DIR/recyclarr.yml."

# --- Prompt for API Keys ---
echo ""
info "Please enter your Radarr API Key:"
read -r RADARR_KEY
info "Please enter your Sonarr API Key:"
read -r SONARR_KEY

# --- Inject API Keys into recyclarr.yml ---
info "Injecting API keys into recyclarr.yml..."
# Escape special characters in the provided API keys so sed does not
# misinterpret them. This allows keys containing '/' or '&' to be
# properly inserted into the configuration file.
safe_radarr=${RADARR_KEY//&/\\&}
safe_radarr=${safe_radarr//\//\\/}
safe_sonarr=${SONARR_KEY//&/\\&}
safe_sonarr=${safe_sonarr//\//\\/}
sed -i "s|RADARR_API_KEY_HERE|$safe_radarr|g" "$CONFIG_DIR/recyclarr.yml"
sed -i "s|SONARR_API_KEY_HERE|$safe_sonarr|g" "$CONFIG_DIR/recyclarr.yml"

success "API keys injected successfully."

# --- Setup Cron Job ---
info "Setting up cron job to auto-sync every Sunday at 4 AM..."
( crontab -l 2>/dev/null | grep -v 'recyclarr sync' ; echo "$CRON_JOB" ) | crontab -

success "Cron job installed."

# --- Test Installation ---
info "Testing recyclarr version..."
recyclarr version && success "Recyclarr CLI working!"

# --- Done ---
echo -e "${GREEN}
Installation Complete! 🎉
✅ Recyclarr installed at /usr/local/bin/recyclarr
✅ Config installed at $CONFIG_DIR/recyclarr.yml
✅ Sync scheduled every Sunday at 4AM.
✅ API keys safely injected.

You can manually run it now using:
${YELLOW}recyclarr sync${NC}

Enjoy!
${NC}"
