# PressGo Newsletter MVP — Implementation Task List

This plan is ordered for sequential execution. Each task is scoped to be completed in under 2 hours by a senior engineer.

## 1. Add Issue Lifecycle Contract
What to do: Define canonical workflow states and transitions for `DraftIssue` and `SentIssue` (e.g., `ingested`, `research_ready`, `draft_ready`, `verification_ready`, `approved`, `scheduled`, `sent`, `failed`) and document which transitions are user-triggered vs job-triggered.
Affected files/services:
- `docs/issue_lifecycle.md`
- `app/models/concerns/` (new concern placeholder for future implementation)
Acceptance criteria:
- Lifecycle states and allowed transitions are explicitly documented.
- Fatal vs warning verification behavior is documented and matches PRD intent.
- Required audit artifacts per state are listed.
Test verification:
- No code tests for this task; reviewer sign-off on lifecycle document completeness.

## 2. Create Newsletter Configuration Schema
What to do: Add migration for `newsletter_configs` scoped to account/team with fields for cadence, tone, story count, template key, autopilot flag, and default scheduling metadata.
Affected files/services:
- `db/migrate/*_create_newsletter_configs.rb`
- `db/schema.rb`
Acceptance criteria:
- Table exists with account foreign key and required columns.
- Defaults exist for tone, story count, and autopilot disabled.
- Indexes support account-level lookup and cadence queries.
Test verification:
- Model test for required fields and defaults in `test/models/newsletter_config_test.rb`.
- Migration/schema load passes in CI.

## 3. Create Source Connection Schema
What to do: Add migration for source definitions supporting RSS and URL watch pages, including status and last-sync metadata.
Affected files/services:
- `db/migrate/*_create_source_connections.rb`
- `db/schema.rb`
Acceptance criteria:
- Source type enum/constraint supports `rss` and `url_watch`.
- Fields include URL, active flag, and last fetched timestamp.
- Account scoping indexes are present.
Test verification:
- Model validation tests for URL presence/format in `test/models/source_connection_test.rb`.

## 4. Implement NewsletterConfig and SourceConnection Models
What to do: Add model validations, associations, and tenant scoping for newsletter settings and sources.
Affected files/services:
- `app/models/newsletter_config.rb`
- `app/models/source_connection.rb`
- `app/models/account.rb`
Acceptance criteria:
- `Account` has correct `has_many` associations.
- Validations enforce allowed tone/story count ranges.
- Source connection rejects unsupported source types.
Test verification:
- Association/validation tests in `test/models/newsletter_config_test.rb` and `test/models/source_connection_test.rb`.

## 5. Create Source Item and Ingest Run Schema
What to do: Add migrations for `source_items` (normalized content records) and `ingest_runs` (pipeline execution metadata).
Affected files/services:
- `db/migrate/*_create_source_items.rb`
- `db/migrate/*_create_ingest_runs.rb`
- `db/schema.rb`
Acceptance criteria:
- `source_items` stores URL, title, published_at, snippet, checksum/dedupe key, and source connection reference.
- `ingest_runs` stores start/end timestamps, status, counts, and error details.
- Uniqueness/index strategy exists for dedupe key per account.
Test verification:
- Model tests validating required fields and uniqueness in `test/models/source_item_test.rb`.
- Model tests validating status transitions in `test/models/ingest_run_test.rb`.

## 6. Add SourceItem and IngestRun Models
What to do: Implement model associations and basic helper methods for ingest metrics.
Affected files/services:
- `app/models/source_item.rb`
- `app/models/ingest_run.rb`
Acceptance criteria:
- Associations link account, source connection, and ingest run correctly.
- Ingest run supports statuses `queued/running/succeeded/failed`.
- Convenience scopes exist for recent successful runs.
Test verification:
- Unit tests for associations and scopes in `test/models/source_item_test.rb` and `test/models/ingest_run_test.rb`.

## 7. Create Research Pack Schema
What to do: Add migrations for `research_packs` and `research_pack_items` with versioning fields and traceability to source items.
Affected files/services:
- `db/migrate/*_create_research_packs.rb`
- `db/migrate/*_create_research_pack_items.rb`
- `db/schema.rb`
Acceptance criteria:
- Pack stores account, target issue date, status, model/provider metadata, and token/cost metrics.
- Items store bullet text, source URL, source item reference, rank, and included/excluded state.
- Unique constraint prevents duplicate rank within same pack.
Test verification:
- Model tests for item ordering and presence in `test/models/research_pack_item_test.rb`.

