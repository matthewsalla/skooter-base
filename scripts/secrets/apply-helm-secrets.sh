#!/bin/bash
set -e  # Exit if any command fails

SECRETS_FILE="./secrets/helm_credentials.txt"

if [ ! -f "$SECRETS_FILE" ]; then
  echo "Helm credentials file not found: $SECRETS_FILE"
  exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
  # Skip commented and empty lines
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue
  # Note: Assuming that the contents of each line are properly formatted
  #       to be passed as arguments to generate-sealed-secret.sh.
  bash base/scripts/generate-sealed-secret.sh $line
done < "$SECRETS_FILE"
