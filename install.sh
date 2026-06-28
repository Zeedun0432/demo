#!/bin/bash

PTERODACTYL_DIR="/var/www/pterodactyl"
ZEEDUN_URL="https://github.com/Zeedun0432/demo/raw/refs/heads/main/zeedun.blueprint"

cd "$PTERODACTYL_DIR" || { echo "Folder Pterodactyl tidak ditemukan!"; exit 1; }

echo "=== Zeedun Theme Installer ==="

export DEBIAN_FRONTEND=noninteractive

# Install dependency dulu (Node 22 + Yarn + inotify-tools)
if ! command -v yarn &> /dev/null; then
    echo "Menginstall Node.js 22 + Yarn..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    apt install -y nodejs
    npm install -g yarn
fi

if ! dpkg -l | grep -q inotify-tools; then
    apt install -y inotify-tools
fi

# Baru install Blueprint
if ! command -v blueprint &> /dev/null; then
    echo "Blueprint belum terinstall. Menginstall sekarang..."
    export PTERODACTYL_DIRECTORY="$PTERODACTYL_DIR"
    wget -q "https://github.com/BlueprintFramework/framework/releases/latest/download/release.zip" -O release.zip
    unzip -o release.zip > /dev/null

    if [ ! -f .blueprintrc ]; then
        echo 'WEBUSER="www-data"; OWNERSHIP="www-data:www-data"; USERSHELL="/bin/bash";' > .blueprintrc
    fi

    chmod +x blueprint.sh
    bash blueprint.sh
else
    echo "Blueprint sudah terinstall, melanjutkan..."
fi
blueprint -upgrade
# Auto-download file zeedun.blueprint kalau belum ada
if [ ! -f "zeedun.blueprint" ]; then
    echo "Mendownload zeedun.blueprint..."
    wget -q "$ZEEDUN_URL" -O zeedun.blueprint
fi

if [ ! -f "zeedun.blueprint" ]; then
    echo "Gagal mendownload zeedun.blueprint! Cek link/koneksi."
    exit 1
fi

echo "Menginstall extension Zeedun..."
echo "Menginstall extension Zeedun..."
cd "$PTERODACTYL_DIR"
yarn install
blueprint -unlock
blueprint -install zeedun.blueprint

echo "=== Instalasi selesai! ==="
