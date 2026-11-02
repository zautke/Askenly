# Mobile MCP Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect Askenly on physical iPhone and iPad to remote Model Context Protocol (MCP) tool servers through reusable components imported from BraisenlyAI.

**Architecture:** Import the official Swift MCP SDK behind a BraisenlyAI adapter. Share a server/tool catalog and approval/execution boundary across provider-specific model adapters, preserving complete invocation/result history. Askenly supplies application configuration, native authentication presentation, and scene ownership.

**Tech Stack:** Swift, Swift Package Manager, Foundation URLSession Streamable HTTP, AuthenticationServices, Keychain, Observation/SwiftUI, Swift Testing, and the existing MLX/provider clients. Exact SDK/toolchain pins are conformance-gated in Task 1; a search result or open pull request is not a release guarantee.

**Spec:** [Mobile MCP design](../specs/2026-11-02-mobile-mcp-design.md).

**Status:** Research-backed proposal for review. No MCP product implementation is part of this documentation pull request. Evidence checked 2026-11-02; recheck upstream releases before execution.

**Verified toolchain:** Swift 6.4.2, Xcode 27.2. The current library fix-worktree manifest declares Swift tools 6.4 (confirmed by Codemunch); its reusable platform floors remain iOS 17/macOS 14, independently of Askenly's iOS 27 target. See [report 04](../../research/2026-11-02-mcp/04-swift64-apple-frameworks.md) for availability and evidence, including the correction to the initial tools-6.2 briefing.

## Global constraints

- iPad/iPhone first; remote Streamable HTTP endpoints are mandatory. No local stdio server launcher, helper daemon, mobile shell or loopback OAuth listener.
- Target official MCP `2026-07-28`, the latest revision verified on 2026-11-02. Show actual legacy compatibility explicitly; never simulate modern support with a header override.
- Public reusable code and views live in the existing `BraisenlyAI` product (`Sources/AI` inside sibling BraisenlySwiftUI package). Keep `BraisenlySwiftUI` presentation primitives provider/protocol independent.
- Preserve local MLX/LFM3 inference alongside remote MCP tools; the MCP network connection does not require cloud model inference. Never download model weights to largo.
- Preserve package floors iOS 17/macOS 14 unless a reviewed requirement proves a change necessary. Askenly currently declares iOS 27; do not conflate its app floor with the reusable package floor. Compile newer APIs behind explicit availability checks.
- Every endpoint, policy limit, timeout and feature setting has one configuration source. Organization-managed URLs come from `.env`-derived build configuration; editable server profiles use one persisted app configuration document. No duplicated host defaults.
- Access adagio services as `adagio.local`; any test service hosted there binds `0.0.0.0` with its unique configured port. No hardcoded address literals or local substitute services.
- Complete prerequisite pre-merge repairs and integrate by reviewed PR before branching implementation from `development`. Existing fix-worktree edits are not assumed merged or verified.
- Use `gh` for GitHub operations and Codemunch for indexed code navigation. All source copying needs a pinned origin and preserved applicable notices. Do not copy GPL/AGPL app code into the package without an explicit compatible licensing decision.
- Main promotion is separate. Merges to `development` receive a MINOR bump and PATCH reset, exactly three release numbers, and a `changeset.md` entry; existing review/live/ledger gates still apply.

## Review focus

1. Modern/legacy detection must not downgrade on an OAuth failure, timeout or malformed event (Task 1).
2. A disconnected write may already have succeeded remotely; a retry must not execute it twice automatically (Tasks 3 and 5).
3. Two servers can expose the same tool name; call IDs and routing must remain correct across catalog changes and model switches (Tasks 2 and 5).
4. Backgrounding one iPad scene must not cancel another scene's run or misdirect an approval/auth callback (Tasks 4 and 6).
5. Unsupported schemas or multimodal results must retain data and surface capability limits, rather than silently changing tool semantics (Tasks 2 and 5).

## Source reuse decisions

Import the official SDK package instead of copying protocol code into Askenly. Stable `0.12.1` is evidence for existing APIs only: reviewed official `main` still ends at `2025-11-25`. Evaluate open PR #314 (`aa545cb891262979cd800170b6037143d6409d02`) as a candidate, not as a conformant release. Do not pin its SHA to the official package URL without proving SwiftPM can fetch that revision from the selected repository.

Use ETOS LLM Studio as a lifecycle/approval architecture reference; its GPL code is not selected for import. CopilotChat's MIT model-loop pattern is worth testing conceptually, but its custom `2025-03-26` client is not the transport base. Ayna's inspected MCP implementation is macOS-only; OpenClient's documented MCP execution is backend-mediated. See complete candidate/source/license qualifications in the research logs.

