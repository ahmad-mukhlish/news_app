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

cat <<'ASCII'
 __       __  __    __  ______  ________  ________  __         ______   _______   ________  __            ______   __    __
|  \  _  |  \|  \  |  \|      \|        \|        \|  \       /      \ |       \ |        \|  \          /      \ |  \  |  \
| $$ / \ | $$| $$  | $$ \$$$$$$ \$$$$$$$$| $$$$$$$$| $$      |  $$$$$$\| $$$$$$$\| $$$$$$$$| $$         |  $$$$$$\| $$  | $$
| $$/  $\| $$| $$__| $$  | $$     | $$   | $$__    | $$      | $$__| $$| $$__/ $$| $$__    | $$         | $$___\$$| $$__| $$
| $$  $$$\ $$| $$    $$  | $$     | $$   | $$  \   | $$      | $$    $$| $$    $$| $$  \   | $$          \$$    \ | $$    $$
| $$ $$\$$\$$| $$$$$$$$  | $$     | $$   | $$$$$   | $$      | $$$$$$$$| $$$$$$$\| $$$$$   | $$          _\$$$$$$\| $$$$$$$$
| $$$$  \$$$$| $$  | $$ _| $$_    | $$   | $$_____ | $$_____ | $$  | $$| $$__/ $$| $$_____ | $$_____  __|  \__| $$| $$  | $$
| $$$    \$$$| $$  | $$|   $$ \   | $$   | $$     \| $$     \| $$  | $$| $$    $$| $$     \| $$     \|  \\$$    $$| $$  | $$
 \$$      \$$ \$$   \$$ \$$$$$$    \$$    \$$$$$$$$ \$$$$$$$$ \$$   \$$ \$$$$$$$  \$$$$$$$$ \$$$$$$$$ \$$ \$$$$$$  \$$   \$$



ASCII

run_with_spinner() {
  local message="$1"
  shift
  local spinner='|/-\\'
  local i=0

  "$@" &
  local cmd_pid=$!

  while kill -0 "$cmd_pid" 2>/dev/null; do
    printf '\r[whitelabel] %s %s' "$message" "${spinner:i % ${#spinner}:1}"
    sleep 0.2
    ((i++))
  done

  wait "$cmd_pid"
  local status=$?
  if [[ $status -eq 0 ]]; then
    printf '\r[whitelabel] %s...done\n' "$message"
  else
    printf '\r[whitelabel] %s...failed\n' "$message"
  fi
  return $status
}

ENV_FILE="${1:-$PROJECT_ROOT/.env}"
CURRENT_ENV_FILE="$PROJECT_ROOT/.env"
SANITIZED_ENV_FILE="$(mktemp -t whitelabel_env)"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[whitelabel] Env file not found: $ENV_FILE" >&2
  exit 1
fi

python3 - "$ENV_FILE" "$SANITIZED_ENV_FILE" <<'PY'
import pathlib
import sys

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])

def sanitize_line(line: str) -> str:
    stripped = line.rstrip('\n\r')
    if stripped.startswith('APP_ICON_PATH='):
        key, value = stripped.split('=', 1)
        value = value.strip()
        if value and value[0] not in {"'", '"'}:
            return f"{key}=\"{value}\"\n"
        return f"{key}={value}\n"
    if '=' in stripped and '<' in stripped and stripped.split('=', 1)[1].strip() and stripped.split('=', 1)[1].strip()[0] not in {"'", '"'}:
        key, value = stripped.split('=', 1)
        return f"{key}=\"{value}\"\n"
    return stripped + '\n'

with src.open('r') as f_in, dst.open('w') as f_out:
    for line in f_in:
        f_out.write(sanitize_line(line))
PY

ENV_SOURCE_FILE="$SANITIZED_ENV_FILE"
if [[ -f "$CURRENT_ENV_FILE" ]] && cmp -s "$ENV_SOURCE_FILE" "$CURRENT_ENV_FILE"; then
  echo "[whitelabel] Using existing .env as env source"
