param(
    [switch]$SkipWsl,
    [switch]$IncludeOllama
)

$Source = "C:\Users\PC\Documents\Personal\FamilyHub"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$Destinations = @("D:\Backups\FamilyHub_$Timestamp", "E:\Backups\FamilyHub_$Timestamp")
$DbContainer = "familyhub_prod_db"
$DbUser = "familyhub"
$DbName = "familyhub"

function Write-Step { param([string]$m); Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $m" -ForegroundColor Cyan }
function Write-OK { param([string]$m); Write-Host "  [OK]   $m" -ForegroundColor Green }
function Write-Warn { param([string]$m); Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function Write-Fail { param([string]$m); Write-Host "  [FAIL] $m" -ForegroundColor Red }

# --- Pre-flight ---
Write-Step "Pre-flight checks"
if (-not (Test-Path $Source)) { Write-Fail "Source not found: $Source"; exit 1 }

$validDests = New-Object System.Collections.ArrayList
foreach ($d in $Destinations) {
    $drive = $d.Substring(0, 3)
    if (Test-Path $drive) { [void]$validDests.Add($d) }
    else { Write-Warn "Drive $drive not available -- skipping $d" }
}
if ($validDests.Count -eq 0) { Write-Fail "No backup destinations available."; exit 1 }

$dbRunning = docker ps --filter "name=$DbContainer" --filter "status=running" --format "{{.Names}}" 2>$null
if ($dbRunning) { Write-OK "DB container is running" }
else { Write-Warn "DB container not running -- skipping pg_dump" }

# --- Create dirs ---
Write-Step "Creating backup directories"
foreach ($d in $validDests) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    Write-OK $d
}

# --- pg_dump ---
if ($dbRunning) {
    Write-Step "PostgreSQL dump"
    foreach ($d in $validDests) {
        $sqlPath = "$d\familyhub_db_$Timestamp.sql"
        try {
            # Write dump inside container first, then docker cp (byte-for-byte, no encoding conversion)
            docker exec $DbContainer pg_dump -U $DbUser $DbName -f /tmp/familyhub_backup_tmp.sql
            docker cp "${DbContainer}:/tmp/familyhub_backup_tmp.sql" $sqlPath
            docker exec $DbContainer rm -f /tmp/familyhub_backup_tmp.sql
            $sz = (Get-Item $sqlPath).Length
            if ($sz -gt 1024) { Write-OK "Saved $sqlPath ($([math]::Round($sz/1KB,1)) KB)" }
            else { Write-Warn "Dump looks small ($sz bytes) -- verify: $sqlPath" }
        }
        catch {
            Write-Fail "pg_dump to $d failed: $_"
        }
    }
}

# --- Robocopy ---
Write-Step "Robocopy data directories"
# /COPY:DAT = Data+Attributes+Timestamps (no ACL), /Z = restartable, /XA:SH = skip system+hidden
$roboArgs = @("/E", "/COPY:DAT", "/Z", "/R:2", "/W:3", "/NP", "/XA:SH")
if (-not $IncludeOllama) { $roboArgs += @("/XD", "ollama") }

foreach ($d in $validDests) {
    Write-Host "  Copying: $Source --> $d" -ForegroundColor DarkCyan
    & robocopy $Source $d @roboArgs
    $rc = $LASTEXITCODE
    if ($rc -ge 8) { Write-Fail "Robocopy exit $rc (error) for $d" }
    else { Write-OK "Robocopy exit $rc (success) --> $d" }
}

# --- WSL ---
if (-not $SkipWsl) {
    Write-Step "WSL export"
    $rawList = wsl --list --quiet 2>$null
    $distros = ($rawList -replace '\x00', '') -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    if ($distros -and $distros.Count -gt 0) {
        foreach ($dist in $distros) {
            $tarSrc = "$($validDests[0])\wsl_${dist}_$Timestamp.tar"
            Write-Host "  Exporting WSL '$dist' to $tarSrc ..."
            try {
                wsl --export $dist $tarSrc
                $szGB = [math]::Round((Get-Item $tarSrc).Length / 1GB, 2)
                Write-OK "$dist exported ($szGB GB)"
                for ($i = 1; $i -lt $validDests.Count; $i++) {
                    $tarDst = "$($validDests[$i])\wsl_${dist}_$Timestamp.tar"
                    Copy-Item $tarSrc $tarDst
                    Write-OK "Copied to $($validDests[$i])"
                }
            }
            catch {
                Write-Fail "WSL export '$dist' failed: $_"
            }
        }
    }
    else {
        Write-Warn "No WSL distros found"
    }
}
else {
    Write-Warn "WSL export skipped (-SkipWsl)"
}

# --- Summary ---
Write-Step "Backup complete"
foreach ($d in $validDests) {
    if (Test-Path $d) {
        $allFiles = Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue
        $fileCount = if ($allFiles -ne $null) { @($allFiles).Count } else { 0 }
        $totalMB = if ($allFiles -ne $null) { [math]::Round((@($allFiles) | Measure-Object -Property Length -Sum).Sum / 1MB, 1) } else { 0 }
        Write-OK "$d -- $fileCount files, $totalMB MB total"
    }
}