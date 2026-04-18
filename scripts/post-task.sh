#!/usr/bin/env bash
set -euo pipefail

# Store agent learnings in mem0 after a multica task completes.
#
# Usage: ./post-task.sh <agent-id> <learning> [extra mem0 flags...]
#
# Example:
#   ./post-task.sh claude-code "OAuth callback URL must match NEXT_PUBLIC_APP_URL env var"
#   ./post-task.sh codex "Frontend uses Zustand for state, not Redux" --user-id ws-myteam

AGENT_ID="${1:-}"
LEARNING="${2:-}"
shift 2 2>/dev/null || true

if [ -z "$AGENT_ID" ] || [ -z "$LEARNING" ]; then
  echo "Usage: ./post-task.sh <agent-id> <learning> [extra mem0 flags...]"
  echo ""
  echo "Examples:"
  echo "  ./post-task.sh claude-code \"OAuth callback must match NEXT_PUBLIC_APP_URL\""
  echo "  ./post-task.sh codex \"Uses pnpm not npm\" --user-id ws-myteam"
  exit 1
fi

RESULT=$(mem0 add "$LEARNING" --agent-id "$AGENT_ID" -o json "$@" 2>&1)

if [ $? -eq 0 ]; then
  echo "Stored memory for agent '$AGENT_ID'."
else
  echo "Failed to store memory: $RESULT" >&2
  exit 1
fi
