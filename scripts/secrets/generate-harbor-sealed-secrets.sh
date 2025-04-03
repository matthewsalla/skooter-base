#!/bin/bash
# apply-sealed-secrets.sh
# This script creates one "master" sealed secret that contains:
#   1) Harbor admin password (key=HARBOR_ADMIN_PASSWORD)
#   2) Global encryption secret (key=secretKey)
#   3) Registry credentials password (key=REGISTRY_PASSWD)
#
# The Harbor chart can reference these via:
#   existingSecretAdminPassword, existingSecretSecretKey,
#   registry.credentials.existingSecret, etc.

# 1. Function to generate a random alphanumeric string of a given length.
generate_random() {
  local length=$1
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
}

# 2. Define output file for secret definitions.
output_file="./secrets/helm_credentials.txt"
mkdir -p "$(dirname "$output_file")"
> "$output_file"  # Clear the file if it exists

# 3. Generate random values for each credential.
admin_password=$(generate_random 16)           # Replaces "Harbor12345"
encryption_secret=$(generate_random 16)          # Replaces "not-a-secure-key"
registry_password=$(generate_random 16)          # Replaces "harbor_registry_password"

# 4. Write one line that includes all keys in the single secret "harbor-master-secret".
# Format: <namespace> <secret-name> key1=value1 key2=value2 ...
echo "harbor harbor-master-secret HARBOR_ADMIN_PASSWORD=${admin_password} secretKey=${encryption_secret} REGISTRY_PASSWD=${registry_password}" >> "$output_file"

# 5. Convert the generated secret into a SealedSecret.
echo "🔐 Generating sealed secret for Harbor..."
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines.
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue
  # Split the line into separate arguments.
  set -- $line
  bash base/scripts/generate-sealed-secret.sh "$@"
done < "$output_file"

echo "✅ Harbor sealed secrets applied! Now update the chart values to reference them."
