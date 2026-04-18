.PHONY: setup login status demo demo-multi add search list help

EMAIL ?=

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-15s %s\n", $$1, $$2}'

setup: ## Install multica + mem0-cli (run: make setup EMAIL=you@example.com)
	@if [ -z "$(EMAIL)" ]; then echo "Usage: make setup EMAIL=you@example.com"; exit 1; fi
	brew install multica-ai/tap/multica || true
	pip install mem0-cli
	@echo ""
	@echo "==> Logging into Mem0 as $(EMAIL)..."
	mem0 init --email $(EMAIL)

login: ## Login to multica cloud
	multica login
	multica daemon start

selfhost: ## Self-host multica (requires Docker)
	curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash -s -- --with-server
	multica setup self-host
	multica daemon start

status: ## Check multica + mem0 status
	@echo "==> Multica"
	@multica version 2>/dev/null || echo "  not installed"
	@multica daemon status 2>/dev/null || echo "  daemon not running"
	@echo ""
	@echo "==> Mem0"
	@mem0 status 2>/dev/null || echo "  not installed"

demo: ## Run single-agent memory demo
	./examples/single-agent.sh

demo-multi: ## Run multi-agent memory demo
	./examples/multi-agent.sh

AGENT ?= claude-code

add: ## Store a memory (run: make add AGENT=claude-code MSG="learned something")
	@if [ -z "$(MSG)" ]; then echo "Usage: make add AGENT=claude-code MSG=\"your memory\""; exit 1; fi
	mem0 add "$(MSG)" --agent-id $(AGENT)

search: ## Search memories (run: make search AGENT=claude-code Q="query")
	@if [ -z "$(Q)" ]; then echo "Usage: make search AGENT=claude-code Q=\"your query\""; exit 1; fi
	mem0 search "$(Q)" --agent-id $(AGENT) -k 5

list: ## List all memories for an agent (run: make list AGENT=claude-code)
	mem0 list --agent-id $(AGENT)