## 8. Create Draft Issue Schema with Version History
What to do: Add migrations for `draft_issues` and `draft_issue_versions` so edited/generated content is auditable.
Affected files/services:
- `db/migrate/*_create_draft_issues.rb`
- `db/migrate/*_create_draft_issue_versions.rb`
- `db/schema.rb`
Acceptance criteria:
- Draft links to account and research pack.
- Draft stores structured sections (intro, stories, quick hits, CTA) and state.
- Version table stores editor, change reason, and serialized content snapshot.
Test verification:
- Model tests for required sections serialization in `test/models/draft_issue_test.rb`.
- Version creation callback test in `test/models/draft_issue_version_test.rb`.

## 9. Create Verification Schema
What to do: Add migrations for `verification_records` and `verification_findings` to store per-rule outcomes and messages.
Affected files/services:
- `db/migrate/*_create_verification_records.rb`
- `db/migrate/*_create_verification_findings.rb`
- `db/schema.rb`
Acceptance criteria:
- Record links to draft issue and stores overall status.
- Findings store `rule_id`, `severity`, `status`, message, and metadata payload.
- Index supports querying fatal findings quickly.
Test verification:
- Model tests in `test/models/verification_record_test.rb` and `test/models/verification_finding_test.rb`.

## 10. Create Ad Ops Schema
What to do: Add migrations for `ad_slots`, `sponsors`, `sponsor_creatives`, and `ad_placements` with pacing and conflict metadata.
Affected files/services:
- `db/migrate/*_create_ad_slots.rb`
- `db/migrate/*_create_sponsors.rb`
- `db/migrate/*_create_sponsor_creatives.rb`
- `db/migrate/*_create_ad_placements.rb`
- `db/schema.rb`
Acceptance criteria:
- Slots support position key and active flag.
- Sponsors include conflict group/tag data and pacing limits.
- Placements link issue + slot + sponsor creative with timestamp.
Test verification:
- Model tests for associations and placement uniqueness in `test/models/ad_placement_test.rb`.

## 11. Create Sent Issue and Receipt Schema
What to do: Add migrations for `sent_issues` and `receipts`, including share token and approval metadata.
Affected files/services:
- `db/migrate/*_create_sent_issues.rb`
- `db/migrate/*_create_receipts.rb`
- `db/schema.rb`
Acceptance criteria:
- Sent issue stores final body, send status, sent timestamp, provider message id, and approver.
- Receipt stores share token, optional comments, and published visibility flag.
- Unique index exists for receipt share token.
Test verification:
- Model tests for token uniqueness and associations in `test/models/receipt_test.rb` and `test/models/sent_issue_test.rb`.

## 12. Wire Tenant Scoping and Authorization Policies
What to do: Add account scoping and policies for all new resources to ensure strict multitenant boundaries.
Affected files/services:
- `app/policies/*_policy.rb`
- `app/controllers/concerns/` (scoping helpers if needed)
- `test/integration/multitenancy_test.rb`
Acceptance criteria:
- Cross-account access to newsletter resources is blocked.
- Create/update/delete actions are limited to account members.
- Shareable receipt visibility follows published flag rules.
Test verification:
- Integration tests for unauthorized access in `test/integration/multitenancy_test.rb`.
- Policy tests per new resource in `test/policies/`.

## 13. Add Routes for Newsletter Domain
What to do: Add REST and member routes for setup, research packs, drafts, verification review, sends, receipts, ads, and autopilot settings.
Affected files/services:
- `config/routes.rb`
- `config/routes/*.rb` (if split by domain)
Acceptance criteria:
- Route set supports full flow from source setup to receipt view.
- Named routes exist for core dashboard links.
- Public receipt route is token-based and read-only.
Test verification:
- Routing tests in `test/controllers/` verifying key route mappings.

