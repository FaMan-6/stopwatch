#!/bin/bash
set -e

echo "Downloading Flutter SDK..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz | tar xJ

export PATH="$PATH:$PWD/flutter/bin"

flutter --version
flutter build web
