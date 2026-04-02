# FamilyHub - Task Tracker

> Updated: 2026-04-02
> Branch: `release/v1.0.0`

---

## Ghostfolio Integration - Merge + E2E (2026-03-30)

> **Goal:** merge `ghostfolio/` scripts into `ghostfolio-src/familyhub/`, wire ghostfolio into
> `familyhub-e2e`, add smoke tests for the TradeVille->Ghostfolio feature.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| G1 | Copy scripts -> `ghostfolio-src/familyhub/` (tradeville_sync, tradeville_to_ghostfolio,_get_token, init.sh, .env.example) | done | |
| G2 | `ghostfolio-src/docker/docker-compose.familyhub.yml` - FamilyHub-specific compose with ghostfolio-init service & named `ghostfolio_net` network | done | |
| G3 | Add ghostfolio service + named-network attachment to `familyhub-e2e/docker-compose.yml` | done | |
| G4 | Add `ghostfolio-smoke` project to `playwright.config.ts` (parallel to regular smoke gate) | done | |
| G5 | Create `tests/01-ghostfolio-smoke.spec.ts` - health, anon auth, accounts, import dry-run, conversion unit tests | done | |
| G6 | Update `global-setup.ts` to check Ghostfolio health (optional, gated by `GHOSTFOLIO_URL` env var) | done | |

---

## TradeVille -> Ghostfolio: Actual Portfolio Sync (2026-03-30)

> **Goal:** actually run the sync to import the real TradeVille portfolio into the production
> Ghostfolio instance at `http://localhost:3333`. The scripts exist; the pipeline has never been
> executed against live data.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| S1 | Create `ghostfolio-src/familyhub/.env` from `ghostfolio/.env` (real secrets, TradeVille creds placeholder) | done | File created; fill in TRADEVILLE_USER + TRADEVILLE_PASSWORD |
| S2 | Verify Ghostfolio token is still valid (health + anonymous auth round-trip) | done | JWT returned OK - token valid |
| S3 | Run demo dry-run (`--demo --dry-run`) to validate full pipeline | blocked | Demo account at max 2 concurrent sessions (shared public account); skip to S4 with real creds |
| S4 | Add real TradeVille credentials to `.env` and run live dry-run (`--dry-run`) | blocked | Error: "Nu aveti acces la API Tradeville cu aceste credentiale" - TradeVille API access may need to be enabled separately in account settings |
| S5 | Run live sync to import portfolio into Ghostfolio production | pending | Run after dry-run looks correct |
| S6 | Create `ghostfolio/run_sync.ps1` convenience wrapper (logs output, date-stamped) | done | Committed to ghostfolio/ repo |

---

## Portfolio Imports - Revolut / Binance / eToro

> **Goal:** create Python import scripts for each brokerage, export CSVs from the apps, and
> import holdings into Ghostfolio via the REST API at `http://localhost:3333`.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| P1 | Create `import_revolut.py` - reads Revolut Stocks CSV export, outputs Ghostfolio JSON | done | `ghostfolio-src/familyhub/import_revolut.py` |
| P2 | Create `import_binance.py` - reads Binance transaction history CSV, outputs Ghostfolio JSON | done | `ghostfolio-src/familyhub/import_binance.py` |
| P3 | Create `import_etoro.py` - reads eToro account statement XLSX/CSV, outputs Ghostfolio JSON | done | `ghostfolio-src/familyhub/import_etoro.py` |
| P4 | Export CSV from Revolut app: Profile -> Statements -> Revolut Stocks | pending | Requires Revolut app on phone; export as CSV |
| P5 | Export CSV from Binance: Orders -> Transaction History -> Export | pending | Requires Binance account login; choose date range |
| P6 | Export XLSX from eToro: Portfolio -> History -> Account Statement -> Download | pending | Requires eToro login; export as Excel |
| P7 | Run each import script and verify output JSON | pending | Test with --dry-run flag first |
| P8 | POST JSON to Ghostfolio API: `POST http://localhost:3333/api/v1/import` | pending | Set Bearer token from Ghostfolio Settings -> Security Token |
| P9 | Verify imported holdings appear in Ghostfolio portfolio view | pending | Open <http://localhost:3333> and check Holdings tab |

