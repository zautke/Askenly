# Askenly MCP research context

Checked: 2026-11-02. This is a research activity log and evidence index, not an implementation or live compatibility claim.

## Request and scope

Research, architect, and plan Model Context Protocol (MCP) tool connections from Askenly through imported, reusable BraisenlyAI components. User clarified iPad/iPhone deployment first and remote Streamable HTTP endpoints as mandatory. No local subprocess launcher or gateway is needed in the mobile client. Four Luna/high agents investigate existing applications, MCP implementations, iOS architecture, and Swift/Apple frameworks. Each writes a full research log locally and to the canonical project knowledge base (kb), or its sanctioned deferred queue when unavailable.

## Repository observations

- Askenly root and BraisenlySwiftUI root are on newly created `development` branches at their existing `main` commits. Feature source remains in open pull requests and fix worktrees.
- Reviewed Askenly source in `/Volumes/MACDEV/Askenly-fix-build`: `AskenlyApp` owns `AIChatWorkspaceController`; `ContentView` embeds `AIChatWorkspaceView`.
- Reviewed library source in `/Volumes/MACDEV/BraisenlySwiftUI-fix-lfm3`. Incremental Codemunch indexing found 88 files and 1,289 symbols. Existing pre-merge fixes are uncommitted and unverified; this planning branch does not claim or replace their completion.
- `AIOnDeviceMLXChatClient` has injected tool specifications and an asynchronous handler in the fix worktree. `AIMultiProviderChatClient` constructs it without those arguments. `AIChatRequest` has no tool catalog; `AIMessage` has text and display-oriented tool calls, without durable provider call/result pairing. `AIToolCall` is a display status, not a complete execution record.
- Existing UI includes model settings, a reusable workspace, and tool-call cards. Extend these conventions; keep transport/protocol/model-loop logic out of Askenly views.

## Research activity

1. Loaded Superpowers brainstorming/writing-plans and Codemunch guidance. Used Codemunch resolve/index/plan/context/outline/symbol retrieval for source understanding. Stopped broad exploration at its shared budget warning.
2. Web searched official MCP specification and Swift SDK. Opened official `specification/latest`; it redirects to `2026-07-28`.
3. Queried Context7 `/modelcontextprotocol/swift-sdk` for transport, tools, version support, and native OAuth integration. Its indexed API still describes `Version.latest` as `2025-11-25`; this is SDK evidence, not the current protocol revision.
4. Used `gh api` for official SDK releases, `main` commit, Versioning.swift, Package.swift, and PR #314 metadata/files; used `gh search code` and `gh search prs`. Corrected one malformed PR search by using `--repo`.
5. Latest published SDK release returned by GitHub: `0.12.1`, published 2026-05-07. Reviewed `main` SHA `727175f35c8a0554d9d61c372d4d0da48ebc8b91`, dated 2026-10-31. Its version list ends at `2025-11-25`.
6. Official-repository PR #314 is open, head `aa545cb891262979cd800170b6037143d6409d02`, updated 2026-11-02. Its checklist is unchecked and no checks were reported. Proposed modern support is a candidate to inspect, not established conformance or a stable dependency recommendation.
7. Applied pertinent Axiom routes: networking and networking discipline, concurrency, SwiftUI architecture, AI, security/native authorization, accessibility, and background-processing guidance. Further framework-specific evidence belongs to agent reports.
8. Canonical kb project discovery returned an internal tool error. No backup/alternate memory server was used. Research and final plan must attempt canonical writes and stage complete bodies in `~/.claude/deferred-kb-sync/` if the outage persists.
9. User clarified mobile-first remote Streamable HTTP and requested four Luna/high researchers, full local/kb research logs, identical plan publication, then commit/push/draft PR. Three researchers ran concurrently; the fourth started as a slot freed. Their research activity reports are adjacent documents.
10. Verified official SDK LICENSE using `gh api`: licensing transition from MIT to Apache-2.0; new code/spec contributions Apache-2.0, unconsented prior contributions MIT, non-spec docs CC-BY-4.0. Dependency adoption must preserve exact selected-source notices.

## Primary evidence

- [Current official specification](https://modelcontextprotocol.io/specification/2026-07-28)
- [Revision changes](https://modelcontextprotocol.io/specification/2026-07-28/changelog)
- [Versioning and compatibility](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning)
- [Streamable HTTP](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http)
- [Tools](https://modelcontextprotocol.io/specification/2026-07-28/server/tools)
- [Authorization](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization)
- [Official Swift SDK 0.12.1](https://github.com/modelcontextprotocol/swift-sdk/releases/tag/0.12.1)
- [Version list at reviewed main commit](https://github.com/modelcontextprotocol/swift-sdk/blob/727175f35c8a0554d9d61c372d4d0da48ebc8b91/Sources/MCP/Base/Versioning.swift)
- [Modern SDK candidate PR #314](https://github.com/modelcontextprotocol/swift-sdk/pull/314)
- [Apple authentication sessions](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
- [Apple URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Apple local-network privacy](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy)

## Limits

No dependencies installed for this research, no models downloaded, no app implementation or device tests performed. Existing build processes and edits from the earlier repair task must be audited separately before any release. Search results, repository activity, and unmerged PR descriptions do not prove mobile compatibility, model quality, or protocol conformance. Agent reports and the final plan supersede provisional design choices in this context log.