## 14. Implement Source Connections CRUD UI
What to do: Build controller/views for users to add/edit/remove RSS and URL watch sources in account settings.
Affected files/services:
- `app/controllers/source_connections_controller.rb`
- `app/views/source_connections/*.html.erb`
- `app/javascript/controllers/` (form UX enhancements)
Acceptance criteria:
- User can create RSS and URL-watch records from UI.
- Validation errors are shown inline.
- List view shows active/inactive and last sync time.
Test verification:
- System test in `test/system/source_connections_system_test.rb`.
- Controller tests for create/update/destroy in `test/controllers/source_connections_controller_test.rb`.

## 15. Build RSS Fetch Client
What to do: Implement service to fetch and parse RSS/Atom feeds into normalized item payloads with resilient error handling.
Affected files/services:
- `app/services/ingest/rss_fetch_client.rb`
- `app/services/ingest/normalizer.rb`
Acceptance criteria:
- Valid feeds return normalized item hashes.
- Malformed feeds fail gracefully with error codes/messages.
- Parser handles missing optional fields safely.
Test verification:
- Service unit tests with fixtures in `test/services/ingest/rss_fetch_client_test.rb`.

## 16. Build URL Watch Fetch Client
What to do: Implement service to fetch configured pages and extract candidate link/story elements for ingest.
Affected files/services:
- `app/services/ingest/url_watch_fetch_client.rb`
- `app/services/ingest/html_extractor.rb`
Acceptance criteria:
- Client extracts links/titles from a representative page fixture.
- Timeouts/network errors produce non-crashing failure results.
- Output conforms to shared normalizer schema.
Test verification:
- Service tests with HTML fixtures in `test/services/ingest/url_watch_fetch_client_test.rb`.

## 17. Implement Dedupe Service
What to do: Add deterministic dedupe logic combining canonical URL normalization and checksum matching.
Affected files/services:
- `app/services/ingest/dedupe_service.rb`
- `app/services/ingest/url_normalizer.rb`
Acceptance criteria:
- Duplicate URLs with query noise collapse to one canonical entry.
- Near-identical content hashes dedupe within same account window.
- Dedupe decisions are logged in ingest run stats.
Test verification:
- Unit tests for normalization/dedupe cases in `test/services/ingest/dedupe_service_test.rb`.

## 18. Create Ingest Orchestrator Job
What to do: Add background job that runs full ingest per account and source set, writes `ingest_runs`, and persists new `source_items` idempotently.
Affected files/services:
- `app/jobs/ingest_run_job.rb`
- `app/services/ingest/orchestrator.rb`
- `config/queue.yml`
Acceptance criteria:
- Job sets run status lifecycle correctly.
- Re-running same ingest window does not create duplicates.
- Failures persist error details for dashboard visibility.
Test verification:
- Job test in `test/jobs/ingest_run_job_test.rb`.
- Service integration test in `test/services/ingest/orchestrator_test.rb`.

## 19. Add Manual “Run Ingest” Trigger in UI
What to do: Add account-scoped action to enqueue ingest and show latest run status.
Affected files/services:
- `app/controllers/ingest_runs_controller.rb`
- `app/views/ingest_runs/index.html.erb`
- `app/views/dashboard/` (status panel)
Acceptance criteria:
- User can trigger ingest from UI.
- UI shows queued/running/success/failure and counts.
- Trigger is account-scoped and permission-checked.
Test verification:
- System test for triggering and status visibility in `test/system/ingest_runs_system_test.rb`.

## 20. Add LLM Provider Interface and Adapter Base
What to do: Implement provider-agnostic interface for text generation/summarization with structured response contract and cost metrics.
Affected files/services:
- `app/clients/llm/base_client.rb`
- `app/clients/llm/provider_client.rb`
- `config/initializers/llm.rb`
Acceptance criteria:
- Interface supports prompts, model key, and metadata output.
- Adapter returns standardized fields: content, tokens, cost, raw id.
- Provider errors are normalized for upstream handling.
Test verification:
- Client tests in `test/clients/llm/provider_client_test.rb` using stubs/mocks.

## 21. Implement Research Pack Prompt Builder
What to do: Build deterministic prompt assembly from source items and parse model output into 10–20 bullet records with citations.
Affected files/services:
- `app/services/research_pack/prompt_builder.rb`
- `app/services/research_pack/response_parser.rb`
Acceptance criteria:
- Output enforces bullet count bounds and includes source URL per bullet.
- Parser rejects malformed output cleanly.
- Prompt includes account tone and story-count preferences.
Test verification:
- Service tests for parser validation in `test/services/research_pack/response_parser_test.rb`.

