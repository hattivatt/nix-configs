#!/usr/bin/env bash

# Срок жизни (в днях)
days=7

# Директории для очистки
directories=(
  "/home/hattivatt/Downloads/Temporary"
  "/home/hattivatt/Downloads/Telegram Desktop"
)

for dir in "${directories[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Directory '$dir' not found. Skipping."
    continue
  fi

  echo "Processing '$dir' (entries older than $days days):"
  find "$dir" \
    -maxdepth 1 \
    -mtime +"$days" \
    -print0 |
  while IFS= read -r -d '' item; do
    if [[ -e "$item" ]]; then
      trash-put "$item" && echo "Moved to trash: $item"
    else
      echo "Skip (does not exist): $item"
    fi
  done
done

echo "All done."
