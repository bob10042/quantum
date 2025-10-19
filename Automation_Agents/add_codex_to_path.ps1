# Add Codex to PATH
$codexPath = "C:\Users\bob43\.vscode\extensions\openai.chatgpt-0.4.21-win32-x64\bin\windows-x86_64"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')

if ($currentPath -notlike "*$codexPath*") {
    $newPath = "$currentPath;$codexPath"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✓ Added codex to PATH successfully!" -ForegroundColor Green
    Write-Host "  Path added: $codexPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "IMPORTANT: You need to restart your terminal for the changes to take effect." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use codex immediately in this session, run:" -ForegroundColor Cyan
    Write-Host "  `$env:Path += ';$codexPath'" -ForegroundColor White
} else {
    Write-Host "✓ Codex is already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "Testing codex..." -ForegroundColor Cyan
& "$codexPath\codex.exe" --version
