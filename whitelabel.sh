#!/bin/bash

# -----------------------------------------------------------------------------
# White-label automation utility.
#
# This script wires an environment-specific configuration into the Flutter app
# without requiring any manual edits. Provide a .env-style file (defaults to
# ./.env) with at least the variables below:
#   APP_NAME       – Display name shown on the launcher and installer.
#   PACKAGE_NAME   – Android bundle identifier; also used for Maestro appId.
#   APP_ICON_PATH  – Optional override pointing to a PNG icon; falls back to
#                    assets/icon/icon.png when omitted.
#   FIREBASE_PROJECT       – Firebase project ID used to generate config via
#                             flutterfire configure.
#
# Workflow overview:
#   1. Load the requested environment file and verify required variables.
#   2. Copy the icon (if needed) into assets/icon/icon.png.
#   3. Update the flutter_launcher_icons.image_path entry within pubspec.yaml.
#   4. Run flutter pub get, package_rename_plus, and flutter_launcher_icons.
#   5. Normalize appId fields across Maestro flows (if present).
#
# Requirements: bash, coreutils (cp/mktemp/find), awk, flutter, dart,
# package_rename_plus, flutter_launcher_icons. The script intentionally sticks to
# bash + POSIX tooling so it can run in minimal build environments.
# -----------------------------------------------------------------------------

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

ENV_FILE="${1:-$PROJECT_ROOT/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[whitelabel] Env file not found: $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

REQUIRED_VARS=(APP_NAME PACKAGE_NAME FIREBASE_PROJECT)
for var in "${REQUIRED_VARS[@]}"; do
  value="${!var:-}"
  if [[ -z "$value" ]]; then
    echo "[whitelabel] Missing $var in $ENV_FILE" >&2
    exit 1
  fi
done

ICON_TARGET_REL="assets/icon/icon.png"
ICON_TARGET_ABS="$PROJECT_ROOT/$ICON_TARGET_REL"
ICON_SOURCE_REL="${APP_ICON_PATH:-$ICON_TARGET_REL}"
ICON_SOURCE_ABS="$ICON_SOURCE_REL"
if [[ ! "$ICON_SOURCE_ABS" = /* ]]; then
  ICON_SOURCE_ABS="$PROJECT_ROOT/$ICON_SOURCE_ABS"
fi

if [[ ! -f "$ICON_SOURCE_ABS" ]]; then
  echo "[whitelabel] Icon not found. Provide APP_ICON_PATH to an existing file or place it at $ICON_TARGET_REL" >&2
  exit 1
fi

if [[ "$ICON_SOURCE_ABS" != "$ICON_TARGET_ABS" ]]; then
  mkdir -p "$(dirname "$ICON_TARGET_ABS")"
  cp "$ICON_SOURCE_ABS" "$ICON_TARGET_ABS"
fi

echo "[whitelabel] Using env file: $ENV_FILE"
echo "[whitelabel] App name........: $APP_NAME"
echo "[whitelabel] Package name....: $PACKAGE_NAME"
echo "[whitelabel] Icon path.......: $ICON_TARGET_REL"
echo "[whitelabel] Firebase project.................: $FIREBASE_PROJECT"

TMP_CONFIG="$(mktemp -t package_rename_config)"
trap 'rm -f "$TMP_CONFIG"' EXIT

cat >"$TMP_CONFIG" <<EOF
package_rename_config:
  android:
    app_name: "$APP_NAME"
    package_name: "$PACKAGE_NAME"
EOF

update_flutter_launcher_icons_image_path() {
  local icon_path="$1"
  local pubspec="pubspec.yaml"

  if [[ ! -f "$pubspec" ]]; then
    echo "[whitelabel] pubspec.yaml not found" >&2
    exit 1
  fi

  local tmp
  tmp="$(mktemp -t pubspec_whitelabel)"

  if ! awk -v icon_path="$icon_path" '
    {
      line = $0
      stripped = line
      sub(/^[[:space:]]+/, "", stripped)

      if (match(stripped, /^flutter_launcher_icons:/)) {
        inside = 1
      } else if (inside && stripped != "" && stripped !~ /^#/ && line !~ /^[[:space:]]/) {
        inside = 0
      }

      if (inside && stripped ~ /^image_path:/ && !updated) {
        sub(/image_path:.*/, "image_path: \"" icon_path "\"", line)
        updated = 1
      }

      print line
    }
    END {
      if (!updated) {
        exit 42
      }
    }
  ' "$pubspec" >"$tmp"; then
    local status=$?
    rm -f "$tmp"
    if [[ $status -eq 42 ]]; then
      echo "[whitelabel] Unable to locate flutter_launcher_icons.image_path entry" >&2
    else
      echo "[whitelabel] Failed updating pubspec.yaml" >&2
    fi
    exit 1
  fi

  mv "$tmp" "$pubspec"
}

echo "[whitelabel] Updating flutter_launcher_icons image path"
update_flutter_launcher_icons_image_path "$ICON_TARGET_REL"

echo "[whitelabel] Running flutter pub get"
flutter pub get

echo "[whitelabel] Updating package/bundle identifiers"
dart run package_rename_plus --path="$TMP_CONFIG"

echo "[whitelabel] Configuring Firebase via flutterfire CLI"
flutterfire configure \
  --project="$FIREBASE_PROJECT" \
  --platforms=android \
  --android-package-name="$PACKAGE_NAME" \
  --yes

echo "[whitelabel] Regenerating launcher icons"
flutter pub run flutter_launcher_icons

echo "[whitelabel] Updating Maestro appIds"
if [[ -d maestro ]]; then
  while IFS= read -r -d '' file; do
    if grep -q '^appId:' "$file"; then
      tmp_file="$(mktemp -t maestro_appid)"
      sed -E "s/^appId:[[:space:]]+.*/appId: $PACKAGE_NAME/g" "$file" >"$tmp_file"
      mv "$tmp_file" "$file"
    fi
  done < <(find maestro -type f -name '*.yaml' -print0)
else
  echo "[whitelabel] No maestro directory found; skipping"
fi

echo "[whitelabel] Done"
