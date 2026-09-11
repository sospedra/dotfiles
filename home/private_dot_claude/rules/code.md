---
paths: ["**/*.{ts,tsx,js,jsx,mjs,cjs,py,go,rs,swift,kt,java,rb,cs,c,h,sol,json,sh,bash,mk,md,mdx}", "**/Makefile", "**/makefile"]
---

# Complexity rules

Scope: every language. Examples are TypeScript and React; the principles transfer. Stack-specific sections (State machines, React and Next.js) apply where the stack matches. These rules apply to every function you write or modify. They target the three ways code becomes hard to follow: control flow (nesting and branching), data flow (reassignment and mutation), and structure (implicit state, inheritance, configuration bags).

## The model

Optimize for cognitive complexity, not cyclomatic complexity. Cyclomatic counts execution paths. Cognitive counts reader effort. Score your code mentally as you write it:

Costs +1:
- each `if`, `else if`, `else`, ternary, loop (`for`, `for...of`, `while`, `do`), `catch`
- each `switch` (+1 total, regardless of case count)
- each sequence of `&&` or `||` (switching operators starts a new sequence: `a && b || c` costs 2)
- recursion
- labeled `break` or `continue`

Costs an extra +1 per nesting level:
- `if`, ternary, `switch`, loops, and `catch` pay a penalty equal to their current nesting depth
- callbacks and nested functions raise nesting depth: an `if` inside a `.map()` callback costs 2, not 1

Free:
- early `return`, unlabeled `break` and `continue`
- `?.` and `??`
- `else` and `else if` pay flat +1 with no nesting penalty

Consequences of the scoring: flat code is cheap, nested code is expensive, a `switch` beats an `else if` chain, early returns beat `else`, and `??` beats `||` fallback chains.

## Budgets

Hard limits per function:

| Metric | Limit | Target |
|---|---|---|
| Cognitive complexity | 10 | 5 or less |
| Nesting depth | 3 | 2 |
| Parameters | 3 | 2 |
| Length | soft, ~60 lines | whatever complexity allows |

Length is a symptom, complexity is the rule. A 50-line pure function with complexity 4 is fine. A 15-line function with complexity 12 is not.

When over budget: extract, restructure, or flag it. Never obfuscate to pass. See Anti-gaming.

## Control flow

### CF1. Guard clauses first

Validate and bail at the top. Handle the edge cases early with returns. The happy path comes last, at the lowest indentation.

```ts
// Bad: cognitive ~12, depth 3, mutation
function shippingLabel(order: Order | null): string {
  let label = '';
  if (order) {
    if (order.status === 'paid') {
      if (order.items.length > 0) {
        label = order.express ? 'EXPRESS' : 'STANDARD';
      } else {
        label = 'EMPTY';
      }
    } else {
      label = 'HOLD';
    }
  }
  return label;
}

// Good: cognitive 4, depth 1, no mutation
function shippingLabel(order: Order | null): string {
  if (!order) return '';
  if (order.status !== 'paid') return 'HOLD';
  if (order.items.length === 0) return 'EMPTY';
  return order.express ? 'EXPRESS' : 'STANDARD';
}
```

### CF2. Nesting depth 3 max, aim for 2

At depth 3, do one of these, in order of preference:
1. Invert the condition and return early.
2. Extract the inner block into a named function.
3. Replace the conditional structure with a lookup (CF5).

Remember callbacks count as a nesting level. A conditional inside a `.filter()` inside an `if` is already at depth 2.

### CF3. No else after return, throw, or continue

If a branch exits, the code after it is already the other branch. Drop the `else` and dedent.

### CF4. Ternaries select between expressions, nothing else

One level only. Never nest ternaries. Never put side effects in ternary arms. If either arm is not a simple expression, use `if` with early returns or extract a function.

### CF5. Branch on a discriminant with switch or lookup, never else-if chains

Three or more branches on the same value: use a lookup table or a `switch`. An `else if` chain costs +1 per branch. A `switch` costs +1 total. A lookup costs 0.

