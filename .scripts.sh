#!/bin/bash

# -------------------------------------------------
# Variables
# -------------------------------------------------

set -euo pipefail
KEYMAP_DEFAULT="default"
KEYBOARD_DEFAULT="default"
ENV_VAR_NAME="QMK_KEYBOARD_DEFAULT"
RC_FILE="$HOME/Projects/dotfiles/.zshrc"

# -------------------------------------------------

OS=""
RP_VOLUME=""
FIRMWARE_FILE_SIZE=0
NEW_KEYBOARD="${3:-./test}"
KEYMAP_SOURCE="${3:-./$KEYMAP_DEFAULT}"
KEYMAP="$(basename "$KEYMAP_SOURCE")"

# -------------------------------------------------
# Functions
# -------------------------------------------------

clone() {
  echo "Cloning keyboard files..."
  if [ ! -e "$KEYBOARD_SOURCE" ]; then
    echo "Error: Clone source does not exist: $KEYBOARD_SOURCE"
    echo ""
    exit 1
  fi

  if [ -e "$NEW_KEYBOARD" ]; then
    echo "Error: Clone target already exist: $NEW_KEYBOARD"
    echo ""
    exit 1
  fi

  cp -R "$KEYBOARD_SOURCE" "$NEW_KEYBOARD"
  echo "Cloning complete."
  echo ""
}

compile() {
  echo "Compiling firmware..."
  if [ ! -d "$QMK_KEYBOARD_TARGET" ]; then
    echo "Error: Keyboard target does not exist: $QMK_KEYBOARD_TARGET"
    echo ""
    exit 1
  fi

  qmk compile -e CONVERT_TO=rp2040_ce -kb charlestheix -km default
  if [ ! -f "$QMK_FIRMWARE_TARGET" ]; then
    echo "Error: Firmware not found: $QMK_FIRMWARE_TARGET"
    echo ""
    exit 1
  fi

  echo "Moving firmware to $FIRMWARE_TARGET"
  mv -f "$QMK_FIRMWARE_TARGET" "$FIRMWARE_TARGET"
  echo "Compile complete."
  echo ""

  get_file_size_info
}

detect_os() {
  UNAME_OUT="$(uname -s)"
  case "${UNAME_OUT}" in
    Darwin)
      OS="macOS"
      RP_VOLUME="/Volumes/RPI-RP2"
      ;;
    Linux)
      OS="Linux"
      RP_VOLUME="/media/$USER/RPI-RP2"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      OS="Windows (Git Bash)"
      for DRIVE in {d..z}; do
        if [ -d "/$DRIVE/RPI-RP2" ]; then
          RP_VOLUME="/$DRIVE/RPI-RP2"
          break
        elif [ -d "/mnt/$DRIVE/RPI-RP2" ]; then
          RP_VOLUME="/mnt/$DRIVE/RPI-RP2"
          break
        fi
      done

      if [ -z "$RP_VOLUME" ]; then
        RP_VOLUME="/r/RPI-RP2"
      fi
      ;;
    *)
      echo "Unsupported OS: $UNAME_OUT"
      echo ""
      exit 1
      ;;
  esac

  echo "Detected OS: $OS"
  echo "RP2040 volume path: $RP_VOLUME"
  echo ""
}

generate_logos() {
  FILE="./.python/generate_logos.py"
  if [ ! -f "$FILE" ]; then
    echo "Error: Python file not found: $FILE"
    echo ""
    exit 1
  fi
  python3 $FILE
}

generate_bmp_from_array() {
  FILE="./.python/generate_bmp_from_array.py"
  if [ ! -f "$FILE" ]; then
    echo "Error: Python file not found: $FILE"
    echo ""
    exit 1
  fi
  python3 $FILE
}

get_file_size_info() {
  if [[ ! -f "$FIRMWARE_TARGET" ]]; then
    echo "Error: File not found: $FIRMWARE_TARGET" >&2
    echo ''
    exit 1
  fi
  
  local size_bytes=$(stat -f%z "$FIRMWARE_TARGET")

  local limit_kb=190
  local size_kb=$((size_bytes / 1024))
  local remaining=$((limit_kb - size_kb))

  echo "File size: ${size_kb}KB"
  if (( remaining >= 0 )); then
    echo "Remaining space: ${remaining}KB"
  else
    echo "Exceeded limit by $((-remaining))KB"
  fi
  echo ''
}

