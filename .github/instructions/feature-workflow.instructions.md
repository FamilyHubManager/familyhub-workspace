---
applyTo: "**"
---

# Feature Workflow — Test → Dev Verify → Deploy

After implementing **any task or feature**, you MUST follow this three-phase workflow before finishing.
Do not skip phases. Do not report "done" until the deploy step has completed.

---

## Phase 1 — Write Tests

Add tests to **every repo that was changed**. Match the test style already used in that repo.

### Backend (Django / pytest)
- Test files live under the affected app: `familyhub-backend/apps/<app>/tests/` or alongside the module as `test_*.py`
- Naming: `test_<feature>.py`, class `Test<Feature>`, methods `test_<scenario>`
- Use `pytest.mark.unit` for pure logic, `pytest.mark.integration` for DB/API tests
- Run with: `pytest apps/<app>/tests/ -v` (inside `familyhub-backend/`)
- Cover: happy path, validation errors, edge cases (empty, null, boundary values)

### Frontend (React / Vitest)
- Test files: `familyhub-frontend/src/__tests__/<Component>.test.tsx` or co-located `<Component>.test.tsx`
- Use `@testing-library/react` + `vi.mock` for API calls
- Run with: `npm run test -- --run` (inside `familyhub-frontend/`)
- Cover: renders without crash, user interactions, API mock responses

### E2E (Playwright)
- Test files live in `familyhub-e2e/tests/`
- Only add E2E tests for user-facing flows that touch multiple services (not every micro-change)
- Run smoke suite with: `npx playwright test --grep @smoke` (inside `familyhub-e2e/`)

---

## Phase 1b — Django Migrations (backend model changes only)

If any **Django model** was added or changed, generate and commit the migration file **before deploying**.

```powershell
cd familyhub-backend
python manage.py makemigrations
python manage.py migrate        # verify locally
```

Then commit the generated `migrations/00XX_*.py` file.  
**NEVER run `makemigrations` in production.** The deploy script runs `migrate` automatically — it expects migration files to already exist in the image.

---

## Phase 2 — Verify on Developer Environment

Run all tests locally and confirm every test is green before moving to Phase 3.

### Backend
```powershell
cd familyhub-backend
pytest apps/ -v --tb=short
```
All tests must pass (`0 failed`). Fix failures before continuing.

### Frontend
```powershell
cd familyhub-frontend
npm run test -- --run
```
All tests must pass. Fix failures before continuing.

### E2E (when applicable)
```powershell
cd familyhub-e2e
npx playwright test 00-smoke.spec.ts
```
Must exit `0`. If the dev stack is not running, start it first.

Only proceed to Phase 3 when **every test suite returns 0 failures**.

---

## Phase 3 — Deploy to Production

Use the canonical deploy script. Do NOT manually restart individual containers.

```powershell
cd familyhub-e2e\scripts
.\deploy-to-prod.ps1
```

This script (in order):
1. Pushes git changes to origin
2. Builds updated Docker images
3. **Runs `python manage.py migrate --no-input`** inside a temporary backend container — aborts if migrations fail
4. Stops and recreates only app containers (backend, celery_worker, celery_beat, frontend, scanner_watcher)
5. Leaves infrastructure untouched (db, redis, ollama, whatsapp_service, watchtower) — the WhatsApp session is preserved
6. Updates the Ghostfolio stack (`ghostfolio-src/familyhub/docker-compose.yml`)

After the script exits `0`, confirm the deploy by checking container health:
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "familyhub_prod|ghostfolio"
```
All prod containers must show `Up`.

---

## Phase 4 — Verify on Production, Then Commit and Push

Once all prod containers show `Up`, **manually verify** that the feature works correctly in the live environment before committing code.

### Production smoke check
- Open the app in the browser (or use `curl`/Playwright) and confirm the feature behaves correctly end-to-end on the actual production data.
- Check backend logs for any runtime errors: `docker logs familyhub_prod_backend --tail 50`
- Only if everything looks correct, proceed to commit.

### Commit and push all changed repos

After production is confirmed working, commit and push every repo that was changed:

```powershell
# Backend
cd d:\Projects\FamilyHubManager\familyhub-backend
git add -A
git commit -m "feat: <short description>"
git push

# Frontend
cd d:\Projects\FamilyHubManager\familyhub-frontend
git add -A
git commit -m "feat: <short description>"
git push

# E2E
cd d:\Projects\FamilyHubManager\familyhub-e2e
git add -A
git commit -m "feat: <short description>"
git push
```

**NEVER commit before verifying production is healthy.** Committing broken code pollutes the branch history.

---

## Summary Checklist

- [ ] Tests written for every changed repo (backend / frontend / e2e as applicable)
- [ ] Migration files generated and committed (if models changed)
- [ ] All test suites pass locally (`0 failed`)
- [ ] `deploy-to-prod.ps1` ran and exited `0` (includes auto-migrate)
- [ ] All prod containers show `Up` in `docker ps`
- [ ] Feature verified working on production (manual check + log review)
- [ ] All changed repos committed and pushed to `origin`
