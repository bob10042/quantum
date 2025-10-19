param(
    [string]$Token,
    [string]$Owner = "bob10042",
    [string]$Repo = "quantum",
    [string]$Branch = "main",
    [string]$Path = "/docs"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Pages Auto-Enable Agent" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "ERROR: GitHub token is required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Yellow
    Write-Host "  .\enable_github_pages.ps1 -Token YOUR_TOKEN_HERE" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Repository: $Owner/$Repo" -ForegroundColor Green
Write-Host "Branch: $Branch" -ForegroundColor Green
Write-Host "Path: $Path" -ForegroundColor Green
Write-Host ""

$apiUrl = "https://api.github.com/repos/$Owner/$Repo/pages"

$body = @{
    source = @{
        branch = $Branch
        path = $Path
    }
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Attempting to enable GitHub Pages..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "SUCCESS! GitHub Pages has been enabled!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your site will be available at:" -ForegroundColor Cyan
    Write-Host "  https://$($Owner.ToLower()).github.io/$($Repo.ToLower())/" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: It may take 2-3 minutes for your site to be built and deployed." -ForegroundColor Gray
    Write-Host ""
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 409) {
        Write-Host ""
        Write-Host "GitHub Pages is already enabled!" -ForegroundColor Yellow
        Write-Host ""
        
        try {
            $pagesInfo = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
            Write-Host "Current configuration:" -ForegroundColor Cyan
            Write-Host "  Branch: $($pagesInfo.source.branch)" -ForegroundColor White
            Write-Host "  Path: $($pagesInfo.source.path)" -ForegroundColor White
            Write-Host "  URL: $($pagesInfo.html_url)" -ForegroundColor White
            Write-Host ""
            
            if ($pagesInfo.source.branch -ne $Branch -or $pagesInfo.source.path -ne $Path) {
                Write-Host "Updating configuration..." -ForegroundColor Yellow
                $updateResponse = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $body -ContentType "application/json"
                Write-Host "Configuration updated!" -ForegroundColor Green
                Write-Host ""
            }
        } catch {
            Write-Host "Could not retrieve Pages configuration." -ForegroundColor Red
        }
        
    } elseif ($statusCode -eq 404) {
        Write-Host ""
        Write-Host "ERROR: Repository not found." -ForegroundColor Red
        Write-Host ""
        
    } elseif ($statusCode -eq 401) {
        Write-Host ""
        Write-Host "ERROR: Authentication failed." -ForegroundColor Red
        Write-Host ""
        
    } else {
        Write-Host ""
        Write-Host "ERROR: Failed to enable GitHub Pages." -ForegroundColor Red
        Write-Host "Status: $statusCode" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
