# Clone all FamilyHub repos
# Run this script from the parent directory where you want the project to live
# Usage: cd D:\Projects && .\clone-all.ps1

param(
    [string]$BaseDir = (Get-Location).Path,
    [string]$GitHubOrg = "FamilyHubManager"
)

$root = Join-Path $BaseDir "FamilyHubManager"

$repos = @(
    @{ name = "FamilyHubManager"; cloneTo = $root },
    @{ name = "familyhub-backend"; cloneTo = "$root\familyhub-backend" },
    @{ name = "familyhub-frontend"; cloneTo = "$root\familyhub-frontend" },
    @{ name = "familyhub-e2e"; cloneTo = "$root\familyhub-e2e" },
    @{ name = "ghostfolio-src"; cloneTo = "$root\ghostfolio-src" }
)

Write-Host "`n=== FamilyHub: Cloning all repos ===" -ForegroundColor Cyan

foreach ($r in $repos) {
    $url = "https://github.com/$GitHubOrg/$($r.name).git"
    if (Test-Path $r.cloneTo) {
        Write-Host "  [SKIP] $($r.name) — already exists at $($r.cloneTo)" -ForegroundColor Yellow
    }
    else {
        Write-Host "  [CLONE] $($r.name) -> $($r.cloneTo)" -ForegroundColor Green
        git clone $url $r.cloneTo
    }
}

Write-Host "`n=== Done. Open FamilyHubManager.code-workspace in VS Code ===" -ForegroundColor Cyan
Write-Host "  code `"$root\FamilyHubManager.code-workspace`""