else
  cp "$ENV_SOURCE_FILE" "$CURRENT_ENV_FILE"
  echo "[whitelabel] Copied $ENV_FILE => .env"
fi

set -a
# shellcheck disable=SC1090
source "$ENV_SOURCE_FILE"
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
ICON_SOURCE_REL="${ICON_SOURCE_REL//$'\r'/}"
ICON_SOURCE_ABS=""
TMP_ICON=""

ensure_png_file() {
  local file_path="$1"
  python3 - "$file_path" <<'PY'
import os
import sys

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
path = sys.argv[1]

if not os.path.isfile(path):
    print(f"[whitelabel] Icon validation failed; file missing: {path}", file=sys.stderr)
    sys.exit(1)

with open(path, "rb") as f:
    signature = f.read(len(PNG_SIGNATURE))
    if signature != PNG_SIGNATURE:
        print("[whitelabel] Icon must be a PNG file, but detected unknown format", file=sys.stderr)
        sys.exit(2)

    # Basic structural sanity check: ensure file declares an IHDR chunk.
    chunk_header = f.read(8)
    if len(chunk_header) < 8:
        print("[whitelabel] Icon PNG header is truncated", file=sys.stderr)
        sys.exit(2)

    chunk_length = int.from_bytes(chunk_header[:4], "big", signed=False)
    chunk_type = chunk_header[4:]
    if chunk_type != b"IHDR" or chunk_length != 13:
        print("[whitelabel] Icon PNG header is malformed", file=sys.stderr)
        sys.exit(2)
PY
}

