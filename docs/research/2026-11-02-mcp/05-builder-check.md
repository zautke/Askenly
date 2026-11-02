# Mobile MCP design builder check

Checked 2026-11-02 by a separate Luna/high builder-review agent. Scope: read the proposed design and implementation plan as an iOS/Swift package engineer, report only material questions that would change implementation. No product edits or tests.

## Finding

High: the draft used a provider tool-call string as the durable invocation ID. Those IDs may repeat across conversations and turns. Without a separate identity or composite scope, result correlation and persisted history can collide after model switches or later turns.

## Resolution

The design and Task 2 now require a canonical invocation UUID plus conversation, run, turn and provider scope, preserving the original provider call ID separately. Results use the canonical UUID; provider adapters restore the original ID only within its recorded scope. Regression fixtures explicitly repeat provider IDs across conversations and turns and assert no cross-run overwrite or routing.

The reviewer found no other material builder gap. Framework APIs remain gated on report 04 and the selected SDK's actual availability rather than future-API assumptions. This is a document review, not code or runtime verification.
