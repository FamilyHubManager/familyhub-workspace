# Apply MCP server configuration for FamilyHub development
# This script reads mcp.json.template, prompts for secrets, and writes
# the final mcp.json to the VS Code user settings directory.
#
# Secrets required:
#   - MongoDB Atlas: connection string, API client ID/secret
#   - Postman: logged-in via Postman app (auth handled via browser)
#   - GitHub MCP: uses GitHub Copilot auth (no extra token needed)
#
# All other MCP servers (Playwright, Markitdown, Serena, NuGet, MicrosoftDocs,
# DesktopCommander, ChromeDevTools) need NO credentials.

param(
    [switch]$DryRun
)

$mcpDest = "$env:APPDATA\Code\User\mcp.json"
$template = Join-Path $PSScriptRoot "..\mcp\mcp.json.template"

Write-Host "`n=== FamilyHub: MCP Server Setup ===" -ForegroundColor Cyan
Write-Host "This will write to: $mcpDest`n"

# ---- MongoDB Atlas (optional — skip if not using MongoDB) ----
$mdbConn = Read-Host "MongoDB connection string (leave blank to skip MongoDB MCP)"
$mdbClientId = ""
$mdbClientSecret = ""
if ($mdbConn) {
    $mdbClientId = Read-Host "MongoDB Atlas API Client ID (for Atlas tools, optional)"
    if ($mdbClientId) {
        $mdbClientSecret = Read-Host "MongoDB Atlas API Client Secret" -AsSecureString | 
        ForEach-Object { [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_)) }
    }
}

# ---- Build final mcp.json from template ----
$template_content = Get-Content $template -Raw
$final = $template_content `
    -replace '\$\{MDB_CONNECTION_STRING\}', $mdbConn `
    -replace '\$\{MDB_API_CLIENT_ID\}', $mdbClientId `
    -replace '\$\{MDB_API_CLIENT_SECRET\}', $mdbClientSecret

if ($DryRun) {
    Write-Host "`n[DRY RUN] Would write to: $mcpDest" -ForegroundColor Yellow
    Write-Host $final
}
else {
    # Backup existing mcp.json if present
    if (Test-Path $mcpDest) {
        $backup = "$mcpDest.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $mcpDest $backup
        Write-Host "  [BACKUP] Existing mcp.json saved to: $backup" -ForegroundColor Yellow
    }
    $final | Set-Content $mcpDest -Encoding UTF8
    Write-Host "`n[OK] mcp.json written to $mcpDest" -ForegroundColor Green
}

Write-Host "`n=== MCP Servers configured ===" -ForegroundColor Cyan
Write-Host "  No-auth servers (ready immediately):"
Write-Host "    playwright-mcp, markitdown, serena, nuget, microsoftdocs, desktop-commander, chrome-devtools"
Write-Host ""
Write-Host "  Auth-required servers:"
Write-Host "    github-mcp-server  -> uses your GitHub Copilot session (automatic)"
Write-Host "    postman-mcp-server -> sign in to Postman app first"
if ($mdbConn) {
    Write-Host "    mongodb-mcp-server -> configured with your connection string"
}
else {
    Write-Host "    mongodb-mcp-server -> SKIPPED (no connection string provided)"
}
Write-Host ""
Write-Host "Restart VS Code to activate the MCP servers."