Official SDK licensing is transitioning: new code is Apache-2.0, prior unconsented contributions retain MIT, and non-spec documentation is CC-BY-4.0. Capture the exact chosen revision's LICENSE/NOTICE and retain applicable notices; GitHub's `Other` label is not the license text.

## Task 1: Select and prove the protocol dependency

**Files:** Modify sibling `Package.swift` and `Package.resolved`; create `Tests/BraisenlyAITests/MCPProtocolCompatibilityTests.swift`; create `docs/protocols/MCP_COMPATIBILITY.md` in the library.

**Consumes:** Official revision, SDK release metadata, source and license at execution time.
**Produces:** A fetchable, exact reviewed SDK revision and a passing mobile-client compatibility matrix. No production callers depend on guessed candidate APIs.

- [ ] Recheck official `specification/latest`, `gh api repos/modelcontextprotocol/swift-sdk/releases/latest`, current `Versioning.swift`, and PR #314 merge/review status. Record publication and access dates separately.
- [ ] Write failing wire fixtures for modern `server/discover`, required request metadata/headers, JSON versus incremental SSE, `resultType`, structured outputs, pagination/cache fields, `subscriptions/listen`, multi-round-trip user input, and unsupported-version selection.
- [ ] Add legacy remote fixtures, including authorization failures that must not trigger downgrade and modern errors that must not trigger legacy initialization.
- [ ] Inspect candidate code for every fixture. Prefer a released official revision; otherwise propose the exact reviewed patch/fork provenance before production adoption. Missing modern semantics must be implemented and tested in the dependency boundary; never rename an older revision to claim compliance.
- [ ] Run the official client conformance harness plus `swift test --filter MCPProtocolCompatibilityTests`. Record exact commands, SDK/server SHAs and exclusions. Expected: all declared supported contracts pass; no unsupported capabilities advertised.
- [ ] Compile the imported product for iOS and the package floor, including Swift concurrency checks. Resolve shared transitive dependencies with the existing MLX graph; do not force mismatched dependency versions.
- [ ] Commit and push the dependency/conformance slice. Stop production integration if the newest required protocol cannot pass; preserve the finding and patch plan rather than quietly releasing older semantics.

## Task 2: Define lossless tools and durable history

**Create:** `Sources/AI/Tools/AIToolDefinition.swift`, `AIToolInvocation.swift`, `AIToolResult.swift`, `AIContentBlock.swift`.
**Modify:** `Sources/AI/Models/AIMessage.swift`, `AIChatRequest.swift`, `AIToolCall.swift`, `AIChatResponseEvent.swift`, and the conversation decoding tests.
**Tests:** `Tests/BraisenlyAITests/AIToolHistoryTests.swift`.

**Produces proposed package contracts:**

- `AIToolID(serverID: UUID, name: String)` is the canonical identity.
- `AIToolDefinition` carries that identity, display metadata, original `inputSchema: Data`, optional `outputSchema: Data`, and annotations retained as untrusted metadata.
- `AIToolInvocation` carries canonical `id: UUID`, `conversationID: UUID`, `runID: UUID`, `turnID: UUID`, `providerID: String`, original `providerCallID: String`, tool identity and `arguments: Data` (validated JSON object). Provider IDs are scoped by conversation/run/turn/provider, never used alone as persistent identity. The provider adapter maps that full scope to the canonical ID before dispatch.
- `AIToolResult` carries canonical `invocationID: UUID`, `content: [AIContentBlock]`, optional `structuredContent: Data` (any valid JSON), and a typed outcome. `AIContentBlock` preserves text, image, audio, embedded resource and resource-link representations and necessary metadata; unsupported future blocks retain raw JSON for display/export.
- `AIToolCall` remains the UI lifecycle summary, correlated to the execution record. It is not a replacement for structured history.

- [ ] Write fixtures that round-trip nested/nullable/array schemas and structured JSON scalars, multimodal/resource output, repeated provider string IDs across conversations/turns and two same-named tools on different servers. Assert results map only to the matching canonical invocation UUID and never overwrite another run's history.
- [ ] Implement the contracts and extend message/request/event storage additively. Old conversation JSON without new fields decodes with empty optional history; malformed history is preserved under the existing recovery policy.
- [ ] Implement stable reversible provider aliases with explicit collision rejection and original-name mapping; tests reject ambiguous concatenation.
- [ ] Test changing model adapters preserves the canonical tool/result linkage. No display-summary parsing may reconstruct arguments or results.
- [ ] Run `swift test --filter AIToolHistoryTests`; commit and push after expected passes.

## Task 3: Implement remote connections and catalog

**Create:** `Sources/AI/MCP/AIMCPServerConfiguration.swift`, `AIMCPServerStore.swift`, `AIMCPConnection.swift`, `AIMCPToolCatalog.swift`.
**Tests:** `Tests/BraisenlyAITests/AIMCPConnectionTests.swift`, `AIMCPToolCatalogTests.swift`.