---

## Ghostfolio Platform Import Wizard (2026-03-31)

> **Goal:** add a guided multi-step import UI inside Ghostfolio itself (Revolut / Binance / eToro /
> Generic), with browser-side CSV conversion feeding into the existing Ghostfolio dry-run flow.
> No Django backend changes — all logic lives inside the Angular client.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| UI1 | `platform-import.service.ts` — browser-side converters for Revolut / Binance / eToro CSV → `CreateOrderDto[]` | done | `ghostfolio-src/apps/client/src/app/services/platform-import.service.ts` |
| UI2 | Extend `ImportStep` enum: add `PLATFORM_SELECT=0`, `EXPORT_GUIDE=1`; renumber existing to 2/3 | done | `import-activities-dialog/enums/import-step.ts` |
| UI3 | Dialog HTML: 4-step MatStepper (platform cards → export guide → file upload → review & import) | done | `import-activities-dialog.html` |
| UI4 | Dialog component: inject `PlatformImportService`, wire `onSelectPlatform`, `onSkipOrContinueGuide`, platform-aware `handleFile` | done | `import-activities-dialog.component.ts` |
| UI5 | SCSS: `.platform-grid`, `.platform-card`, `.export-steps` styles | done | `import-activities-dialog.scss` |
| UI6 | Fix Docker entrypoint CRLF: `entrypoint.sh` had Windows line endings → `#!/bin/sh\r` unrecognised on Linux | done | compose override + source file converted to LF + Dockerfile `RUN sed` |
| UI7 | Build custom Ghostfolio Docker image from `ghostfolio-src/` and deploy via `ghostfolio-src/familyhub/docker-compose.yml` | done | `name: ghostfolio` preserves existing DB volumes |

---

## Ghostfolio EUR / RON Currency Support (2026-03-31)

> **Goal:** Ghostfolio ships with only USD/USX. Add EUR and RON so accounts, portfolio, and
> imported activities all work with European currencies.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| C1 | Upsert `CURRENCIES` property in DB: `["EUR", "RON"]` via `seed_currencies.py` | done | `ghostfolio-src/familyhub/seed_currencies.py`; run against live DB |
| C2 | Fix `property.service.ts` default: change hardcoded `[]` fallback to `['EUR', 'RON', 'USD']` | done | `ghostfolio-src/apps/api/src/services/property/property.service.ts` |
| C3 | `platform-import.service.ts`: Binance pair quotes now map to EUR/RON/GBP/CHF (not just USD); eToro detects account currency; Revolut fallback changed USD→EUR | done | |
| C4 | Rebuild Docker image and restart `ghostfolio_app` | done | Container restarted; EUR/RON/USD/USX confirmed in API `/v1/info` |
| C5 | Verify EUR and RON appear in "Add Account → Currency" dropdown | done | Confirmed via `GET /api/v1/info` → `currencies: ["EUR","RON","USD","USX"]` |

---

## In Progress

*(nothing currently active)*

---

## Document Bundle System (2026-04-02)

