#!/usr/bin/env bash
set -e

### 0) Parse flags ###
DOWNLOAD=false
while getopts "D" opt; do
  case $opt in
    D) DOWNLOAD=true ;;
    *) echo "Usage: $0 [-D]"; exit 1 ;;
  esac
done
shift $((OPTIND -1))

### 1) Ensure we're root ###
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Detect the “real” user running sudo
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null)}"
HOME_DIR=$(eval echo "~$REAL_USER")

echo "👤 Configuring for user: $REAL_USER (home: $HOME_DIR)"

### 2) System update & essential tools ###
echo "🔄 Updating & upgrading system..."
apt update && apt full-upgrade -y
apt autoremove -y
apt autoclean -y

echo "🔧 Installing essential packages..."
apt install -y \
  htop git curl vim gedit net-tools wireless-tools firmware-ath9k-htc \
  open-vm-tools-desktop virtualbox-guest-x11 \
  apt-transport-https ca-certificates gnupg lsb-release \
  nmap metasploit-framework wordlists torbrowser-launcher snort

### 3) Prepare wordlists ###
echo "📂 Preparing wordlists..."
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  gunzip -f /usr/share/wordlists/rockyou.txt.gz
  echo "✔ rockyou.txt extracted."
else
  echo "ℹ rockyou.txt.gz not found; skipping."
fi

### 4) Docker installation ###
echo "🐳 Setting up Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "📥 Adding Docker apt source..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian bookworm stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Refreshing package lists..."
apt update

echo "⬇️ Installing Docker packages..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "👥 Adding $REAL_USER to docker group..."
usermod -aG docker "$REAL_USER"

echo "⚙️ Enabling & starting services..."
systemctl enable --now open-vm-tools
systemctl enable --now docker

echo
echo "✅ Docker installed. $REAL_USER has been added to the 'docker' group."
echo "   → After re-logging in (or reboot), you can run 'docker ps' without sudo."

### 5) Firefox prefs: disable HTTPS-only & trimURLs ###
echo
echo "🦊 Configuring Firefox prefs for $REAL_USER..."

FF_PROFILES_INI="$HOME_DIR/.mozilla/firefox/profiles.ini"
if [ ! -f "$FF_PROFILES_INI" ]; then
  echo "⚠️  No Firefox profiles.ini at $FF_PROFILES_INI; skipping."
else
  PROFILE_REL=$(awk -F= '/^Path=/ { print $2; exit }' "$FF_PROFILES_INI")
  FF_PROFILE_DIR="$HOME_DIR/.mozilla/firefox/$PROFILE_REL"
  if [ -d "$FF_PROFILE_DIR" ]; then
    USER_JS="$FF_PROFILE_DIR/user.js"
    echo "   ➤ Writing prefs to $USER_JS…"
    touch "$USER_JS"
    chown "$REAL_USER":"$REAL_USER" "$USER_JS"

    # disable HTTPS-only
    if grep -q 'dom.security.https_only_mode' "$USER_JS"; then
      sed -i 's|user_pref("dom.security.https_only_mode".*|user_pref("dom.security.https_only_mode", false);|' "$USER_JS"
    else
      echo 'user_pref("dom.security.https_only_mode", false);' >> "$USER_JS"
    fi

    # disable URL-bar trimming
    if grep -q 'browser.urlbar.trimURLs' "$USER_JS"; then
      sed -i 's|user_pref("browser.urlbar.trimURLs".*|user_pref("browser.urlbar.trimURLs", false);|' "$USER_JS"
    else
      echo 'user_pref("browser.urlbar.trimURLs", false);' >> "$USER_JS"
    fi

    chown "$REAL_USER":"$REAL_USER" "$USER_JS"
    echo "✔ Firefox prefs updated."
  else
    echo "⚠️  Profile dir not found: $FF_PROFILE_DIR; skipping."
  fi
fi

### 6) Configure Metasploit database ###
echo
echo "🔐 Configuring Metasploit database..."
systemctl enable postgresql
systemctl start postgresql
echo "Status of PostgreSQL service:"
service postgresql status --no-pager || true

echo "Initializing msf database..."
msfdb init
echo "✔ Metasploit database initialized."

### 7) Optional download to Desktop ###
if [ "$DOWNLOAD" = true ]; then
  echo
  echo "📥 Downloading LabSec files to Desktop..."

  DESKTOP_DIR="$HOME_DIR/Desktop"
  mkdir -p "$DESKTOP_DIR"
  chown "$REAL_USER":"$REAL_USER" "$DESKTOP_DIR"

  FILE_ID="18_o7qIZ0H7Y93-adOLxlh9IMi_uBATxN"
  FILE_NAME="labsec2.zip"
  OUT_PATH="$DESKTOP_DIR/$FILE_NAME"

  sudo -u "$REAL_USER" curl -L -o "$OUT_PATH" \
    "https://drive.google.com/uc?export=download&id=${FILE_ID}"

  echo "✔ Downloaded $FILE_NAME to $DESKTOP_DIR."
fi

echo
echo "🎉 All done! It’s best to reboot now so:"
echo "   • Docker group membership takes effect,"
echo "   • Firefox will pick up the new prefs on next launch,"
echo "   • Metasploit will connect to its new database immediately."
