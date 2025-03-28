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

# Load sensitive configuration from .env
if [ -f ./terraform/.env ]; then
  source ./terraform/.env
else
  echo "Missing .env file. Exiting."
  exit 1
fi

echo "📡 Deploying Gitea Actions..."

echo "Importing Gitea Actions Token"
kubectl apply -f "$SECRETS_PATH/gitea-actions-token-sealed-secret.yaml"
echo "Gitea Actions Token Imported Successfully!"

# Restore Persistent Volume from backup for Gitea Actions Docker
echo "🔐 Restoring Data Volume..."
base/scripts/longhorn-automation.sh restore gitea-actions-docker --wrapper
echo "✅ Persistent Data Volume Restored!"

# Deploy Gitea Actions
helm dependency update "$HELM_CHARTS_PATH/gitea-actions"
helm upgrade --install gitea-actions "$HELM_CHARTS_PATH/gitea-actions" \
  --namespace gitea \
  --values "$HELM_VALUES_PATH/gitea-actions-values.yaml" \
  --values "$HELM_VALUES_PATH/gitea-actions-docker-restored-volume.yaml" \

echo "✅ Gitea Deployed Successfully!"
