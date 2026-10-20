#!/bin/bash
# Script for Vercel to install Flutter and build web release
set -e

echo "=== Downloading Flutter SDK ==="
if [ ! -d "_flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
fi

export PATH="$PATH:$(pwd)/_flutter/bin"

echo "=== Flutter Environment ==="
flutter --version
flutter config --no-analytics
flutter config --enable-web

echo "=== Building Flutter Web ==="
flutter build web --release