> **Goal:** hierarchical document grouping (bundles-of-bundles) so that ~90 documents can be
> organised into nested packs (e.g. Car → Purchase, Service, Fines), browsed as trees, and
> used as first-class filters everywhere documents appear. Smart bundles auto-populate from a
> saved filter. Bundles also give Ollama richer context for link recommendations.
>
> **Data model:**
> ```
> DocumentBundle
>   id, name, description, icon, color
>   parent ──FK→ self (null = root bundle)
>   is_smart: bool          # True = auto-populate from filter_config
>   filter_config: JSON     # {"owners":["eu"], "categories":["auto"], "tags":["masina"]}
>   documents ──M2M→ Document  (through BundleDocument: bundle, document, added_at, added_by)
>   created_by, created_at, updated_at
> ```
> Sub-bundle depth is unlimited. `get_subtree_ids()` walks children recursively to resolve
> the full document set when filtering.
>
> **API surface (`/api/v1/bundles/`):**
> - CRUD on bundles;  `GET .../tree/` → full nested tree for sidebar
> - `POST .../suggest/` + `{"document_ids": [...]}` → Ollama suggests name + sub-groupings
> - `POST {id}/add_documents/` / `remove_documents/` / `refresh_smart/`
> - `GET {id}/documents/` → all docs in bundle + every sub-bundle
>
> **Document filter:** `?bundle=<id>` on `GET /api/v1/documents/` resolves full subtree.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| BUN1 | `apps/bundles/` Django app: `DocumentBundle` + `BundleDocument` models; `get_subtree_ids()` + `get_all_documents()` methods | pending | New app; add to `INSTALLED_APPS` |
| BUN2 | Serializers: `BundleTreeSerializer` (nested children), `BundleFlatSerializer`, `BundleDocumentSerializer` | pending | `apps/bundles/serializers.py` |
| BUN3 | Views: `BundleViewSet` with CRUD + `tree`, `documents`, `add_documents`, `remove_documents`, `suggest`, `refresh_smart` actions | pending | `apps/bundles/views.py` |
| BUN4 | Document filter: add `?bundle=<id>` to `DocumentViewSet.get_queryset()` using subtree resolver | pending | `apps/documents/views.py` + `filterset_fields` |
| BUN5 | Wire URL: `router.register('bundles', BundleViewSet)` in `config/urls.py` | pending | |
| BUN6 | Migrations: `python manage.py makemigrations bundles` | pending | Must be committed before deploy |
| BUN7 | Backend tests: `apps/bundles/tests/test_bundle.py` — subtree resolver, add/remove docs, smart bundle refresh, API CRUD, `?bundle=` filter | pending | `pytest.mark.unit` + `pytest.mark.integration` |
| BUN8 | Frontend: `src/pages/Bundles/BundlePage.tsx` — left panel tree (nested expand/collapse), right panel document grid filtered by selected bundle | pending | |
| BUN9 | Frontend: multi-select in document list + "Add to bundle" / "Create bundle" toolbar button | pending | |
| BUN10 | Frontend: bundle filter pills row above document grid (click to filter; breadcrumb path shown) | pending | |
| BUN11 | Frontend tests: `BundlePage.test.tsx` — tree renders, select bundle filters docs, create bundle modal | pending | Vitest + RTL |
| BUN12 | Add `bundle` entity type to `EntityLink.EntityType` so bundles can be linked to other entities | pending | `apps/links/models.py` |
| BUN13 | Add `EntityType.BUNDLE` resolver to `_resolve_entity_name` in `links/serializers.py` | pending | |
| BUN14 | Sidebar nav: add "Bundles" entry with folder icon | pending | `src/layouts/Sidebar.tsx` or equivalent |
| BUN15 | Deploy (Phase 3): run `deploy-to-prod.ps1`, verify containers Up, smoke-test bundle CRUD via browser | pending | |

---

## Ollama Smart Linking Enhancement (2026-04-02)

