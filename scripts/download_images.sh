#!/usr/bin/env bash
# Downloads general images listed in images/manifest.csv into images/general/
# Usage: bash scripts/download_images.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/images/general"
mkdir -p "$DEST"

while IFS=, read -r name url; do
  [[ -z "${name// }" || "$name" == \#* ]] && continue
  url="${url%$'\r'}"
  if [[ -z "${url// }" ]]; then
    echo "SKIP  $name (no URL in manifest; add one or drop your own image)"; continue
  fi
  if [[ -s "$DEST/$name" ]]; then echo "EXISTS $name"; continue; fi
  if curl -fsSL --retry 2 -o "$DEST/$name" "$url"; then echo "OK    $name"
  else echo "FAIL  $name <- $url"; rm -f "$DEST/$name"; fi
done < "$ROOT/images/manifest.csv"
echo "Done. Images in: $DEST"
