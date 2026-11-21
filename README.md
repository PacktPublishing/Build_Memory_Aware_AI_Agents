<h1 align="center">Designing and Building Memory for AI Agents</h1>

<p align="center">
  <strong>Attendee package for the 4-hour Packt live workshop (Saturday November 21, 2026, 11:00-15:00 EST).</strong><br />
  OAMP threads, context cards, skillbox/toolbox retrieval, in-database ONNX embeddings, and synthetic memory bootstrap.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.10+" />
  <img src="https://img.shields.io/badge/Oracle_AI_Database-Free-F80000?style=for-the-badge&logo=oracle&logoColor=white" alt="Oracle AI Database Free" />
  <img src="https://img.shields.io/badge/OAMP-oracleagentmemory-7B61FF?style=for-the-badge" alt="OAMP" />
  <img src="https://img.shields.io/badge/ONNX-in--database-005CED?style=for-the-badge&logo=onnx&logoColor=white" alt="ONNX" />
  <img src="https://img.shields.io/badge/Docker_or_Podman-container-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker or Podman" />
  <img src="https://img.shields.io/badge/Codespaces-ready-181717?style=for-the-badge&logo=github&logoColor=white" alt="Codespaces ready" />
</p>

<p align="center">
  <a href="https://luma.com/agentic-memory">Workshop page</a> ·
  Presented by the Agentic Engineering community, hosted by Packt Publishing
</p>

---

## Get the Code and Run the Labs

Pick one path. Paste the commands one at a time, in order; a line ending in `\` continues on the next line, so paste both together.

### Option A — GitHub Codespaces (nothing to install)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/PacktPublishing/Build_Memory_Aware_AI_Agents)

1. Click the button, keep the default 4-core machine, then **Create codespace**.
2. Wait for creation, about 10 minutes the first time (mostly the Oracle image download). It installs the Python environment and the notebook kernel, starts Oracle AI Database, loads the ONNX model, and runs the readiness check. Follow it with Command Palette → **Codespaces: View Creation Log**; it is done when it prints `Workshop environment ready.` (an earlier `All requested checks passed.` is only the offline file check).
3. In the Codespace terminal, confirm:

   ```bash
   uv run workshop-smoke-check --require-onnx
   ```

4. Open `notebooks/01_oamp_memory_agent.ipynb`. If VS Code asks for a kernel: **Select Kernel → Python Environments → .venv**. Run the cells in order, then `02_skillbox_toolbox.ipynb` and `03_synthetic_memory_bootstrap.ipynb`.

Details and the lifecycle scripts: [`CODESPACES.md`](CODESPACES.md).

### Option B — your machine (Docker or Podman)

You need a running Docker or Podman (8 GB of memory for containers), Python 3.10+, and `uv` (`curl -LsSf https://astral.sh/uv/install.sh | sh`). Install notes per OS: [`SETUP.md`](SETUP.md).

```bash
git clone https://github.com/PacktPublishing/Build_Memory_Aware_AI_Agents.git
cd Build_Memory_Aware_AI_Agents
test -f .env || cp .env.example .env
scripts/preflight.sh
scripts/setup_oracle.sh
uv sync --all-extras
uv run workshop-kernel
uv run python scripts/load_onnx_model.py
uv run workshop-smoke-check --require-onnx
uv run jupyter lab
```

- Both Docker and Podman installed? Pin one first: `export CONTAINER_ENGINE=podman` (or `docker`).
- `uv run workshop-kernel` registers the **Python (agentic-memory workshop)** kernel inside `.venv`. The notebooks ask for that kernel by name, so a stale `python3` kernel from another project cannot hijack them.
- `setup_oracle.sh` takes 3–5 minutes on first boot; re-running any step is safe.
- In Jupyter Lab, open `notebooks/01_oamp_memory_agent.ipynb`, `02_skillbox_toolbox.ipynb`, `03_synthetic_memory_bootstrap.ipynb` in order and run each top to bottom.

No git? Download the ZIP instead: <https://github.com/PacktPublishing/Build_Memory_Aware_AI_Agents/archive/refs/heads/main.zip>, unzip it, and `cd` into the folder. Prefer not to type? Open the folder in Claude Code or Codex and ask:

> Set up this workshop environment by following AGENTS.md.

### Check the labs without opening Jupyter

Runs notebooks 1 and 2 end to end and stops at the first failing cell (works locally and in the Codespace terminal):

```bash
mkdir -p /tmp/labs
uv run jupyter nbconvert --to notebook --execute \
  --output-dir /tmp/labs notebooks/01_oamp_memory_agent.ipynb
uv run jupyter nbconvert --to notebook --execute \
  --output-dir /tmp/labs notebooks/02_skillbox_toolbox.ipynb
```