if [[ "$ICON_SOURCE_REL" =~ ^https?:// ]]; then
  echo "[whitelabel] Downloading icon from $ICON_SOURCE_REL"
  TMP_ICON="$(mktemp -t whitelabel_icon)"
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$ICON_SOURCE_REL" -o "$TMP_ICON"; then
      echo "[whitelabel] Failed downloading icon via curl" >&2
      exit 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -q -O "$TMP_ICON" "$ICON_SOURCE_REL"; then
      echo "[whitelabel] Failed downloading icon via wget" >&2
      exit 1
    fi
  else
    echo "[whitelabel] Neither curl nor wget available to download icon" >&2
    exit 1
  fi
  ICON_SOURCE_ABS="$TMP_ICON"
else
  ICON_SOURCE_ABS="$ICON_SOURCE_REL"
  if [[ ! "$ICON_SOURCE_ABS" = /* ]]; then
    ICON_SOURCE_ABS="$PROJECT_ROOT/$ICON_SOURCE_ABS"
  fi
fi

if [[ ! -f "$ICON_SOURCE_ABS" ]]; then
  echo "[whitelabel] Icon not found. Provide APP_ICON_PATH to an existing file, remote URL, or place it at $ICON_TARGET_REL" >&2
  exit 1
fi

ensure_png_file "$ICON_SOURCE_ABS"

if [[ "$ICON_SOURCE_ABS" != "$ICON_TARGET_ABS" ]]; then
  mkdir -p "$(dirname "$ICON_TARGET_ABS")"
  cp "$ICON_SOURCE_ABS" "$ICON_TARGET_ABS"
fi

ensure_png_file "$ICON_TARGET_ABS"

echo "[whitelabel] Using env file: $ENV_FILE"
echo "[whitelabel] App name........: $APP_NAME"
echo "[whitelabel] Package name....: $PACKAGE_NAME"
echo "[whitelabel] Icon path.......: $ICON_TARGET_REL"
echo "[whitelabel] Firebase project.................: $FIREBASE_PROJECT"

TMP_CONFIG="$(mktemp -t package_rename_config)"
cleanup() {
  rm -f "$TMP_CONFIG"
  rm -f "$SANITIZED_ENV_FILE"
  if [[ -n "$TMP_ICON" ]]; then
    rm -f "$TMP_ICON"
  fi
}
trap cleanup EXIT

cat >"$TMP_CONFIG" <<EOF
package_rename_config:
  android:
    app_name: "$APP_NAME"
    package_name: "$PACKAGE_NAME"
EOF

APK_OUTPUT_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"

run_flutter_with_env_defines() {
  local device_id="${FLUTTER_RUN_DEVICE_ID:-}"
  if [[ -z "$device_id" ]]; then
    echo "[whitelabel] Skipping flutter run (set FLUTTER_RUN_DEVICE_ID to enable)"
    return
  fi

  run_with_spinner "Running flutter run on $device_id" \
    bash -c "printf 'q\n' | flutter run --dart-define-from-file='$ENV_SOURCE_FILE' -d '$device_id' --debug"
}

build_debug_apk() {
  run_with_spinner "Building debug APK" \
    flutter build apk --debug --dart-define-from-file="$ENV_SOURCE_FILE"

  if [[ ! -f "$APK_OUTPUT_PATH" ]]; then
    echo "[whitelabel] APK not found at $APK_OUTPUT_PATH" >&2
    exit 1
  fi
}

dropbox_upload_file() {
  local local_path="$1"
  if [[ -z "${DROPBOX_API_KEY:-}" ]]; then
    echo "[whitelabel] DROPBOX_API_KEY not configured; skipping Dropbox upload"
    return
  fi

  if [[ ! -f "$local_path" ]]; then
    echo "[whitelabel] Dropbox upload skipped; file not found: $local_path" >&2
    return
  fi

  local remote_path="${DROPBOX_UPLOAD_PATH:-/whitelabel/app-debug.apk}"
  local api_arg
  api_arg=$(python3 - "$remote_path" <<'PY'
import json
import sys

remote = sys.argv[1]
print(json.dumps({
    "path": remote,
    "mode": "overwrite",
    "autorename": False,
}))
PY
)

  run_with_spinner "Uploading APK to Dropbox ($remote_path)" \
    curl -sS -X POST https://content.dropboxapi.com/2/files/upload \
      --header "Authorization: Bearer $DROPBOX_API_KEY" \
      --header "Dropbox-API-Arg: $api_arg" \
      --header "Content-Type: application/octet-stream" \
      --data-binary "@$local_path"

  local share_payload
  share_payload=$(python3 - "$remote_path" <<'PY'
import json
import sys

remote = sys.argv[1]
print(json.dumps({
    "path": remote,
    "settings": {"requested_visibility": "public"}
}))
PY
)

  local share_response
  share_response=$(curl -sS -X POST https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings \
    --header "Authorization: Bearer $DROPBOX_API_KEY" \
    --header "Content-Type: application/json" \
    --data "$share_payload")

  local share_url
  share_url=$(python3 - "$share_response" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print("")
    sys.exit(0)

if isinstance(data, dict) and data.get('url'):
    print(data['url'])
else:
    print("")
PY
)

  local share_error_tag
  share_error_tag=$(python3 - "$share_response" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print("")
    sys.exit(0)

error = data.get('error')
if isinstance(error, dict):
    print(error.get('.tag', ''))
else:
    print('')
PY
)

  local final_share_url=""
  if [[ -n "$share_url" ]]; then
    final_share_url="${share_url/&dl=0/&dl=1}"
    echo "[whitelabel] Dropbox shared link: $final_share_url"
  elif [[ "$share_error_tag" == "shared_link_already_exists" ]]; then
    local list_payload existing_response existing_url
    list_payload=$(python3 - "$remote_path" <<'PY'
import json
import sys

remote = sys.argv[1]
print(json.dumps({
    "path": remote,
    "direct_only": True
}))
PY
)

    existing_response=$(curl -sS -X POST https://api.dropboxapi.com/2/sharing/list_shared_links \
      --header "Authorization: Bearer $DROPBOX_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$list_payload")

    existing_url=$(python3 - "$existing_response" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print("")
    sys.exit(0)

links = data.get('links') or []
for link in links:
    url = link.get('url')
    if url:
        print(url)
        break
else:
    print("")
PY
)

    if [[ -n "$existing_url" ]]; then
      final_share_url="${existing_url/&dl=0/&dl=1}"
      echo "[whitelabel] Dropbox shared link: $final_share_url"
    else
      echo "[whitelabel] Dropbox share response: $share_response"
      echo "[whitelabel] Dropbox existing-link lookup response: $existing_response"
    fi
  else
    echo "[whitelabel] Dropbox share response: $share_response"
  fi

  if [[ -n "$final_share_url" ]]; then
    print_whatsapp_share_link "$final_share_url"
  fi
}

print_whatsapp_share_link() {
  local public_url="$1"
  if [[ -z "${WHITELABEL_WA_NUMBER:-}" ]]; then
    return
  fi

  local trimmed_number="${WHITELABEL_WA_NUMBER//[[:space:]]/}"
  trimmed_number="${trimmed_number#+}"
  if [[ -z "$trimmed_number" ]]; then
    return
  fi

  local wa_link
  wa_link=$(python3 - "$trimmed_number" "$APP_NAME" "$public_url" <<'PY'
import sys
import urllib.parse

number = sys.argv[1]
app_name = sys.argv[2]
share_url = sys.argv[3]

message = f"Download the APK {app_name}\nLink : {share_url}"
encoded_message = urllib.parse.quote(message, safe="")
print(f"https://wa.me/{number}?text={encoded_message}")
PY
)

  if [[ -n "$wa_link" ]]; then
    echo "[whitelabel] WhatsApp share link: $wa_link"
  fi
}

sync_app_config_defaults() {
  local app_config="$PROJECT_ROOT/lib/app/config/app_config.dart"
  if [[ ! -f "$app_config" ]]; then
    echo "[whitelabel] App config file not found at $app_config; skipping"
    return
  fi

  python3 - "$app_config" <<'PY'
import os
import pathlib
import re
import sys

app_config = pathlib.Path(sys.argv[1])
text = app_config.read_text()
mappings = [
    "APP_NAME",
    "PRIMARY_COLOR",
    "SECONDARY_COLOR",
    "NEWS_API_KEY",
    "NEWS_API_BASE_URL",
    "PACKAGE_NAME",
    "SEARCH_PAGE_LOTTIE_ANIMATION",
    "EMPTY_NEWS_ANIMATION",
    "ERROR_ANIMATION",
    "COMING_SOON_ANIMATION",
    "NOTIFICATION_CHANNEL_ID",
    "NOTIFICATION_CHANNEL_NAME",
    "NOTIFICATION_ICON",
]

updated_keys = []

for env_key in mappings:
    value = os.environ.get(env_key)
    if not value:
        continue

    escaped = value.replace("\\", "\\\\").replace("'", "\\'")
    pattern = re.compile(
        r"(String\.fromEnvironment\(\s*'{key}',\s*defaultValue:\s*)'[^']*'".format(
            key=re.escape(env_key)
        ),
        re.MULTILINE,
    )

    def repl(match, *, replacement=escaped):
        return f"{match.group(1)}'{replacement}'"

    new_text, count = pattern.subn(repl, text, count=1)
    if count:
        text = new_text
        updated_keys.append(env_key)

if updated_keys:
    app_config.write_text(text)
    for key in updated_keys:
        print(f"[whitelabel] AppConfig default updated: {key}")
else:
    print("[whitelabel] No AppConfig defaults updated (missing env vars?)")
PY
}

echo "[whitelabel] Syncing AppConfig default values"
sync_app_config_defaults

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

run_with_spinner "Running flutter pub get" flutter pub get

run_with_spinner "Updating package/bundle identifiers" \
  dart run package_rename_plus --path="$TMP_CONFIG"

run_with_spinner "Configuring Firebase via flutterfire CLI" \
  flutterfire configure \
    --project="$FIREBASE_PROJECT" \
    --out="$PROJECT_ROOT/lib/firebase_options.dart" \
    --platforms=android \
    --android-package-name="$PACKAGE_NAME" \
    --yes

run_with_spinner "Regenerating launcher icons" \
  flutter pub run flutter_launcher_icons

run_flutter_with_env_defines

build_debug_apk

dropbox_upload_file "$APK_OUTPUT_PATH"

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