## 22. Implement Research Pack Generator Service + Job
What to do: Add service/job that creates `research_packs` and `research_pack_items` from recent source items.
Affected files/services:
- `app/services/research_pack/generator.rb`
- `app/jobs/research_pack_generate_job.rb`
Acceptance criteria:
- Job creates one pack per account + target date window.
- Pack captures provider, token usage, and cost.
- Errors set pack status to failed with reason.
Test verification:
- Job test in `test/jobs/research_pack_generate_job_test.rb`.
- Service test in `test/services/research_pack/generator_test.rb`.

## 23. Build Research Pack Review Screen
What to do: Create UI for viewing generated bullets and allowing quick include/exclude before drafting.
Affected files/services:
- `app/controllers/research_packs_controller.rb`
- `app/views/research_packs/show.html.erb`
- `app/javascript/controllers/research_pack_controller.js`
Acceptance criteria:
- User can toggle include/exclude per bullet in under a minute.
- Each bullet displays summary + source link.
- Save action persists selection changes.
Test verification:
- System test for include/exclude flow in `test/system/research_pack_review_system_test.rb`.

## 24. Add Template Configuration Artifact
What to do: Define fixed newsletter template schema and seed default template options (daily/weekly) per PRD format.
Affected files/services:
- `config/newsletter_templates.yml`
- `db/seeds.rb`
- `app/models/newsletter_config.rb`
Acceptance criteria:
- Template schema includes intro, 3–5 stories, quick hits, CTA.
- Newsletter config references template key.
- Invalid template keys are rejected.
Test verification:
- Model/config tests in `test/models/newsletter_config_test.rb` and `test/lib/newsletter_templates_test.rb`.

## 25. Implement Draft Generation Service
What to do: Build generator that converts selected research bullets + template into structured `draft_issues` content.
Affected files/services:
- `app/services/draft_issue/generator.rb`
- `app/jobs/draft_issue_generate_job.rb`
Acceptance criteria:
- Generated draft always includes required sections.
- Draft references originating research pack and selected items.
- Generation metadata (provider/model/cost) is persisted.
Test verification:
- Service and job tests in `test/services/draft_issue/generator_test.rb` and `test/jobs/draft_issue_generate_job_test.rb`.

## 26. Build Draft Review/Edit UI
What to do: Add draft detail page with sectioned content, inline edit controls, and save/version behavior.
Affected files/services:
- `app/controllers/draft_issues_controller.rb`
- `app/views/draft_issues/show.html.erb`
- `app/views/draft_issues/_form.html.erb`
Acceptance criteria:
- User can edit sections without breaking required structure.
- Save creates a new draft version record.
- UI shows latest verification status badge placeholder.
Test verification:
- System test for edit/save/versioning in `test/system/draft_issues_system_test.rb`.

## 27. Implement Broken Link Verification Rule
What to do: Add rule service that checks reachability/status codes for source links referenced in draft.
Affected files/services:
- `app/services/verification/rules/broken_link_rule.rb`
- `app/services/verification/http_checker.rb`
Acceptance criteria:
- Broken/unreachable links produce findings with severity and message.
- Timeouts are handled as warnings with guidance.
- Rule execution is deterministic and repeatable.
Test verification:
- Rule tests using HTTP stubs in `test/services/verification/rules/broken_link_rule_test.rb`.

## 28. Implement Required Section Completeness Rule
What to do: Add rule service that asserts all required sections are present and non-empty.
Affected files/services:
- `app/services/verification/rules/section_completeness_rule.rb`
Acceptance criteria:
- Missing required sections create fatal findings.
- Empty sections below minimum length are flagged.
- Rule reports section-level details.
Test verification:
- Unit tests in `test/services/verification/rules/section_completeness_rule_test.rb`.

