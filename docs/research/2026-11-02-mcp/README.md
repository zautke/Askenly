# Askenly mobile MCP planning package

Research date: **2026-11-02**. Documentation only; implementation and physical-device verification have not run.

## Read first

- [Implementation plan](../../superpowers/plans/2026-11-02-mobile-mcp-integration.md)
- [Architecture and design](../../superpowers/specs/2026-11-02-mobile-mcp-design.md)
- [Repository and primary-source context](00-research-context.md)

## Four Luna/high research transcripts

| Report | Focus | Main result |
| --- | --- | --- |
| [01: Existing iOS AI implementations](01-ios-ai-implementations.md) | Actual app code, source revisions, licenses, reuse candidates | ETOS is the strongest lifecycle reference; CopilotChat is readable but protocol-stale; desktop/backend implementations are not direct mobile clients |
| [02: MCP implementation patterns](02-ios-mcp-patterns.md) | Official SDK/protocol alignment, candidate PR, schema/tool loops | Official protocol `2026-07-28` is newer than the released Swift SDK's support; conformance must precede adoption |
| [03: iOS internal architecture](03-ios-internal-architecture.md) | Sandbox, networking, scenes, background, native OAuth, LAN and memory | Direct remote HTTP, native authentication and explicit lifecycle ownership; local MLX and MCP must coexist on device |
| [04: Swift and Apple frameworks](04-swift64-apple-frameworks.md) | Released Swift/Xcode, availability and framework boundaries | Swift 6.4.2/Xcode 27.2 verified; package tools 6.4 confirmed; newer model APIs are individually availability-gated |

The tool limit allowed three researchers concurrently alongside the parent; the fourth ran as soon as a slot freed. Logs record real queries, sources, source/code qualifications, failed lookups, conclusions and limits. They are research audit trails, not claims of runtime verification. Corrections preserve original query history.

[Separate builder check](05-builder-check.md) found one material invocation-identity gap. The design/plan now preserve provider call IDs within their scope and correlate durable results with canonical UUIDs.

## Knowledge-base publication

The canonical kb connector returned internal errors. A direct write to the same `https://kb.braisenly.com/mcp` endpoint returned **HTTP 503 Service Unavailable**. No alternate knowledge base was used.

Every full research report, the context log, builder check, design and final plan is staged in `~/.claude/deferred-kb-sync/` using its established frontmatter schema. The report/plan body bytes match local docs exactly, including headings and whitespace. This is pending synchronization, not a claim that remote notes were successfully written. Existing SessionStart/SessionEnd hooks will retry and verify before deleting the queue files.

[Publication manifest](publication-manifest.json) records source paths, destination titles/directories, SHA-256 values and staging state. The final plan body SHA-256 is `50daf568b55846803836bfb98addcf9e489d7765f92132391bc9f0c76f938bce`.

## Validation and limits

Document link/path checks, manifest hashes, staged-body parity, scoped diff and whitespace checks ran before commit. Builds, protocol conformance, model inference and device tests were not run for this planning change. Those gates are defined in the plan. Previous pre-merge fixes remain separate worktrees and are not reported as completed by this research.

No process, server, browser tab or simulator was started for this planning task. Research agents completed; no agent is left running.
