# FamilyHub Workspace Setup

This repo bootstraps a complete **FamilyHub development environment** on a new machine.
Clone it and run the setup script — it handles all repos, VS Code extensions, and MCP servers.

> **No secrets are stored here.** All credentials are entered interactively during setup or loaded from `.env` files.

---

## Quick Start (new machine)

```powershell
# 1. Clone this workspace repo
git clone https://github.com/FamilyHubManager/familyhub-workspace.git
cd familyhub-workspace

# 2. Run the full setup (clones repos + installs extensions + configures MCP)
cd scripts
.\setup-new-machine.ps1 -BaseDir "D:\Projects"
```

That's it. VS Code opens the multi-root workspace ready to go.

---

## What Gets Set Up

### Repositories (cloned into `FamilyHubManager/`)

| Repo | Purpose |
|------|---------|
| `FamilyHubManager` | Workspace root — deploy scripts, workspace file |
| `familyhub-backend` | Django REST API + Celery workers |
| `familyhub-frontend` | React + Vite + TailwindCSS SPA |
| `familyhub-e2e` | Playwright E2E + Docker Compose stacks |
| `ghostfolio-src` | Ghostfolio fork with FamilyHub docker-compose overlay |

### VS Code Extensions (42 extensions)

See [`.vscode/extensions.json`](.vscode/extensions.json) for the full list.
Key extensions:

- **GitHub Copilot Chat** — AI coding assistant + MCP host
- **GitLens** + **Git Graph** — git history and blame
- **Python**, **Pylance**, **Debugpy** — Django backend development  
- **ESLint**, **Prettier**, **Tailwind CSS IntelliSense** — frontend tooling
- **Docker**, **Remote Containers** — container management
- **Playwright** — E2E test runner
- **Error Lens**, **Better Comments** — code readability

### MCP Servers (10 servers)

See [`mcp/mcp.json.template`](mcp/mcp.json.template) for the full configuration.

| Server | Auth | Purpose |
|--------|------|---------|
| `microsoft/playwright-mcp` | None | Browser automation via MCP |
| `microsoft/markitdown` | None | Convert docs to markdown |
| `io.github.github/github-mcp-server` | GitHub Copilot session | GitHub API (issues, PRs) |
| `oraios/serena` | None | Semantic code navigation |
| `com.microsoft/nuget` | None | NuGet package management |
| `microsoftdocs/mcp` | None | Microsoft Learn docs search |
| `io.github.wonderwhy-er/desktop-commander` | None | Terminal + file operations |
| `io.github.mongodb-js/mongodb-mcp-server` | Connection string | MongoDB Atlas queries |
| `com.postman/postman-mcp-server` | Postman app login | API collection management |
| `io.github.ChromeDevTools/chrome-devtools-mcp` | None | Chrome DevTools automation |

---

## Individual Setup Steps

### Clone repos only

```powershell
.\scripts\clone-all.ps1 -BaseDir "D:\Projects"
```

### Install extensions only

```powershell
.\scripts\install-extensions.ps1
```

### Configure MCP only

```powershell
.\scripts\setup-mcp.ps1
```

---

## Post-Setup: Secrets Configuration

The scripts set up the **tooling** — you still need to provide secrets for the **apps**:

### Backend (`.env`)

```powershell
cd D:\Projects\FamilyHubManager\familyhub-backend
copy .env.example .env
# Edit .env — fill in DB credentials, Django SECRET_KEY, API keys
```

### Ghostfolio (`.env`)

```powershell
cd D:\Projects\FamilyHubManager\ghostfolio-src\familyhub
copy .env.example .env
# Edit .env — fill in POSTGRES_*, JWT_SECRET_KEY, ACCESS_TOKEN_SALT, GHOSTFOLIO_API_KEY
```

### MCP: MongoDB Atlas

Prompted during `setup-mcp.ps1`. You need:

- A MongoDB Atlas connection string (`mongodb+srv://...`)
- Optionally: Atlas API Client ID + Secret (for Atlas management tools)

### MCP: GitHub (automatic)

Uses your active GitHub Copilot session — no extra token needed.

### MCP: Postman

Sign in to the Postman desktop app. The MCP server authenticates via the app.

---

## Prerequisites

| Tool | Min Version | Install |
|------|-------------|---------|
| VS Code | 1.95+ | <https://code.visualstudio.com> |
| Git | Any | <https://git-scm.com> |
| Node.js | 20+ | <https://nodejs.org> |
| Python | 3.11+ | <https://python.org> |
| uv / uvx | Any | `pip install uv` or <https://docs.astral.sh/uv> |
| Docker Desktop | Any | <https://docker.com/products/docker-desktop> |
| .NET SDK | 9+ | <https://dotnet.microsoft.com> (for NuGet MCP) |

---

## Repository Layout

```
familyhub-workspace/
├── README.md                    ← This file
├── SETUP.md                     ← Detailed setup reference
├── FamilyHubManager.code-workspace  ← VS Code multi-root workspace file
├── repos.json                   ← Machine-readable repo list
├── .vscode/
│   └── extensions.json          ← Recommended extensions (42)
├── mcp/
│   └── mcp.json.template        ← MCP server config (no secrets)
└── scripts/
    ├── setup-new-machine.ps1    ← Full setup (clone + extensions + MCP)
    ├── clone-all.ps1            ← Clone all 5 repos
    ├── install-extensions.ps1  ← Install VS Code extensions
    └── setup-mcp.ps1           ← Configure MCP servers
```

---

## Asking an Agent to Set Up Your Environment

Open VS Code, start a Copilot Chat session, and say:

> "I'm on a new machine. Read the FamilyHub workspace repo (github.com/FamilyHubManager/familyhub-workspace), clone all repos, install extensions, and guide me through MCP setup and secrets configuration."

The agent can read `repos.json`, `mcp/mcp.json.template`, and `SETUP.md` and run the scripts on your behalf.