```ts
// Bad: cost grows linearly with branches
function statusColor(s: Status): string {
  if (s === 'active') return 'green';
  else if (s === 'pending') return 'amber';
  else if (s === 'blocked') return 'red';
  else return 'gray';
}

// Good: zero branches, compile-time exhaustive
const STATUS_COLOR = {
  active: 'green',
  pending: 'amber',
  blocked: 'red',
  archived: 'gray',
} satisfies Record<Status, string>;

const color = STATUS_COLOR[status];
```

For `switch`, enforce exhaustiveness: in TypeScript, a `default` that calls `assertNever(value)`, or the linter's exhaustiveness check.

```ts
function assertNever(x: never): never {
  throw new Error(`Unhandled case: ${JSON.stringify(x)}`);
}
```

### CF6. Merge collapsible ifs, name complex conditions

`if (a) { if (b) { ... } }` becomes `if (a && b)`. A condition with three or more operands, or mixed `&&`/`||`, gets extracted into a named boolean or predicate function:

```ts
const canCheckout = cart.items.length > 0 && user.verified && !cart.locked;
if (!canCheckout) return;
```

### CF7. Positive conditions first

Never write `if (!x) { A } else { B }`. Flip it. Negations force the reader to invert twice.

### CF8. try/catch at boundaries only

One `try` per operation, placed at the boundary: route handler, server action, job entry point, top of a use case. Keep the `try` body minimal by extracting the fallible call into a function. Never wrap a whole function body reflexively. `catch` pays nesting penalties like any other block, and code inside `try` reads as provisional.

### CF9. No labeled breaks, no gratuitous recursion

A labeled break means the loop should be a function with a `return`. Recursion only when the data is recursive (trees, nested comments). It costs +1 and hides stack depth.

## Data flow

### DF1. const by default, let as a last resort

Bind once. Reach for the mutation-free rewrite first: ternary, lookup, extraction, `some`/`find`. If the `let` version is clearly the most readable option, keep it and keep its scope tiny. `var` is banned.

### DF2. Never assign in branches

The single biggest reassignment smell. A variable that gets its value in different branches becomes a ternary, a lookup, or a function.

```ts
// Bad
let discount = 0;
if (user.tier === 'pro') discount = 0.2;
else if (user.tier === 'plus') discount = 0.1;

// Good
const DISCOUNTS = { pro: 0.2, plus: 0.1, free: 0 } satisfies Record<Tier, number>;
const discount = DISCOUNTS[user.tier];
```

If the arms need real logic, extract: `const discount = discountFor(user);` where `discountFor` uses early returns.

### DF3. One variable, one meaning

Never reuse a variable for a second purpose. New meaning, new `const`, new name. A `response` that first holds a fetch result and later a parsed body is two variables wearing one name.

### DF4. Never reassign parameters

If you need a modified version, copy explicitly: `const normalized = input.trim().toLowerCase()`. Reassigned parameters make the signature lie.

### DF5. Minimize span

Declare at first use, not at the top of the function. Declaration and last use should fit on one screen. If a variable lives across 30 lines, the code in between is a function waiting to be extracted.

### DF6. Do not mutate data you did not just create

Prefer `toSorted`, `toReversed`, `toSpliced`, and `with` over `sort`, `reverse`, `splice` on arrays you received. Use spread for object updates. Build indexes declaratively:

```ts
const byId = Object.fromEntries(items.map((item) => [item.id, item]));
```

Local mutation of a value created inside the same function is contained and safe, but reserve it for measured hot paths (IT4). The declarative form reads better everywhere else.

### DF7. No status flags flipped later

```ts
// Bad
let hasInvalid = false;
for (const item of items) {
  if (!item.sku) hasInvalid = true;
}

// Good
const hasInvalid = items.some((item) => !item.sku);
```

Same for `found`, `firstMatch`, `count`: use `find`, `some`, `every`, `filter(...).length`.

## Iteration

Collections get combinators, not loops. Imperative iteration is the escape hatch, not the default.

