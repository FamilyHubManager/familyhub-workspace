# FamilyHub - Comprehensive Testing Guide

> **Note:** Reference guide for all three test layers. Example data uses placeholders - use actual data from your environment.

## Overview

This project has **three levels of testing**, all using the same test data for consistency:

1. **Backend Integration Tests** (Pytest) - API workflow testing
2. **Frontend Component Tests** (Vitest) - UI component testing  
3. **E2E Tests** (Playwright) - Full browser automation testing

---

## ✅ Automated Browser Testing (Playwright)

**Yes, there is a way to automate browser testing like Selenium!** We use **Playwright**, which is more modern and reliable.

### Setup E2E Tests

```bash
cd familyhub-e2e
npm install
npx playwright install
```

### Run E2E Tests

```bash
# Run all tests (headless)
npm test

# Run in headed mode (SEE the browser)
npm run test:headed

# Run with interactive UI
npm run test:ui

# Debug specific test
npm run test:debug

# Generate test code by recording
npm run test:codegen http://localhost:80
```

### What Gets Tested

✅ **Authentication** - Login, logout, invalid credentials  
✅ **Properties** - Buildings, apartments, contracts with multiple people  
✅ **Payments** - Rent, utilities (by property), mark as paid  
✅ **Tasks** - View, create, update, filter by priority  
✅ **Budget** - Categories, income/expense tracking  
✅ **Documents** - Navigation, upload  
✅ **Settings** - Profile, notifications

### Multi-Person Contract Testing

```typescript
// tests/02-properties.spec.ts
test('should create rental contract with multiple people', async ({ page }) => {
  // Create contract with tenant + guarantors
  await page.selectOption('select[name="tenant"]', 'Ion Popescu');
  await page.fill('textarea[name="notes"]', 
    'Garanți: Maria Ionescu și Florentin-Cristian Fusneica'
  );
  // ... validates contract with 3-4 people mentioned
});
```

### Utility Payment by Property Testing

```typescript
// tests/03-payments.spec.ts
test('should create utility payments for a property', async ({ page }) => {
  // Creates electric, gas, water utilities for same apartment
  // Verifies property association and totals
});
```

---

## 🔗 Test Data Integration

**Yes, mock testing data is integrated!** All tests use shared fixtures.

### Shared Test Data

All three test frameworks use the **same test data**:

- **3 Buildings**: Tineretului 29A, 31A, Uverturii 163B
- **4 Tenants**: Ion Popescu, Maria Ionescu, Andrei Georgescu, Elena Vasilescu
- **2 Apartments**: Apt 4 (2 rooms, 350 RON), Apt 2 (3 rooms, 450 RON)
- **2 Contracts**: With guarantors (multi-person)
- **4 Tasks**: Property maintenance
- **4 Budget Categories**: Income/expense tracking

### Backend Integration Tests

```python
# tests/conftest.py - Shared fixtures
@pytest.fixture
def complete_test_data(admin_user, buildings, tenants, apartments, contracts, tasks):
    """All test data in one fixture"""
    return {
        'users': {'admin': admin_user, 'family': family_user},
        'buildings': buildings,
        'tenants': tenants,
        'apartments': apartments,
        'contracts': contracts,
        'tasks': tasks,
    }

# tests/test_integration.py - Use fixtures
def test_multi_person_contract(complete_test_data):
    client = APIClient()
    client.force_authenticate(user=complete_test_data['users']['admin'])
    
    response = client.get('/api/v1/properties/contracts/')
    contract = response.data['results'][0]
    
    # Verify multi-person contract
    assert 'garanți' in contract['notes'].lower()
    assert 'Maria Ionescu' in contract['notes']
```

### E2E Tests - API Integration

```typescript
// tests/fixtures.ts - Fetch data from API
export const test = base.extend<{ testData: TestData }>({
  testData: async ({ page }, use) => {
    // Login and get auth token
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@familyhub.local');
    await page.fill('input[name="password"]', 'admin');
    await page.click('button[type="submit"]');
    
    // Fetch existing test data via API
    const buildings = await apiClient.get('/api/v1/properties/buildings/');
    const tenants = await apiClient.get('/api/v1/properties/tenants/');
    const tasks = await apiClient.get('/api/v1/tasks/');
    
    await use({ buildings, tenants, tasks });
  },
});

// tests/02-properties.spec.ts - Use test data
test('should display buildings', async ({ page, testData }) => {
  await page.goto('/properties');
  
  // Verify test buildings exist
  await expect(page.locator('text=Tineretului 29A')).toBeVisible();
  await expect(page.locator('text=Tineretului 31A')).toBeVisible();
});
```

---

## 🧪 Backend Integration Tests

### Setup

```bash
cd familyhub-backend

# Install test dependencies
pip install pytest pytest-django pytest-cov

# Create test data
python create_test_data.py
```