## 29. Implement Recent-Issue Duplicate Story Rule
What to do: Add rule service to detect repeated stories against recent `sent_issues` within configurable lookback window.
Affected files/services:
- `app/services/verification/rules/recent_duplicate_rule.rb`
- `app/services/verification/similarity_matcher.rb`
Acceptance criteria:
- Reused links/titles across recent issues are flagged.
- Lookback period is configurable at account level or app config.
- Rule output includes matched historical issue references.
Test verification:
- Rule tests with fixtures in `test/services/verification/rules/recent_duplicate_rule_test.rb`.

## 30. Implement Claim Risk Flag Rule (Warning Only)
What to do: Add semantic risk detection for medical/financial/high-risk claims with warning-level findings.
Affected files/services:
- `app/services/verification/rules/claim_risk_rule.rb`
- `app/clients/llm/provider_client.rb`
Acceptance criteria:
- Rule never marks findings as fatal in MVP.
- High-risk phrases generate actionable warning messages.
- Rule can be skipped/fallback safely if provider unavailable.
Test verification:
- Unit tests with mocked LLM output in `test/services/verification/rules/claim_risk_rule_test.rb`.

## 31. Implement Single-Source Similarity Rule
What to do: Add rule to detect near-copying from one source using text similarity thresholds.
Affected files/services:
- `app/services/verification/rules/source_similarity_rule.rb`
Acceptance criteria:
- Drafts overly similar to one source generate warning findings.
- Threshold is configuration-driven.
- Finding references implicated source URL.
Test verification:
- Unit tests for threshold boundaries in `test/services/verification/rules/source_similarity_rule_test.rb`.

## 32. Build Verification Orchestrator
What to do: Implement orchestrator that runs all rules, persists `verification_records/findings`, and computes overall pass/warn/fail status.
Affected files/services:
- `app/services/verification/orchestrator.rb`
- `app/jobs/verification_run_job.rb`
Acceptance criteria:
- Rules execute in deterministic order.
- Overall status escalates to fail when fatal findings exist.
- Each run is timestamped and linked to draft version.
Test verification:
- Orchestrator tests in `test/services/verification/orchestrator_test.rb`.
- Job tests in `test/jobs/verification_run_job_test.rb`.

## 33. Add Verification Results UI + Send Gating
What to do: Render findings in draft review and enforce send blocking on fatal findings while allowing warning-only sends.
Affected files/services:
- `app/views/draft_issues/show.html.erb`
- `app/controllers/sent_issues_controller.rb`
- `app/helpers/` (status badge helpers)
Acceptance criteria:
- Findings are grouped by severity and rule.
- “Send” action is disabled/blocked for fatal status.
- Warning guidance text is visible before approval.
Test verification:
- System test for blocking/allowing send in `test/system/verification_gating_system_test.rb`.

## 34. Add Sponsor and Creative Management UI
What to do: Build CRUD UI for sponsors and ad creatives (name, link, copy, active state, conflict group).
Affected files/services:
- `app/controllers/sponsors_controller.rb`
- `app/controllers/sponsor_creatives_controller.rb`
- `app/views/sponsors/*.html.erb`
- `app/views/sponsor_creatives/*.html.erb`
Acceptance criteria:
- User can create and manage sponsor inventory per account.
- Required creative fields validated.
- Inactive creatives are excluded from rotation.
Test verification:
- System tests in `test/system/sponsors_system_test.rb`.
- Controller tests in `test/controllers/sponsors_controller_test.rb`.

## 35. Add Ad Slot Configuration UI
What to do: Build UI to configure 2–4 template ad slots and assign slot rules.
Affected files/services:
- `app/controllers/ad_slots_controller.rb`
- `app/views/ad_slots/*.html.erb`
Acceptance criteria:
- User can create slot keys/positions.
- Slot limits enforce max configured count for MVP.
- Slot state (active/inactive) is reflected in draft/send flow.
Test verification:
- System tests in `test/system/ad_slots_system_test.rb`.

## 36. Implement Ad Rotation and Pacing Engine
What to do: Add deterministic selection service that cycles creatives, applies pacing caps, and enforces conflict exclusion.
Affected files/services:
- `app/services/ad_ops/selector.rb`
- `app/services/ad_ops/pacing_service.rb`
Acceptance criteria:
- Selector avoids over-serving one sponsor beyond configured limit.
- Conflict groups are not co-selected in same issue.
- Selection is reproducible for same input state.
Test verification:
- Service tests for rotation/pacing/conflict scenarios in `test/services/ad_ops/selector_test.rb`.

