# GitHub Codespaces

Codespaces runs the whole workshop in the browser: no Docker, Python, or API key on your machine. The devcontainer runs Oracle AI Database Free inside Docker-in-Docker, so the same `scripts/` run unchanged and the engine detection picks Docker.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/PacktPublishing/Build_Memory_Aware_AI_Agents)

## Attendee steps

1. Click the button above (or **Code → Codespaces → Create codespace on main** on the repository page).
2. Keep the default machine type: the devcontainer asks for 4 cores (16 GB RAM, 32 GB disk), which Oracle and the ONNX load need.
3. Wait for creation to finish, about 10 minutes the first time. Follow it in the **Codespaces: creation log** (Command Palette → *Codespaces: View Creation Log*). It ends with `All requested checks passed.`
4. Open `notebooks/01_oamp_memory_agent.ipynb`, click **Select Kernel → Python Environments → .venv**, and run the cells in order. Notebooks `02` and `03` follow.

Prefer Jupyter Lab? Run `uv run jupyter lab --no-browser --ip 0.0.0.0` in the terminal and open the forwarded port `8888`.

## What creation does

| Lifecycle step | Script | What it runs |
|---|---|---|
| `onCreateCommand` | `.devcontainer/on-create.sh` | Installs `uv`, `uv sync --all-extras`, creates `.env` from `.env.example` (shared LLM keys included), offline smoke check |
| `postCreateCommand` | `.devcontainer/post-create.sh` | Waits for Docker, `scripts/setup_oracle.sh` (container, vector memory pool, `VECTOR` user), `scripts/load_onnx_model.py`, `workshop-smoke-check --require-onnx` (includes a live LLM call) |
| `postStartCommand` | `.devcontainer/post-start.sh` | After a stopped Codespace resumes: starts the Oracle container again; a running one is left untouched |

Every step is idempotent. If something failed, rerun it by hand:

```bash
bash .devcontainer/post-create.sh
```

## LLM keys

`.env.example` carries the shared OCI Generative AI keys for the session (rotated afterwards), so nothing needs to be configured. To use your own provider, edit `.env`: blank both `OCI_GENAI_*ENDPOINT` lines and set `OAMP_LLM` plus its key, then run `uv run workshop-smoke-check --require-onnx`.

## Instructor checks before the event

- Create a fresh Codespace from `main` and confirm the creation log ends with `All requested checks passed.`; note the creation time.
- Optional: enable **Codespaces prebuilds** for `main` (repository **Settings → Codespaces**, needs admin). Prebuilds cache the `on-create` step (Python environment); the Oracle image download and first boot still happen per Codespace.
- Codespaces stop after 30 idle minutes by default; the `postStartCommand` restarts Oracle on resume, and the data volume survives.