### IT1. A loop that produces a value is a smell

Transform with `map`, `filter`, `flatMap`. Search with `find`, `some`, `every`. Index with `Object.fromEntries`. Group, dedup, and chunk with an installed utility library (DP1), or natives like `Object.groupBy` where the target runtime supports them (bundlers transpile syntax, not APIs). A `push` into an array declared outside the loop means the loop wanted to be `map` or `flatMap`. `reduce` only for scalar folds (sum, min, max). Never build objects or arrays with spread inside `reduce`: quadratic and unreadable.

### IT2. No forEach

It produces a value: use a combinator. It performs a side effect per item: use `for...of`, which supports `await` and `break` and is honest about being imperative. `forEach` is imperative code in a functional costume.

### IT3. while only for genuinely unbounded work

Cursor pagination, retry with backoff, draining a queue. Always with an explicit termination bound: max attempts, max pages, a deadline. Iteration over data of known size never gets a `while`.

### IT4. Hot-path escape hatch

A measured hot path (per-message reducers, per-frame rendering, large-batch processing) may use a plain loop with local mutation. Justify it with a one-line comment naming the constraint. Unmeasured "performance" is not a justification.

## Dependencies

### DP1. Don't reinvent the wheel

Before writing a nontrivial helper (grouping, dedup, chunking, debounce, deep equality, date math, retries, id generation), check the project's installed dependencies. Read package.json. The answer usually already ships, and the installed version handles the edge cases yours won't.

### DP2. Suggest, never install

No installed library covers it and the work is heavy or common: propose an installation in your summary, with the candidate and the tradeoff. Never add a dependency, touch a lockfile, or import an uninstalled package without explicit confirmation.

## Strings and parsing

### SP1. Regex is a last resort

Prefer string methods: `startsWith`, `endsWith`, `includes`, `split`, `slice`, `trim`, `at`. Prefer real parsers for structured input: `URL`, `URLSearchParams`, `JSON.parse`, `Number`, `Intl`, `Date`/Temporal. A regex is justified only for genuinely irregular text patterns no method or parser expresses.

```ts
// Bad
if (/^https:\/\//.test(url)) { ... }
const [, id] = path.match(/\/event\/([\w-]+)/) ?? [];

// Good
if (url.startsWith('https://')) { ... }
const id = new URL(url, origin).pathname.split('/')[2];
```

When a regex survives that test:

- Hoist it to module scope with a domain name. Never construct one in a render body or hot loop.
- Keep it linear: no nested quantifiers, no overlapping alternations. ReDoS is a one-line mistake.
- Slice untrusted input to a fixed bound before matching.
- If it needs a comment to decode, replace it with a parser or split it into named steps.

## State machines

When logic branches on the phase of a process, the phase is state. Model it explicitly. Booleans multiply; machines enumerate.

### SM1. Model stateful processes as discriminated unions

Any process with phases (fetching, forms, wizards, connections, orders, payments) gets a union with a discriminant. Never parallel booleans and nullables: three fields encode eight representable shapes when four are legal, and every consumer re-derives which combinations exist.

```ts
// Bad: 8 representable shapes, 4 legal
type Fetch = { isLoading: boolean; error: Error | null; data: User | null };

// Good: exactly the legal states, data exists only where it exists
type FetchState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: Error };
```

Illegal states become unrepresentable. Downstream code stops null-checking `data` on the error path because the type forbids the question.

### SM2. Transitions live in one pure function

One `(state, event) => state` function owns every transition. Events that are invalid in the current state return the state unchanged, decided in this one place. No scattered setters, no flags flipped in handlers. In React this is `useReducer`. Outside React it is the same function feeding a store.

```ts
type FetchEvent =
  | { type: 'FETCH' }
  | { type: 'RESOLVE'; data: User }
  | { type: 'REJECT'; error: Error };

function reducer(state: FetchState, event: FetchEvent): FetchState {
  switch (event.type) {
    case 'FETCH':
      return { status: 'loading' };
    case 'RESOLVE':
      return state.status === 'loading' ? { status: 'success', data: event.data } : state;
    case 'REJECT':
      return state.status === 'loading' ? { status: 'error', error: event.error } : state;
  }
}
```

