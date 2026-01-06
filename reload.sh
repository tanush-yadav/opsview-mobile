#!/bin/bash
# Quick reload script: pulls latest code and triggers Flutter hot restart
# Usage: ./reload.sh

cd "$(dirname "$0")"

echo "📥 Pulling latest changes..."
git pull origin main

echo "🔥 Triggering Flutter hot restart..."
# Send 'R' (hot restart) to the running flutter process
# This works because flutter run is listening for keyboard input
echo "R" | nc localhost 50483 2>/dev/null || echo "⚠️  Could not auto-restart. Press 'R' in your flutter run terminal."

echo "✅ Done! Check the emulator for updates."
