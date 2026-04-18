#!/usr/bin/env bash
set -euo pipefail

# Setup Multica + Mem0 CLI.
# Usage: ./setup-mem0.sh your@email.com [--self-host]

EMAIL="${1:-}"
SELF_HOST="${2:-}"

if [ -z "$EMAIL" ]; then
  echo "Usage: ./setup-mem0.sh your@email.com [--self-host]"
  echo ""
  echo "  --self-host    Install multica server locally (requires Docker)"
  exit 1
fi

# --- Multica ---

echo "==> Installing Multica CLI..."
if command -v brew &>/dev/null; then
  brew install multica-ai/tap/multica
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  echo "On Windows, run in PowerShell:"
  echo "  irm https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.ps1 | iex"
  echo "Then re-run this script."
  exit 1
else
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  [ "$ARCH" = "x86_64" ] && ARCH="amd64"
  [ "$ARCH" = "aarch64" ] && ARCH="arm64"
  echo "Downloading multica for ${OS}/${ARCH}..."
  curl -fsSL "https://github.com/multica-ai/multica/releases/latest/download/multica_${OS}_${ARCH}" -o /usr/local/bin/multica
  chmod +x /usr/local/bin/multica
fi

echo ""
if [ "$SELF_HOST" = "--self-host" ]; then
  echo "==> Setting up self-hosted Multica server..."
  if ! command -v docker &>/dev/null; then
    echo "Error: Docker is required for self-hosting. Install Docker first."
    exit 1
  fi
  curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash -s -- --with-server
  multica setup self-host
  echo "Self-hosted server running at http://localhost:3000 (code: 888888)"
else
  echo "==> Logging into Multica Cloud..."
  multica login
fi

echo ""
echo "==> Starting Multica daemon..."
multica daemon start
multica daemon status

# --- Mem0 ---

echo ""
echo "==> Installing mem0-cli..."
pip install mem0-cli

echo ""
echo "==> Sending verification code to $EMAIL..."
mem0 init --email "$EMAIL"

echo ""
echo "Enter the verification code from your email:"
read -r CODE

echo ""
echo "==> Completing login..."
mem0 init --email "$EMAIL" --code "$CODE" --force

echo ""
echo "==> Verifying Mem0..."
mem0 status

echo ""
echo "=== All set! ==="
echo ""
echo "Multica daemon is running. Mem0 CLI is authenticated."
echo ""
echo "Try it out:"
echo "  mem0 add \"test memory\" --agent-id claude-code"
echo "  mem0 search \"test\" --agent-id claude-code"