**Consumes:** SDK pin from Task 1 and canonical types from Task 2.
**Produces:** `AIMCPConnection` actor with `discover() async throws`, `listTools(cursor: String?) async throws`, `call(_ invocation: AIToolInvocation) async throws -> AIToolResult`, and `disconnect() async`. SDK result types stay internal. `AIMCPToolCatalog.snapshot() async -> [AIToolDefinition]` returns the enabled, stable snapshot.

- [ ] Write failing tests for paginated lists, duplicate/looping cursors, auth-scoped cache invalidation, `ttlMs` expiry, scoped subscriptions, interrupted JSON/SSE frames, bounded response size and disconnect-during-discovery.
- [ ] Implement per-server actor ownership and generation checks so stale operations cannot publish into a replacement connection. Use SDK URLSession streaming; no custom HTTP stack or preflight reachability gate.
- [ ] Implement the single authoritative server profile store and injected configuration limits. Refresh subscriptions on foreground demand; share one listener per server only where the chosen protocol requires it.
- [ ] Distinguish transport, protocol and tool errors. Preserve original invocation identity for uncertain outcomes. Test no automatic mutating replay after a connection loss.
- [ ] Run `swift test --filter AIMCPConnectionTests` and `swift test --filter AIMCPToolCatalogTests`; commit and push.

## Task 4: Native authorization and approval

**Create:** `Sources/AI/MCP/AIMCPAuthorization.swift`, `AIMCPTokenStore.swift`; `Sources/AI/Tools/AIToolExecutor.swift`.
**Tests:** `Tests/BraisenlyAITests/AIMCPAuthorizationTests.swift`, `AIToolExecutorTests.swift`.

**Consumes:** Server configuration/connection and invocation/result types.
**Produces:** SDK authorization delegate backed by scene-anchored `ASWebAuthenticationSession`, an injected persistent token-store adapter, and `AIToolExecutor.execute(_ invocation: AIToolInvocation, conversationID: UUID) async throws -> AIToolResult`.

- [ ] Write authorization fixtures for resource/issuer discovery, proof key for code exchange (PKCE), callback/state validation, refresh single-flight, issuer change and user cancellation. Use native public-client registration; deployment supplies actual redirect and registration values.
- [ ] Bridge the selected SDK's actual auth API to AuthenticationServices. Use an availability-appropriate app/HTTPS callback; never start a localhost callback server. Keep network refresh off the main actor and presentation on it.
- [ ] Write approval tests: pending invocation executes zero times; allow executes once; deny/dismiss/cancel resolves the waiter without network execution; changing arguments/server identity invalidates approval. Server annotations cannot grant approval.
- [ ] Implement executor cancellation/error mapping and per-conversation limits. Approval state identifies both conversation and scene; one window cannot accept another's pending request.
- [ ] Run the two focused suites; commit and push. Native callback behavior remains a physical-device gate in Task 7.

## Task 5: Complete model-to-tool-to-model loops

**Modify:** `Sources/AI/Models/AIMultiProviderChatClient.swift`, `AIOnDeviceMLXChatClient.swift`, `AIOpenAICompatibleChatClient.swift`, `AIAnthropicChatClient.swift`, `AIFoundationModelsChatClient.swift`, `AIChatSession.swift`, `AIChatWorkspaceController.swift`.
**Create:** focused provider schema/result adapters only where each wire format needs them, under `Sources/AI/Tools/`.
**Tests:** `Tests/BraisenlyAITests/AIToolRoundTripTests.swift` with one fixture family per provider.

**Consumes:** Immutable catalog snapshot plus shared executor.
**Produces:** Tool-aware provider construction preserving existing text-only initializers; every enabled tool-capable provider emits a correlated call, awaits actual result and continues the same turn.

- [ ] First write a deterministic local-tool round trip through the MLX handler seam without weights: call ID/arguments preserved, approval awaited, result inserted, continued answer returned, and failure/denial distinct from success.
- [ ] Inject catalog/executor through controller/router construction. Keep tool schemas off the static global configuration provider and resolve them for each turn. Never duplicate execution loops at both SDK/model framework and outer host levels.
- [ ] Add OpenAI-compatible and Anthropic request/stream fixtures covering fragmented/multiple calls and result roles. Execute their declared tool operations through the same executor and map complete output with explicit representation limits.
- [ ] Verify current Apple Foundation Models Tool/dynamic-schema APIs and availability using report 04 plus exact SDK headers/docs. Implement the supported dynamic adapter or declare a visible per-model schema incompatibility; do not present an unsupported profile as fully tool-capable. Do not raise the package OS floor implicitly.
- [ ] Add tests for model switch, catalog refresh mid-turn, server removal, cancellation during approval/execution, bounded recursive calls, and reconnect after a possibly completed mutation. Persist the canonical execution record before reporting completion.
- [ ] Run `swift test --filter AIToolRoundTripTests`, then the complete library suite; commit and push. Numerical model/real-server execution is separately required on target hardware.

