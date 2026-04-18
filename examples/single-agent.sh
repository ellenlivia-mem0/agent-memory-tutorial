#!/usr/bin/env bash
set -euo pipefail

# Example: Single agent (Claude Code) building up memory across tasks.

AGENT="claude-code"

echo "=== Task 1: Agent works on database migration ==="

# Before task — check what the agent knows
echo "Searching memories..."
mem0 search "database migration" --agent-id "$AGENT" -k 3

# (Agent does the task in multica...)

# After task — store what it learned
mem0 add "Database migrations are in server/migrations/. Use make migrate-up to apply. Always test with make migrate-down first." \
  --agent-id "$AGENT"
echo "Stored learning from task 1."

echo ""
echo "=== Task 2: Agent works on another database task ==="

# Before task — now it remembers task 1
echo "Searching memories..."
mem0 search "database schema changes" --agent-id "$AGENT" -k 3

# (Agent does the task in multica...)

# After task — more knowledge accumulated
mem0 add "Schema changes require updating sqlc.yaml and running make sqlc to regenerate Go code." \
  --agent-id "$AGENT"
echo "Stored learning from task 2."

echo ""
echo "=== Task 3: Agent gets a third database task ==="

# Before task — it now has context from both previous tasks
echo "Searching memories..."
mem0 search "database" --agent-id "$AGENT" -k 5

echo ""
echo "The agent now has rich context about database work from its previous tasks."
