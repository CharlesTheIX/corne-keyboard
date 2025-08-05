#!/bin/bash

set -euo pipefail

SOURCE="./charlestheix"
RP_VOLUME="/Volumes/RPI-RP2"
OUTPUT_DEST="./charlestheix/firmware.uf2"
TARGET="$HOME/qmk_firmware/keyboards/charlestheix"
BUILD_OUTPUT="$HOME/qmk_firmware/.build/charlestheix_default_rp2040_ce.uf2"

sync() {
    echo "🔄 Syncing keyboard files..."
    if [ ! -e "$SOURCE" ]; then
        echo "❌ Error: Source path does not exist: $SOURCE"
        echo ""
        exit 1
    fi

    if [ -e "$TARGET" ]; then
        echo "🧹 Removing existing target: $TARGET"
        rm -rf "$TARGET"
    fi

    echo "📂 Copying $SOURCE → $TARGET"
    cp -R "$SOURCE" "$TARGET"
    echo "✅ Sync complete."
    echo ""
}

compile() {
    echo "🛠 Compiling firmware..."
    if [ ! -d "$TARGET" ]; then
        echo "❌ Error: Keyboard target does not exist: $TARGET"
        echo ""
        exit 1
    fi

    qmk compile -e CONVERT_TO=rp2040_ce -kb charlestheix -km default
    if [ ! -f "$BUILD_OUTPUT" ]; then
        echo "❌ Error: Firmware not found: $BUILD_OUTPUT"
        echo ""
        exit 1
    fi

    echo "📦 Moving firmware to $OUTPUT_DEST"
    mv -f "$BUILD_OUTPUT" "$OUTPUT_DEST"
    echo "✅ Compile complete."
    echo ""
}

flash() {
    echo "🚀 Flashing firmware..."
    if [ ! -f "$OUTPUT_DEST" ]; then
        echo "❌ Error: Firmware file not found: $OUTPUT_DEST"
        echo ""
        exit 1
    fi

    if [ ! -d "$RP_VOLUME" ]; then
        echo "❌ Error: RP2040 drive not found at $RP_VOLUME. Is the keyboard in bootloader mode?"
        echo ""
        exit 1
    fi

    echo "📁 Copying firmware to $RP_VOLUME"
    cp "$OUTPUT_DEST" "$RP_VOLUME"
    echo "✅ Flash complete. Your keyboard should reboot automatically."
    echo ""
}

help() {
    echo "Usage: $0 [sync|compile|flash|all]"
    echo ""
    exit 1
}

if [ $# -lt 1 ]; then
    help
fi

case "$1" in
    sync)    sync ;;
    compile) compile ;;
    flash)   flash ;;
    all)
        sync
        compile
        flash
        ;;
    *) help ;;
esac
