# Mem0 + Multica: Persistent Memory for AI Agents

Give your [Multica](https://github.com/multica-ai/multica) agents persistent memory using the [Mem0 CLI](https://pypi.org/project/mem0-cli/). Each agent (Claude Code, Codex, Gemini, etc.) gets its own scoped memory via `--agent-id` — so Claude Code remembers what Claude Code learned, and Codex remembers what Codex learned.

No API key needed. Just your email.

## How It Works

```
┌──────────────────────────────────────────────────┐
│                   Multica                         │
│                                                   │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐    │
│  │Claude Code│  │  Codex    │  │  Gemini   │    │
│  │agent-id:  │  │agent-id:  │  │agent-id:  │    │
│  │claude-code│  │codex      │  │gemini     │    │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘    │
│        │              │              │            │
│        └──────────┬───┴──────────────┘            │
│                   │                               │
│              ┌────▼────┐                          │
│              │ Mem0 CLI│                          │
│              │(per agent│                         │
│              │ memory)  │                         │
│              └─────────┘                          │
└──────────────────────────────────────────────────┘
```

Before a task: search mem0 for what this agent knows.
After a task: store what the agent learned.

Each agent's memories are isolated by `--agent-id`.

---

## Setup

### 1. Install Multica

**Option A: Cloud (fastest)**

Sign up at [multica.ai](https://multica.ai) and install the CLI:

```bash
# macOS / Linux
brew install multica-ai/tap/multica

# Windows (PowerShell)
irm https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.ps1 | iex
```

Then log in and start the daemon:

```bash
multica login          # opens browser for auth
multica daemon start   # starts the local agent daemon
multica daemon status  # verify it's running
```

**Option B: Self-hosted**

Requires Docker and Docker Compose.

```bash
# One-liner install
curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash -s -- --with-server
multica setup self-host
```

Or manually:

```bash
git clone https://github.com/multica-ai/multica.git
cd multica
make selfhost          # starts server on localhost:3000, API on localhost:8080
multica setup self-host
multica daemon start
```

Default login verification code for self-hosted: `888888`

### 2. Install Mem0 CLI

```bash
pip install mem0-cli
```

### 3. Login to Mem0 with email (no API key)

```bash
mem0 init --email you@example.com
# check your email for a verification code
mem0 init --email you@example.com --code 123456
```

### 4. Verify both are running

```bash
multica version        # check multica
multica daemon status  # check daemon is up
mem0 status            # check mem0
```

---

## Usage with Multica Agents

### Storing memories per agent

Every multica agent gets its own `--agent-id`. When an agent finishes a task, store what it learned:

```bash
# Claude Code finished a task and learned something
mem0 add "This repo uses sqlc for database queries. Always regenerate with make sqlc after schema changes." \
  --agent-id claude-code

# Codex learned something different
mem0 add "The frontend uses pnpm not npm. Run pnpm install, not npm install." \
  --agent-id codex

# Gemini learned repo conventions
mem0 add "All API handlers must include workspace authorization middleware." \
  --agent-id gemini
```

### Searching memories before a task

Before dispatching a task, search for what this specific agent remembers:

```bash
# What does Claude Code know about database work?
mem0 search "database migrations" --agent-id claude-code -o json

# What does Codex know about frontend setup?
mem0 search "frontend dependencies" --agent-id codex -o json

# What does Gemini know about API patterns?
mem0 search "API handler conventions" --agent-id gemini -o json
```

### Listing all memories for an agent

```bash
mem0 list --agent-id claude-code -o json
mem0 list --agent-id codex -o json
```

---

## Scoping Strategy

Use `--agent-id` to isolate memories per multica agent. Optionally combine with other scopes:

| Flag | Use for | Example |
|---|---|---|
| `--agent-id` | Which multica agent | `claude-code`, `codex`, `gemini` |
| `--user-id` | Which multica workspace | `ws-myteam` |
| `--app-id` | Which multica project | `proj-backend` |
| `--run-id` | Which specific task/issue | `issue-142` |

**Examples:**

```bash
# Memory scoped to agent + workspace
mem0 add "Use dark mode in all UI components" \
  --agent-id claude-code --user-id ws-myteam

# Memory scoped to agent + project
mem0 add "This service uses gRPC, not REST" \
  --agent-id codex --app-id proj-payments

# Search within a specific workspace
mem0 search "deployment process" \
  --agent-id claude-code --user-id ws-myteam -o json
```

---

## Automation Scripts

### Inject memory before task dispatch

Use `scripts/pre-task.sh` to automatically search mem0 and inject context before an agent starts work:

```bash
./scripts/pre-task.sh claude-code "Fix the login redirect bug"
```

This outputs relevant memories as context the agent can use.

### Store learnings after task completion

Use `scripts/post-task.sh` to store agent output as memory:

```bash
./scripts/post-task.sh claude-code "Discovered that login redirect fails because OAuth callback URL is hardcoded to localhost in dev config"
```

### Full lifecycle

```bash
# 1. Before: get context for the agent
CONTEXT=$(./scripts/pre-task.sh claude-code "Fix payment webhook retry logic")

# 2. Agent does its work in multica with the extra context...

# 3. After: store what the agent learned
./scripts/post-task.sh claude-code "Payment webhooks need idempotency keys. Added dedup check in webhook handler."
```

---

## Example: Multi-Agent Workflow

A real scenario with multiple multica agents sharing knowledge through their own memory lanes:

```bash
# Assign backend fix to Claude Code
# First, check what Claude Code remembers about this area
mem0 search "webhook handler error handling" --agent-id claude-code -o json -k 3

# Claude Code completes the task
mem0 add "Webhook handler at server/internal/handler/webhook.go retries 3 times with exponential backoff. Idempotency key stored in webhooks_processed table." \
  --agent-id claude-code

# Now assign frontend update to Codex
# Codex has its own memory — doesn't see Claude Code's memories
mem0 search "webhook status UI" --agent-id codex -o json -k 3

# Codex completes its task
mem0 add "Webhook status displayed in settings page at apps/web/src/app/settings/webhooks/page.tsx. Uses SWR for polling." \
  --agent-id codex
```

Each agent builds up its own knowledge base over time. The more tasks they complete, the more context they have for future work.

---

## Native Multica Integration (Fork)

We also have a fork of multica with mem0 built directly into the daemon — agents automatically search and store memories without any scripts:

**Fork:** [ellenlivia-mem0/multica (feat/mem0-integration)](https://github.com/ellenlivia-mem0/multica/tree/feat/mem0-integration)

### What the fork does

The integration adds a `server/internal/mem0/` package that wraps the mem0 CLI and hooks into two points in the daemon's task lifecycle:

| Hook | File | What happens |
|---|---|---|
| Before task dispatch | `daemon.go` → `runTask()` | Searches mem0 for relevant memories, prepends them to the agent prompt |
| After task completion | `daemon.go` → `handleTask()` | Stores the agent's output as a memory for future tasks |

Memories are scoped by `--agent-id` (the agent provider, e.g. `claude-code`) and `--user-id` (the workspace ID).

### Running the fork

```bash
# Clone the fork
git clone https://github.com/ellenlivia-mem0/multica.git
cd multica
git checkout feat/mem0-integration

# Install and authenticate mem0 CLI on the machine running the daemon
pip install mem0-cli
mem0 init --email you@example.com --force

# Start multica as normal
make dev
```

The daemon will automatically use mem0 if the CLI is installed and authenticated. If not, it works exactly like upstream multica — mem0 is entirely optional.

### Key files changed

- `server/internal/mem0/mem0.go` — CLI wrapper (Search, Add, FormatForPrompt)
- `server/internal/daemon/prompt.go` — BuildPrompt accepts mem0 context
- `server/internal/daemon/daemon.go` — search before dispatch, store after completion

---

## File Structure

```
agent-memory-tutorial/
└── Adding Memory to Multi-Agent Systems — mem0-multica/
    ├── README.md                   # this file
    ├── Makefile                    # make setup, make demo, etc.
    ├── scripts/
    │   ├── setup-mem0.sh          # install + email login
    │   ├── pre-task.sh            # search memories before task
    │   └── post-task.sh           # store memories after task
    └── examples/
        ├── single-agent.sh        # basic single agent example
        └── multi-agent.sh         # multi-agent workflow example
```

## License

Apache 2.0
