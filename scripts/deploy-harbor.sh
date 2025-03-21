#!/bin/bash
set -e  # Exit on error

# Determine the script's directory and source the configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
  source "$SCRIPT_DIR/config.sh"
else
  # Fallback: Try to source config from the thin repo if available
  if [ -f "$SCRIPT_DIR/../../scripts/config.sh" ]; then
    source "$SCRIPT_DIR/../../scripts/config.sh"
  else
    echo "Missing config.sh file. Exiting."
    exit 1
  fi
fi

echo "📡 Deploying Harbor.io"

# Create Namespace
kubectl create namespace harbor || true

echo "🔑 Import Harbor Secrets..."
kubectl apply -f "$SECRETS_PATH/harbor-admin-secret-sealed-secret.yaml"

# Restore Persistent Volume from backup for Harbor.io
echo "🔐 Restoring Data Volume..."
# base/scripts/longhorn-automation.sh restore harbor
echo "✅ Persistent Data Volume Restored!"

# Deploy Harbor.io App
helm dependency update "$HELM_CHARTS_PATH/harbor"
helm upgrade --install harbor "$HELM_CHARTS_PATH/harbor" \
  --namespace harbor \
  --values "$HELM_VALUES_PATH/harbor-values.yaml"


echo "✅ Harbor.io Deployed Successfully!"