An exhaustiveness check turns a missing case into a compile error.

### SM3. Derive flags from the machine, never the machine from flags

`const isLoading = state.status === 'loading'` at the point of display is fine. Storing `isLoading` next to `status` is a sync bug on a timer.

### SM4. Domain status fields get a transition map

Server-side statuses (orders, payments, subscriptions) get one table of legal moves and one guard that enforces it. Never sprinkle `if (order.status !== 'paid') throw` across handlers.

```ts
const ORDER_FLOW = {
  draft: ['submitted'],
  submitted: ['paid', 'cancelled'],
  paid: ['shipped', 'refunded'],
  shipped: ['delivered'],
  delivered: [],
  cancelled: [],
  refunded: [],
} satisfies Record<OrderStatus, readonly OrderStatus[]>;

function transition(order: Order, next: OrderStatus): Order {
  if (!ORDER_FLOW[order.status].includes(next)) {
    throw new Error(`Illegal transition: ${order.status} -> ${next}`);
  }
  return { ...order, status: next };
}
```

### SM5. Library threshold

Plain union plus reducer first, always. Reach for XState only when you genuinely need hierarchy, parallel regions, delayed transitions, or actor orchestration. A four-state fetch does not need a library.

## Function shape

### FN1. One level of abstraction per function

A function either orchestrates (calls named steps) or does low-level work. Not both. If you see a `fetch` call next to a domain decision next to string formatting, split by level.

### FN2. Three parameters max

Beyond that, take a single options object and destructure it in the signature. Related parameters that always travel together become a type.

### FN3. No boolean behavior switches

A `doThing(data, true)` call site is unreadable and the `if (flag)` inside doubles the function's paths. Split into two named functions that share a private helper.

### FN4. Extractions must earn their name

An extracted function needs a domain name and must be understandable alone. If the only honest name is `handleRestOfIt` or `processPart2`, the split boundary is wrong. Re-split by responsibility, not by line count.

### FN5. Pure core, imperative shell

Separate computing from doing. Decision logic goes in pure functions that take data and return data. I/O (fetch, db, fs, analytics) stays in thin outer layers. Pure functions have naturally low complexity and are trivially testable.

## Naming

### NM1. Names are self-explanatory

A name states what the value is without the reader tracing its assignment. `retryCount` beats `n`. `parsedBody` beats `res2`. Abbreviations the reader must decode are naming failures: `usrCfg`, `tmp`, `arr`, `val`, `obj`.

Conventional short names survive, in tiny scopes only:

- `i`, `j` in index loops.
- `err` in catch clauses, `ctx` for a context parameter, `id` for an identifier.
- Names the surrounding codebase already established (`db`, `tx`, `req`, `res`).

Everywhere else, name the role. In a callback, name the item: `(order) => order.id`, not `(o) => o.id`.

### NM2. Length scales with scope

A wider scope earns a longer name. A module-level constant carries the full meaning: `MAX_RETRY_ATTEMPTS`. A three-line local can be terse: `attempts`. A single letter is only legal where the scope fits on one line.

### NM3. No bloated names

Cap at roughly four words. Name the role, not the history or the type: `activeUsers`, not `filteredActiveUserAccountsList`. Drop words that discriminate nothing: `data`, `info`, `object`, `Manager`, `Helper`, `Impl`. If the honest name needs a sentence, the variable holds two meanings. Split it (DF3).

## Comments

The default comment count for any function you write or modify is zero. A comment is an exception that must justify itself, never a habit. Before writing one, attempt the rewrite that deletes it: rename, extract, restructure. Only when no rewrite can carry the information does a comment survive.

Exactly three cases earn one:

- Missing context. The constraint lives outside the codebase and no identifier can carry it: "gateway rejects batches over 100".
- Non-obvious algorithm. The code implements published math or a tricky invariant that a name cannot summarize: a reference, a bound.
- A hack. The workaround states its justification and its exit condition: "retry twice, the PSP webhook races the redirect; remove after PSP-341".

