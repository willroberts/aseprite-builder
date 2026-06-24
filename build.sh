#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="aseprite-builder"
IMAGE_TAG_FILE="$SCRIPT_DIR/.image-id"
OUTPUT_DIR="$SCRIPT_DIR/output"
SKIA_CACHE_DIR="$SCRIPT_DIR/.skia-cache"

DOCKERFILE_HASH=$(sha256sum "$SCRIPT_DIR/Dockerfile" | awk '{print $1}')
STORED_HASH=$(cat "$IMAGE_TAG_FILE" 2>/dev/null || true)

if [[ "$DOCKERFILE_HASH" != "$STORED_HASH" ]]; then
    echo "==> Dockerfile changed, rebuilding image..."
    podman build -t "$IMAGE_NAME" "$SCRIPT_DIR"
    echo "$DOCKERFILE_HASH" > "$IMAGE_TAG_FILE"
else
    echo "==> Container image up to date, skipping build."
fi

ASEPRITE_SHA="${ASEPRITE_SHA:-main}"
echo "==> Aseprite commit: $ASEPRITE_SHA"

mkdir -p "$OUTPUT_DIR" "$SKIA_CACHE_DIR"

echo "==> Running build inside container..."
podman run --rm \
    -v "$SKIA_CACHE_DIR:/root/deps:z" \
    -v "$OUTPUT_DIR:/output:z" \
    -e "ASEPRITE_SHA=$ASEPRITE_SHA" \
    "$IMAGE_NAME" \
    bash -c '
        set -euo pipefail

        git clone --recursive https://github.com/aseprite/aseprite.git /tmp/aseprite
        cd /tmp/aseprite
        git checkout "$ASEPRITE_SHA"
        git submodule update --init --recursive

        SKIA_TAG=$(cat laf/misc/skia-tag.txt)
        SKIA_DIR_NAME="skia-$(echo "$SKIA_TAG" | cut -d- -f1)"
        mkdir -p .build
        echo "user"                      > .build/userkind
        echo "/root/deps/$SKIA_DIR_NAME" > .build/main_skia_dir
        echo "/root/deps/$SKIA_DIR_NAME" > .build/HEAD_skia_dir

        sed -i "s/--ssl-revoke-best-effort //" build.sh  # Not supported on Linux.

        ./build.sh --auto --norun

        cp -r build/bin /output/bin
        cp -r build/lib /output/lib 2>/dev/null || true
        echo "==> Build complete. Binary at output/bin/aseprite"
    '
