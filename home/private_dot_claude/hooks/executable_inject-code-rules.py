#!/usr/bin/env python3
"""PreToolUse hook. Injects ~/.claude/rules/code.md once per session, on the
first file write. Shared by Claude Code and Codex."""
import json, os, pathlib, re, sys, time

RULES = pathlib.Path.home() / '.claude' / 'rules' / 'code.md'
MARKERS = pathlib.Path.home() / '.claude' / 'cache' / 'code-rules'

EDIT_TOOLS = {'Edit', 'Write', 'MultiEdit', 'NotebookEdit', 'apply_patch'}
SHELL_TOOLS = {'Bash', 'shell', 'exec_command', 'local_shell'}
CODE_EXT = 'ts|tsx|js|jsx|mjs|cjs|py|go|rs|swift|kt|java|rb|cs|c|h|sol|json|sh|bash|md|mdx'
SHELL_WRITE = re.compile(
    r'apply_patch|\bsed\s+-i|\btee\b|\bcat\s*<<|>>?\s*[^\s|&;\'"]*\.(?:' + CODE_EXT + r')\b'
)


def nothing():
    print('{}')
    sys.exit(0)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        nothing()

    tool = payload.get('tool_name') or ''
    if tool in SHELL_TOOLS:
        blob = json.dumps(payload.get('tool_input') or {})[:4000]
        if not SHELL_WRITE.search(blob):
            nothing()
    elif tool not in EDIT_TOOLS:
        nothing()

    if not RULES.is_file():
        nothing()

    session = str(payload.get('session_id') or os.getppid())
    MARKERS.mkdir(parents=True, exist_ok=True)
    marker = MARKERS / re.sub(r'[^A-Za-z0-9_.-]', '_', session)
    if marker.exists():
        nothing()

    cutoff = time.time() - 7 * 86400
    for stale in MARKERS.iterdir():
        if stale.is_file() and stale.stat().st_mtime < cutoff:
            stale.unlink(missing_ok=True)

    body = RULES.read_text(encoding='utf-8')
    if body.startswith('---'):
        end = body.find('\n---', 3)
        if end != -1:
            body = body[body.find('\n', end + 1) + 1:]

    marker.touch()
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'additionalContext': body.strip(),
        }
    }))


main()
