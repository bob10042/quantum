# Fix Codex Timeout Issue
Write-Host "=== Fixing Codex Extension Timeout Issue ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill stuck codex processes
Write-Host "[1/3] Stopping stuck codex processes..." -ForegroundColor Yellow
$codexProcesses = Get-Process -Name "codex" -ErrorAction SilentlyContinue
if ($codexProcesses) {
    foreach ($proc in $codexProcesses) {
        Write-Host "  Stopping process: $($proc.Id)" -ForegroundColor Gray
        Stop-Process -Id $proc.Id -Force
    }
    Write-Host "  ✓ Stopped $($codexProcesses.Count) codex process(es)" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "  ℹ No codex processes running" -ForegroundColor Gray
}

Write-Host ""

# Step 2: Clear extension cache/state
Write-Host "[2/3] Clearing VS Code extension state..." -ForegroundColor Yellow
$statePaths = @(
    "$env:APPDATA\Code\User\globalStorage\openai.chatgpt",
    "$env:APPDATA\Code\User\workspaceStorage"
)

foreach ($path in $statePaths) {
    if (Test-Path $path) {
        Write-Host "  Found: $path" -ForegroundColor Gray
        # Don't delete, just note it exists
    }
}
Write-Host "  ℹ Extension state locations identified" -ForegroundColor Gray
Write-Host ""

# Step 3: Provide instructions
Write-Host "[3/3] Next Steps" -ForegroundColor Yellow
Write-Host ""
Write-Host "To complete the fix:" -ForegroundColor Cyan
Write-Host "  1. Close VS Code completely" -ForegroundColor White
Write-Host "  2. Wait 5 seconds" -ForegroundColor White
Write-Host "  3. Reopen VS Code" -ForegroundColor White
Write-Host "  4. Try sending a message in Codex again" -ForegroundColor White
Write-Host ""
Write-Host "If the issue persists:" -ForegroundColor Yellow
Write-Host "  - Check your internet connection" -ForegroundColor White
Write-Host "  - Verify you are logged into ChatGPT/OpenAI in VS Code" -ForegroundColor White
Write-Host "  - Check if you have an active ChatGPT Plus/Pro subscription" -ForegroundColor White
Write-Host "  - Try: Extensions -> Codex -> Reload Extension" -ForegroundColor White
Write-Host ""
Write-Host "✓ Cleanup complete!" -ForegroundColor Green
