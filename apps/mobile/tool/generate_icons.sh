#!/usr/bin/env bash
#
# Generates the app launcher icon from the Taboor logo.
#
# Usage:
#   ./tool/generate_icons.sh
#
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Generating PNG sources from the Taboor logo..."
flutter test tool/generate_app_icon_test.dart

echo "==> Generating all launcher icons (Android + iOS)..."
dart run flutter_launcher_icons

echo "==> Done."