Everything the labs need is in this repository: setup scripts, the pinned Oracle AI Database container definition, the helper package, sample tools and skills, the three notebooks, the slide deck (`slides/agentic-memory-management.md`), and shared OCI Generative AI keys for the LLM cells (`.env.example`; they are rotated after the session, so no personal API key is needed).

## What You Build

This package turns the live workshop into a reproducible attendee repo. You will run three labs:

| Lab | Outcome |
|---|---|
| **Lab 1 — OAMP memory agent** | Create users, agents, memories, threads, automatic extraction, summaries, and `thread.get_context_card()`; then put that card into a real LLM turn through LiteLLM. |
| **Mini-lab — Skillbox/toolbox** | Store tools and prose skills as vector-searchable Oracle rows; retrieve only top-k context per turn. |
| **Lab 2 — Synthetic bootstrap** | Generate synthetic conversations, workflows, entities, knowledge snippets, skills, and tools; load them before the agent has real history. |

The final state is a memory-augmented agent stack with durable Oracle-backed memory and a bounded active context surface.

## Before the Session

The environment is set up **during** the live session, in the first 15 minutes. Codespaces needs only a GitHub account. For a local run you need:

| Item | Why |
|---|---|
| Docker **or** Podman installed (daemon startable, 8 GB of memory for containers) | Runs Oracle AI Database Free locally |
| Python 3.10+ (3.12 recommended) | Runs the labs; Jupyter comes from `uv sync` |
| A coding agent such as Claude Code or Codex | Runs the setup for you with this repo's `AGENTS.md` instead of you typing commands |

No LLM API key is needed: `.env.example` carries shared OCI Generative AI keys for the session.

You do not need Oracle DBA experience, and you do not need to install anything during the workshop: the repo's scripts do it.

### Container engine notes

The scripts use Docker when its daemon is reachable, otherwise Podman, and honor `CONTAINER_ENGINE=docker|podman`.

- macOS/Windows Podman: `podman machine init --memory 8192 --disk-size 40` once (Oracle AI Database Free needs the RAM and the image needs disk), then `podman machine start`.
- Linux Podman: `sudo apt-get install -y podman podman-compose`, or install a compose provider for `podman compose`. Compose resolution is `docker compose`, then `podman compose`, then `podman-compose`.
- SELinux hosts (Fedora, RHEL, CentOS): a rootless Podman container cannot read the bind-mounted init scripts until you run `chcon -Rt container_file_t sql` from the repo root.

