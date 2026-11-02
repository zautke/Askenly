# iOS MCP patterns — research log

Checked 2026-11-02. Read-only external research; no source repo edits, builds, test runs, package installs, or local model/cache operations. This document records queries and evidence, not private reasoning.

## Finding

MCP's official current specification revision is `2026-07-28`. The official Swift SDK's latest tagged release remains `0.12.1` (tag commit `a0ae212`, released 2026-05-07), and its README plus `Versioning.swift` still say `2025-11-25` is latest. Therefore, today's stable official release does not meet the requirement to speak the newest MCP revision. The high-quality candidate is open upstream PR #314 at head `aa545cb891262979cd800170b6037143d6409d02`, but it is unmerged, untagged, large, and explicitly has unchecked test-plan boxes. Treat it as a review candidate, not as a conformant dependency.

Recommendation: plan the native integration around the official `MCP` package API and the existing BraisenlyAI model/tool seam, but gate adoption on an upstream tagged release (or an explicitly audited, pinned fork commit) that passes the 2026-07-28 conformance and app integration tests below. Do not make a gateway the default. `Askenly` itself is only a thin SwiftUI host; keep MCP connection, tool adaptation, and dispatch in the reusable BraisenlyAI layer.

## Evidence and queries

### Official spec and SDK

- Web search: `site:modelcontextprotocol.io spec latest 2026-07-28 Streamable HTTP`. Official spec index [https://modelcontextprotocol.io/specification/2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28) labels the revision and describes stateless per-request protocol/version/capability negotiation; consent section says hosts must obtain explicit user consent before tool invocation.
- Web search: `site:github.com/modelcontextprotocol/swift-sdk releases 0.12.1`. Official release page [https://github.com/modelcontextprotocol/swift-sdk/releases/tag/0.12.1](https://github.com/modelcontextprotocol/swift-sdk/releases/tag/0.12.1) identifies `0.12.1`, commit `a0ae212`, release date 2026-05-07. Repo license is listed as `Other`; review the repository `LICENSE` before redistribution.
- Context7 `resolve_library_id("Model Context Protocol Swift SDK", ...)` first matched generic official docs; resolving exact `swift-sdk` returned `/modelcontextprotocol/swift-sdk` (High reputation, 794 snippets). Query: “Use official MCP Swift SDK Client with HTTPClientTransport to connect to remote Streamable HTTP endpoint, list tools, map inputSchema and callTool. What are current release version and protocol version support? Include cancellation/authorizer headers.” Context7 returned `Version.supported` only `2025-11-25`, `2025-06-18`, `2025-03-26`, `2024-11-05`; `HTTPClientTransport` default protocol version is `Version.latest`, plus endpoint, URLSession configuration, streaming, OAuth authorizer, and per-request `requestModifier`. This independently confirms release/main API lag.
- Context7 initially resolved the generic protocol docs and returned Java examples. That result was not used for Swift API claims; exact Swift SDK library resolution was then performed and queried as above.
- Official README says SDK supports Swift 6/Xcode 16 and iOS 16+, and documents `Client`, `HTTPClientTransport`, `listTools`, `callTool`, OAuth authorizer and request modifier: [README at main](https://github.com/modelcontextprotocol/swift-sdk/blob/main/README.md).
- Official current main still states 2025-11-25 is latest in the README: [README](https://github.com/modelcontextprotocol/swift-sdk/blob/main/README.md); exact version source: [Versioning.swift at main](https://github.com/modelcontextprotocol/swift-sdk/blob/main/Sources/MCP/Base/Versioning.swift).

### PR #314 audit status

- GitHub issue search query: `repo:modelcontextprotocol/swift-sdk 314`. Found PR #314, “feat: dual-era MCP 2026-07-28 modern protocol profile.” `gh pr view 314 --repo modelcontextprotocol/swift-sdk --json number,state,title,headRefOid,baseRefOid,updatedAt,mergedAt,body,files,commits,reviews` reported OPEN, no reviews, not merged, head SHA `aa545cb891262979cd800170b6037143d6409d02`, last updated 2026-11-02 09:42 UTC.
- PR description claims: `server/discover`; per-request `_meta`; `resultType`; unsupported-version `-32022`; `subscriptions/listen` over stateful HTTP SSE; cancel closes parked stream; listen filter/cancel/complete-listen tests. The description's Swift test and manual test checklist remained unchecked. Claim is not verification.
- GitHub `gh pr view` listed 44 changed files and roughly 5,000 added lines, covering protocol types, client/server, stateless/stateful HTTP transports, OAuth, conformance harness, and tests. Size and concurrent OAuth/transport changes make an unreviewed snapshot risky to vendor wholesale.
- Exact source links pinned to that SHA: [Versioning.swift](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Sources/MCP/Base/Versioning.swift), [ModernProtocol.swift](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Sources/MCP/Base/ModernProtocol.swift), [Client.swift](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Sources/MCP/Client/Client.swift), [HTTPClientTransport.swift](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Sources/MCP/Base/Transports/HTTPClientTransport.swift), [subscriptions/listen implementation](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Sources/MCP/Server/SubscriptionsListen.swift), [ModernProtocolTests.swift](https://github.com/modelcontextprotocol/swift-sdk/blob/aa545cb891262979cd800170b6037143d6409d02/Tests/MCPTests/ModernProtocolTests.swift), [PR review/test status](https://github.com/modelcontextprotocol/swift-sdk/pull/314).
- The PR has dedicated protocol, transport, and server tests, but this research did not run them or inspect every changed line. The `gh` GitHub code-search command (`"MCP-Protocol-Version" language:Swift`) failed with “Requires authentication”; web pages, Context7 and `gh pr view`/`gh pr diff` were used instead. The failed code-search attempt is not evidence of absence.
- Review focus before adoption: prove all modern request/response metadata and `resultType` semantics, response/error version selection and required HTTP headers; JSON Schema fidelity; MRTR request correlation/response continuation and fail-closed behavior; `subscriptions/listen` filtering, reconnect/caching semantics and cancellation cleanup; exact dual-era negotiation with legacy peers; OAuth discovery/cache invalidation, issuer checks, PKCE, callback and cancellation on iOS. The PR description says it addresses multiple points, but these remain acceptance checks until CI/conformance results and a focused code review are available.

### Existing Swift implementations / alternatives

- GitHub repo search via `gh repo view` and web search found [redroostertech/SwiftAgent](https://github.com/redroostertech/SwiftAgent), described as a mobile-first Swift agent/tool SDK with MCP interoperability; HEAD `e535af5500187fc8bb46d272bc3a65ae6ca358ff`, last pushed 2026-04-21. Web result calls out a Streamable HTTP client transport and a Notes sample with local tools; useful host-app pattern. GitHub reports no declared license (`licenseInfo: null`), so reject as a dependency until licensing is clarified and inspect its current protocol revision before borrowing code.
- Found [chrischabot/codex-swift](https://github.com/chrischabot/codex-swift), HEAD `ce2ff9d09df5fc74a13cd2a9e041f7f93cfcd383`, Apache-2.0, pushed 2026-06-16. Its [MCP architecture note](https://github.com/chrischabot/codex-swift/blob/main/docs/MCP.md) describes config loading, starting clients, `tools/list`, registering proxies in a tool router, dispatching calls, and returning results into the agent loop. Useful dispatch/continuation pattern, but a macOS coding-agent harness, not an iOS client, and predates the July protocol revision. Do not import it as the iOS base.
- Search surfaced [gheydon/apple-mcp](https://github.com/gheydon/apple-mcp) and App Store Connect MCP projects. They are MCP **servers**, not native remote MCP clients, so they do not solve this task.
- Unofficial Swift SDK fork discussions and server-side gateway examples were not treated as a default architecture. The direct client-to-remote-server path remains the target; gateway can be a later deployment choice only if product constraints require it.

## Project fit

The supplied project context says BraisenlyAI already has MLX `toolSpecifications` plus an async handler seam, while the provider router does not connect that seam; Askenly is a thin SwiftUI host. The missing pieces are an MCP client/connection owner, remote tool discovery and JSON-schema-to-MLX-spec conversion, per-server namespacing, dispatch through the existing async handler, and feeding results/errors back to the same model turn. Reuse those seams; do not place protocol logic in SwiftUI views or fork unrelated app-server architecture.

Schema conversion must preserve JSON Schema constraints that MLX's `ToolSpecification` cannot express. Do not silently flatten enums, nested objects, required fields, arrays, nullable unions, or `additionalProperties`; either prove MLX supports them or reject/mark unsupported schemas before exposing a tool to the model. Preserve original input schema for validation at dispatch. Namespace tools by server to avoid collisions.

Consent belongs in the app host around invocation: show tool/server identity, purpose, and arguments; allow/deny; never auto-run side-effecting MCP tools merely because the model requested them. The SDK transport's `requestModifier`/authorizer is plumbing, not a consent UI. For native OAuth, use the SDK's OAuth authorization-code/PKCE facilities only if the callback flow can be bridged to iOS `ASWebAuthenticationSession` and app URL routing; confirm cancellation and issuer validation behavior on device.

## Adoption gate

1. Pin an official tagged version that declares `2026-07-28` support. If PR #314 is still pending, do not call its branch conformant by description; require upstream merge/tag or a separately approved, exact-SHA fork with reviewed license and green CI.
2. Run the official protocol conformance suite against both a current modern server and a legacy `2025-11-25` server. Record exact SDK SHA, test command, result, and known excluded/unsupported behaviors.
3. Add the five app-level tests below. Release claims require actual native device verification of OAuth redirect/cancel, tool approval, and network task cancellation.

## Five key tests

1. **Protocol version / discovery compatibility:** modern discovery with `2026-07-28`, unsupported-version response and retry, correct modern headers and per-request metadata; also connect to legacy server and verify legacy initialize/session behavior.
2. **Tool schema and discovery:** tools from multiple servers preserve namespacing and supported JSON Schema; unsupported schema shapes fail closed instead of producing a misleading MLX tool spec.
3. **Full tool turn + user approval:** model emits an MCP tool call, host presents arguments and waits; allow dispatches once and returns structured/text result plus `isError` to the model's continuation; deny causes no remote `tools/call`.
4. **Native OAuth:** authorization-code + PKCE via `ASWebAuthenticationSession`, state/issuer/redirect validation, token refresh/retry, and cancellation/denial return without hanging or logging the token.
5. **Cancellation and lifecycle:** cancel during tool call / `subscriptions/listen`; verify JSON-RPC cancellation where applicable, HTTP/SSE task teardown, no stale callbacks or duplicate events, and reconnect refresh works without leaks.

## Source and tool transcript

Commands / tool queries used:

- jCodemunch `plan_turn(repo: "zautke/Askenly", query: "Research whether Askenly thin SwiftUI host and BraisenlyAI provider can integrate official Swift MCP client; identify files/architecture context", model: "gpt-6.1-sol")` → high confidence; recommended SwiftUI host and test files; confirmed narrow host footprint.
- Context7 resolver, then exact official library `/modelcontextprotocol/swift-sdk`; query text recorded above. Initial generic match returned Java-only results and was discarded for Swift claims.
- GitHub code search (`gh search code` equivalent via GitHub MCP, query `"MCP-Protocol-Version" language:Swift`) → authentication required; no code results.
- GitHub issue search: `repo:modelcontextprotocol/swift-sdk 314` → PR #314 metadata and description.
- `gh pr view 314 --repo modelcontextprotocol/swift-sdk --json number,state,title,headRefOid,baseRefOid,updatedAt,mergedAt,body,files,commits,reviews` → open state, exact head SHA, changed files/commits, unchecked plan.
- `gh pr diff 314 --repo modelcontextprotocol/swift-sdk` filtered for `Version.latest`, `resultType`, `requestModifier`, `Cache-Control`, `subscriptions/listen`, `cancel`, `MRTR`, `OAuth`, `scope`, `PKCE`, `MCP-Protocol-Version`, and `schema` → reviewed targeted protocol/transport/auth diff excerpts; not full manual audit.
- `gh repo view`/`gh api .../commits/main` for SwiftAgent, codex-swift, official SDK → licenses where declared, pushed dates, exact heads.
- Web search queries: `site:modelcontextprotocol.io spec latest 2026-07-28 Streamable HTTP`; `site:github.com/modelcontextprotocol/swift-sdk releases 0.12.1`; `site:github.com/modelcontextprotocol/swift-sdk pull 314 aa545cb891262979cd800170b6037143d6409d02`; `site:github.com Swift MCP iOS app tools/list tools/call MCPClient HTTPClientTransport`; `site:github.com "toolSpecifications" MLX Swift MCP tools`.

## Unverified / limits

Parent verification addendum (2026-11-02): `gh api repos/modelcontextprotocol/swift-sdk/contents/LICENSE` returned a licensing-transition notice: new code/specification contributions are Apache-2.0; prior contributions without relicensing consent remain MIT; non-specification documentation is CC-BY-4.0. Use the [LICENSE at reviewed main SHA](https://github.com/modelcontextprotocol/swift-sdk/blob/727175f35c8a0554d9d61c372d4d0da48ebc8b91/LICENSE), not GitHub's `Other` classification, to record applicable notices. The earlier GitHub connector attempts above are retained as a truthful log; subsequent verification uses `gh` as requested. No failed search is evidence that an implementation is absent.

- No PR #314 tests or official conformance suite were run. No full source-by-source audit of the 44-file diff; claims from its description are marked as claims.
- No source-code inspection of BraisenlyAI was performed in this delegated research slice; project architecture note above is based on parent-provided context.
- SwiftAgent's reported client behavior is from public repo description/search snippet, not a line-by-line review; its license is undeclared in GitHub metadata.
- No device validation of `ASWebAuthenticationSession`, model-provider tool result continuation, UI consent, or task cancellation.
