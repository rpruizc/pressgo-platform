# Issue Lifecycle Contract

This document defines the canonical workflow contract for newsletter issues across `DraftIssue` and `SentIssue`.

## Canonical States

The issue lifecycle uses the following states in order:

1. `ingested`
2. `research_ready`
3. `draft_ready`
4. `verification_ready`
5. `approved`
6. `scheduled`
7. `sent`
8. `failed`

## State Ownership

- `DraftIssue` owns: `ingested`, `research_ready`, `draft_ready`, `verification_ready`, `approved`, `scheduled`
- `SentIssue` owns: `sent`, `failed`

`sent` and `failed` are terminal states.

## Allowed Transitions

| From | To | Triggered by | Notes |
| --- | --- | --- | --- |
| `ingested` | `research_ready` | Job-triggered | Ingest/research pipeline completed with persisted research artifacts. |
| `ingested` | `failed` | Job-triggered | Ingest failed and cannot produce a research pack. |
| `research_ready` | `draft_ready` | Job-triggered | Draft generation completed and draft version persisted. |
| `research_ready` | `failed` | Job-triggered | Draft generation failed. |
| `draft_ready` | `verification_ready` | Job-triggered | Verification run completed and findings persisted. |
| `draft_ready` | `failed` | Job-triggered | Verification execution failed unexpectedly. |
| `verification_ready` | `approved` | User-triggered | Reviewer approval after non-fatal verification outcome. |
| `verification_ready` | `draft_ready` | User-triggered | Reviewer requests edits; draft is revised and re-verified. |
| `verification_ready` | `failed` | User-triggered | Reviewer explicitly rejects issue. |
| `approved` | `scheduled` | User-triggered or job-triggered | Manual schedule by user or autopilot scheduling job. |
| `approved` | `draft_ready` | User-triggered | Content changes after approval require re-verification. |
| `scheduled` | `sent` | Job-triggered | Send orchestrator sends successfully and records provider receipt. |
| `scheduled` | `failed` | Job-triggered | Send attempt fails or is blocked by fatal verification gate at send time. |

All other transitions are invalid and must be rejected.

## Verification Gate Behavior

Verification outcomes are grouped into two severities:

- Fatal findings:
  - Block transition to `approved`
  - Block transition to `sent`
  - Require a new draft revision and a new verification run before approval/sending
- Warning findings:
  - Do not automatically block transition to `approved` or `sent`
  - Must be visible to reviewer and captured in approval audit metadata

Publishing must never bypass verification. The send orchestrator must re-check the latest verification record before final send.

## Required Audit Artifacts by State

| State | Required artifacts |
| --- | --- |
| `ingested` | `ingest_run` record, source list, timestamps, counts, and ingest errors (if any). |
| `research_ready` | `research_pack` with citations/source URLs, ranking metadata, model/provider metadata, and token/cost metrics. |
| `draft_ready` | `draft_issue` content payload plus `draft_issue_version` snapshot with actor/reason metadata. |
| `verification_ready` | `verification_record` with overall status and persisted `verification_findings` per rule. |
| `approved` | Approval actor, timestamp, referenced verification record id, and warning acknowledgment metadata when applicable. |
| `scheduled` | Scheduled send timestamp, scheduler actor (user/job), and enqueue/job identifier. |
| `sent` | `sent_issue` final body, provider message id, sent timestamp, and immutable `receipt` payload. |
| `failed` | Failure code/message, failed step, actor/job id, retry metadata, and timestamped audit event. |

## Invariants

- State transitions are append-only audit events; transitions must be attributable to actor/job.
- Every transition must reference the artifact(s) required for the destination state.
- `failed` is terminal for a specific run attempt; recovery requires creating a new run path from a valid preceding state.