Hard budget: most files get zero comments. A file with more than three inline comments is over budget; delete or rewrite until it passes.

Banned outright, no exceptions:

- What-comments. A comment describing what the next line does: naming failure, fix the name.
- Narration and section headers inside functions: `// fetch the user`, `// validate input`, `// handle errors`. The structure or an extracted function name does this job.
- Change markers: `// added`, `// updated to fix X`, `// new implementation`. That is commit history.
- Reviewer-directed comments explaining why your edit is correct. That belongs in the PR description or your summary, never in the file.
- Restating types, parameter lists, or obvious defaults. The signature already says it.
- JSDoc on internal functions whose signature is self-explanatory. JSDoc earns its place on public API surfaces only.

```ts
// Bad: the comment does the code's job
// check if the user can trade
if (user.verified && !user.frozen && user.region === 'US') { ... }

// Good: the name does it
const canTrade = user.verified && !user.frozen && user.region === 'US';
if (canTrade) { ... }
```

When modifying existing code, never add comments around your change. Also delete any adjacent comment your change makes stale or redundant.

An earned comment is one line, a fragment, no preamble. Two lines is the absolute ceiling. Compress to the constraint itself: "gateway rejects batches over 100" beats "we limit the batch size here because the gateway will reject batches with more than 100 items". Anything longer is documentation and belongs in the PR description, the ticket, or a doc file.

## Composition

Build behavior by combining small functions. Inheritance hierarchies and giant options bags are the same mistake in different clothes: one unit configured to be everything.

### CP1. No inheritance for behavior

Classes exist for platform contracts only: `Error` subclasses, framework base classes you do not control. Never author your own hierarchy. The urge for an `abstract class` with overrides is the urge for a function parameter.

### CP2. Vary behavior by passing functions

A strategy is an argument, not a subclass and not a mode string with an internal switch.

```ts
// Bad
abstract class Exporter {
  run(rows: Row[]): string {
    return rows.map((r) => this.format(r)).join('\n');
  }
  protected abstract format(row: Row): string;
}
class CsvExporter extends Exporter {
  protected format(row: Row): string {
    return row.cells.join(',');
  }
}

// Good
type FormatRow = (row: Row) => string;
const formatCsv: FormatRow = (row) => row.cells.join(',');

function exportRows(rows: Row[], formatRow: FormatRow): string {
  return rows.map(formatRow).join('\n');
}
```

Closed set of behaviors: a lookup of functions, `FORMATTERS[kind]` (CF5). Open set: accept the function.

### CP3. Higher-order functions for cross-cutting concerns

Retry, caching, auth, logging, timing wrap functions. This replaces base classes and decorator hierarchies.

```ts
const getUser = withRetry(withCache(fetchUser, { ttlMs: 60_000 }), { attempts: 3 });
```

Each wrapper does one thing and composes with the others in any order.

### CP4. No god options objects

An options bag with mode strings, behavior flags, and keys that only apply when other keys are set is inheritance by configuration. Fixes, in order:

1. Split into one function per mode (FN3).
2. Make the input a discriminated union so the compiler enforces valid combinations.
3. Accept functions for the parts that vary (CP2).

```ts
// Bad: barWidth is meaningless for lines, nothing stops you passing it
createChart({ type: 'line', smooth: true, barWidth: 12 });

// Good
type ChartSpec =
  | { type: 'line'; smooth: boolean }
  | { type: 'bar'; barWidth: number };
```

### CP5. Compose in named stages

A pipeline is named functions called in order. Name the intermediate values when they carry meaning.

```ts
function publishPost(draft: Draft): Post {
  const valid = validateDraft(draft);
  const normalized = normalizeContent(valid);
  return persist(normalized);
}
```

A `pipe`/`flow` utility is fine if the codebase already has one. Point-free golf is not composition, it is compression.

