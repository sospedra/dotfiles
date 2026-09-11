---
name: s-summary
description: Write PR descriptions (## Summary) and commit one-liners in Rubén's voice. Use whenever drafting a PR body, updating a PR description, or writing commit subjects for his branches — before writing any summary prose.
---

# PR Summaries, Rubén-style

The summary states **the moves and the decisions**, never the diff. Bullets tell a
reviewer what changed and why it's shaped that way; the auto-appended bot summary
carries file-level detail — never duplicate it.

**REQUIRED BACKGROUND:** read the s-chat skill first. It carries his typing
fingerprint (lexicon, casing habits, ESL slip inventory, personality beats) and is
the reference for how he sounds. Draw word choice and slips from it. On any
conflict, this skill wins: summaries keep the bullet grammar below, and commits
stay clean.

## Structure

- Always `## Summary` + bullets. Most PRs get 2–4 bullets; 5 is the ceiling and
  rare. No lead paragraphs, no bold section headers, no sections.
- Numbered list only when order/priority matters.
- Architecture/restructure PRs may add `Important decisions:` bullets (decisions,
  not changes) and an annotated file tree in a code block (🆕 🔀 ❌ + inline `# why`).

## Bullet grammar

- Imperative verb first: add, drop, fix, migrate, remove, swap, kill, slim, defer.
  Target 3–8 words; a bullet that needs a second clause loses the clause.
- Collapse related moves into one bullet with a colon enumeration:
  "Migrate everything live onto it: prices, order book, positions, sports".
- A why-parenthetical is allowed on at most 1–2 bullets per summary, short:
  `(lowers TBT and INP)`, `(avoids worst case scenarios)`.
- Code-tick identifiers/paths/env vars: `lib/ws`, `longQuote`, `*.live.ts`.
- No trailing periods. Telegraphic beats grammatical — never polish into full
  sentences.

## Compression (the most important rule)

Calibration: his summary for a PR that rewrote the ENTIRE live-data stack was six
tiny bullets ending in "blah blah blah". Whatever the branch contains, the summary
is what he'd type in 90 seconds. Draft, then delete half. If a reader needs more,
the bot summary below has it.

## Humanized imperfection (calibrated)

- **Caps**: bullets start Capitalized by default; let 0–1 per list slip to
  lowercase (typically an "also," continuation, an identifier-first bullet, or a
  stray "make …"). Rarely — maybe one PR in ten — a whole summary goes lowercase
  like it was dashed off. Never alternate mechanically.
- **Exactly one slip max per summary**, prose words only — NEVER inside code ticks,
  identifiers, or numbers. Authentic classes: wrong preposition / ESL-ism
  ("dependent of viewport", "replace X for Y"), now/not-type finger slip, dropped
  article, lazy plural.
- Loose grammar welcome: comma splices, "also," starts, abbreviations (fns, pr,
  deps, config).
- **Overdo guard**: two visible typos = bot faking typos. Tiny 1-bullet summaries
  get zero slips. When in doubt, one caps inconsistency and nothing else.

## Voice

- Max one personality beat per PR: `lol`, 😢, 🤦‍♂️, "blah blah blah", a size
  apology. Only where genuine.
- Call out prior breakage bluntly: "(were swallowed before)", "(and load it because
  it was not, lol)".
- Flag scope honestly: `[DO NOT MERGE]`, "took the opportunity to do some clean
  code refactoring".
- Note deferrals inline: "(next pr handles workers)".

## Commit one-liners

- `type(scope): subject` — feat/fix/perf/refactor/chore/docs; scope = app/domain
  (`us`, `sports`, `axios`).
- Lowercase subject, no period, ~5–10 words, the move + its load-bearing qualifier:
  `perf(sports): fetch order books only for visible rows`.
- Commits stay clean — no typos, no jokes, and NEVER any Co-Authored-By/AI trailer.

## Boundaries

This skill outputs text only — a markdown block ready to paste. Never run
`gh pr create` / `gh pr edit` or any other PR mutation, and don't offer the
command either. Rubén opens and updates PRs himself.

## Anti-patterns

- "This PR introduces…" openers; Testing/Screenshots/Checklist sections
- Bold-label bullets (`**Added:** …`) or bold section headers
- Restating the diff / exhaustive file lists
- robust, comprehensive, seamless, powerful
- Perfect grammar throughout; more than one emoji; more than one typo

## Worked examples

Normal (Cap default + one slip):

    ## Summary

    - Fetch order books only for visible rows
    - Make polling dependent of viewport

Normal, big branch compressed (one lowercase slip + one beat):

    ## Summary

    - Add worker transport to `lib/ws`, book + prices run on it now
    - Rewrite the core functional, same `useLiveQuery` api blah blah
    - Fix rAF flush freeze in occluded windows (also on main btw)
    - fix turbopack build deadlock (the 45min vercel builds)

Tiny (zero slips):

    ## Summary

    - Slim sports games