> **Goal:** upgrade the current rule-based recommender in `apps/links/recommender.py` so that
> Ollama (llama3.2, GPU) acts as a second-pass semantic engine. Rule-based text matching remains
> as a fast Phase 1. Ollama runs Phase 2 with richer context.
>
> **Why bundles matter for linking:** bundle membership is the strongest contextual signal.
> "This document is in bundle Car › Service" tells Ollama far more than raw OCR text alone.
> Ollama can then say "this looks like a receipt for a car service — link to the car bundle
> and to the identity who owns the car".
>
> **Orchestration:**
> ```
> POST /api/v1/links/recommend/document/<id>/
>   Phase 1 (sync, fast):   rule-based text/address matching  → PENDING links
>   Phase 2 (async Celery): OllamaLinkRecommender             → upgrades confidence / adds new links
>                           context = {title, tags, summary, bundle_paths, entities_already_linked}
> ```
> `recommend_for_bundle(bundle_id)` — after bulk-adding docs to a bundle, runs Phase 2 on all
> of them at once and cross-links documents within the bundle that share entities/topics.
>
> **Prompt context injected per document:**
> - `title`, `document_type` (from `ai_extracted_data`)
> - `approved_tags` key/label pairs
> - first 500 chars of `ocr_text` / `ai_extracted_data.summary`
> - bundle membership paths: `["Car", "Car › Service docs"]`
> - already-accepted entity links (to avoid re-suggesting them)
> - all Identity names + all building addresses (as candidate targets)

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| OLL1 | `services/ai/link_recommender.py`: class `OllamaLinkRecommender` with `recommend(doc, context) → list[LinkSuggestion]`; prompt template; JSON parsing with fallback | pending | |
| OLL2 | `apps/links/recommender.py`: add `recommend_for_document_ai(doc)` that builds full context (bundles included) and calls `OllamaLinkRecommender` | pending | Gated by `settings.OLLAMA_ENABLED`; skipped gracefully if Ollama offline |
| OLL3 | Celery task `apps/links/tasks.py`: `run_ai_link_recommendations(doc_id)` — called async after OCR completes and after any bundle membership change | pending | |
| OLL4 | `recommend_for_bundle(bundle_id)` — batch AI recommendation across all documents in a bundle; cross-document links for shared entities/topics | pending | `apps/links/recommender.py` |
| OLL5 | Hook: after `BundleDocument` save, queue `run_ai_link_recommendations` for the newly added document | pending | `apps/bundles/models.py` post-save signal or viewset action |
| OLL6 | Hook: after document OCR + AI labeling completes, queue `run_ai_link_recommendations` automatically | pending | `apps/documents/tasks.py` — already calls `analyze_document_with_ai`; extend pipeline |
| OLL7 | Prompt context: include bundle paths in all existing AI prompts (document analyzer, auto-label) so Ollama can use bundle membership when suggesting tags/categories | pending | `services/ai/document_analyzer.py` |
| OLL8 | Backend tests: `apps/links/tests/test_ai_recommender.py` — mock Ollama; test context builder, JSON parse fallback, bundle path injection | pending | `pytest.mark.unit` |
| OLL9 | Deploy (Phase 3): run `deploy-to-prod.ps1`; verify Celery picks up new task; run manual recommendation on 1 document and inspect results | pending | |

---

## Known Issues

| # | Issue | Area | Status | Notes |
| --- | --- | --- | --- | --- |
| I1 | Apartment 4 (Tineretului 29A Ap.1) legacy tenant not editable | frontend | fixed 2026-04-05 | Legacy `properties_tenant` row shown in ApartmentDetail Linked People with delete button |
| I2 | Document scanner queue stuck on test file | backend | fixed 2026-04-05 | Removed `e2e_test_1773866692569.pdf` from scanner_inbox in both dev and prod containers |
| I3 | Scanner watcher processes e2e test files left in inbox | backend | fixed | Filename prefix filter in `scanner_watcher.py` + `_process_existing_files` ignores `e2e_test_*` files |
| I4 | Nginx caches backend IP at startup -> 502 after reboot | infra | fixed | Docker resolver `127.0.0.11` + variable upstream - see #56 |
| I5 | `formatCurrency` missing currency param - all amounts showed EUR sign regardless of apartment currency | frontend | fixed | `e4c29da` |
| I6 | Negative floor display: demisol apartments showed "floor 0" instead of "-1" | frontend | fixed | `ffe638b` |
| I7 | Stale GHCR Docker image cached - prod did not pick up latest frontend build | infra | fixed | Deploy script now forces image pull |

---

## Backlog

