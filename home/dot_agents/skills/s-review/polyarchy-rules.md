<!-- snapshot: 2026-07-17 | source: notion.so/polymarket/The-Polyarchy-Foundations-388d316c50d5807b9d12c74725c4a4e6 -->
# Polyarchy foundations: reviewable rules

Scope: Polymarket web apps on App Router with Cache Components.

## Data classes

- PF-class-1: Class 1 static-ish shell (titles, metadata, browse cards, stale display prices), Class 2 volatile (trading price, order book, scores), Class 3 user/session (positions, balances, auth, P&L).
- PF-class-2: Class 1: Server Components with `use cache`, prerendered shell.
- PF-class-3: Class 2: client island, owned by WebSocket descriptors plus `liveQueryOptions`. No shared server cache.
- PF-class-4: Class 3 never touches a shared cache. Client-owned or request-time private server frame only.
- PF-class-5: Any value the user can trade against is `cache: 'no-store'`, never cached.
- PF-class-6: Stale display-price seeds in the shell are fine. Trading prices are never cached.
- PF-class-7: Comments: cached Class 1 list plus Class 3 socket patches, never the high-frequency live store.
- PF-class-8: Never SSR a live value for the socket to overwrite. Seed from Class 1, then the socket takes over.

## Caching (Cache Components)

- PF-cache-1: `cacheComponents: true` is app-wide. No `export const dynamic`, `dynamicParams`, `revalidate`, or `fetchCache` anywhere.
- PF-cache-2: Caching is explicit via `use cache` boundaries. `fetch()` memoization is not caching.
- PF-cache-3: `use cache` functions are async, return serializable values, and never read `cookies()`, `headers()`, or `searchParams` inside; pass request values in from above.
- PF-cache-4: Shell content needs `expire >= 300`. `revalidate: 0` or `expire < 300` creates a dynamic hole that needs `<Suspense>`.
- PF-cache-5: `revalidateTag(tag, 'max')` for stale-while-revalidate, `updateTag(tag)` for read-your-own-writes. One-argument `revalidateTag(tag)` is deprecated.
- PF-cache-6: No `use cache: private` or `use cache: remote` without explicit approval.
- PF-cache-7: Use `connection()` (not `unstable_noStore`) before non-deterministic sync work. It cannot appear inside `use cache`; wrap the region in `<Suspense>`.
- PF-cache-8: Do not mix `experimental.ppr` branches with Cache Components.

## Data fetching

- PF-fetch-1: Server Components fetch through domain loaders (`data/<route>.ts`). No server-side passthrough proxy routes; delete them.
- PF-fetch-2: Project at the boundary (BFF or gateway). Never fetch a fat record and trim it in render.
- PF-fetch-3: No fat fetch for one field. Use a slim endpoint or projection.
- PF-fetch-4: No per-entity fetch loops. Batch by IDs in the BFF or gateway.
- PF-fetch-5: Parallelize independent fetches via sibling Server Components. No hand-built waterfalls.
- PF-fetch-6: Below-the-fold widgets go behind `next/dynamic` plus `<Suspense>`, never blocking the shell.
- PF-fetch-7: One owner per data class: cached shell, socket-owned live store, React Query for user data.
- PF-fetch-8: Seed client islands. First paint comes from the seed, never blank.
- PF-fetch-9: Zod-validate API responses and socket messages before they touch app state. On mismatch, log and refetch. Never write an invalid payload.
- PF-fetch-10: On reconnect, refetch full state. Never resume deltas after a gap.
- PF-fetch-11: Aggregation and fan-out belong in the BFF or gateway. One cross-network call from Vercel.

## Fetch boundary

- PF-http-1: All app JSON REST goes through the fetch boundary (`createJsonFetcher` / `fetchJson`). Raw `fetch()` only inside the boundary or framework-specific cases.
- PF-http-2: No axios in app data code.
- PF-http-3: No `res.json() as T` casts. The boundary parses with a Zod schema from `*.schema.ts`.
- PF-http-4: No `fetch().then(res => res.json())` without status handling and Zod parsing.
- PF-http-5: An intentionally unvalidated response passes `z.unknown()` explicitly, never omits the schema.
- PF-http-6: Authenticated calls use `authenticatedFetchJson`: bearer token, `no-store`, refresh once on 401, retry once. Features never hand-roll 401 retry.

## React Query

- PF-rq-1: No inline queries in components. Every query is a `queryOptions()` object in `data/` or a domain hook.
- PF-rq-2: Keys come from one central `qk` factory, never hand-typed. Parameters go into the key.
- PF-rq-3: One QueryClient. Global `onError` maps 401 to sign-in. Mutations declare `meta: { invalidates }`; no scattered `invalidateQueries` in `onSuccess`.
- PF-rq-4: Socket-owned keys (positions, balances, comments) use `staleTime: Infinity` and reconcile by invalidation. REST-only keys use finite stale times (events 30s, flags 10m).
- PF-rq-5: Class 2 live ticks never get a React Query key. They live in the per-URL store via `useLiveQuery`.
- PF-rq-6: Server seeding uses `<Hydrate>`/dehydrate, never `initialData`.
- PF-rq-7: Cacheable prefetch gets bare `<Hydrate>`. Request-time prefetch gets `<Suspense>` + `<Hydrate>`. Never blanket-wrap cacheable seeds in Suspense.
- PF-rq-8: Default hook is `useQuery`. `useSuspenseQuery` only for unseeded dynamic holes or the void-prefetch streaming case.
- PF-rq-9: Read with `select` slices. Prefetch page n+1 only on active pagination or hover intent.
- PF-rq-10: Socket writes React Query only via the Class 3 observer bind (`onMessage` -> `setQueryData`), with optimistic update, rollback, and periodic REST reconciliation.

