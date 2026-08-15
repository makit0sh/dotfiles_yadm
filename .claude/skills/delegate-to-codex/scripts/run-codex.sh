#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: run-codex.sh <review|test-gaps|alternative|implement> <workspace> [task or focus]" >&2
}

if (( $# < 2 )); then
  usage
  exit 64
fi

mode="$1"
workspace_input="$2"
shift 2
task_text="$*"

case "$mode" in
  review|test-gaps|alternative)
    sandbox_mode="read-only"
    use_ephemeral="true"
    ;;
  implement)
    sandbox_mode="workspace-write"
    use_ephemeral="false"
    ;;
  *)
    echo "Unsupported mode: $mode" >&2
    usage
    exit 64
    ;;
esac

if [[ ! -d "$workspace_input" ]]; then
  echo "Workspace is not a directory: $workspace_input" >&2
  exit 66
fi

workspace_path="$(cd -P -- "$workspace_input" && pwd)"

if ! git -C "$workspace_path" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "Workspace is not inside a Git repository: $workspace_path" >&2
  exit 65
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "Codex CLI was not found in PATH. Install Codex CLI before using this skill." >&2
  exit 127
fi

if ! codex login status >/dev/null 2>&1; then
  echo "Codex CLI is not authenticated. Run: codex login" >&2
  exit 77
fi

case "$mode" in
  review)
    role_instructions="Act as an independent code reviewer. Inspect the repository and its current git diff. Do not modify any file. Prioritize concrete bugs, security issues, concurrency hazards, backward-compatibility problems, and missing tests. Cite file paths and line numbers where possible. Rank findings by severity. If there are no material findings, say so explicitly."
    ;;
  test-gaps)
    role_instructions="Act as an independent test strategist. Inspect the repository and current changes. Do not modify any file. Identify missing tests, edge cases, failure modes, and regression risks. For each material gap, explain the setup, expected behavior, and why the existing tests do not cover it. Prioritize by risk."
    ;;
  alternative)
    role_instructions="Act as an independent software designer. Inspect the relevant repository context. Do not modify any file. Produce a genuinely independent approach, including assumptions, design outline, tradeoffs, migration or compatibility concerns, and verification strategy. Avoid merely restating the apparent current approach."
    ;;
  implement)
    role_instructions="Act as an implementation specialist. Make only the changes required by the task. Preserve unrelated user changes. Add or update relevant tests, run proportionate verification, and finish with a concise report of changed files, commands run, results, and unresolved risks. Do not commit, push, or modify anything outside the workspace."
    ;;
esac

if [[ -z "$task_text" ]]; then
  task_text="Use the current repository state and git diff as the task context."
fi

prompt="$role_instructions

Task from Claude:
$task_text

Return evidence and conclusions to Claude, which will independently verify your work. Do not ask Claude to invoke another agent."

output_file="$(mktemp "${TMPDIR:-/tmp}/delegate-to-codex.XXXXXX")"
cleanup() {
  rm -f -- "$output_file"
}
trap cleanup EXIT INT TERM

codex_args=(
  exec
  -C "$workspace_path"
  --sandbox "$sandbox_mode"
)
if [[ "$use_ephemeral" == "true" ]]; then
  codex_args+=(--ephemeral)
fi
codex_args+=(
  --color never
  --output-last-message "$output_file"
  "$prompt"
)

codex "${codex_args[@]}" >/dev/null

if [[ ! -s "$output_file" ]]; then
  echo "Codex completed without a final message." >&2
  exit 70
fi

cat -- "$output_file"
