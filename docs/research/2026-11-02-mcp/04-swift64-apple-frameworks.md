# Swift and Apple framework fit for Askenly MCP

Checked 2026-11-02. This is currentness research and a design input for the iPhone/iPad application plus reusable `BraisenlyAI` components. It is not an implementation, dependency recommendation, build result, MCP interoperability proof, or device validation.

## Decisions for the plan

1. **Use Swift 6 language mode and the current released toolchain.** Swift 6.4.2 is the latest Swift release verified on the check date; Xcode 27.2 is the latest released Xcode. The installed host reports Apple Swift 6.4.2 and Xcode 27.2 build 27B52. A package declaring `swift-tools-version: 6.2` sets a package manifest compatibility floor; it does not pin the compiler to 6.2. Keep source compatible with the package's declared minimum, and validate strict concurrency using Swift 6 mode. No need to invent a 6.4-only requirement.
2. **Use Foundation `URLSession` for Streamable HTTP, with incremental bytes.** `URLSession.bytes(for:delegate:)` yields `URLSession.AsyncBytes`; inspect HTTP status and content type before parsing, consume SSE lines or JSON body incrementally, propagate task cancellation, and bound parser buffers. This API is available from iOS 15, below the app's stated iOS 17 floor. MCP message framing/session details still belong in the reusable transport, not SwiftUI views.
3. **Treat MCP transport and Apple model tool calling as separate interfaces.** Foundation Models `Tool` is a `Sendable` protocol for code called by a language model; it is not an MCP client or Streamable HTTP transport. A tool can delegate to a reusable MCP client, but remote MCP calls still need their own protocol validation, cancellation, authorization, and user-consent policy. Do not assume an arbitrary server-provided JSON Schema can be passed directly as a Foundation Models tool: `Tool.Arguments` is a Swift type conforming to `ConvertibleFromGeneratedContent`, and its `parameters` property is a `GenerationSchema`. `DynamicGenerationSchema` exists for runtime guided-generation schemas, but current official references do not establish a general dynamic adapter from arbitrary MCP tool schemas to `Tool` conformances. Validate this API boundary against the shipped SDK before designing a model-to-MCP bridge.
4. **Gate Apple Foundation Models separately from the app's iOS 17 floor.** Framework availability begins with iOS/iPadOS 26 and requires supported Apple Intelligence hardware for the system model. Basic on-device `SystemLanguageModel`, `LanguageModelSession`, guided generation, and tool calling are iOS 26-era APIs. iOS 27 adds `LanguageModel` provider integration, dynamic profiles, Private Cloud Compute model access, and new multimodal/tool experiences. These are additive optional capabilities, not prerequisites for remote MCP. Confirm exact per-symbol availability in the iOS 27 SDK; current docs and beta references can differ.
5. **Keep native OAuth browser-mediated.** `ASWebAuthenticationSession` is the system API for third-party web authentication and returns a callback to the initiating app's session. Use Authorization Code with PKCE for a native public client, state/issuer validation, and no client secret or localhost callback server. Current typed callback APIs support the app's iOS 17.4+ target; older callback-scheme API remains available but is deprecated in current docs. Store and refresh credentials inside the reusable auth component, not views.
6. **Use Observation with SwiftUI and adapt to available space.** `Observation` plus SwiftUI support starts at iOS/iPadOS 17 and macOS 14, matching the stated floors. `@Observable` models can be owned with SwiftUI `@State` and injected through `Environment`; views then update from properties they read. Use size classes and measured available space to adapt iPhone, iPad split view, and resizable multiwindow layouts. Keep connection/auth lifetime app-scoped and chat presentation state scene/conversation-scoped.
7. **Use Swift Testing for logic and XCTest/XCUITest for UI/device flows.** Swift Testing supports async tests and parameterized cases; test MCP protocol framing, schema conversion, cancellation and redaction/error policy deterministically with controlled transport inputs. UI/device checks remain necessary for OAuth presentation/callback, real-network streaming/path changes, iPad layout, local-network prompts, and memory/thermal behavior. Do not treat simulator or a parser unit test as proof of a real endpoint/device flow.
8. **MLX can bridge into Foundation Models on iOS 27, through a distinct optional open-source adapter.** Apple’s Foundation Models updates identify `MLXLanguageModel`; the `mlx-swift-lm` adapter README says it conforms to `FoundationModels.LanguageModel`, supports existing session guided generation, tool calling, and streaming, and requires an iOS/macOS/visionOS 27 SDK. That settles API existence, not product suitability: review the package/version, model loading/download behavior, capability support, memory use and license before adding it. It is unrelated to the remote MCP transport and is not required for that path.

