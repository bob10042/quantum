param(
    [switch]$Detailed
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         MY AUTOMATION AGENTS           " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$agentPath = "C:\Users\bob43\Downloads\quantum"
$agents = Get-ChildItem "$agentPath\*.ps1" | Sort-Object Name

Write-Host "Location: $agentPath" -ForegroundColor Gray
Write-Host "Total Agents: $($agents.Count)" -ForegroundColor Green
Write-Host ""

if ($Detailed) {
    # Detailed view with descriptions
    $count = 1
    foreach ($agent in $agents) {
        Write-Host "[$count] " -NoNewline -ForegroundColor Cyan
        Write-Host $agent.Name -ForegroundColor Yellow
        Write-Host "    Size: " -NoNewline -ForegroundColor Gray
        Write-Host "$([math]::Round($agent.Length/1KB,2)) KB" -ForegroundColor White
        Write-Host "    Modified: " -NoNewline -ForegroundColor Gray
        Write-Host $agent.LastWriteTime.ToString("yyyy-MM-dd HH:mm") -ForegroundColor White
        Write-Host "    Run: " -NoNewline -ForegroundColor Gray
        Write-Host $agent.Name -ForegroundColor Green
        Write-Host ""
        $count++
    }
} else {
    # Simple table view
    $agents | Select-Object `
        @{Name="Agent";Expression={$_.Name}}, `
        @{Name="Size (KB)";Expression={[math]::Round($_.Length/1KB,2)}}, `
        @{Name="Last Modified";Expression={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")}} | 
        Format-Table -AutoSize
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Yellow
Write-Host "  list_agents.ps1              " -NoNewline; Write-Host "# Simple list" -ForegroundColor Gray
Write-Host "  list_agents.ps1 -Detailed    " -NoNewline; Write-Host "# Detailed info" -ForegroundColor Gray
Write-Host ""
Write-Host "Run any agent by typing its name!" -ForegroundColor Green
Write-Host "Example: " -NoNewline -ForegroundColor Gray
Write-Host "research_agent.ps1 -Query 'quantum physics'" -ForegroundColor White
Write-Host ""
