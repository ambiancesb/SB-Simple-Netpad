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
  libnss-mdns

echo ""
echo "Verifying compilers..."
command -v clang++
command -v cmake
command -v ninja

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "Cleaning and fetching Flutter packages..."
flutter clean
flutter pub get

echo ""
echo "Done. Run: flutter run -d linux"
