# FamilyHub – Task Tracker

> Updated: 2026-03-31
> Branch: `release/v1.0.0`

---

## � Ghostfolio Integration — Merge + E2E (2026-03-30)

> **Goal:** merge `ghostfolio/` scripts into `ghostfolio-src/familyhub/`, wire ghostfolio into
> `familyhub-e2e`, add smoke tests for the TradeVille→Ghostfolio feature.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| G1 | Copy scripts → `ghostfolio-src/familyhub/` (tradeville_sync, tradeville_to_ghostfolio,_get_token, init.sh, .env.example) | ✅ done | |
| G2 | `ghostfolio-src/docker/docker-compose.familyhub.yml` — FamilyHub-specific compose with ghostfolio-init service & named `ghostfolio_net` network | ✅ done | |
| G3 | Add ghostfolio service + named-network attachment to `familyhub-e2e/docker-compose.yml` | ✅ done | |
| G4 | Add `ghostfolio-smoke` project to `playwright.config.ts` (parallel to regular smoke gate) | ✅ done | |
| G5 | Create `tests/01-ghostfolio-smoke.spec.ts` — health, anon auth, accounts, import dry-run, conversion unit tests | ✅ done | |
| G6 | Update `global-setup.ts` to check Ghostfolio health (optional, gated by `GHOSTFOLIO_URL` env var) | ✅ done | |

---

## 🟡 TradeVille → Ghostfolio: Actual Portfolio Sync (2026-03-30)

> **Goal:** actually run the sync to import the real TradeVille portfolio into the production
> Ghostfolio instance at `http://localhost:3333`. The scripts exist; the pipeline has never been
> executed against live data.

| # | Step | Status | Notes |
| --- | --- | --- | --- |
| S1 | Create `ghostfolio-src/familyhub/.env` from `ghostfolio/.env` (real secrets, TradeVille creds placeholder) | ✅ done | File created; fill in TRADEVILLE_USER + TRADEVILLE_PASSWORD |
| S2 | Verify Ghostfolio token is still valid (health + anonymous auth round-trip) | ✅ done | JWT returned OK — token valid |
| S3 | Run demo dry-run (`--demo --dry-run`) to validate full pipeline | ⚠️ blocked | Demo account at max 2 concurrent sessions (shared public account); skip to S4 with real creds |
| S4 | Add real TradeVille credentials to `.env` and run live dry-run (`--dry-run`) | ⚠️ blocked | Error: "Nu aveti acces la API Tradeville cu aceste credentiale" — TradeVille API access may need to be enabled separately in account settings |
| S5 | Run live sync to import portfolio into Ghostfolio production | ⏳ pending | Run after dry-run looks correct |
| S6 | Create `ghostfolio/run_sync.ps1` convenience wrapper (logs output, date-stamped) | ✅ done | Committed to ghostfolio/ repo |

---

## �🔴 In Progress

---

## 🔴 Known Issues / Backlog

| # | Issue | Area | Status | Notes |
| --- | --- | --- | --- | --- |
| I1 | Apartment 4 (Tineretului 29A Ap.1) legacy tenant not editable | frontend | ✅ fixed 2026-04-05 | Legacy `properties_tenant` row (id=1, "Chiriași Ap1-29A") shown in ApartmentDetail Linked People with delete button |
| I2 | Document scanner queue stuck on test file | backend | ✅ fixed 2026-04-05 | Removed `e2e_test_1773866692569.pdf` from scanner_inbox in both dev and prod containers |
| I3 | Scanner watcher processes e2e test files left in inbox | backend | ✅ fixed | Add filename prefix filter in `scanner_watcher.py` + `_process_existing_files` to ignore `e2e_test_*` files |


---

## 📋 Backlog