## 37. Persist Ad Placements During Send Prep
What to do: Integrate ad selection into pre-send flow and create `ad_placements` records tied to draft/sent issue.
Affected files/services:
- `app/services/send_flow/ad_placement_step.rb`
- `app/models/ad_placement.rb`
Acceptance criteria:
- Each active slot has zero or one resolved placement.
- Placements are persisted before send dispatch.
- Placement failures are surfaced in send status.
Test verification:
- Integration tests for placement persistence in `test/services/send_flow/ad_placement_step_test.rb`.

## 38. Implement Email Provider Adapter
What to do: Add outbound delivery adapter for SMTP (or chosen single provider) with standardized response contract.
Affected files/services:
- `app/clients/email/base_client.rb`
- `app/clients/email/smtp_client.rb`
- `config/initializers/email_provider.rb`
Acceptance criteria:
- Adapter can send HTML/text payload with subject and recipients.
- Delivery response includes provider message id and status.
- Failures return normalized error format.
Test verification:
- Client tests with mocked SMTP interactions in `test/clients/email/smtp_client_test.rb`.

## 39. Build Send Orchestrator Transaction
What to do: Implement orchestrator sequence: verify status check -> ad selection -> approval capture -> send dispatch -> sent issue persistence.
Affected files/services:
- `app/services/send_flow/orchestrator.rb`
- `app/controllers/sent_issues_controller.rb`
- `app/jobs/send_issue_job.rb`
Acceptance criteria:
- Send is blocked if latest verification is fatal.
- Approval user and timestamp are always recorded.
- On successful send, `sent_issues` and linked receipt record are created.
Test verification:
- Service integration tests in `test/services/send_flow/orchestrator_test.rb`.
- Controller test for approval/send endpoint in `test/controllers/sent_issues_controller_test.rb`.

## 40. Add Schedule-Later Send Support
What to do: Add optional scheduling UI and delayed job dispatch for approved drafts.
Affected files/services:
- `app/controllers/scheduled_sends_controller.rb`
- `app/jobs/scheduled_send_job.rb`
- `app/views/draft_issues/show.html.erb`
Acceptance criteria:
- User can choose immediate send or future timestamp.
- Scheduled job respects account timezone/cadence settings.
- Scheduled status is visible in dashboard list.
Test verification:
- Job test in `test/jobs/scheduled_send_job_test.rb`.
- System test for scheduling flow in `test/system/scheduled_send_system_test.rb`.

## 41. Implement Receipt Builder Service
What to do: Create service to compile receipt payload from sent issue, sources, verification findings, ads, approver, and timestamps.
Affected files/services:
- `app/services/receipts/builder.rb`
- `app/models/receipt.rb`
Acceptance criteria:
- Receipt payload includes all required proof-of-work fields from PRD.
- Missing optional fields degrade gracefully.
- Receipt generation is idempotent per sent issue.
Test verification:
- Service tests in `test/services/receipts/builder_test.rb`.

## 42. Build Shareable Receipt Page
What to do: Add tokenized public receipt route and view with optional comments and visibility control.
Affected files/services:
- `app/controllers/receipts_controller.rb`
- `app/views/receipts/show.html.erb`
- `config/routes.rb`
Acceptance criteria:
- Receipt page renders issue details, sources, checks, ads, send info, and approver.
- Share URL uses non-guessable token.
- Hidden/unpublished receipts return not found/unauthorized behavior.
Test verification:
- Controller tests for token access in `test/controllers/receipts_controller_test.rb`.
- System test for shareable view in `test/system/receipts_system_test.rb`.

## 43. Add Post-Send Notifications
What to do: Notify account users on successful send and on verification-risk events requiring attention.
Affected files/services:
- `app/notifiers/issue_sent_notifier.rb`
- `app/notifiers/verification_flag_notifier.rb`
- `app/views/` notification partials
Acceptance criteria:
- Success notification includes receipt link.
- Warning notification includes top findings and next actions.
- Notifications are account-scoped.
Test verification:
- Notifier tests in `test/notifiers/issue_sent_notifier_test.rb` and `test/notifiers/verification_flag_notifier_test.rb`.

