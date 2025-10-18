# GitHub Pages Auto-Enable Script
# This script automatically enables GitHub Pages for your repository

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

# Check if token is provided
if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "ERROR: GitHub token is required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To get a token:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/settings/tokens/new" -ForegroundColor White
    Write-Host "2. Give it a name like 'GitHub Pages Setup'" -ForegroundColor White
    Write-Host "3. Select scopes: 'repo' (full repository access)" -ForegroundColor White
    Write-Host "4. Click 'Generate token' and copy it" -ForegroundColor White
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

# GitHub API endpoint
$apiUrl = "https://api.github.com/repos/$Owner/$Repo/pages"

# Create the request body
$body = @{
    source = @{
        branch = $Branch
        path = $Path
    }
} | ConvertTo-Json

# Set headers
$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Attempting to enable GitHub Pages..." -ForegroundColor Yellow

try {
    # Try to create GitHub Pages
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✓ SUCCESS! GitHub Pages has been enabled!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your site will be available at:" -ForegroundColor Cyan
    Write-Host "  https://$($Owner.ToLower()).github.io/$($Repo.ToLower())/" -ForegroundColor White
    Write-Host ""
    Write-Host "Status: $($response.status)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Note: It may take 2-3 minutes for your site to be built and deployed." -ForegroundColor Gray
    Write-Host ""
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 409) {
        Write-Host ""
        Write-Host "GitHub Pages is already enabled for this repository!" -ForegroundColor Yellow
        Write-Host ""
        
        # Try to get current Pages info
        try {
            $pagesInfo = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
            Write-Host "Current configuration:" -ForegroundColor Cyan
            Write-Host "  Source Branch: $($pagesInfo.source.branch)" -ForegroundColor White
            Write-Host "  Source Path: $($pagesInfo.source.path)" -ForegroundColor White
            Write-Host "  URL: $($pagesInfo.html_url)" -ForegroundColor White
            Write-Host "  Status: $($pagesInfo.status)" -ForegroundColor White
            Write-Host ""
            
            if ($pagesInfo.source.branch -ne $Branch -or $pagesInfo.source.path -ne $Path) {
                Write-Host "Updating GitHub Pages configuration..." -ForegroundColor Yellow
                
                # Update the configuration
                $updateResponse = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $body -ContentType "application/json"
                
                Write-Host "✓ Configuration updated successfully!" -ForegroundColor Green
                Write-Host ""
            }
            
        } catch {
            Write-Host "Could not retrieve current Pages configuration." -ForegroundColor Red
        }
        
    } elseif ($statusCode -eq 404) {
        Write-Host ""
        Write-Host "ERROR: Repository not found or you don't have access." -ForegroundColor Red
        Write-Host "Please check:" -ForegroundColor Yellow
        Write-Host "  - Repository name is correct: $Owner/$Repo" -ForegroundColor White
        Write-Host "  - Your token has 'repo' permissions" -ForegroundColor White
        Write-Host "  - You have admin access to the repository" -ForegroundColor White
        Write-Host ""
        
    } elseif ($statusCode -eq 401) {
        Write-Host ""
        Write-Host "ERROR: Authentication failed." -ForegroundColor Red
        Write-Host "Please check:" -ForegroundColor Yellow
        Write-Host "  - Your token is valid" -ForegroundColor White
        Write-Host "  - Your token hasn't expired" -ForegroundColor White
        Write-Host ""
        
    } else {
        Write-Host ""
        Write-Host "ERROR: Failed to enable GitHub Pages." -ForegroundColor Red
        Write-Host "Status Code: $statusCode" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        
        if ($_.ErrorDetails.Message) {
            $errorJson = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "Details: $($errorJson.message)" -ForegroundColor Yellow
            Write-Host ""
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "For more information, visit:" -ForegroundColor Gray
Write-Host "https://docs.github.com/en/pages" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