flash() {
  echo "Flashing firmware..."
  if [ ! -f "$FIRMWARE_TARGET" ]; then
    echo "Error: Firmware file not found: $FIRMWARE_TARGET"
    echo ""
    exit 1
  fi

  if [ ! -d "$RP_VOLUME" ]; then
    echo "Error: RP2040 drive not found at $RP_VOLUME. Is the keyboard in bootloader mode?"
    echo ""
    exit 1
  fi

  echo "Copying firmware to $RP_VOLUME"
  cp "$FIRMWARE_TARGET" "$RP_VOLUME"
  echo "Flash complete. Your keyboard should reboot automatically."
  echo ""
}

help() {
  echo "Usage: $0 [sync|compile|flash|all|all_no_logo|generate_logos|generate_bmp_from_array|clone|update_keyboard_default|remove_keyboard_default]"
  echo ""
  exit 1
}

remove_keyboard_default() {
  if grep -q "^export ${ENV_VAR_NAME}=" "$RC_FILE"; then
    TMP_FILE=$(mktemp)
    grep -v "^export ${ENV_VAR_NAME}=" "$RC_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$RC_FILE"
    echo "Removed ${ENV_VAR_NAME} from $RC_FILE"
  else
    echo "${ENV_VAR_NAME} not found in $RC_FILE"
  fi

  echo ""
  echo "Please re-source your file:"
  echo "source $RC_FILE"
  echo ""
  exit 1;
}

sync() {
  echo "Syncing keyboard files..."
  if [ ! -e "$KEYBOARD_SOURCE" ]; then
    echo "Error: Source path does not exist: $KEYBOARD_SOURCE"
    echo ""
    exit 1
  fi

  if [ -e "$QMK_KEYBOARD_TARGET" ]; then
    echo "Removing existing target: $QMK_KEYBOARD_TARGET"
    rm -rf "$QMK_KEYBOARD_TARGET"
  fi

  echo "Copying $KEYBOARD_SOURCE → $QMK_KEYBOARD_TARGET"
  cp -R "$KEYBOARD_SOURCE" "$QMK_KEYBOARD_TARGET"
  echo "Sync complete."
  echo ""
}

update_keyboard_default() {
  read -p "Enter value (current default is '$KEYBOARD_DEFAULT'): " input
  if [ -z "$input" ]; then
    input="$KEYBOARD_DEFAULT"
  fi

  VAR_VALUE="$input"

  if grep -q "^export ${ENV_VAR_NAME}=" "$RC_FILE"; then
    if [[ "$OS" == "macOS" ]]; then
      sed -i '' "s/^export ${ENV_VAR_NAME}=.*/export ${ENV_VAR_NAME}=\"${VAR_VALUE}\"/" "$RC_FILE"
    else
      sed -i "s/^export ${ENV_VAR_NAME}=.*/export ${ENV_VAR_NAME}=\"${VAR_VALUE}\"/" "$RC_FILE"
    fi
    echo "Updated ${ENV_VAR_NAME} in $RC_FILE"
  else
    echo "export ${ENV_VAR_NAME}=\"${VAR_VALUE}\"" >> "$RC_FILE"
    echo "Added ${ENV_VAR_NAME} to $RC_FILE"
  fi

  echo ""
  echo "Please re-source your file:"
  echo "source $RC_FILE"
  echo ""
  exit 1;
}

# -------------------------------------------------
# On Execution
# -------------------------------------------------

detect_os
if [ -z "${QMK_KEYBOARD_DEFAULT+x}" ]; then
  update_keyboard_default
fi

KEYBOARD_DEFAULT="$QMK_KEYBOARD_DEFAULT"
KEYBOARD_SOURCE="${2:-./$KEYBOARD_DEFAULT}"
KEYBOARD="$(basename "$KEYBOARD_SOURCE")"
FIRMWARE_TARGET="./$KEYBOARD/firmware.uf2"
QMK_KEYBOARD_TARGET="$HOME/qmk_firmware/keyboards/$KEYBOARD"
QMK_FIRMWARE_TARGET="$HOME/qmk_firmware/.build/${KEYBOARD}_${KEYMAP}_rp2040_ce.uf2"
if [ $# -lt 1 ]; then
  help
fi

case "$1" in
  sync) sync ;;
  clone) clone ;;
  flash) flash ;;
  compile) compile ;;
  generate_logos) generate_logos ;;
  generate_bmp_from_array) generate_bmp_from_array ;;
  update_keyboard_default) update_keyboard_default ;;
  remove_keyboard_default) remove_keyboard_default ;;
  all_no_logo)
    sync
    compile
    flash
    ;;
  all)
    generate_logos
    sync
    compile
    flash
    ;;
  *) help ;;
esac