## 44. Build MVP Operations Dashboard
What to do: Implement dashboard sections for scheduled issues, recent sends, recent receipts, and failures/flags.
Affected files/services:
- `app/controllers/dashboard_controller.rb`
- `app/views/dashboard/show.html.erb`
- `app/helpers/dashboard_helper.rb`
Acceptance criteria:
- Dashboard shows account-scoped scheduled, sent, and failed items.
- Each row links to draft, sent issue, or receipt detail.
- Empty states are user-friendly and actionable.
Test verification:
- System test in `test/system/dashboard_system_test.rb`.

## 45. Add Autopilot Settings UI
What to do: Add account-level toggle and schedule configuration for autopilot, gated behind minimum trust condition (e.g., prior sends).
Affected files/services:
- `app/controllers/autopilot_settings_controller.rb`
- `app/views/autopilot_settings/edit.html.erb`
- `app/models/newsletter_config.rb`
Acceptance criteria:
- User can enable/disable autopilot and set cadence/time.
- UI explains prerequisites and risk warnings.
- Setting changes are audited with timestamp/user.
Test verification:
- System test for toggle flow in `test/system/autopilot_settings_system_test.rb`.

## 46. Implement Autopilot Scheduler Job
What to do: Create recurring scheduler job that selects due accounts and enqueues full pipeline execution.
Affected files/services:
- `app/jobs/autopilot_scheduler_job.rb`
- `config/recurring.yml`
- `config/schedule.rb`
Acceptance criteria:
- Due accounts are selected by cadence and local send time.
- Disabled autopilot accounts are skipped.
- Enqueue metrics are logged.
Test verification:
- Job tests for due/skip logic in `test/jobs/autopilot_scheduler_job_test.rb`.

## 47. Implement Autopilot End-to-End Pipeline Job
What to do: Add job/service to run ingest -> research -> draft -> verification -> send automatically with failure isolation and notifications.
Affected files/services:
- `app/jobs/autopilot_run_job.rb`
- `app/services/autopilot/run_orchestrator.rb`
Acceptance criteria:
- Pipeline executes in correct order and persists artifacts at each step.
- Fatal verification blocks send and triggers alert.
- Successful run creates sent issue and receipt automatically.
Test verification:
- Integration tests in `test/jobs/autopilot_run_job_test.rb`.
- Service orchestration tests in `test/services/autopilot/run_orchestrator_test.rb`.

## 48. Add Basic Metrics and Cost Tracking
What to do: Instrument core events (time to first send, sends, autopilot adoption, ad fill, LLM cost per issue) for MVP analytics.
Affected files/services:
- `app/services/metrics/event_tracker.rb`
- `app/services/*` orchestrators (emit events)
- `config/initializers/` analytics provider config
Acceptance criteria:
- Events emitted for each KPI defined in PRD.
- LLM cost per issue is recorded and queryable.
- Metrics failures do not break send path.
Test verification:
- Unit tests for event payload shape in `test/services/metrics/event_tracker_test.rb`.

## 49. Build Onboarding “First Send” Wizard
What to do: Add lightweight guided flow: connect source -> set template/tone -> run research -> approve -> send.
Affected files/services:
- `app/controllers/onboarding_controller.rb`
- `app/views/onboarding/*.html.erb`
- `config/routes.rb`
Acceptance criteria:
- New users can complete first send path in one guided flow.
- Progress state persists if user leaves and returns.
- Completion links to first receipt.
Test verification:
- End-to-end system test in `test/system/onboarding_first_send_system_test.rb`.

## 50. Add End-to-End Regression Suite for MVP Flow
What to do: Create comprehensive integration/system tests covering happy path and critical failures across ingest, verification, send, receipt, ads, and autopilot.
Affected files/services:
- `test/system/mvp_newsletter_flow_system_test.rb`
- `test/integration/mvp_newsletter_flow_test.rb`
- `test/fixtures/` domain fixtures
Acceptance criteria:
- Happy path from source ingest to shareable receipt passes in CI.
- Fatal verification scenario blocks send and surfaces reason.
- Autopilot scenario produces send + notification + receipt.
Test verification:
- Full test run includes new suites and is stable in CI.
