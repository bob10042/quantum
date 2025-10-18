# Test Codex MCP Server Directly
Write-Host "Testing Codex MCP Server..." -ForegroundColor Cyan
Write-Host ""

$codexPath = "C:\Users\bob43\.vscode\extensions\openai.chatgpt-0.4.19-win32-x64\bin\windows-x86_64\codex.exe"

Write-Host "1. Testing basic codex command..." -ForegroundColor Yellow
& $codexPath --version
Write-Host ""

Write-Host "2. Testing login status..." -ForegroundColor Yellow
& $codexPath login status
Write-Host ""

Write-Host "3. Testing MCP server initialization..." -ForegroundColor Yellow
Write-Host "   (This will timeout after 5 seconds if it hangs)" -ForegroundColor Gray

$job = Start-Job -ScriptBlock {
    param($path)
    & $path mcp-server 2>&1
} -ArgumentList $codexPath

Wait-Job $job -Timeout 5 | Out-Null

if ($job.State -eq "Running") {
    Write-Host "   ✓ MCP server started successfully (running in background)" -ForegroundColor Green
    Stop-Job $job
    Remove-Job $job
} else {
    Write-Host "   ✗ MCP server exited immediately" -ForegroundColor Red
    $output = Receive-Job $job
    if ($output) {
        Write-Host "   Output:" -ForegroundColor Gray
        $output | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    }
    Remove-Job $job
}

Write-Host ""
Write-Host "4. Checking for Windows Defender blocks..." -ForegroundColor Yellow
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-Windows Defender/Operational'
    ID = 1116, 1117
    StartTime = (Get-Date).AddHours(-1)
} -ErrorAction SilentlyContinue | Where-Object { $_.Message -like "*codex*" }

if ($events) {
    Write-Host "   ⚠ Windows Defender may be blocking codex!" -ForegroundColor Red
    $events | Select-Object -First 3 | ForEach-Object {
        Write-Host "   $($_.TimeCreated): $($_.Message)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ✓ No Defender blocks detected" -ForegroundColor Green
}