## Release state and compatibility

Parent source verification addendum: Codemunch `get_file_content` read the current fix-worktree `Package.swift` header on 2026-11-02 and found `// swift-tools-version: 6.4`, not the 6.2 value in the delegated briefing. Preserve the iOS 17/macOS 14 platform floors, but use the actual Swift tools 6.4 manifest floor in the final plan. Askenly's current project target is iOS 27; references below to an iOS 17 app floor describe the reusable package compatibility requirement, not that app target. The historical briefing/query log is retained to show this correction.

GitHub routing addendum: initial connector searches below are retained as actual research history. Parent used `gh api repos/ml-explore/mlx-swift-lm/contents/Libraries/MLXFoundationModels/README.md` to confirm the adapter name, iOS 27 SDK requirement, tool/streaming support claims and direct-loader alternative. A `gh search code` query returned no results; that is not absence evidence. Behavior still needs testing at the selected pinned dependency revision.

| Item | Verified state on 2026-11-02 | Consequence |
|---|---|---|
| Swift language/toolchain | Swift 6.4.2 release announced Oct 30, 2026. `swift --version` locally reports `Apple Swift version 6.4.2 (swiftlang-6.4.2.1.9 ...)`. | Latest released Swift found; no later stable version surfaced in Swift.org/Swift Forums searches. |
| Xcode | Apple release page lists Xcode 27.2 (27B52) on Oct 29, 2026. Local `xcodebuild -version` reports Xcode 27.2, build 27B52. Xcode 27.2 Beta 2 notes/search-index entries are stale and must not be read as current channel state. | Current Xcode release provides iOS/iPadOS 27.2 SDK and Swift 6.4. |
| Xcode's deployment range | Apple's Xcode 27.2 support table says iOS/iPadOS deployment targets 15–27 and simulator/device support iOS 17+. | iOS 17 app floor remains within supported deployment range. |
| Swift package tools 6.2 | Supplied project briefing says reusable package declares Swift tools 6.2 and iOS 17/macOS 14 floors. Not independently reopened in this research pass. | Do not conflate manifest tools version with installed compiler version. Recheck manifest during implementation planning. |
| Askenly project iOS 27 | Supplied project briefing says app project targets iOS 27; not independently reopened here. | Check app target separately from package floor before selecting APIs; app targeting iOS 27 does not automatically raise reusable package's minimum. |
| Foundation Models | Apple introduced framework in OS 26. iOS 27 docs advertise external `LanguageModel` conformers and dynamic profiles. `Tool` reference was labeled preliminary/beta in the fetched page. | Basic tool API is available to an iOS 26+ guarded path; iOS 27-only provider/dynamic-profile APIs require availability gates and validation against final 27 SDK. Do not cite a beta page as evidence of a released API. |
| `URLSession.AsyncBytes` | Apple documents async byte streaming; API is available since iOS 15. | Compatible with iOS 17 package/app floor. |
| `ASWebAuthenticationSession` | Core API predates the app floor; typed callback API is available from iOS/iPadOS 17.4. | Use availability-aware callbacks if iOS 17.0–17.3 remain supported. |
| Observation / SwiftUI | SwiftUI Observation support starts at iOS/iPadOS 17 and macOS 14. | Directly fits stated library floors. |

The exact supported model/tool use remains bounded by device capability, user settings, OS version, and framework availability. Foundation Models is optional: remote model providers and remote MCP servers do not depend on Apple Intelligence being available.

## Swift concurrency guidance

