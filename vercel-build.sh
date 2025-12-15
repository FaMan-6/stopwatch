#!/usr/bin/env bash
set -e

echo "Installing Flutter..."

curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz | tar xJ

export PATH="$PATH:$PWD/flutter/bin"

git config --global --add safe.directory /vercel/path0/flutter

flutter config --no-analytics
flutter doctor -v

flutter build web