### Run Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=apps --cov-report=html

# Run specific test file
pytest tests/test_integration.py

# Run specific test
pytest tests/test_integration.py::TestCompletePropertyWorkflow::test_multi_person_contract

# Verbose output
pytest -v -s
```

### Test Files

- [tests/conftest.py](familyhub-backend/tests/conftest.py) - Shared fixtures
- [tests/test_integration.py](familyhub-backend/tests/test_integration.py) - Integration tests

### Example Test

```python
@pytest.mark.django_db
class TestCompletePropertyWorkflow:
    def test_view_buildings(self, complete_test_data):
        """Test viewing buildings"""
        client = APIClient()
        client.force_authenticate(user=complete_test_data['users']['admin'])
        
        response = client.get('/api/v1/properties/buildings/')
        
        assert response.status_code == 200
        assert response.data['count'] == 3
        
    def test_property_with_utilities(self, complete_test_data):
        """Test utility responsibility for property"""
        client = APIClient()
        client.force_authenticate(user=complete_test_data['users']['admin'])
        
        response = client.get('/api/v1/properties/contracts/')
        contract = response.data['results'][0]
        
        # Verify utilities not included
        assert contract['includes_utilities'] is False
```

---

## 🎭 E2E Test Structure

```text
familyhub-e2e/
├── package.json                    # Playwright dependencies
├── playwright.config.ts            # Test configuration
├── tests/
│   ├── fixtures.ts                 # Shared test data via API
│   ├── 01-auth.spec.ts            # Authentication tests (3 tests)
│   ├── 02-properties.spec.ts      # Properties tests (5 tests)
│   ├── 03-payments.spec.ts        # Payments tests (6 tests)
│   └── 04-other-modules.spec.ts   # Tasks/Budget/Docs/Settings (9 tests)
└── test-results/                   # Screenshots, videos, traces
```

### Key Features

✅ **Auto-start servers** - Playwright starts both Django and React automatically  
✅ **Multiple browsers** - Tests run on Chrome, Firefox, Safari, Mobile Chrome  
✅ **Screenshots on failure** - Automatic screenshot capture  
✅ **Video recording** - Records test execution  
✅ **Trace viewer** - Step-by-step debugging  
✅ **API integration** - Fetches real test data from backend

---

## 📊 Running All Tests

### Complete Test Suite

```bash
# 1. Backend Integration Tests
cd familyhub-backend
pytest --cov=apps

# 2. Frontend Component Tests
cd ../familyhub-frontend
npm test -- --run

# 3. E2E Browser Tests
cd ../familyhub-e2e
npm test
```

### Test Summary

| Test Type | Framework | Count | Speed | Scope |
| --- | --- | --- | --- | --- |
| Backend Integration | Pytest | ~15 tests | ⚡ Fast | API workflows |
| Frontend Unit | Vitest | ~20 tests | ⚡ Fast | Components |
| E2E Browser | Playwright | 23 tests | 🐢 Slow | Full app |

Total: ~58 automated tests

---

## 🎯 Test Scenarios Covered

### 1. Multi-Person Contract

**User Requirement**: "a mock contract, having that contract be relevant for 3-4 people"

**Backend Test**:

```python
def test_multi_person_contract(complete_test_data):
    response = client.get('/api/v1/properties/contracts/')
    contract = response.data['results'][0]
    
    # Verify tenant + guarantors mentioned
    assert 'Ion Popescu' in str(contract['tenant'])
    assert 'Maria Ionescu' in contract['notes']
    assert 'garanți' in contract['notes'].lower()
```

**E2E Test**:

```typescript
test('should display contract with multiple people', async ({ page }) => {
  await page.goto('/properties/contracts');
  
  // Verify tenant
  await expect(page.locator('text=Ion Popescu')).toBeVisible();
  
  // Verify guarantors in notes
  await page.click('text=/contract details/i');
  await expect(page.locator('text=/Maria Ionescu/i')).toBeVisible();
});
```

### 2. Utility Payments by Property

**User Requirement**: "check who it would be for a mock utility to be paid and how it would look for the property view"

**Backend Test**:

```python
def test_property_utilities(complete_test_data):
    # Property has utilities not included in rent
    contract = get_contract(apartment=apartments[0])
    assert contract.includes_utilities is False
    
    # Can create separate utility payments
    payments = create_utilities_for_property(apartment=apartments[0])
    assert len(payments) == 3  # electric, gas, water
