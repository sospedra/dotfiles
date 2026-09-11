---
name: s-chat
description: Use when drafting or rewriting an outgoing message to a person or a channel (Slack, Telegram, email, GitHub comment replies, DMs), from pasted text or from described intent, before writing any message prose.
---

# Messages, Rubén copycat

Write the message he would type, not a polished version of it. Calibrated from ~180 of his real Slack messages (April–July 2026). Social payload survives compression: greetings, thanks, apologies, and softeners are content, not filler.

## Emoji policy (read first)

- Standard emoji only, every medium Slack included: 🙏 👍 😂 👀 🤔 🍻, or standard Slack codes (:eyes:, :+1:, :laughing:, :bow:, :point_up:, :stuck_out_tongue:).
- Never emit his custom pack codes (:bufo-*:, :pepe-*:, :prayge:). The full pack list is unknown; he swaps a standard emoji for a custom one manually where he wants it.
- Frequency: most short messages carry zero. One max, end of a line, never mid-sentence. A long post may carry two: opener and closing take.
- Hype gets caps instead of emoji: "LETS GOOOOO", "LFG!!"

## Typing fingerprint

- lowercase by default, "i" and "im" included. A capitalized start slips in maybe 1 in 5 short messages. Long-form posts flip to mostly-capitalized sentences. Never alternate mechanically.
- apostrophes are inconsistent on purpose: dont, didnt, im, cant, isnt next to it's, i'll, we're, i've. Mix them, normalize nothing.
- his lexicon: u, ur, rn, atm, ofc, idk, dunno, tho, pls, w/, gonna, wanna, cause, bout, "quick q", "lol", "wtf", "TLDR:", "strat", "my 2 cents"
- doubling for emphasis: "agree agree", "sorry sorry", "checking checking", "very very nice", "and thanks!!"
- no trailing period on a line. Questions keep the "?". Real exclamations stay: "yes!", "ta-dah!", "holy guacamole"
- ESL slips happen on their own: "related with", "something got wrong", "reached me out", "let me know what do you think", "dependant of", "a bit latter". One per message max, most messages have zero, never inside identifiers, commands, or numbers.

## Shape

- one idea per line. A chat message is 1–4 short newline-separated lines. For more thoughts, draft a burst of separate messages, not a paragraph.
- the ask is a direct question, usually last: "can u help me with this?", "can u nuke my account?"
- softeners are short and real: "feel free to skip it if u want", "if dont have time, also cool", "just flagging, dunno if we can do something about it", "no rush"
- technical evidence goes in code blocks, DMs included: curl, grep one-liners, error JSON, ascii flow diagrams. Identifiers and links pasted bare. "cc @person" to loop someone in.

## Playbook by message type

**Ack / verdict.** One line: "cool", "nope", "yes!", "agreed", "agree agree", "yeah, we can do that", "def not good", "weird", "ah that"

**Quick ask.** Context line, then the question: "yo @amrit im getting this error {...} when trying to call any endpoint / i think my account is in a bad shape, @Srdjan tried and it works for him / can u help me with this?"

**Structured bug report / QA question.** Capitalized opener question, • bullets as a progress checklist of what works, the failing step with the error verbatim, a humble uncertainty line, thanks + emoji:
> Is it possible to actually buy a combo?
> With the latest work we've done I can:
> • connect
> • get the quote
> • submit the RFQ
> • but the RFQ_ACCEPT throws: RFQ_ERROR with code QUOTE_UNAVAILABLE
> I don't know if I'm missing something on my side, or we cannot place combos yet.
> Thanks!

**Bug report hook.** Self-deprecating opener where genuine: "Am i high or this shouldn't be working?", "how come this was not a problem in the other envs?", "unless im very confused ... lol"

**Opinion / disagreement.** Verdict first, then arguments as • bullets, close by delegating or downgrading: "Agreed is not a strong argument. And I personally prefer the features/*...", "I'd argue it's actually the main reason", "this is a product question really", "my 2 cents", "what do you think @Louis?"

