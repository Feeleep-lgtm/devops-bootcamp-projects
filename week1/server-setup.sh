#!/bin/bash
# =============================================================================
# HNG DevOps - Server Setup Script
# Purpose: Automatically configure a fresh Linux server with best practices
# =============================================================================

# STEP 1: Safety Settings
set -euo pipefail
# -e : Exit immediately if any command fails
# -u : Treat unset variables as an error
# -o pipefail : Return the exit status of the last command in a pipe that failed

# STEP 2: Logging Function
LOG_FILE="/tmp/setup-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================"
log "Starting Server Setup Script"
log "========================================"

# STEP 3: Update System
log "Updating package lists and upgrading system..."
sudo apt update -y
sudo apt upgrade -y
log "System packages updated successfully"

# STEP 4: Install Useful Tools
PACKAGES="git curl vim htop wget unzip net-tools ca-certificates gnupg lsb-release"
log "Installing essential packages: $PACKAGES"
sudo apt install -y $PACKAGES
log "Essential packages installed"

# STEP 5: Create Non-Root User
NEW_USER="devopsuser"

if id "$NEW_USER" &>/dev/null; then
    log "User '$NEW_USER' already exists. Skipping creation."
else
    log "Creating new user: $NEW_USER"
    sudo useradd -m -s /bin/bash "$NEW_USER"
    sudo usermod -aG sudo "$NEW_USER"
    log "User '$NEW_USER' created and added to sudo group"
fi

# STEP 6: Set Timezone
log "Setting timezone to Africa/Lagos..."
sudo timedatectl set-timezone Africa/Lagos
log "Timezone set to: $(timedatectl | grep 'Time zone')"

# STEP 7: Configure Basic Firewall (UFW)
log "Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable
log "Firewall (UFW) enabled with SSH allowed"

# STEP 8: Final Summary
log "========================================"
log "Server Setup Completed Successfully!"
log "========================================"

echo ""
echo "══════════════════════════════════════════════"
echo "               SETUP SUMMARY"
echo "══════════════════════════════════════════════"
echo "OS          : $(lsb_release -ds 2>/dev/null || echo 'Ubuntu/Debian')"
echo "User Created: $NEW_USER"
echo "Timezone    : $(timedatectl | grep 'Time zone' | awk '{print $3}')"
echo "Firewall    : Active (UFW)"
echo "Log File    : $LOG_FILE"
echo "══════════════════════════════════════════════"
echo ""

log "Script finished. Log saved to: $LOG_FILE"