- Make request, notification, tool, and parsed-result value types `Sendable` where they cross task/actor boundaries. Keep mutable HTTP/SSE parser state owned by one task or actor; do not share mutable buffers between a URLSession byte-consumer and UI.
- Treat `Tool`'s `Sendable` requirement as a real isolation contract. A model tool may run concurrently; immutable configuration or an actor-isolated service is a better fit than a mutable reference captured from a view.
- Keep view-facing state `@MainActor`/SwiftUI-observed and translate transport events into immutable/sendable updates. Do not do synchronous parsing, disk work, or inference on the main actor.
- Swift 6.2 introduced `NonisolatedNonsendingByDefault` as an upcoming feature and `@concurrent` to force execution away from the caller actor. Swift 6.4 does not make every async function a background thread; `async` means suspension, not automatic off-main execution. Avoid turning on upcoming language features just because the compiler supports them; choose based on package language-mode policy and verify semantics.
- Prefer structured task ownership and cancellation propagation. Cancelling an MCP call must stop the URLSession task and event parser. Actor reentrancy means revalidate connection/session generation after each `await`; reconnection may replace state while a request is suspended.
- Avoid `@unchecked Sendable`, `nonisolated(unsafe)`, and broad `@preconcurrency` imports as compiler-warning escape hatches. If a legacy delegate boundary forces an escape hatch, isolate it narrowly and verify runtime callback isolation.

## Foundation Models and MCP boundary

Apple Foundation Models can call a `Tool` implementation through `LanguageModelSession`; the tool's `call(arguments:)` may be async and its output feeds back into the model. The API therefore can mediate model-selected use of application capabilities, but it does not own MCP initialization, protocol version negotiation, HTTP headers, OAuth token refresh, server capabilities, SSE parsing, or request cancellation semantics.

The stable-looking API concept is still schema-typed around Swift conformance. Tool metadata contains a name, description, typed `Arguments`, and a `GenerationSchema`. Runtime `DynamicGenerationSchema` describes dynamically assembled structured-generation shapes. These two facts do not prove dynamic server tool declarations can be converted into arbitrary Swift `Tool` implementations at runtime. In particular, MCP JSON Schema has constructs, optionality, unions, output schemas, annotations, and evolving fields that may not map 1:1 to Foundation Models guided generation. Keep the reusable MCP catalog and result representation model-neutral. If Apple Foundation Models is later used to select MCP tools, use a deliberately bounded adapter and require policy/confirmation for side-effecting tools; never let a natural-language model decision silently authorize destructive or privacy-sensitive remote actions.

For custom local inference, iOS 27 has two evidenced bridges into Foundation Models: Apple's `CoreAILanguageModel` in `apple/coreai-models`, and the community `MLXLanguageModel` adapter in `ml-explore/mlx-swift-lm`. The latter declares a `FoundationModelsIntegration` SwiftPM trait and requires the iOS 27 SDK; the README's macro downloads model weights through Hugging Face, while its direct initializer permits a caller-supplied local weights location/loader. This makes MLX technically viable behind Foundation Models for later opt-in exploration. It still carries model-distribution, memory, cold-load, cancellation, and licensing decisions and should not be bundled into the remote MCP feature by default.

## Framework fit by capability