### CP6. Pass effects into logic

Functions that contain decisions take their collaborators (clock, id generator, fetcher) as parameters so the core stays pure and testable. Thin shells at the boundary may import directly. `priceOrder(order, now)` beats `priceOrder(order)` calling `new Date()` inside.

## Reactive patterns

The whole model in one sentence: events flow in, pure functions fold them into state, everything else derives. Each rule below defends one arrow of that loop.

### RF1. One owner per fact, everything else derives

Classify every piece of state by its owner: server cache, URL, client store, local component. A fact lives in exactly one owner. Copying between owners (an effect writing store B when store A changes) is a sync bug with latency. Subscribe to the owner and compute.

### RF2. Events in, snapshots out

An external event source (WebSocket, timer, DOM) gets exactly one subscription point that reduces events into a store. Components never touch the raw source. They select the smallest slice of the store they need and re-render only when that slice changes.

### RF3. Updates are pure folds

The update function is `(state, event) => state` with no I/O inside. When a state change must cause an effect, the update returns a description and the shell executes it, or the effect subscribes to the state from outside. Never fetch inside a reducer.

### RF4. Immutable updates, stable references

Reactive layers detect change by reference. Produce new objects for what changed, keep the same references for what did not. Never mutate store state in place. This is DF6 with teeth: get it wrong and the UI silently stops updating, or updates far too much.

### RF5. Expected failures are values

Operations that fail in normal use (validation, not found, declined payment) return a result union instead of throwing:

```ts
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
```

Callers switch on `ok`, exhaustiveness applies, and the failure path is visible in every signature that carries it. Throwing is for bugs and truly exceptional conditions. A thrown error is a goto; a returned error is data.

### RF6. Coordinate async with combinators

Independent work runs in `Promise.all`. Fan-out that tolerates partial failure uses `allSettled`. Timeouts and racing use `AbortSignal.timeout` and `Promise.race`. Sequential `await`s are only for real data dependencies. Long-lived async work accepts an `AbortSignal` and honors it.

### RF7. Subscriptions are declarative and paired with cleanup

Subscribe through the layer built for it: store selectors, `useSyncExternalStore`, framework hooks. Subscription and cleanup live in the same expression or the same effect. An `addEventListener` without a visible matching removal is a leak in review, even when it happens to be fine.

## React and Next.js

### RX1. Component guards

Loading, error, empty, and unauthorized states return early, before the main JSX. One unconditional return at the bottom.

```tsx
// Bad
return (
  <div>
    {isLoading ? <Spinner /> : error ? <ErrorBox error={error} /> : items.length ? <List items={items} /> : <Empty />}
  </div>
);

// Good
if (isLoading) return <Spinner />;
if (error) return <ErrorBox error={error} />;
if (items.length === 0) return <Empty />;
return <List items={items} />;
```

### RX2. JSX conditionals

Two branches: one ternary. More than two: early returns, an extracted variable, or a subcomponent. Never nest ternaries in JSX. Use `&&` only with actual booleans: `items.length > 0 && <List />`, never `items.length && <List />` (renders `0`).

### RX3. Render by discriminant with a lookup

```tsx
const STATUS_VIEW = {
  idle: <IdleBadge />,
  syncing: <SyncSpinner />,
  error: <SyncError />,
} satisfies Record<SyncStatus, ReactNode>;

return <header>{STATUS_VIEW[status]}</header>;
```

### RX4. Hooks

A component updating four or more `useState` values together across branches gets a `useReducer`: all transitions in one function, one place where state changes. This is DF2 applied to React. Extract a custom hook per concern; a component wiring subscriptions, fetching, and form state at once is three hooks.

### RX5. Derived state is computed, never stored

Never `useState` plus `useEffect` to mirror props or other state. Compute during render, `useMemo` only if measurably expensive. An effect that sets state in response to another value changing is reassignment across renders, with extra render cycles as interest.

### RX6. Server Components

Parallelize independent fetches with `Promise.all`. Guard with `redirect()` and `notFound()`: they throw, so no `else` needed after them. Conditional data loading goes into extracted functions, not inline branching around `await`.

