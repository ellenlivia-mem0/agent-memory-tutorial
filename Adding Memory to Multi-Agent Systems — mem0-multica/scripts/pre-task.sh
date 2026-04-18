#!/usr/bin/env bash
set -euo pipefail

# Search mem0 for relevant context before dispatching a task to a multica agent.
#
# Usage: ./pre-task.sh <agent-id> <task-description> [--user-id ws-id] [--app-id proj-id]
#
# Example:
#   ./pre-task.sh claude-code "Fix the login redirect bug"
#   ./pre-task.sh codex "Update frontend auth flow" --user-id ws-myteam

AGENT_ID="${1:-}"
QUERY="${2:-}"
shift 2 2>/dev/null || true

if [ -z "$AGENT_ID" ] || [ -z "$QUERY" ]; then
  echo "Usage: ./pre-task.sh <agent-id> <task-description> [extra mem0 flags...]"
  echo ""
  echo "Examples:"
  echo "  ./pre-task.sh claude-code \"Fix the login redirect bug\""
  echo "  ./pre-task.sh codex \"Update auth flow\" --user-id ws-myteam"
  exit 1
fi

RESULTS=$(mem0 search "$QUERY" --agent-id "$AGENT_ID" -o json -k 5 "$@" 2>/dev/null || echo "[]")

# Check if we got any results
if [ "$RESULTS" = "[]" ] || [ -z "$RESULTS" ]; then
  echo "No relevant memories found for agent '$AGENT_ID'."
  exit 0
fi

echo "=== Mem0 Context for $AGENT_ID ==="
echo ""
echo "Relevant memories from previous tasks:"
echo ""
echo "$RESULTS" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    results = data if isinstance(data, list) else data.get('results', data.get('memories', []))
    for i, mem in enumerate(results, 1):
        text = mem.get('memory', mem.get('text', mem.get('content', '')))
        if text:
            print(f'  {i}. {text}')
except:
    print(sys.stdin.read())
"
echo ""
echo "=================================="
