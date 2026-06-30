#!/usr/bin/env bash
# Option A: Linux desktop toolchain for Flutter (SB Simple Netpad)
set -euo pipefail

echo "Installing Linux desktop build dependencies..."
sudo apt-get update
sudo apt-get install -y \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev \
  build-essential \
  avahi-daemon \
  avahi-utils \
  dbus \
  libnss-mdns

sudo systemctl enable --now dbus avahi-daemon 2>/dev/null || true

echo ""
echo "Verifying compilers..."
command -v clang++
command -v cmake
command -v ninja
systemctl is-active dbus 2>/dev/null && echo "dbus: running" || echo "dbus: not running (start with: sudo systemctl start dbus)"
systemctl is-active avahi-daemon 2>/dev/null && echo "avahi-daemon: running" || echo "avahi-daemon: not running (start with: sudo systemctl start avahi-daemon)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "Cleaning and fetching Flutter packages..."
flutter clean
flutter pub get

echo ""
echo "Done. Run: flutter run -d linux"
