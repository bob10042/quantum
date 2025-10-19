# Complete Codex Extension Fix
Write-Host "=== Complete Codex Extension Fix ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop all VS Code and Codex processes
Write-Host "[1/4] Stopping VS Code and Codex processes..." -ForegroundColor Yellow
$vscodeProcesses = Get-Process -Name "Code" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
    foreach ($proc in $vscodeProcesses) {
        Stop-Process -Id $proc.Id -Force
    }
    Write-Host "  Stopped $($vscodeProcesses.Count) VS Code process(es)" -ForegroundColor Green
}

$codexProcesses = Get-Process -Name "codex" -ErrorAction SilentlyContinue
if ($codexProcesses) {
    foreach ($proc in $codexProcesses) {
        Stop-Process -Id $proc.Id -Force
    }
    Write-Host "  Stopped $($codexProcesses.Count) codex process(es)" -ForegroundColor Green
}

Start-Sleep -Seconds 3
Write-Host ""

# Step 2: Clear extension state
Write-Host "[2/4] Clearing extension state..." -ForegroundColor Yellow
$globalStorage = "$env:APPDATA\Code\User\globalStorage\openai.chatgpt"
if (Test-Path $globalStorage) {
    Remove-Item -Path $globalStorage -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleared global storage" -ForegroundColor Green
} else {
    Write-Host "  No global storage to clear" -ForegroundColor Gray
}
Write-Host ""

# Step 3: Clear codex session cache
Write-Host "[3/4] Clearing codex session cache..." -ForegroundColor Yellow
$codexSessions = "$env:USERPROFILE\.codex\sessions"
if (Test-Path $codexSessions) {
    Get-ChildItem $codexSessions -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
    Write-Host "  Cleared session cache" -ForegroundColor Green
} else {
    Write-Host "  No sessions to clear" -ForegroundColor Gray
}
Write-Host ""

# Step 4: Instructions
Write-Host "[4/4] Next Steps" -ForegroundColor Yellow
Write-Host ""
Write-Host "Extension state has been reset. Now:" -ForegroundColor Cyan
Write-Host "  1. Open VS Code" -ForegroundColor White
Write-Host "  2. Open the Codex sidebar (blossom icon)" -ForegroundColor White
Write-Host "  3. If you see a login prompt, click 'Sign in with ChatGPT'" -ForegroundColor White
Write-Host "  4. Try sending a message" -ForegroundColor White
Write-Host ""
Write-Host "If error persists, try this in VS Code:" -ForegroundColor Yellow
Write-Host "  Ctrl+Shift+P -> 'Developer: Reload Window'" -ForegroundColor White
Write-Host ""
Write-Host "Still not working? Check:" -ForegroundColor Yellow
Write-Host "  - ChatGPT Plus/Pro subscription is active" -ForegroundColor White
Write-Host "  - Internet connection is stable" -ForegroundColor White
Write-Host "  - No VPN interfering with OpenAI API" -ForegroundColor White
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
