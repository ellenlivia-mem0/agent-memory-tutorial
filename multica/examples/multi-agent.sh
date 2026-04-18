#!/usr/bin/env bash
set -euo pipefail

# Example: Multiple multica agents, each with isolated mem0 memories.
# Claude Code handles backend, Codex handles frontend, Gemini handles docs.

echo "=== Setting up agent memories ==="
echo ""

# Claude Code learns backend patterns
mem0 add "Go backend uses Chi router. All handlers are in server/internal/handler/." \
  --agent-id claude-code
mem0 add "Database queries use sqlc. Generated code is in server/internal/storage/." \
  --agent-id claude-code
echo "Claude Code: 2 memories stored"

# Codex learns frontend patterns
mem0 add "Frontend is Next.js 16 with App Router. Pages are in apps/web/src/app/." \
  --agent-id codex
mem0 add "UI components use shadcn/ui. Install with pnpm dlx shadcn-ui@latest add <component>." \
  --agent-id codex
echo "Codex: 2 memories stored"

# Gemini learns docs patterns
mem0 add "Documentation lives in docs/ folder. Uses MDX format." \
  --agent-id gemini
mem0 add "API docs are auto-generated from handler comments. Run make docs to rebuild." \
  --agent-id gemini
echo "Gemini: 2 memories stored"

echo ""
echo "=== Each agent only sees its own memories ==="
echo ""

echo "--- Claude Code searching 'router' ---"
mem0 search "router" --agent-id claude-code -k 3
echo ""

echo "--- Codex searching 'router' ---"
mem0 search "router" --agent-id codex -k 3
echo ""

echo "--- Gemini searching 'documentation' ---"
mem0 search "documentation" --agent-id gemini -k 3
echo ""

echo "=== Assigning a cross-cutting task ==="
echo ""
echo "New feature: add webhook management page"
echo ""

# Backend context for Claude Code
echo "--- Context for Claude Code (backend) ---"
mem0 search "handler webhook API" --agent-id claude-code -k 3
echo ""

# Frontend context for Codex
echo "--- Context for Codex (frontend) ---"
mem0 search "page UI components" --agent-id codex -k 3
echo ""

# Docs context for Gemini
echo "--- Context for Gemini (docs) ---"
mem0 search "API documentation" --agent-id gemini -k 3
