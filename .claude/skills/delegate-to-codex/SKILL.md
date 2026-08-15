---
name: delegate-to-codex
description: Delegate a bounded coding task to Codex CLI as an independent specialist, then verify its result in Claude. Use when the user explicitly asks Claude to consult Codex, requests a Codex code review, test-gap analysis, alternative design, second opinion, or implementation by Codex.
argument-hint: "[review|test-gaps|alternative|implement] [task or focus]"
allowed-tools: Bash Read Grep Glob
---

# Delegate to Codex

Use Codex as an independent specialist. Keep Claude responsible for scope, verification, and the final answer.

## Select a mode

- `review`: Review the repository and current diff without modifying files. Use this when no mode is supplied.
- `test-gaps`: Find missing tests, edge cases, and failure scenarios without modifying files.
- `alternative`: Produce an independent design or implementation approach without modifying files.
- `implement`: Modify the workspace and run appropriate checks. Use only when the user explicitly requested implementation or file changes by Codex.

Treat the first argument as the mode when it matches one of the values above. Treat the remaining arguments as the task or focus. If the first argument is not a mode, use `review` and treat all arguments as the focus.

## Run Codex

1. Resolve the current repository root with `git rev-parse --show-toplevel`. Stop with a clear explanation if the current directory is not inside the intended repository.
2. Do not use `implement` unless the user explicitly authorized file changes. Downgrade to a read-only mode when that preserves the request; otherwise ask the user.
3. Run exactly one delegation for the task:

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/run-codex.sh" <mode> "<repository-root>" "<task-or-focus>"
   ```

4. Never add sandbox-bypass flags, approval-bypass flags, extra writable directories, or shell evaluation around the bundled script.
5. Do not recursively ask Codex to consult Claude or invoke another Codex session.

## Verify the result

For `review`, `test-gaps`, and `alternative`:

1. Inspect every material Codex claim against the repository using read-only tools.
2. Reject unsupported or irrelevant claims.
3. Combine verified Codex findings with Claude's own analysis.
4. Clearly distinguish verified findings, rejected suggestions, and remaining uncertainty.
5. Do not edit files unless the user separately requested fixes.

For `implement`:

1. Inspect the resulting diff and confirm that changes stay within the user's scope.
2. Check the tests, lint, build, or other verification that Codex reports; run additional checks when needed.
3. Report changed files, verified results, and unresolved risks.
4. Do not make unrelated follow-up edits.

Retry only once for a clearly transient execution failure. Do not retry a substantive answer merely to seek a preferred conclusion.
