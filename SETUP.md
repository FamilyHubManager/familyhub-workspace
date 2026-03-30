# SETUP.md — Detailed Setup Reference

Verbose companion to README.md for troubleshooting and manual setup steps.

---

## 1. Prerequisites Check

Run this to verify all required tools are installed:

```powershell
@{
    "git"    = { git --version }
    "node"   = { node --version }
    "npm"    = { npm --version }
    "python" = { python --version }
    "uvx"    = { uvx --version }
    "docker" = { docker --version }
    "code"   = { code --version }
    "dotnet" = { dotnet --version }
}.GetEnumerator() | ForEach-Object {
    try { $v = & $_.Value 2>&1; Write-Host "  ✓ $($_.Key): $v" -ForegroundColor Green }
    catch { Write-Host "  ✗ $($_.Key): NOT FOUND" -ForegroundColor Red }
}
```

---

## 2. Cloning Repos

The five repos must be siblings inside one `FamilyHubManager` folder:

```
D:\Projects\
└── FamilyHubManager\
    ├── FamilyHubManager.code-workspace   ← workspace launcher
    ├── familyhub-backend\
    ├── familyhub-frontend\
    ├── familyhub-e2e\
    └── ghostfolio-src\
```

Clone manually if the script fails:
```powershell
$base = "D:\Projects\FamilyHubManager"
New-Item -ItemType Directory -Path $base -Force
git clone https://github.com/FamilyHubManager/FamilyHubManager.git     $base
git clone https://github.com/FamilyHubManager/familyhub-backend.git    "$base\familyhub-backend"
git clone https://github.com/FamilyHubManager/familyhub-frontend.git   "$base\familyhub-frontend"
git clone https://github.com/FamilyHubManager/familyhub-e2e.git        "$base\familyhub-e2e"
git clone https://github.com/FamilyHubManager/ghostfolio-src.git       "$base\ghostfolio-src"
```

---

## 3. MCP Server Details

### Servers requiring NO setup

| Server | Mechanism |
|--------|-----------|
| `microsoft/playwright-mcp` | `npx @playwright/mcp@latest` — downloads on first use |
| `microsoft/markitdown` | `uvx markitdown-mcp` — downloads on first use |
| `oraios/serena` | `uvx` from GitHub — downloads on first use |
| `com.microsoft/nuget` | `dnx` — requires .NET SDK |
| `microsoftdocs/mcp` | HTTP endpoint — no auth |
| `io.github.wonderwhy-er/desktop-commander` | `npx` — downloads on first use |
| `io.github.ChromeDevTools/chrome-devtools-mcp` | `npx` — downloads on first use |

### GitHub MCP Server

Uses GitHub Copilot's existing OAuth session via `https://api.githubcopilot.com/mcp/`.
No additional token needed — just sign in to GitHub Copilot in VS Code.

### MongoDB MCP Server

Requires a MongoDB Atlas connection string and optionally Atlas API credentials.

1. Go to https://cloud.mongodb.com → your cluster → **Connect** → **Drivers**
2. Copy the `mongodb+srv://` connection string
3. Run `.\scripts\setup-mcp.ps1` and paste when prompted

For Atlas management tools (create clusters, manage users), also create an API key:
1. Atlas → Project Settings → Access Manager → API Keys → Create
2. Save the Client ID and Client Secret — they're shown once

### Postman MCP Server

1. Install Postman desktop app: https://postman.com/downloads
2. Sign in to your Postman account
3. The MCP server at `https://mcp.postman.com/mcp` authenticates via the app

---

## 4. Start the Development Stack

```powershell
cd D:\Projects\FamilyHubManager\familyhub-e2e

# Start everything (backend + frontend + DB + Redis)
docker compose -f docker-compose.dev.yml up -d

# Check status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Backend API: http://localhost:8000
Frontend:    http://localhost:5173

---

## 5. Backend `.env` Reference

Copy `familyhub-backend/.env.example` to `familyhub-backend/.env` and fill in:

| Variable | Description |
|----------|-------------|
| `SECRET_KEY` | Django secret key — generate with `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"` |
| `DATABASE_URL` | PostgreSQL URL — usually `postgresql://familyhub:familyhub@localhost:5432/familyhub` in dev |
| `REDIS_URL` | Redis URL — usually `redis://localhost:6379/0` |
| `ALLOWED_HOSTS` | Comma-separated hostnames |
| `DEBUG` | `True` for development |

---

## 6. Ghostfolio `.env` Reference

Copy `ghostfolio-src/familyhub/.env.example` to `ghostfolio-src/familyhub/.env` and fill in:

| Variable | Description |
|----------|-------------|
| `POSTGRES_DB` | Database name (e.g. `ghostfolio`) |
| `POSTGRES_USER` | DB user |
| `POSTGRES_PASSWORD` | DB password |
| `JWT_SECRET_KEY` | Random string for JWT signing |
| `ACCESS_TOKEN_SALT` | Random string for access token hashing |
| `GHOSTFOLIO_API_KEY` | Ghostfolio API key — set after first login |

---

## 7. Troubleshooting

### MCP server not starting
- Check VS Code Output panel → **MCP: <server-name>**
- For `uvx` servers: run `uvx --version` in terminal — if not found, install uv: `pip install uv`
- For `npx` servers: run `node --version` — needs Node 20+
- For `dnx` (NuGet): run `dotnet --version` — needs .NET 9+

### Extensions not installing
- Run `code --install-extension <ext-id> --force` manually for failing extensions
- Check VS Code extension marketplace connectivity

### Repos cloning with wrong branch
The default branch for each repo:
- `familyhub-backend`: `main`
- `familyhub-frontend`: `main`
- `familyhub-e2e`: `main`
- `ghostfolio-src`: `release/v1.0.0` (FamilyHub fork branch)