## Task 6: Importable mobile views and thin Askenly composition

**Create in library:** `Sources/AI/UI/AIMCPConnectionsView.swift`, `AIMCPToolApprovalSheet.swift`, `Sources/AI/MCP/AIMCPController.swift`.
**Modify in library:** `Sources/AI/UI/AIChatWorkspaceView.swift`, `AIModelSettingsSheet.swift`, `AIToolCallCard.swift`.
**Modify in Askenly:** `Askenly/AskenlyApp.swift`, `ContentView.swift`, and required project Info.plist/build configuration entries.
**Tests:** library presentation-state tests and `AskenlyUITests/AskenlyUITests.swift` native interaction flows.

**Consumes:** Injected services from Tasks 3–5.
**Produces:** Askenly composes reusable server management, enabled-tool list and approval views. It owns only deployment configuration and scene-level presentation routing.

- [ ] Test and implement add/edit/enable/disconnect/reconnect, empty/loading/error/denied states, negotiated revision display, tool selection, and request/result details using existing design primitives.
- [ ] Keep app-scoped server/auth/catalog ownership separate from scene-scoped chat and approval state. Write the two-window test: closing/backgrounding one scene does not cancel another's request or route its OAuth callback incorrectly.
- [ ] Handle scene background/foreground and local persistence explicitly. Stop optional listeners when no scene needs them; do not claim an ordinary SSE call survives suspension or force quit. Durable remote jobs use only a supported Tasks extension with persisted handles.
- [ ] Declare local-network purpose text when LAN endpoints are supported. Add only callback/associated-domain capabilities actually required by selected registration; validate hostname/TLS on device without broad transport-security bypasses.
- [ ] Verify Dynamic Type, VoiceOver order/status announcements, keyboard navigation, visible denial/cancel actions and reachable touch targets on both compact and resizable layouts. Implement relevant Axiom audit findings.
- [ ] Build both projects and run native UI fixtures; commit/push library and host slices, pinning Askenly to the reviewed library revision.

## Task 7: Physical-device interoperability and release evidence

**Files:** append-only project run ledger/test-metrics registry in kb; library `docs/protocols/MCP_COMPATIBILITY.md`; Askenly `docs/verification/` report and screenshots.

- [ ] Select first real remote server configuration and both lowest-supported physical device classes. Configure tests as public users encounter them; no prewarming or local weights on largo.
- [ ] On physical iPhone and iPad, exercise native sign-in/cancel, modern and legacy discovery, actual approved tool execution, tool error, user denial, unsupported schema, structured/multimodal result rendering and model continuation. Record exact app/library/SDK/server revisions.
- [ ] Capture screenshots before/after user actions; inspect native device logs and transport telemetry. Test Wi-Fi loss/restore, cellular transition, LAN permission denial, hostname/trust failure, lock/background/foreground, app termination/relaunch, two scenes and concurrent local MLX inference.
- [ ] Measure discovery latency, time to first tool result, cancellation-to-quiescence, duplicate execution count, peak/resident memory, suspension memory and transcript-restoration correctness. Register metrics once and append each later subsystem run; warning bands report findings rather than silently becoming gates.
- [ ] Run Axiom networking, concurrency, SwiftUI architecture/navigation, AI, accessibility and memory checks as applicable. Negative tests pass only when they produce exactly their declared failure.
- [ ] Address review bots against current project rules; re-run only checks affected by subsequent changes. No merge until required native verification and review are complete.
- [ ] Add the prescribed development changeset/version change and merge reviewed PRs to `development`. Main promotion uses its separate verification/version policy.

## Publication and evidence handoff

- [ ] Finalize four complete research logs and design with source-pinned provenance; label findings versus inference and tests not run.
- [ ] Copy this final plan body verbatim into the project kb and verify normalized note body against this file. If canonical kb is unavailable, stage the exact body using `~/.claude/deferred-kb-sync/README.md`; do not use an alternate kb.
- [ ] Record SHA-256 for local docs and normalized kb/deferred bodies in the research index. Commit/push the documentation branch and open a draft PR with all research, design and plan documents.

## Open deployment inputs

The first actual server endpoints, native OAuth registrations, minimum physical device models, approved output/round/concurrency limits and any durable Tasks requirement must be supplied or selected before the owning tasks execute. These are deployment inputs, not reasons to substitute older protocol support or a desktop-only architecture. Dependency choice is resolved by Task 1's evidence, not by an arbitrary SDK version in this proposal.
