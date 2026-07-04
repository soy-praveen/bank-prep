#!/usr/bin/env bash
# Downloads the source books from Google Drive into books/ (git-ignored).
# Requires the Drive folder to be link-shared: Anyone with the link - Viewer.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p books

manifest=scripts/books-manifest.json
count=$(node -e "console.log(require('./$manifest').books.length)")

for i in $(seq 0 $((count - 1))); do
  id=$(node -e "console.log(require('./$manifest').books[$i].id)")
  file=$(node -e "console.log(require('./$manifest').books[$i].file)")
  if [ -s "books/$file" ]; then
    echo "skip   $file (exists)"
    continue
  fi
  echo "fetch  $file"
  # confirm=t skips the "can't scan for viruses" interstitial on larger files
  curl -sL "https://drive.google.com/uc?export=download&id=${id}&confirm=t" -o "books/$file"
  # If we still got an HTML page, the file isn't link-shared
  if head -c 200 "books/$file" | grep -qi '<!doctype html\|<html'; then
    echo "ERROR: got an HTML page instead of the file — is the folder link-shared?" >&2
    rm -f "books/$file"
    exit 1
  fi
done

echo "---"
ls -lh books/