| # | Task | Priority | Notes |
| --- | --- | --- | --- |
| B1 | Tag input UX: Enter/Add chip style instead of comma-separated text | High | done - TagChipInput component added |
| B2 | Categories selector in document modal (assign category on upload/edit) | High | done - UI added |
| B3 | Upgrade Ollama model to llama3.2:8b or mistral (needs VRAM check) | Medium | RTX 4070 Super = 12 GB VRAM |
| B4 | Search toggle for AI-suggested tags (already in `searchText`, just add checkbox) | Medium | |
| B5 | Tag display: show specific values (e.g. `163B` not `Building code`) - prompt already fixed | Low | Re-label existing docs to get new tags |
| B6 | Document preview: show `signatories` section with roles | Low | Data available, needs UI |
| B7 | Google Drive sync | Low | Infrastructure exists |
| B8 | WhatsApp reminders | Low | `whatsapp-service/` exists |
| B9 | Bulk category assignment | Low | |
| B10 | Ghostfolio first-time setup: register, save Security Token, configure `ACCESS_TOKEN_SALT` | infra | done - `ghostfolio/docker-compose.yml` in place; run `docker compose up -d`, open <http://localhost:3333> |
| B11 | Import Revolut Stocks portfolio into Ghostfolio | investments | done - `import_revolut.py` created; export CSV from Revolut app -> Profile -> Statements |
| B12 | Import eToro portfolio into Ghostfolio | investments | done - `import_etoro.py` created; export XLSX from eToro Account Statement |
| B13 | Import TradeVille portfolio into Ghostfolio | investments | done - `tradeville_to_ghostfolio.py` converts CSV/XLSX to Ghostfolio JSON |
| B14 | FamilyHub Dashboard widget or sidebar link to Ghostfolio (<http://localhost:3333>) | frontend | done - Sidebar nav item "Investments" added with TrendingUp icon |

---

## Architecture Notes

- **Backend**: Django + Celery + PostgreSQL + Redis
- **AI**: Ollama (`llama3.2:3b`, RTX 4070 Super via GPU), context window 8192
- **Frontend**: React + Vite + TailwindCSS + i18n (ro/en)
- **Investments**: Ghostfolio at `http://localhost:3333`; import scripts in `ghostfolio-src/familyhub/`
- **Containers**: `familyhub_prod_backend`, `_celery_worker`, `_celery_beat`, `_frontend`, `_db`, `_redis`, `_ollama`, `_nginx`, `_scanner_watcher`, `_watchtower`
- **Git remotes**: local bare repos at `C:\Users\PC\Documents\Personal\familyhub-backend/frontend`

---

## Completed

| # | Task | Commit | Date |
| --- | --- | --- | --- |
| 1 | WSL `.wslconfig` 8 GB cap | manual | 2026-03-19 |
| 2 | Ollama GPU container (`ollama/ollama`) | docker-compose | 2026-03-19 |
| 3 | `num_ctx=8192` fix for llama3.2 | backend | 2026-03-19 |
| 4 | Document filename pre-parser (`_extract_filename_hints`) | `a1f01c2` | 2026-03-19 |
| 5 | Romanian-aware LLM prompt (8-15 tags, Comodat, people names) | `a1f01c2` | 2026-03-19 |
| 6 | Tag confidence sorting (highest first) | `a1f01c2` | 2026-03-19 |
| 7 | `people_mentioned` persistence to `ai_extracted_data` | `a1f01c2` | 2026-03-19 |
| 8 | Frontend: suggested tags sorted by confidence + gold badge | `9ff1c6d` | 2026-03-19 |
| 9 | Signature detection (`is_signed`, `signatories`, `signed_by_*` tags) | `3a62ae1` | 2026-03-19 |
| 10 | Broader document types + categories (medical, auto, legal, etc.) | - | 2026-03-19 |
| 11 | Generic FamilyMember DB model (replaces hardcoded lists) | - | 2026-03-19 |
| 12 | FamilyRelation model (typed relations between members) | - | 2026-03-19 |
| 13 | Fusneica family seeded via management command | - | 2026-03-19 |
| 14 | Family admin API (CRUD for members + relations) | - | 2026-03-19 |
| 15 | Table view: text labels added to view-mode buttons | - | 2026-03-19 |
| 16 | Table view: labels + tags columns added | - | 2026-03-19 |
| 17 | Parking spots per building (`Building.parking_spots` field + migration) | backend | 2026-03-22 |
| 18 | Parking spots per apartment (`Apartment.parking_spots` field + migration) | backend | 2026-03-22 |
| 19 | Parking stats in Properties: capacity/usage display with over-capacity tooltip | frontend | 2026-03-22 |
| 20 | Existing apartments with `has_parking=true` default to 1 parking spot | frontend | 2026-03-22 |
| 21 | Apartment name made optional (null/blank) + conditional unique constraint | backend | 2026-03-22 |
| 22 | Apartment name shows "Unnamed" in UI when null | frontend | 2026-03-22 |
| 23 | Duplicate apartment action (`_Copy` suffix, backend + button in UI) | backend+frontend | 2026-03-22 |
| 24 | Bills status labels fix (translation key mismatch `payments.status.X` -> `payments.X`) | frontend | 2026-03-22 |
| 25 | Add Payment modal (title, amount, type, apartment, due date) | frontend | 2026-03-22 |
| 26 | Add Transaction modal in Budget (description, amount, type, category, account, date) | frontend | 2026-03-22 |
| 27 | Project model for tasks + CRUD ViewSet at `/tasks/projects/` | backend | 2026-03-22 |
| 28 | New Task modal in Tasks (title, description, priority, status, due date, project) | frontend | 2026-03-22 |
| 29 | Create project inline from New Task modal | frontend | 2026-03-22 |
| 30 | Username field on User model (optional, unique) + login by email OR username | backend | 2026-03-22 |
| 31 | Username field in Settings Profile form | frontend | 2026-03-22 |
| 32 | Fix `@` showing without username in Settings Users list | frontend | 2026-03-22 |
| 33 | Fix profile save error (wrong PATCH URL `users/me/` -> `users/update_me/`) | frontend | 2026-03-22 |
| 34 | Documents table Name filter crash fix (300ms debounce) | frontend | 2026-03-24 |
| 35 | Documents table numeric size sort + millisecond-precision updatedAt sort | frontend | 2026-03-24 |
| 36 | WhatsApp backend tests: stale sessions, webhooks, diagnostic fields (29 tests) | backend | 2026-03-24 |
| 37 | WhatsApp config UI: free/self-hosted info panel | frontend | 2026-03-24 |
| 38 | WhatsApp frontend unit tests | frontend | 2026-03-24 |
| 39 | Playwright table interaction tests (switch view, filter, sort, rapid clicks) | e2e | 2026-03-24 |
| 40 | Entity AI connections panel (`View AI connections` button on Person/Identity) | frontend | 2026-03-24 |
| 41 | "See details" eye icon in AI connections -> entity preview panel | frontend | 2026-03-24 |
| 42 | PDF/image preview in entity preview (DocumentPreview component) | frontend | 2026-03-24 |
| 43 | "Add Document" + "Open in Documents" buttons in entity preview footer | frontend | 2026-03-24 |
| 44 | Fix entity preview footer always visible (flex-col h-full layout, shrink-0 footer) | frontend | 2026-03-24 |
| 45 | Fix `estate.roles.resident` i18n key showing raw in role dropdown | `5be11fc` | 2026-03-24 |
| 46 | Conditional date fields in RoleAssignModal (hide for Owner, Co-owner, Guarantor, Agent roles) | `5be11fc` | 2026-03-24 |
| 47 | Role category UX: visually separate "Permanent residents" vs "Contractual/renters" in role picker | `5be11fc` | 2026-03-24 |
| 48 | Grouped multi-connection display in IdentityCard / AI connections panel | `5be11fc` | 2026-03-24 |
| 49 | Bidirectional entity links: document detail shows all connected identities | `5be11fc` | 2026-03-24 |
| 50 | Building detail view: full apartment CRUD + delete (Add / Edit / Archive / Delete) | `9a795a8` | 2026-03-25 |
| 51 | Administration entity detail view/page per person/company | `5be11fc` | 2026-03-24 |
| 52 | Fix archived apartments still showing in BuildingDetail (`is_archived` missing from filterset_fields) | `a9c6cb9` | 2026-03-25 |
| 53 | Delete button in every edit/update form (ApartmentFormModal x2, building modal, IdentityFormModal) | `9a795a8` | 2026-03-25 |
| 54 | Graceful EntityLink cleanup on apartment delete (`perform_destroy` in ApartmentViewSet) | `a9c6cb9` | 2026-03-25 |
| 55 | Deploy script: force-remove known container names to fix compose project-name conflicts | deploy script | 2026-03-25 |
| 56 | Nginx runtime DNS resolution fix (Docker resolver `127.0.0.11` + variable upstream) | `32eb2de` | 2026-03-23 |
| 57 | Apartment row action buttons always visible in BuildingDetail (removed hover-only opacity) | `32eb2de` | 2026-03-23 |
| 58 | Delete button on ApartmentDetail page (`/properties/apartments/:id`) | `eda2d57` | 2026-03-23 |
| 59 | `seed_apartments_production` management command (bulk-seeds apartments from dict) | backend | 2026-03-29 |
| 60 | `payment_status` + `contract_end_date` fields on Apartment API/types | backend+frontend | 2026-03-29 |
| 61 | BuildingDetail apartment cards: vacancy date badge (<=60 days) + payment status badges (overdue/pending) | frontend | 2026-03-29 |
| 62 | Ghostfolio investment tracker docker-compose added to stack | infra | 2026-03-29 |
| 63 | Full i18n of BuildingDetail.tsx - all sub-components translated; TASK_STATUS_CONFIG/PRIORITY_CONFIG/TASK_TYPES changed to `labelKey` | frontend | 2026-03-29 |
| 64 | Fix DB encoding corruption: restored corrupted Romanian chars in tasks, buildings, identities - caused by backup_production.ps1 piping pg_dump through PowerShell console (OEM->UTF-8 double-encoding) | backend | 2026-04-05 |
| 65 | Fix backup_production.ps1: replaced `pg_dump | Out-File -Encoding utf8` with `pg_dump -f /tmp/...` + `docker cp` to preserve byte-for-byte encoding | infra | 2026-04-05 |
| 66 | ApartmentDetail: show legacy tenant (properties_tenant) in Linked People with delete button when no IdentityRole records exist | frontend | 2026-04-05 |
| 67 | LegacyTenantModal: full edit/delete CRUD for properties_tenant via modal in ApartmentDetail (6 new Vitest tests) | frontend | `0b26d27` |
| 68 | deploy-to-prod.ps1: STEP 3.5 auto-runs `manage.py migrate --no-input` before container restart; aborts on failure | e2e/infra | `32a5aa9` |
| 69 | feature-workflow.instructions.md: Phase 1b (migrations), Phase 4 (commit/push after prod verify), summary checklist | root | 2026-03-31 |
| 70 | Fix apartment edit forms: deposit_amount + currency fields added to both BuildingDetail and Properties modals | frontend | `d5cedd7` |
| 71 | Fix currency display on ApartmentDetail: conditional RON vs EUR based on apartment.currency field | frontend | `d5cedd7` |
| 72 | RentDuePicker component: flexible rent due date (day-of-month or Nth weekday picker) used in both BuildingDetail and Properties modals | frontend | `d5cedd7` |
| 73 | Fix monthly_rent and deposit inputs: flex-1 min-w-0 layout prevents truncation in all edit modals | frontend | `d5cedd7` |
| 74 | useExchangeRate hook: ECB XML fetch for live EUR/RON rate; convert() helper; shown in ApartmentDetail rent+deposit | frontend | `d5cedd7` |
| 75 | RoleAssignmentModal searchable combobox: search state, filteredIdentities, inline person creation | frontend | `d5cedd7` |
| 76 | scanner.py + scanner_watcher.py skip e2e_test_* files; 6 backend tests added | backend | pending |
| 77 | Fix `formatCurrency` missing currency param - RON amounts showed EUR sign regardless of apartment currency | frontend | `e4c29da` |
| 78 | Fix negative floor display: demisol apartments showed "floor 0" instead of "-1" | frontend | `ffe638b` |
| 79 | Document-Identity Role M2M link: attach documents to specific role records in ApartmentDetail; new DocumentRoleLink model + API + UI | backend+frontend | `e8ef8c9` / `fd84333` |
| 80 | deploy-to-prod.ps1 robustness improvements: better logging, error handling, stack ordering | e2e/infra | `163b5f2` |
| 81 | Portfolio import scripts: import_revolut.py, import_binance.py, import_etoro.py for Ghostfolio | ghostfolio | - |