### RX7. Route handlers and server actions

Fixed order: parse and validate input (schema `safeParse`, early 400), authenticate and authorize (early 401/403), perform the effect, return the response. One `try/catch` around the effect if failure needs a custom response. The happy path appears exactly once, at the end.

### RX8. Compose components, do not configure them

A component sprouting boolean props (`isCompact`, `withIcon`, `asLink`, `noBorder`) is CP4 in JSX. Prefer separate components sharing internals (`Button`, `LinkButton`, `IconButton`), `children` and slot props for structure, and discriminated union props when variants change which fields are required. Hooks compose the same way: build `useOrderSync` out of `useSocket` and `useStore`, not one mega-hook with option flags.

## Refactoring playbook

When a rule fires, apply the matching move:

| Symptom | Move |
|---|---|
| Depth over 2 | Invert condition, return early; or extract the inner block |
| else-if chain on one value | Lookup table, or switch with exhaustiveness check |
| `let` assigned in branches | Ternary, lookup, or extracted function |
| Flag flipped inside a loop | `some`, `every`, `find` |
| Loop building an array | `map`, `filter`, `flatMap` (IT1) |
| `forEach` anywhere | Combinator for values, `for...of` for effects (IT2) |
| `while` without a termination bound | Max attempts, max pages, or a deadline (IT3) |
| Hand-rolled groupBy/dedup/debounce | Installed utility library (DP1) |
| Condition with 4+ operands | Named `const` or predicate function |
| Regex where a string method or parser works | `startsWith`/`includes`/`split`, `URL`, `JSON.parse` (SP1) |
| Two branches with identical bodies | Merge the conditions |
| Boolean parameter | Two named functions |
| `try` wrapping a whole body | Extract the fallible call, wrap only that |
| Nested ternary in JSX | Early returns, variable, or subcomponent |
| `useState` mirrored via `useEffect` | Compute during render |
| Several `useState` updated together | `useReducer` |
| Extracted function has a vague name | Wrong boundary; re-split by responsibility |
| Cryptic or single-letter name outside an index loop | Rename to the role (NM1) |
| Name over ~4 words | Drop type and history words (NM3) |
| Comment restating the code | Delete it, fix the name it papers over |
| Narration comment inside a function | Delete it, or extract a named function |
| Parallel booleans encoding phases | Discriminated union state (SM1) |
| State written from many handlers | One transition function (SM2) |
| Status checks scattered per handler | Transition map plus single guard (SM4) |
| Base class with overrides | Function parameter or HOF (CP2, CP3) |
| Options with interdependent keys | Union input or split functions (CP4) |
| Boolean prop explosion | Component composition (RX8) |
| Effect copying one store into another | Subscribe and derive (RF1) |
| Throwing for expected failures | Result union (RF5) |
| Sequential awaits, no data dependency | `Promise.all` (RF6) |

## Anti-gaming

These metrics are proxies for a reader's effort. Passing the number while making the code worse is failure. Do not:

- Split a function into `part1`/`part2` fragments to duck the budget. Every extraction must stand alone (FN4).
- Hide branching in a table of closures over shared mutable state. A `Record` of data or components is a lookup; a `Record` of stateful lambdas is a `switch` in disguise.
- Chain five array methods where one plain loop reads better. A `for...of` with two branches is fine and often clearer than a clever pipeline.
- Collapse statements into one dense expression to shrink line counts.
- Introduce new paradigms or libraries (RxJS, fp-ts, Effect, XState, Ramda) into a codebase that does not already use them. Plain TypeScript unions, closures, and async/await implement everything in this document. Proposing one is a flagged suggestion in your summary, never a silent import.

A flat exhaustive `switch` with 20 cases is fine. If you cannot meet a budget through meaningful refactoring, stop, keep the clearest version, and say so explicitly in your summary: the measured score and what blocks the reduction. Do not silently add a disable comment.

## Standards

- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would use the product. This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.