## WebSocket / live data

- PF-ws-1: Product code never hand-rolls sockets. Live data goes through descriptors (`lib/ws/`) plus `liveQueryOptions` and `useLiveQuery`.
- PF-ws-2: One socket and one store per URL, module-scope manager, ref-counted, pinned on `globalThis` for HMR. Never a connection in component state or context.
- PF-ws-3: The connection is the only writer to its store. `onMessage` observers are read-only side effects.
- PF-ws-4: Components read derived slices with an equality fn, never the whole store. One shared descriptor per feed, no per-card sockets.
- PF-ws-5: Descriptors declare `schema`, `getKey`, `normalize`, `topics`, heartbeat, backoff-with-jitter reconnect, and `onReconnect: 'refetch'`.
- PF-ws-6: No socket or server data in Zustand app stores.

## State ownership

- PF-state-1: Zustand owns UI state only. `useState` owns local component state. `nuqs` owns URL state.
- PF-state-2: No new React Context for cross-component state.
- PF-state-3: No API values stored in `useState`.

## Auth

- PF-auth-1: The session token lives in an httpOnly cookie, read server-side only, tainted with `experimental_taintUniqueValue`. It never reaches client JS.
- PF-auth-2: Pages are not auth-gated by default. Operations guard via `useRequireAuth` and ask for sign-in.
- PF-auth-3: Mutation route handlers are public endpoints: require a session, validate the body with Zod, let the gateway authorize by token.
- PF-auth-4: Every Server Action argument, route handler body, and `searchParams` is Zod-validated on the server before business logic.
- PF-auth-5: `proxy.ts` is not the auth system. Redirects, rewrites, headers, coarse checks only. No slow data fetching. Node runtime.

## Structure

- PF-dir-1: Files follow the App Router, not a `features/` tree. Route-local code in `_components/` and `_lib/`. Loaders in `data/<route>.ts` with client-safe types in `data/<route>.types.ts`. WS core in `lib/ws/`, query in `lib/query/`, HTTP adapters in `lib/` or `data/http/`.
- PF-dir-2: First-party barrel `index.ts` files are banned. Boundaries: `import/no-restricted-paths` zones.
- PF-dir-3: Loaders are `server-only` guarded. Client components import types from `*.types.ts`, never the loader.
- PF-dir-4: The layered `data/<domain>/` module (schema, fetcher, mapper, snapshot, types) is a migration shape. Collapse to the thin loader as the gateway projects.

## Rendering and navigation

- PF-render-1: `<Suspense>` wraps uncached server data, `expire < 300` regions, per-user first frames, and code-split islands. Never wrap stale shell snapshots or seeded live islands.
- PF-render-2: `loading.tsx` is the whole-route fallback only. In-page holes use `<Suspense>`.
- PF-render-3: Pair boundaries with `error.tsx` and a root `global-error.tsx`.
- PF-render-4: Call `notFound()` or redirect before any Suspense boundary streams; the HTTP status commits at first flush.
- PF-render-5: Server-to-client props are plain serializable data: no class instances, functions, socket clients, or stores.
- PF-render-6: No slow async work in shared layouts.
- PF-nav-1: Internal navigation uses framework `<Link>` with typed routes. Never raw `<a>`, never `router.push` for a standard link.
- PF-nav-2: Mutations go through React Query `useMutation` to a route handler or gateway, not Server Actions. Reads stay cacheable GETs.
- PF-nav-3: Detail views over lists use intercepting plus parallel routes (`@modal` + `(.)route`).
- PF-nav-4: Keep route groups under one root layout unless a hard split with full reload is intended.

## Metadata and SEO

- PF-seo-1: Public Class 1 pages get `generateMetadata`, `sitemap.ts`, `robots.ts`, and `opengraph-image.tsx`.
- PF-seo-2: `generateStaticParams` only for stable enumerable params with real samples. Never `__placeholder__` samples. Omit for volatile slugs.
- PF-seo-3: Wrap loaders shared by `generateMetadata` and the page in React `cache()` so the upstream is hit once.
- PF-seo-4: Telemetry, audit, and analytics run in `after()`, never blocking the streamed response.

## Performance

- PF-perf-1: Fonts via `next/font`, route-scoped. Images via `next/image` with `remotePatterns`, `preload` (not deprecated `priority`), and `images.qualities` set.
- PF-perf-2: Third-party scripts use `next/script` at the smallest route scope, `lazyOnload` for non-critical vendors. Analytics, KYC, auth, and payment SDKs stay out of the shell path.
- PF-perf-3: Heavy client libraries (charts, SDKs, modals, chat) load via `next/dynamic` after intent. The shell must render without them.
- PF-perf-4: Never wrap the whole page in a client provider for one island.
- PF-perf-5: Field vitals via a `useReportWebVitals` island plus `webVitalsAttribution`. Bundle budgets tracked with `@next/bundle-analyzer` in CI.
- PF-perf-6: On Next 16.3, `partialPrefetching: true` next to `cacheComponents`. `<Link prefetch={true}>` only where a deeper first frame earns the server cost. `export const instant = false` only for intentionally blocking routes.

## Migration

- PF-mig-1: `next/router` becomes `next/navigation`. No `<Link legacyBehavior>`.
- PF-mig-2: `params`, `searchParams`, `cookies()`, `headers()`, `draftMode()` are async and must be awaited.
- PF-mig-3: Route handlers use Web `Request`/`Response`.
- PF-mig-4: US trading is custodial: unsigned JSON orders, bearer session. No wallet, no EIP-712, no clob-client. DeFi signing stays behind adapters.
