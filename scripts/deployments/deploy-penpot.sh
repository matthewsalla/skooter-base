#!/bin/bash
set -e

# ─── 1) Bootstrap ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if   [ -f "$SCRIPT_DIR/config.sh" ]; then
  source "$SCRIPT_DIR/config.sh"
elif [ -f "$SCRIPT_DIR/../../../scripts/config.sh" ]; then
  source "$SCRIPT_DIR/../../../scripts/config.sh"
else
  echo "⚠️  Missing config.sh – cannot continue."
  exit 1
fi

NAMESPACE=penpot
RELEASE=penpot
CHART_PATH="$HELM_CHARTS_PATH/penpot/app"

echo "📡 Deploying Penpot → namespace/$NAMESPACE"

# ─── 2) Namespace ────────────────────────────────────────────────────────────
kubectl create namespace $NAMESPACE 2>/dev/null || true

# ─── 3) Secrets ─────────────────────────────────────────────────────────────
echo "🔑 Applying Penpot secrets…"
# kubectl apply -n $NAMESPACE -f "$SECRETS_PATH/penpot/penpot-secrets.yaml"

# ─── 4) Restore Volumes (optional) ───────────────────────────────────────────
# If you have Longhorn backups for your Penpot data/assets, restore them here:
# echo "🔐 Restoring Penpot assets volume…"
# base/scripts/longhorn-automation.sh restore penpot-assets --wrapper
# echo "✅ Assets restored."

# ─── 5) Choose values file ───────────────────────────────────────────────────
if [[ "$DEPLOYMENT_MODE" == "prod" ]]; then
  VALUES_FILE="$HELM_VALUES_PATH/prod/penpot/penpot-values.yaml"
  echo "🚀 Production mode: using $VALUES_FILE"
else
  VALUES_FILE="$HELM_VALUES_PATH/staging/penpot/penpot-values.yaml"
  echo "⚠️  Staging mode: using $VALUES_FILE"
fi

# ─── 6) Helm deploy ──────────────────────────────────────────────────────────
# ensure the repo is present
helm repo add penpot https://helm.penpot.app 2>/dev/null || true
helm repo update

# build any chart dependencies
helm dependency update "$CHART_PATH"

# upgrade/install in one go, create namespace if missing
helm upgrade --install $RELEASE "$CHART_PATH" \
  --namespace $NAMESPACE \
  --create-namespace \
  --values "$VALUES_FILE" \
  --wait

echo "✅ Penpot deployed successfully in '$NAMESPACE'!"
