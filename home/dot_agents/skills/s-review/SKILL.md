---
name: s-review
description: Read-only code review of a GitHub PR link, the current branch, or a working diff. Explicit /s-review invocation only.
disable-model-invocation: true
---

# s-review

Read-only code review. The deliverable is one short report, nothing else. Reviews never edit files, commit, push, comment on the PR, or approve. `gh` usage is read-only: view, diff, checks.

Invocation: `/s-review [pr-url] [--codex]`. The codex adversarial pass runs only with `--codex`. Without the flag, skip pass 4 silently. Everything else runs unchanged.

## Gather

- PR link given: `gh pr view <url> --json title,body,state,comments,reviews` and `gh pr diff <url>`. Read the comment threads; unresolved asks are review context.
- No link: review the current branch. Diff against the default branch (`git merge-base HEAD origin/HEAD`, fall back to `main`), include uncommitted changes. Then `gh pr view --json comments,reviews` for this branch; a PR may exist, include its comments the same way. No PR is fine.
- Read the full touched files, not just hunks. Complexity budgets judge whole functions.

## Review passes

1. Correctness: wrong logic, edge cases, races, silent behavior changes (array length, dropped elements, changed defaults), breaking signatures, security, perf, missing tests for the bug class found.
2. code.md compliance: run every touched function against `~/.claude/rules/code.md`. Cite rule ids (CF1-9, DF1-7, IT1-4, DP1-2, SP1, SM1-5, FN1-5, CP1-6, RF1-7, RX1-8). A finding with no rule id and no concrete failure is a nit.
3. Polyarchy compliance, only when both hold: `git remote get-url origin` points at `Polymarket/polymarket-next`, and the diff touches files under `apps/us/`. Run those `apps/us/` files against `polyarchy-rules.md` in this skill's directory. Cite PF ids. Anywhere else, skip this pass silently. The file is a dated snapshot of the Polyarchy Foundations Notion doc; the header carries the snapshot date and source URL. If that date is more than 30 days old, the report ends with the line `polyarchy snapshot from <date>, refresh if the doc changed`.
   Precedence on the known conflicts: Polyarchy owns the architecture surfaces. The fetch boundary throws (`fetchJson`, React Query need it), so RF5's result-union rule stops at that boundary. Caching belongs to `use cache` and React Query, so no hand-rolled `withCache` wrappers despite CP3's example. Mutations avoid Server Actions (PF-nav-2); RX7 still governs route handler internals. Everywhere else, code.md owns function-level style.
4. Codex adversarial pass, only with `--codex`, after your findings exist:

```bash
codex exec --cd <repo> "Adversarially review the diff between <base> and HEAD.
Then check this findings list: refute any finding that is wrong, and name real issues it misses.
Findings: <numbered one-liners>"
```

Codex is a reviewer, not an oracle. Verify every codex claim against the code. Drop a finding only when the refutation checks out. Add a codex discovery only after verifying it yourself, tagged `(codex)`. If `--codex` was given but codex fails or is not available, the report ends with one line: `codex pass skipped: <reason>`.

## Report contract

The report is the entire output. One numbered item per finding, ordered HIGH first, then MED, then LOW. Each item: headline, explanation line, snippet. The explanation line is mandatory: exactly one line, the why (the consequence), never a restatement of the headline:

    1. HIGH: One-line finding statement.
       One-line why: the concrete consequence of shipping this.
       ```ts
       // src/discount.ts:17
       result.push(p * discount);
       // fix
       result.push(p * (1 - discount));
       ```

Rules of the contract:

- severity: HIGH = bugs, broken behavior, money or security. MED = binding rule violations (code.md, polyarchy) and real risks. LOW = nits.
- no rule-id citations in the output; code.md and polyarchy-rules.md drive detection only
- every snippet lives inside a fenced code block with a language tag (```ts). Never emit snippet lines as bare indented text; an unfenced snippet is a contract violation.
- the code block opens with a comment carrying the repo-relative path and line number, then the offending lines as they are today, then `// fix`, then the proposed lines. Keep both sides minimal, 1–6 lines each. No function names in the prose; the snippet shows them.
- the current-code side is verbatim from the file at the cited line. Never imagine or reconstruct code from memory — re-read the file if unsure. If the offending lines can't be quoted verbatim, use the PROBLEM/SOLUTION form instead.
- a fix spanning multiple files stays in one fenced block: repeat the `// path:line` comment before each file's section, current lines then `// fix` then proposed lines per file.
- every prose line starts with a capital letter: headlines, explanation lines, PROBLEM/SOLUTION lines. Fixed literals (`clean, nothing to report`, the codex skip line, the polyarchy staleness line) stay as written.
- a blank line separates each numbered item from the next.
- a finding with no code to show (missing tests, process, config direction) replaces the snippet with two lines and no invented code:

      4. MED: No tests cover the discount math.
         PROBLEM: the money-path bug class ships unguarded
         SOLUTION: unit tests for applyDiscount and parseCoupon
- `(codex)` at the end of the headline only for codex-discovered findings
- nothing found: the single line `clean, nothing to report`

No preamble, no severity legend, no closing paragraph, no "overall". Compress hard: Rubén asks to expand when he wants detail.

The codex pass leaves no narrative in the report. A refuted finding is dropped or kept, silently. A verified codex discovery is a normal item tagged `(codex)`. The only sentences allowed after the items are the codex skip line and the polyarchy staleness line.

## Refreshing the polyarchy snapshot

Only when Rubén asks ("refresh polyarchy rules"). Fetch the source URL from the snapshot header via the Notion tool; the oversized result lands in a tool-results file. Dispatch a subagent to read the full export and distill ONLY diff-checkable rules: concrete violable prescriptions, one-line bullets, `PF-<topic>-<n>` ids kept stable where the rule survived, under 1500 words. Overwrite `polyarchy-rules.md`, update the header date. Reply with the added, changed, and removed ids.

## Boundaries

Report only, until Rubén explicitly asks for fixes after reading it. Never: edit files, `git commit`, `git push`, `gh pr comment`, `gh pr review`, `gh pr merge`, create branches. Not even to revert a subagent's side effects.