```

**E2E Test**:

```typescript
test('should show utility breakdown for property', async ({ page }) => {
  await page.goto('/properties/1');
  
  // View property details
  await expect(page.locator('text=/Property Details/i')).toBeVisible();
  
  // See utilities section
  await expect(page.locator('text=/Utilities/i')).toBeVisible();
  await expect(page.locator('text=/Curent electric/i')).toBeVisible();
  await expect(page.locator('text=/132.75/i')).toBeVisible();
});
```

### 3. Task Management

**E2E Test**:

```typescript
test('should create and assign maintenance task', async ({ page }) => {
  await page.goto('/tasks');
  await page.click('text=/new task/i');
  
  await page.fill('input[name="title"]', 'Revizie centrala termica');
  await page.selectOption('select[name="priority"]', 'high');
  await page.fill('input[name="due_date"]', '2026-02-15');
  
  await page.click('button[type="submit"]');
  
  await expect(page.locator('text=/success/i')).toBeVisible();
  await expect(page.locator('text=Revizie centrala')).toBeVisible();
});
```

---

## 🔍 Debugging Tests

### Backend (Pytest)

```bash
# Run with debugger
pytest --pdb

# Stop on first failure
pytest -x

# Show print statements
pytest -s

# Run last failed tests
pytest --lf
```

### E2E (Playwright)

```bash
# Debug mode - pauses execution
npm run test:debug

# Show trace viewer
npx playwright show-trace test-results/trace.zip

# Slow motion (1 second per action)
npx playwright test --headed --slow-mo=1000

# Screenshot on every action
npx playwright test --headed --screenshot=on
```

### Playwright UI Mode

```bash
npm run test:ui
```

Features:

- ✅ Run tests interactively
- ✅ See browser actions
- ✅ Time travel debugging
- ✅ Pick locators
- ✅ Watch mode

---

## 📈 Coverage Reports

### Backend Coverage

```bash
cd familyhub-backend
pytest --cov=apps --cov-report=html

# Open report
start htmlcov/index.html
```

### E2E Test Report

```bash
cd familyhub-e2e
npm test

# View report
npx playwright show-report
```

---

## 🚀 CI/CD Integration

Tests run automatically in GitHub Actions:

```yaml
# .github/workflows/ci.yml
jobs:
  backend-tests:
    runs-on: self-hosted
    steps:
      - run: pytest --cov=apps
  
  e2e-tests:
    runs-on: self-hosted
    steps:
      - run: npx playwright test
```

View results:

- **Actions** → **Backend CI/CD Pipeline**
- **Actions** → **E2E Tests**

---

## 💡 Best Practices

1. **Use Fixtures** - Reuse test data across all tests
2. **Independent Tests** - Each test should work standalone
3. **Descriptive Names** - `test_should_create_contract_with_multiple_guarantors`
4. **Arrange-Act-Assert** - Clear test structure
5. **Test Real Scenarios** - Multi-person contracts, utility tracking
6. **Fast Feedback** - Run unit tests frequently, E2E less often

---

## 🛠️ Troubleshooting

### E2E Tests Failing

```bash
# Reinstall browsers
npx playwright install --with-deps

# Check servers running
curl http://localhost:80
curl http://127.0.0.1:8000/api/v1/

# Reset test data
cd familyhub-backend
python create_test_data.py
```

### Backend Tests Failing

```bash
# Reset database
python manage.py flush --no-input

# Run migrations
python manage.py migrate

# Recreate test data
python create_test_data.py
```

---

## 📝 Test Data Accounts

### Users

```text
admin@familyhub.local / admin
manager@familyhub.local / manager123
viewer@familyhub.local / viewer123
```

### Test Data Creation

```bash
# Option 1: Run script
cd familyhub-backend
python create_test_data.py

# Option 2: Use fixtures (automatic in tests)
# tests/conftest.py provides complete_test_data fixture
```

---

## 📚 Resources

- [Playwright Documentation](https://playwright.dev/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Testing Best Practices](https://testingjavascript.com/)

---

## ✨ Summary

### Automated Browser Testing

✅ **YES** - Playwright automates browser testing (better than Selenium)  
✅ **23 E2E tests** covering all app functionality  
✅ **Multi-browser** - Chrome, Firefox, Safari, Mobile  
✅ **Auto-start servers** - No manual setup needed  
✅ **Debug mode** - See tests run step-by-step

### Test Data Integration

✅ **YES** - Mock data integrated with all tests  
✅ **Shared fixtures** - Backend uses pytest fixtures  
✅ **API integration** - E2E tests fetch data from backend API  
✅ **Consistent data** - Same buildings, tenants, contracts across all tests  
✅ **Real scenarios** - Multi-person contracts, utility tracking

### Commands

```bash
# Backend integration tests
cd familyhub-backend && pytest

# E2E browser tests (headless)
cd familyhub-e2e && npm test

# E2E browser tests (see browser)
cd familyhub-e2e && npm run test:headed

# E2E interactive UI mode
cd familyhub-e2e && npm run test:ui
```

**Next Steps**:

1. Install Playwright: `cd familyhub-e2e && npm install && npx playwright install`
2. Run E2E tests: `npm run test:headed` (watch tests run in browser)
3. Check test report: `npx playwright show-report`