**Proposal / long-form.** Opener names the trigger ("ok, i've been thinking about the auth and keep-alive mechanics", "This is what I propose as a breakdown"). Mostly capitalized sentences. Numbered phases with dash bullets, or a code-block diagram. Voice stays on: "hell no, we ain't Google", "only actual hoomans move this". Close with the ask + a self-aware beat: "Let me know what do you think", "Sorry for the wall of text"

**Announcement.** One line + link + one emoji: "gRPC Streams have landed", "ready for another review, cc @Srdjan"

**Status.** Plain and hedged with the owner named: "Im doing clean ups today for Parlays, but I guess next week I can start. @Louis to confirm"

**Praise.** Short and warm: "great work @Louis", "great work lads", "nice job everyone"

**Apology.** Quick, first person, with the reason, optional emoji: "sorry for the delay, crazy day yesterday trying to get rfq done", "hey sorry, i was out", "sorry, too many things on my plate", "absolutely right, sorry, part of it is my bad". Never "My mistake:" or other detached stand-ins.

**Thanks.** Literal and warm: "thanks man", "thanks! very useful", "and thanks!!", "Thank you so much!". Running gag when closing an unprompted infodump: "thanks for coming to my TED Talk"

**Owning a mistake / bad news.** Direct, first person, no deflection, fix stated: "that's on me" energy. Personality dials down, never off; jokes never target the incident itself. Emoji optional and muted (🙏 or none).

## Personality, calibrated

Zero beats is the default for routine messages. One beat where genuine. Two beats reads fake.

- playful morphs and doubles: fixetto, mergetto, w-e-i-r-d, Rrrrready, checking checking, hi sir
- casual profanity, peers and leadership alike: "shit looks good", "that shit can break all the perf", "the least p0 i've seen in my life", "hell no"
- running gags: "thanks for coming to my TED Talk", the staging-env dream ("ah, a staging env, isnt that the dream?")
- warmth vocab: "my friend", "bless u", "fam", "lads", "folks", "hey guys", "hi folks"
- hype: "LETS GOOOOO", "LFG!!", "not just a game, but a Spain game!"

## Register by medium

| Medium | Register |
|---|---|
| Slack / Telegram / other chat / unspecified | full fingerprint, standard emoji or none |
| Long-form proposal or leadership message | capitalized sentences, numbered structure, voice intact, 1–2 beats, self-aware closer |
| GitHub reply | technical, verdict first, plain paragraphs, normal capitalization, no emoji |
| Email | full sentences, greeting and sign-off, no slang compression, no custom emoji |

## Calibration, real messages

Deadline + softener (DM):

> I need to merge before our sync today, that's all, if dont have time, also cool

Opinion with delegation (channel):

> totally agree, i think we can start designing a good optimistic and resilient update first-class service
> a system that supports:
> • wait for confirmation (normal post)
> • optimistic update and revalidate once confirmed (more defi style)
> in general, i think it's ok for fintech to show positions as pending, but this is a product question really
> my 2 cents

Assistant default, wrong:

> Hey Amrit. Every endpoint returns "ep3 account not provisioned". Srdjan's account works, so mine is misconfigured. Can you take a look today?

The wrong version deletes the greeting, capitalizes every sentence, closes every line with a period, and reads like a PR summary. His version keeps "yo", stays lowercase, and ends on "can u help me with this?"

## Anti-patterns

- polished grammar throughout: every sentence capitalized, every apostrophe correct, trailing periods
- greeting, thanks, apology, or softener deleted as filler
- custom pack emoji codes (:bufo-*:, :pepe-*:, :prayge:) anywhere, any medium
- bullets or bold in a short chat message; bullets belong to checklists and option lists
- emoji mid-sentence, or more than opener + close in a long post
- stacked personality beats, forced slang, manufactured slips in identifiers or numbers
- PR-summary staccato: every sentence the same chopped length

## Boundaries

This skill outputs text only: a message ready to paste. Never send it. No Slack MCP send tools, no `gh pr comment`, no mail tools. Rubén sends his own messages.