| Need | Recommended platform surface | Fit and constraints |
|---|---|---|
| Streamable HTTP | `URLSession` + `AsyncBytes` | Incremental delivery, task cancellation, HTTP status and headers available. MCP-specific line/event framing remains the client's job. |
| OAuth authorization | `ASWebAuthenticationSession` | System browser-mediated authorization callback; use PKCE for native public client. No local listener. |
| App-facing state | `Observation` + SwiftUI `@State`/`Environment` | Available at iOS 17/macOS 14; track only fields a view reads. Keep reusable transport free of SwiftUI dependencies. |
| Adaptive iPhone/iPad | SwiftUI environment size classes, `ViewThatFits`, standard containers | Adapt to current window dimensions and size-class changes; do not infer layout solely from device model. Validate Split View, Stage Manager/resizing, rotation, Dynamic Type, and accessibility on hardware/simulator. |
| On-device Apple model | Foundation Models (`SystemLanguageModel`, `LanguageModelSession`, `Tool`) | Optional iOS 26+ gated path and Apple Intelligence-capable hardware; not needed for MCP transport. |
| External provider behind Apple model API | Foundation Models `LanguageModel` provider / Dynamic Profiles | iOS 27+ according to current Apple docs; verify final SDK symbol availability and provider package constraints. Separate from MCP server connection. |
| Custom Apple-deployed LLM | Core AI or MLX through its Foundation Models adapter | Apple/Core AI adapter and MLX community adapter both target iOS 27 SDK. Separate packaging/runtime and memory evaluation; MLX adapter can fetch model weights through its loader. |
| Unit/integration checks | Swift Testing + injected URLSession/transport seam | Good for parser, protocol, policy, concurrency, and error cases; does not prove real OAuth/network/device behavior. |
| UI/device validation | XCTest/XCUITest + real iPhone/iPad | Required for system auth presentation, lifecycle, changing layouts, local network/TLS, permissions, and real performance. |

## Open questions / uncertainty

- The app/project/package version floors are relayed from the parent research brief rather than independently inspected. Confirm `Package.swift`, project build settings, and generated Info.plist before adding API use.
- Tool and dynamic-profile documentation includes preliminary material. This report treats iOS 27 as the latest platform release surfaced by Apple and `LanguageModel` provider support as iOS 27-era, but symbol-level availability annotations should be checked in Xcode 27.2's actual SDK before code design.
- No exact dynamic MCP-schema → Foundation Models Tool mapping was documented by Apple. Treat this as unresolved; do not assume `DynamicGenerationSchema` removes the compile-time `Tool.Arguments` requirement.
- `URLSession.AsyncBytes` is a byte stream, not a complete SSE or MCP parser. UTF-8 boundaries, CRLF/LF, multiline `data:` frames, comments, content type, JSON event formats, response status, server reconnection behavior, and cancellation need explicit protocol-level handling.
- Device-specific Apple Intelligence availability, rate limits, model revisions, prompt behavior, and memory vary. Model output requires evaluation, not exact-string unit assertions.
- Axiom skill guidance is not primary Apple API evidence; it shaped architecture and validation advice. Primary links below support availability/API claims.
- No implementation, dependency install, model download, build, or real-device validation was performed.

## Research transcript and activity

All queries below ran on 2026-11-02. This is the research activity log, including tool versions and failures; it excludes private reasoning.

### Local checks

- Working directory initially `/Volumes/MACDEV/Askenly`; working tree was clean (`git status --short` empty). Research artifact target is sibling repository `/Volumes/MACDEV/Askenly-mcp-plan/docs/research/2026-11-02-mcp/`.
- Listed and read relevant Axiom skill routers under `/Users/derp/.agents/claude/plugins/marketplaces/axiom-marketplace/axiom-codex/skills/`: `axiom-concurrency/SKILL.md`, `axiom-ai/SKILL.md`, `axiom-networking/SKILL.md`, `axiom-swiftui/SKILL.md`, `axiom-testing/SKILL.md`, and `axiom-apple-docs/SKILL.md`. Applied these as guidance for concurrency, model-vs-network boundaries, HTTP streaming, adaptive UI, tests, and official-source preference.
- Ran `swift --version`: `swift-driver version 1.168.6 Apple Swift version 6.4.2 (swiftlang-6.4.2.1.9 clang-2100.4.1.1)`, target `arm64-apple-macosx27.2.0`.
- Ran `xcodebuild -version`: `Xcode 27.2`, `Build version 27B52`; `xcode-select -p`: `/Applications/Xcode.app/Contents/Developer`.
- Inspected sibling plan's `00-research-context.md` and `03-ios-internal-architecture.md` for scope and avoid conflicting with existing work. No files in the app/library repositories were changed.

### Web searches and official source inspection

Searches submitted:

1. `site:swift.org Swift 6.4.2 release Swift 6.5 November 2026`
2. `site:developer.apple.com Xcode release notes Xcode 27 Swift compiler version November 2026`
3. `site:developer.apple.com/documentation/foundationmodels Tool DynamicGenerationSchema Foundation Models iOS 27`
4. `site:developer.apple.com/documentation/foundation/urlsession/bytes URLSession.AsyncBytes stream`
5. `site:developer.apple.com/documentation/authenticationservices ASWebAuthenticationSession iOS 17 OAuth callback URL`
6. `site:developer.apple.com/documentation/observation Observation framework iOS 17 SwiftUI`
7. `site:developer.apple.com/documentation/foundationmodels/tool Foundation Models Tool protocol availability iOS 26`
8. `site:developer.apple.com/videos/play Foundation Models dynamic profiles external model provider iOS 27`
9. `site:developer.apple.com/news/releases "Xcode 27.2" November 2026`
10. `site:developer.apple.com/documentation/xcode-release-notes "Xcode 27.2" Swift 6.4.2`
11. `site:developer.apple.com/documentation/foundationmodels/dynamicgenerationschema "iOS 26"`
12. `site:developer.apple.com/documentation/foundationmodels/languagemodel "iOS 27" external language model`
13. `site:developer.apple.com/documentation/testing Swift Testing supported platforms iOS 18`
14. `site:developer.apple.com/documentation/swiftui ViewThatFits iOS 16 availability size classes adaptive layout`
15. `site:developer.apple.com/documentation/foundation/urlsession/bytes(for:delegate:) iOS 15`
16. `site:developer.apple.com/documentation/foundationmodels/dynamicgenerationschema iOS 26 availability`
17. `site:github.com/apple "MLXLanguageModel" Foundation Models`
18. `site:developer.apple.com "MLXLanguageModel" Foundation Models`
19. `site:github.com/apple/coreai-models MLXLanguageModel`

Key retrieved evidence: Apple Xcode release listing says Xcode 27.2 (27B52) released Oct 29; Xcode system requirements lists SDK iOS 27.2, deployment iOS 15–27, Swift 6.4. Apple Swift Forums announcement says Swift 6.4.2 released Oct 30 and that Xcode 27.2 contains Swift 6.4.2. The local compiler/version checks agree. Search index also returned stale Xcode 27.2 beta notes; Apple Releases page resolves release-vs-beta ambiguity. Apple Foundation Models overview/API, SwiftUI Observation docs, URLSession docs, Authentication Services API, Swift Testing docs, iOS release notes, Apple Foundation Models update page and the MLX adapter README provided capability evidence. The GitHub repository search for `MLXLanguageModel Apple Foundation Models` returned zero repositories, but web search directly located the source README.

### Context7 queries

1. `mcp__context7__resolve_library_id` with `libraryName: "Swift"`, query `Swift 6.4 concurrency isolation Sendable and URLSession AsyncBytes documentation`; selected `/swiftlang/swift` (High source reputation; indexed version `swift-6.1.2-RELEASE`, so useful for concepts, not current release verification).
2. `mcp__context7__resolve_library_id` with `libraryName: "Apple Foundation Models"`, query `Foundation Models Tool protocol DynamicGenerationSchema tool schemas availability`; selected `/websites/developer_apple_foundationmodels` (High source reputation).
3. `mcp__context7__query_docs` for `/websites/developer_apple_foundationmodels`, language Swift, query `Foundation Models Tool protocol DynamicGenerationSchema runtime dynamically generated tools, Model availability and platform minimum versions in iOS 26 versus iOS 27`. Returned Apple's DynamicGenerationSchema guide, iOS 26 starting point and iOS 27 server-model availability examples.
4. `mcp__context7__query_docs` for `/swiftlang/swift-foundation`, language Swift, query `URLSession bytes(for:) AsyncBytes streaming HTTP response cancellation, headers, and Sendable behavior`. Result ranking was poor and returned unrelated ContiguousBytes content; used Apple's direct URLSession pages instead.
5. `mcp__context7__query_docs` for `/swiftlang/swift`, language Swift, query `Swift 6 language mode strict concurrency Sendable actor isolation changes Swift 6.4 and nonisolated async execution`. Returned Swift compiler diagnostics: `NonisolatedNonsendingByDefault` introduced in 6.2; `@concurrent` forces a switch to generic executor. Used Swift project docs for semantics, not release-state claims.