| # | Task | Priority | Notes |
| --- | --- | --- | --- |
| B1 | Tag input UX: Enter/Add chip style instead of comma-separated text | High | Currently a plain text input |
| B2 | Categories selector in document modal (assign category on upload/edit) | High | Backend has categories, needs UI |
| B3 | Upgrade Ollama model to llama3.2:8b or mistral (needs VRAM check) | Medium | RTX 4070 Super = 12 GB VRAM |
| B4 | Search toggle for AI-suggested tags (already in `searchText`, just add checkbox) | Medium | |
| B5 | Tag display: show specific values (e.g. `163B` not `Building code`) — prompt already fixed | Low | Re-label existing docs to get new tags |
| B6 | Document preview: show `signatories` section with roles | Low | Data available, needs UI |
| B7 | Google Drive sync | Low | Infrastructure exists |
| B8 | WhatsApp reminders | Low | `whatsapp-service/` exists |
| B9 | Bulk category assignment | Low | |
| B10 | Ghostfolio first-time setup: register, save Security Token, configure `ACCESS_TOKEN_SALT` | infra | `ghostfolio/docker-compose.yml` already in place; run `cd ghostfolio && docker compose up -d`, open <http://localhost:3333> |
| B11 | Import Revolut Stocks portfolio into Ghostfolio | investments | ✅ Built-in importer; export CSV from Revolut app → Profile → Statements → Revolut Stocks → import in Ghostfolio UI |
| B12 | Import eToro portfolio into Ghostfolio | investments | ✅ Built-in importer; export CSV from eToro → Portfolio → History → Download → import in Ghostfolio UI |
| B13 | Import TradeVille portfolio into Ghostfolio | investments | ✅ `ghostfolio/tradeville_to_ghostfolio.py` — converts CSV/XLSX export to Ghostfolio JSON; run `python tradeville_to_ghostfolio.py transactions.xlsx -o out.json` then import JSON in Ghostfolio |
| B14 | FamilyHub Dashboard widget or sidebar link to Ghostfolio (<http://localhost:3333>) | frontend | ✅ Sidebar nav item "Investments" added with `TrendingUp` icon — opens <http://localhost:3333> in new tab |

---

## 🐛 Known Issues

| # | Issue | Area | Status |
| --- | --- | --- | --- |
| I1 | Docker Desktop auto-restarts WSL → `.wslconfig` 8 GB cap not applied until Docker Desktop restarted manually | infra | Workaround: restart Docker Desktop from tray |
| I2 | `building_163b` / `apartment_3` tags generated by LLM use generic labels instead of raw values | AI | Fixed in new prompt — re-label docs needed |
| I3 | Unsaved form in `Partenera de completat` (doc 131) — "Onea eee eee" is OCR noise | AI | Template not filled in, expected |

---

## 🔍 File Audit (2026-03-21)

All files across `familyhub-backend`, `familyhub-frontend`, and `familyhub-e2e` checked for errors/warnings.

| File | Repo | Status | Issues Found / Fixed |
| --- | --- | --- | --- |
| `services/ai/ollama_client.py` | backend | ✅ Fixed | `requests` possibly unbound (moved import out of try/except); 8× `str = None` → `Optional[str] = None` |
| `TASKS.md` | root | ✅ Fixed | MD060 table separator style — separator rows lacked spaces |
| All other backend Python files | backend | ✅ No issues | Pylance clean |
| All frontend TypeScript/TSX files | frontend | ✅ No issues | `tsc --noEmit` clean |
| All e2e files | e2e | ✅ No issues | No errors reported |

---

## 🏗️ Architecture Notes

- **Backend**: Django + Celery + PostgreSQL + Redis
- **AI**: Ollama (`llama3.2:3b`, RTX 4070 Super via GPU), context window 8192
- **Frontend**: React + Vite + TailwindCSS + i18n (ro/en)
- **Containers**: `familyhub_prod_backend`, `_celery_worker`, `_celery_beat`, `_frontend`, `_db`, `_redis`, `_ollama`, `_nginx`
- **Git remotes**: local bare repos at `C:\Users\PC\Documents\Personal\familyhub-backend/frontend`

---

## ✅ Completed

| # | Task | Commit | Date |
| --- | --- | --- | --- |
| 1 | WSL `.wslconfig` 8 GB cap | manual | 2026-03-19 |
| 2 | Ollama GPU container (`ollama/ollama`) | docker-compose | 2026-03-19 |
| 3 | `num_ctx=8192` fix for llama3.2 | backend | 2026-03-19 |
| 4 | Document filename pre-parser (`_extract_filename_hints`) | `a1f01c2` | 2026-03-19 |
| 5 | Romanian-aware LLM prompt (8-15 tags, Comodat, people names) | `a1f01c2` | 2026-03-19 |
| 6 | Tag confidence sorting (highest first) | `a1f01c2` | 2026-03-19 |
| 7 | `people_mentioned` persistence to `ai_extracted_data` | `a1f01c2` | 2026-03-19 |
| 8 | Frontend: suggested tags sorted by confidence + ★ gold badge | `9ff1c6d` | 2026-03-19 |
| 9 | Signature detection (`is_signed`, `signatories`, `signed_by_*` tags) | `3a62ae1` | 2026-03-19 |
| 10 | Broader document types + categories (medical, auto, legal, etc.) | – | 2026-03-19 |
| 11 | Generic FamilyMember DB model (replaces hardcoded lists) | – | 2026-03-19 |
| 12 | FamilyRelation model (typed relations between members) | – | 2026-03-19 |
| 13 | Fusneica family seeded via management command | – | 2026-03-19 |
| 14 | Family admin API (CRUD for members + relations) | – | 2026-03-19 |
| 15 | Table view: text labels added to view-mode buttons | – | 2026-03-19 |
| 16 | Table view: labels + tags columns added | – | 2026-03-19 |
| 17 | Parking spots per building (`Building.parking_spots` field + migration) | backend | 2026-03-22 |
| 18 | Parking spots per apartment (`Apartment.parking_spots` field + migration) | backend | 2026-03-22 |
| 19 | Parking stats in Properties: capacity/usage display with ⚠️ over-capacity tooltip | frontend | 2026-03-22 |
| 20 | Existing apartments with `has_parking=true` default to 1 parking spot | frontend | 2026-03-22 |
| 21 | Apartment name made optional (null/blank) + conditional unique constraint | backend | 2026-03-22 |
| 22 | Apartment name shows "Unnamed" in UI when null | frontend | 2026-03-22 |
| 23 | Duplicate apartment action (`_Copy` suffix, backend + button in UI) | backend+frontend | 2026-03-22 |
| 24 | Bills status labels fix (translation key mismatch `payments.status.X` → `payments.X`) | frontend | 2026-03-22 |
| 25 | Add Payment modal (title, amount, type, apartment, due date) | frontend | 2026-03-22 |
| 26 | Add Transaction modal in Budget (description, amount, type, category, account, date) | frontend | 2026-03-22 |
| 27 | Project model for tasks + CRUD ViewSet at `/tasks/projects/` | backend | 2026-03-22 |
| 28 | New Task modal in Tasks (title, description, priority, status, due date, project) | frontend | 2026-03-22 |
| 29 | Create project inline from New Task modal | frontend | 2026-03-22 |
| 30 | Username field on User model (optional, unique) + login by email OR username | backend | 2026-03-22 |
| 31 | Username field in Settings Profile form | frontend | 2026-03-22 |
| 32 | Fix `@` showing without username in Settings Users list | frontend | 2026-03-22 |
| 33 | Fix profile save error (wrong PATCH URL `users/me/` → `users/update_me/`) | frontend | 2026-03-22 |
| 34 | Documents table Name filter crash fix (300ms debounce) | frontend | 2026-03-24 |
| 35 | Documents table numeric size sort + millisecond-precision updatedAt sort | frontend | 2026-03-24 |
| 36 | WhatsApp backend tests: stale sessions, webhooks, diagnostic fields (29 tests) | backend | 2026-03-24 |
| 37 | WhatsApp config UI: free/self-hosted info panel | frontend | 2026-03-24 |
| 38 | WhatsApp frontend unit tests | frontend | 2026-03-24 |
| 39 | Playwright table interaction tests (switch view, filter, sort, rapid clicks) | e2e | 2026-03-24 |
| 40 | Entity AI connections panel (`View AI connections` button on Person/Identity) | frontend | 2026-03-24 |
| 41 | "See details" eye icon in AI connections → entity preview panel | frontend | 2026-03-24 |
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
| 53 | Delete button in every edit/update form (ApartmentFormModal ×2, building modal, IdentityFormModal) | `9a795a8` | 2026-03-25 |
| 54 | Graceful EntityLink cleanup on apartment delete (`perform_destroy` in ApartmentViewSet) | `a9c6cb9` | 2026-03-25 |
| 55 | Deploy script: force-remove known container names to fix compose project-name conflicts | deploy script | 2026-03-25 |
| 56 | Nginx runtime DNS resolution fix (Docker resolver `127.0.0.11` + variable upstream) | `32eb2de` | 2026-03-23 |
| 57 | Apartment row action buttons always visible in BuildingDetail (removed hover-only opacity) | `32eb2de` | 2026-03-23 |
| 58 | Delete button on ApartmentDetail page (`/properties/apartments/:id`) | `eda2d57` | 2026-03-23 |
| 59 | `seed_apartments_production` management command (bulk-seeds apartments from dict) | backend | 2026-03-29 |
| 60 | `payment_status` + `contract_end_date` fields on Apartment API/types | backend+frontend | 2026-03-29 |
| 61 | BuildingDetail apartment cards: vacancy date badge (≤60 days) + payment status badges (overdue/pending) | frontend | 2026-03-29 |
| 62 | Ghostfolio investment tracker docker-compose added to stack | infra | 2026-03-29 |
| 63 | Full i18n of BuildingDetail.tsx — all sub-components (ApartmentFormModal, OverviewTab, TaskListTab, TaskModal) translated; TASK_STATUS_CONFIG/PRIORITY_CONFIG/TASK_TYPES changed to `labelKey` | frontend | 2026-03-29 |
| 64 | Fix DB encoding corruption: restored corrupted Romanian chars (ăîâșț) in tasks, project, building, tenant, identity addresses — caused by backup_production.ps1 piping pg_dump through PowerShell console (OEM→UTF-8 double-encoding) | backend | 2026-04-05 |
| 65 | Fix backup_production.ps1: replaced `pg_dump \| Out-File -Encoding utf8` with `pg_dump -f /tmp/...` + `docker cp` to preserve byte-for-byte encoding | infra | 2026-04-05 |
| 66 | ApartmentDetail: show legacy tenant (properties_tenant) in Linked People with delete button when no IdentityRole records exist | frontend | 2026-04-05 |
| 67 | LegacyTenantModal: full edit/delete CRUD for properties_tenant via modal in ApartmentDetail (6 new Vitest tests) | frontend | `0b26d27` | 2026-03-31 |
| 68 | deploy-to-prod.ps1: STEP 3.5 auto-runs `manage.py migrate --no-input` before container restart; aborts on failure | e2e/infra | `32a5aa9` | 2026-03-31 |
| 69 | feature-workflow.instructions.md: Phase 1b (migrations), Phase 4 (commit/push after prod verify), summary checklist | root | 2026-03-31 |
| 70 | Fix apartment edit forms: deposit_amount + currency fields added to both BuildingDetail and Properties modals | frontend | `d5cedd7` |
| 71 | Fix currency display on ApartmentDetail: conditional RON vs € based on apartment.currency field | frontend | `d5cedd7` |
| 72 | RentDuePicker component: flexible rent due date (day-of-month or Nth weekday picker) used in both BuildingDetail and Properties modals | frontend | `d5cedd7` |
| 73 | Fix monthly_rent and deposit inputs: flex-1 min-w-0 layout prevents truncation in all edit modals | frontend | `d5cedd7` |
| 74 | P3: useExchangeRate hook — ECB XML fetch for live EUR/RON rate; convert() helper; shown in ApartmentDetail rent+deposit | frontend | `d5cedd7` |
| 75 | P6: RoleAssignmentModal searchable combobox — search state, filteredIdentities, inline person creation | frontend | `d5cedd7` |
| 76 | I3: scanner.py + scanner_watcher.py skip e2e_test_* files; 6 backend tests added | backend | pending |
| I4 → fixed | Nginx caches backend IP at startup → 502 after reboot | infra | Fixed in #56 |

---
