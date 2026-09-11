---
name: s-main
description: Use when asked to sync or update the current branch with latest main — "merge main", "pull main into my branch", "update this branch", "branch is behind main", or before pushing a stale branch.
---

# s-main

## Overview

Merge the latest `origin/main` into the current branch. Resolve mechanical conflicts. Stop on semantic ones. Never guess intent on logic, math, or config values.

## Arguments

- `--push`: push after the merge commits cleanly. Default: no push. Never force-push.
- `--force`: do not stop on fragile conflicts. Resolve every conflict with best judgment and commit. See "--force mode".

## Workflow

1. Preconditions:
   - Dirty tree (`git status --porcelain` non-empty) → STOP. Report the dirty files. Don't stash, don't commit for the user.
   - On main → `git pull origin main`, report, done.
2. `git fetch origin main`
3. `git merge-base --is-ancestor origin/main HEAD` succeeds → already up to date, report, done.
4. `git merge origin/main`
5. Clean merge → done. Push only if `--push`.
6. Conflicts → classify every conflicted file (table below). Resolve and `git add` the mechanical ones. Any fragile file left → STOP (see below), unless `--force` (see "--force mode").
7. All conflicts mechanical → commit with the default merge message. Push only if `--push`.

## Conflict classification

| Class | Signs | Action |
|---|---|---|
| Mechanical | Both sides added independent entries to a list, imports, exports, translations, routes | Union, keep both |
| Mechanical | Lockfile or generated file | Take main's, re-run the generator/install |
| Mechanical | Pure formatting on one side vs content on the other | Content on the new formatting |
| Fragile | Both sides changed the same expression, value, or condition: rates, rounding, limits, timeouts, flags, config values, version pins | STOP |
| Fragile | Money math, order/position logic, signing, auth, credentials, migrations | STOP |
| Fragile | One side deleted or moved code the other side modified | STOP |
| Fragile | Resolution requires knowing which behavior is intended | STOP |

**The classic wrong call:** "both changes look orthogonal, so take the union." Orthogonal edits to the same statement interact — a rate change plus a new multiplier can double a fee. The union compiling proves nothing. Same statement + both sides changed semantics = fragile. Stop.

## Stopping on fragile conflicts

Leave the merge in progress. Keep mechanical resolutions staged. Leave conflict markers in the fragile files. Do not commit. Do not push, even with `--push`.

Report per fragile file: path, what base had, what main changed, what the branch changed, and the one-line question the user must answer.

## --force mode

`--force` removes the STOP on fragile conflicts. It does not remove judgment.

1. Resolve mechanical conflicts as normal.
2. Resolve each fragile conflict with best judgment. Read both sides in full context first. Prefer the resolution that keeps both intents when they compose. Prefer main's side when the branch did not touch that behavior on purpose.
3. A file with zero defensible resolution → take main's side and mark the branch's change as dropped in the report.
4. Never leave conflict markers. Commit the merge. Push only if `--push`. `--force` never enables force-push.
5. Run the workspace typecheck and lint on the resolved files. Report failures, do not amend.

Report every fragile resolution: path, the choice made, the alternative rejected, and the risk. The user must verify each one.