### GitHub searches

- `mcp__github__search_code` query: `repo:modelcontextprotocol/swift-sdk "2025-11-25" StreamableHTTPTransport`. Tool failed with `Authentication Failed: Requires authentication`; no code-search results were used.
- `mcp__github__search_repositories` query `modelcontextprotocol swift-sdk` succeeded and located official `modelcontextprotocol/swift-sdk`.
- `mcp__github__search_issues` query `repo:modelcontextprotocol/swift-sdk Streamable HTTP 2025-11-25`, sorted `updated`, succeeded. Results included open SDK issue #255 describing an HTTP POST waiter that can remain suspended when the corresponding request is cancelled, and closed PR #175 proposal details. This is implementation/issue evidence to inspect separately; issue descriptions are not proof of behavior in the latest release.
- Existing shared research context records latest official SDK release 0.12.1 (2026-05-07), checked `main` commit `727175f35c8a0554d9d61c372d4d0da48ebc8b91` ending at protocol `2025-11-25`, and PR #314 as open candidate. This subreport did not revalidate those repository files; use context doc's explicit evidence and current SDK audit before dependency choice.

## Sources

### Primary Swift / Apple documentation

- [Swift 6.4.2 release announcement](https://forums.swift.org/t/announcing-swift-6-4-2/90337)
- [Apple Xcode 27.2 release listing](https://developer.apple.com/news/releases/?id=10292026a)
- [Xcode SDK and system requirements](https://developer.apple.com/xcode/system-requirements/)
- [Apple Xcode release notes index](https://developer.apple.com/documentation/xcode-release-notes)
- [Foundation Models overview](https://developer.apple.com/documentation/foundationmodels)
- [Foundation Models Tool protocol](https://developer.apple.com/documentation/foundationmodels/tool)
- [DynamicGenerationSchema guide](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Bring an LLM provider to Foundation Models](https://developer.apple.com/documentation/foundationmodels/bringing-a-language-model-to-foundation-models)
- [Foundation Models updates](https://developer.apple.com/documentation/updates/foundationmodels)
- [Apple Core AI model adapter source](https://github.com/apple/coreai-models/tree/main/swift/Sources/CoreAILanguageModels)
- [MLXFoundationModels adapter README](https://github.com/ml-explore/mlx-swift-lm/blob/main/Libraries/MLXFoundationModels/README.md)
- [Core AI model in a Foundation Models session](https://developer.apple.com/documentation/foundationmodels/running-a-core-ai-model-in-a-foundation-models-session)
- [URLSession.bytes(for:delegate:)](https://developer.apple.com/documentation/foundation/urlsession/bytes%28for%3Adelegate%3A%29)
- [URLSession.AsyncBytes](https://developer.apple.com/documentation/foundation/urlsession/asyncbytes)
- [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
- [ASWebAuthenticationSession typed Callback API](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/callback)
- [Migrating to Observation in SwiftUI](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Observation framework](https://developer.apple.com/documentation/observation)
- [SwiftUI ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits)
- [SwiftUI size classes](https://developer.apple.com/documentation/swiftui/userinterfacesizeclass)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [Swift compiler diagnostics: nonisolated(nonsending) by default](https://docs.swift.org/compiler/documentation/diagnostics/nonisolated-nonsending-by-default/)
- [OAuth 2.0 for Native Apps (RFC 8252)](https://datatracker.ietf.org/doc/html/rfc8252)
- [Proof Key for Code Exchange (PKCE), RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636)

### Context / GitHub references

- [Official MCP Swift SDK releases](https://github.com/modelcontextprotocol/swift-sdk/releases)
- [Official Swift SDK issue #255](https://github.com/modelcontextprotocol/swift-sdk/issues/255)
- [Official Swift SDK PR #175](https://github.com/modelcontextprotocol/swift-sdk/pull/175)
- [Official Swift SDK PR #314](https://github.com/modelcontextprotocol/swift-sdk/pull/314)
