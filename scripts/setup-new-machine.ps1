# Full new-machine setup: clones all repos, installs extensions, configures MCP
# Run from the parent directory where you want the FamilyHubManager folder created.
# Usage: cd D:\Projects && .\setup-new-machine.ps1

param(
    [string]$BaseDir = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$workspaceRepo = "d:\Projects\FamilyHubManager\familyhub-workspace"  # update if different

Write-Host "`n╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  FamilyHub — New Machine Setup               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Step 1: Clone all repos
Write-Host "Step 1/3: Cloning repositories..." -ForegroundColor Yellow
& "$PSScriptRoot\clone-all.ps1" -BaseDir $BaseDir

# Step 2: Install extensions
Write-Host "`nStep 2/3: Installing VS Code extensions..." -ForegroundColor Yellow
& "$PSScriptRoot\install-extensions.ps1"

# Step 3: Configure MCP
Write-Host "`nStep 3/3: Configuring MCP servers..." -ForegroundColor Yellow
& "$PSScriptRoot\setup-mcp.ps1"

Write-Host "`n╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Setup complete!                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open the workspace:"
Write-Host "     code `"$BaseDir\FamilyHubManager\FamilyHubManager.code-workspace`""
Write-Host "  2. Sign in to GitHub Copilot (required for github-mcp-server)"
Write-Host "  3. Sign in to Postman app (required for postman-mcp-server)"
Write-Host "  4. Copy familyhub-backend/.env.example -> .env and fill in secrets"
Write-Host "  5. Copy ghostfolio-src/familyhub/.env.example -> .env and fill in secrets"
Write-Host ""
Write-Host "See SETUP.md for detailed instructions."
