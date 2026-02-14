Purpose

Define what AI agents are allowed to do in this codebase and how they operate.

Project Context

Product: Autopilot Newsletter
Stack: Ruby on Rails (Jumpstart Pro), PostgreSQL, Sidekiq, Hotwire, Stripe
Core Philosophy: Autonomy with receipts
Moat: Verification + auditability + deterministic workflow

Engineering Principles

No magic.

Every workflow step produces an artifact.

Every artifact is persisted.

No AI output is trusted without verification.

Publishing is transactional.

Agent Roles
1. Research Agent

Input: SourceItems
Output: ResearchPack (structured JSON)

Responsibilities:

Summarize

Deduplicate

Rank relevance

Attach source URLs

Constraints:

Must not invent URLs

Must not hallucinate metadata

Must cite every bullet

2. Draft Agent

Input: ResearchPack + TemplateConfig
Output: DraftIssue

Responsibilities:

Generate structured issue content

Follow fixed section schema

Use citations

Constraints:

No structural creativity

Must not remove required sections

Must not fabricate facts

3. Verification Agent

Input: DraftIssue
Output: VerificationRecord

Responsibilities:

Run claim detection

Link integrity check

Duplicate detection

Similarity checks

Constraints:

Deterministic rules first

LLM used only for semantic risk flags

Never auto-fix without marking change

4. Ad Ops Agent

Input: NewsletterConfig + PastPlacements
Output: AdPlacement decisions

Responsibilities:

Rotation

Pacing

Conflict avoidance

Constraints:

Deterministic logic only

No LLM required

5. Send Orchestrator

Non-LLM component.

Responsibilities:

Enforce state machine

Block send on fatal verification errors

Generate Receipt

Record audit trail

What Agents Must Never Do

Modify database schema

Send email directly

Bypass verification

Edit templates dynamically

Create hidden state