#!/bin/bash
set -e

# Config - adjust these paths:
DEVICE_PATH=$(pwd)  # run inside device tree root
PROPRIETARY_LIST="$DEVICE_PATH/proprietary-files.txt"
OUTPUT_PREBUILTS="$DEVICE_PATH/prebuilts"

# Source root: where to extract blobs from
# Could be a mounted device, or your extracted stock dump root folder
# Adjust this accordingly:
STOCK_ROOT="$HOME/dumpyara/working/ums9230_hulk_Natv-user-gms_QOGIRL6_hulk_SIGN"  

echo "[*] Starting extraction..."

mkdir -p "$OUTPUT_PREBUILTS"

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue

  # Line format: [source][:destination]
  src_file=$(echo "$line" | cut -d':' -f1)
  dst_file=$(echo "$line" | cut -d':' -f2)

  # If no destination provided, use source path
  if [ -z "$dst_file" ]; then
    dst_file="$src_file"
  fi

  # Absolute source path (relative to STOCK_ROOT)
  abs_src="$STOCK_ROOT/$src_file"
  if [ ! -f "$abs_src" ]; then
    echo "⚠️ Source file not found: $abs_src"
    continue
  fi

  # Destination inside prebuilts
  abs_dst="$OUTPUT_PREBUILTS/$dst_file"
  dst_dir=$(dirname "$abs_dst")

  mkdir -p "$dst_dir"
  cp -v "$abs_src" "$abs_dst"

done < "$PROPRIETARY_LIST"

echo "✅ Extraction complete. Prebuilts are at: $OUTPUT_PREBUILTS"
