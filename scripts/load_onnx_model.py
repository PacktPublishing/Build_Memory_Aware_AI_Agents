#!/usr/bin/env python3
"""Load the workshop embedding ONNX model into Oracle AI Database.

This script wraps the `onnx2oracle` CLI because that tool builds the Oracle-safe
augmented ONNX graph: tokenizer + transformer + pooling + normalization in one
model. The workshop's toolbox/skillbox SQL uses this model through
`VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING :text AS DATA)`.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

from agentic_memory_workshop.connection import connect, load_env, oracle_settings
from agentic_memory_workshop.onnx import configured_model_name, embedding_sample, model_registered

ROOT = Path(__file__).resolve().parent.parent


def run(cmd: list[str]) -> int:
    print("$", " ".join(cmd))
    return subprocess.run(cmd, cwd=ROOT).returncode


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--preset",
        default=os.environ.get("ORACLE_EMBED_PRESET", "all-MiniLM-L12-v2"),
        help="onnx2oracle preset to load. Default: all-MiniLM-L12-v2.",
    )
    parser.add_argument("--force", action="store_true", help="Reload the model even if it exists.")
    parser.add_argument("--skip-verify", action="store_true", help="Skip post-load SQL verification.")
    args = parser.parse_args(argv)

    load_env(ROOT / ".env")
    settings = oracle_settings()
    full_dsn = f"{settings.user}/{settings.password}@{settings.dsn}"
    expected_model = configured_model_name()

    if not args.force:
        try:
            with connect() as conn:
                if model_registered(conn, expected_model):
                    print(f"✓ {expected_model} is already registered. Use --force to reload.")
                    if not args.skip_verify:
                        print(f"✓ sample embedding: {embedding_sample(conn, expected_model)}...")
                    return 0
        except Exception as exc:
            print(f"Pre-check could not verify model state yet: {exc}")

    rc = run(["uv", "run", "onnx2oracle", "load", args.preset, "--dsn", full_dsn, "--force"])
    if rc != 0:
        print("onnx2oracle load failed. Check Docker/Oracle logs and rerun SETUP.md step 6.", file=sys.stderr)
        return rc

    if args.skip_verify:
        return 0

    with connect() as conn:
        if not model_registered(conn, expected_model):
            print(f"Load finished but {expected_model} was not visible in USER_MINING_MODELS.", file=sys.stderr)
            return 2
        print(f"✓ {expected_model} registered")
        print(f"✓ sample embedding: {embedding_sample(conn, expected_model)}...")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