Want a head start on the biggest download? The optional pre-pull is in [`PREWORK.md`](PREWORK.md#optional-save-time-before-the-session). It saves minutes, not correctness: skipping it is fine.

## Live Setup (first 15 minutes)

| Clock | What happens |
|---|---|
| 11:00-11:15 | Welcome, clone the repo, open it in Claude Code or Codex, the coding agent runs the setup in [`AGENTS.md`](AGENTS.md): preflight, `.env`, Oracle container via Docker or Podman, `uv sync`. The image pull and first Oracle boot keep running in the background. |
| 11:15-11:45 | Module 1 — Why AI Agents Need Memory (concept + live demo) |
| 11:45-12:25 | Module 2 — Designing an Agent Memory Architecture (concept) |
| 12:25-12:35 | Break 1 + setup checkpoint: load the ONNX model, `uv run workshop-smoke-check --require-onnx` passes (it includes a live LLM call) |
| 12:35-13:30 | Module 3 — Build a Memory-Augmented Agent (Lab 1) |
| 13:30-13:40 | Break 2 |
| 13:40-14:15 | Module 4 — Keep Context Bounded: skillbox / toolbox (concept + mini-lab) |
| 14:15-14:50 | Module 5 — Bootstrap Memory with Synthetic Data (Lab 2) |
| 14:50-15:00 | Wrap, Q&A, what's next |

The checkpoint that matters is `uv run workshop-smoke-check --require-onnx`: it means the database, the HNSW vector memory pool, the ONNX embedder, the LLM, and the notebook imports are all live.

## Repository Map

| Path | Purpose |
|---|---|
| `AGENTS.md` | Exact, ordered setup runbook for a coding agent (Codex, Claude Code, others) |
| `CLAUDE.md` | One-line Claude Code import of `AGENTS.md` |
| `PREWORK.md` | Short pre-session checklist and the optional pre-pull |
| `SETUP.md` | Detailed local setup guide with Docker and Podman install notes |
| `CODESPACES.md` | Zero-install path: GitHub Codespaces / VS Code Dev Containers |
| `TROUBLESHOOTING.md` | Live-tested guardrails from Docker/Podman/Oracle/ONNX validation |
| `docker-compose.yml` | Pinned release-26 Oracle AI Database Free container |
| `.devcontainer/` | Codespaces configuration: provisions Oracle, the ONNX model, and the Python environment automatically |
| `notebooks/01_oamp_memory_agent.ipynb` | Final Lab 1 notebook |
| `notebooks/02_skillbox_toolbox.ipynb` | Final skillbox/toolbox mini-lab notebook |
| `notebooks/03_synthetic_memory_bootstrap.ipynb` | Final Lab 2 notebook |
| `src/agentic_memory_workshop/` | Helper package used by the notebooks and scripts (`llm.py`: model + shared-key failover) |
| `scripts/container_engine.sh` | Shared Docker/Podman detection sourced by the setup scripts |
| `scripts/preflight.sh` | Docker/Podman engine + Python/resource readiness check |
| `scripts/setup_oracle.sh` | Starts Oracle (never recreates a running container), sizes the vector memory pool, waits for health |
| `scripts/load_onnx_model.py` | Loads `ALL_MINILM_L12_V2` into Oracle through `onnx2oracle` |
| `scripts/synthesize_memory.py` | Lab 2 synthetic memory generator/loader |
| `samples/` | Sample tools and skills for retrieval labs |
| `slides/agentic-memory-management.md` | Marp-compatible workshop deck |

## Architecture

```text
Jupyter notebooks / CLI scripts
          |
          v
agentic_memory_workshop helper package
          |
          +--> OAMP: users, agents, memories, threads, context cards
          |
          +--> Skillbox/toolbox: top-k retrieval over tools and playbooks
          |
          v
Oracle AI Database Free container (pinned release-26 image)
  - relational tables
  - JSON tool parameters
  - VECTOR columns
  - VECTOR_EMBEDDING(ALL_MINILM_L12_V2 ...)
  - DBMS_VECTOR-loaded ONNX model
```

## Key Commands

| Command | Use |
|---|---|
| `scripts/preflight.sh` | Check Docker/Podman, compose, container memory, Python, uv, disk, `.env`, LLM configuration |
| `CONTAINER_ENGINE=podman scripts/preflight.sh` | Force Podman when both engines are installed |
| `scripts/setup_oracle.sh` | Start Oracle AI Database and wait for a healthy container |
| `uv run workshop-kernel` | Register the notebooks' Jupyter kernel (`agentic-memory`) inside `.venv` |
| `uv run python scripts/load_onnx_model.py` | Load the in-database embedding model |
| `uv run workshop-smoke-check --offline` | Validate files without external services |
| `uv run workshop-smoke-check --require-onnx` | Validate full workshop readiness, including a live LLM call |
| `uv run python scripts/synthesize_memory.py --out generated/synthetic_memory.json --write-skill-files` | Generate Lab 2 memory bundle |
| `uv run jupyter lab` | Open the final notebooks |

## What Success Looks Like

- Lab 1 prints a non-empty or explainable `thread.get_context_card()`, sends it to the LLM, and proves the thread survives reconnect.
- The mini-lab retrieves a small top-k tool/skill set instead of showing all schemas and playbooks.
- Lab 2 writes `generated/synthetic_memory.json`, loads memory into OAMP, and retrieves synthetic context on the first turn.
- `uv run workshop-smoke-check --require-onnx` passes before Module 4 starts.

## Runtime Notes

- OAMP base labs use `OAMP_EMBEDDER=oracle-db`, which routes embeddings through the in-database ONNX model after `scripts/load_onnx_model.py` runs.
- The LLM is `OAMP_LLM=openai/xai.grok-4.3` on OCI Generative AI through its OpenAI-compatible API: six shared keys on the Phoenix endpoint, six on Chicago as automatic failover (`src/agentic_memory_workshop/llm.py`). To use your own provider instead, blank both `OCI_GENAI_*ENDPOINT` lines in `.env` and set `OAMP_LLM` plus its key (`gpt-4o-mini` with `OPENAI_API_KEY`, `anthropic/claude-...` with `ANTHROPIC_API_KEY`); the smoke check verifies the pair with a live call.
- `scripts/setup_oracle.sh` sizes Oracle's vector memory pool (`vector_memory_size=512M`, one restart on first setup), so HNSW vector indexes never fail with `ORA-51962`.
- The toolbox/skillbox mini-lab uses Oracle `VECTOR_EMBEDDING(ALL_MINILM_L12_V2 ...)`. Load it with `scripts/load_onnx_model.py` before the session.
- The synthetic generator is deterministic and offline by default; loading into Oracle is opt-in.
- Do not reuse the sample `VECTOR` credentials outside the local workshop container.

## Codespaces

If local setup fails, or you would rather not install anything, use GitHub Codespaces or VS Code Dev Containers. See [`CODESPACES.md`](CODESPACES.md).
