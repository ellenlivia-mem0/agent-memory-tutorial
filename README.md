# Adding Memory to Multi-Agent Systems

## mem0-multica

Add persistent memory to multi-agent systems using [Mem0](https://mem0.ai) and [Multica](https://github.com/multica-ai/multica). Each agent (Claude Code, Codex, Gemini) gets its own scoped memory via `--agent-id` — no API key needed, just your email.

## Tutorials

| Platform | Description | Link |
|---|---|---|
| [Multica](https://github.com/multica-ai/multica) | Give each Multica agent (Claude Code, Codex, Gemini) its own scoped memory via `--agent-id` | [Adding Memory to Multi-Agent Systems — mem0-multica/](Adding%20Memory%20to%20Multi-Agent%20Systems%20—%20mem0-multica/) |

## Quick Start

```bash
# Install mem0 CLI
pip install mem0-cli

# Login with email
mem0 init --email you@example.com

# Pick a tutorial
cd "Adding Memory to Multi-Agent Systems — mem0-multica/"
make setup EMAIL=you@example.com
make demo
```

## How It Works

```
┌──────────────────────────────┐
│    Multi-Agent Platform      │
│  (Multica, CrewAI, etc.)     │
│                              │
│  Agent A    Agent B    ...   │
│     │          │             │
│     └────┬─────┘             │
│          │                   │
│     ┌────▼─────┐             │
│     │ Mem0 CLI │             │
│     │ per-agent│             │
│     │  memory  │             │
│     └──────────┘             │
└──────────────────────────────┘
```

Each agent gets its own memory lane via `--agent-id`. Before a task, search for what the agent knows. After a task, store what it learned.

## Adding a New Tutorial

Create a folder for your platform with:
- `README.md` — setup + usage guide
- `Makefile` — `make setup`, `make demo`, `make add`, `make search`
- `scripts/` — automation scripts
- `examples/` — runnable demos

## License

Apache 2.0
