#!/bin/bash
# Builds "build/System Design Oracle.app" (release, universal when possible) and validates content first.
# Usage: scripts/build_app.sh [--install]   (--install also copies the app to /Applications)
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="System Design Oracle"
VERSION="1.0.0"
APP="build/$APP_NAME.app"

python3 scripts/validate_content.py

if swift build -c release --arch arm64 --arch x86_64 >/dev/null 2>&1; then
  BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/SystemDesignOracle"
else
  swift build -c release
  BIN="$(swift build -c release --show-bin-path)/SystemDesignOracle"
fi

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/SystemDesignOracle"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
rsync -a --include='*/' --include='*.json' --exclude='*' Sources/SystemDesignOracle/Content/ "$APP/Contents/Resources/Content/"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>com.amalmehta.SystemDesignOracle</string>
  <key>CFBundleExecutable</key><string>SystemDesignOracle</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.education</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# Ad-hoc signature so Gatekeeper treats it as a locally built app.
codesign --force --deep --sign - "$APP" >/dev/null
echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
  rm -rf "/Applications/$APP_NAME.app"
  cp -R "$APP" /Applications/
  echo "Installed /Applications/$APP_NAME.app"
fi
