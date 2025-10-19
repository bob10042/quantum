param(
    [string]$OutputDir = ".\ECE_Papers",
    [int]$StartPaper = 1,
    [int]$EndPaper = 100
)

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "  ECE Paper Downloader Agent" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created: $OutputDir" -ForegroundColor Green
}

Write-Host "Searching for ECE papers $StartPaper to $EndPaper..." -ForegroundColor Yellow
Write-Host ""

# Possible URL patterns for ECE papers
$urlPatterns = @(
    "http://www.aias.us/documents/uft/a{0}.pdf",
    "http://www.aias.us/documents/ece/a{0}.pdf",
    "http://www.aias.us/papers/a{0}.pdf",
    "http://www.aias.us/ECE/ECE{0}.pdf",
    "http://www.aias.us/UFT/UFT{0}.pdf",
    "http://web.archive.org/web/20200101/http://www.aias.us/documents/uft/a{0}.pdf"
)

$successCount = 0
$failCount = 0
$foundUrls = @()

for ($i = $StartPaper; $i -le $EndPaper; $i++) {
    $paperFound = $false
    
    foreach ($pattern in $urlPatterns) {
        $url = $pattern -f $i
        
        try {
            # Try to access the URL
            $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            
            if ($response.StatusCode -eq 200) {
                Write-Host "[FOUND] Paper $i : $url" -ForegroundColor Green
                $foundUrls += @{
                    Number = $i
                    Url = $url
                    Size = $response.Headers.'Content-Length'
                }
                $successCount++
                $paperFound = $true
                break
            }
        } catch {
            # Silent fail, try next pattern
        }
    }
    
    if (-not $paperFound) {
        Write-Host "[---] Paper $i : Not found" -ForegroundColor Gray
        $failCount++
    }
    
    # Small delay to avoid overwhelming server
    Start-Sleep -Milliseconds 200
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Search Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Results:" -ForegroundColor Yellow
Write-Host "  Found: $successCount papers" -ForegroundColor Green
Write-Host "  Not Found: $failCount" -ForegroundColor Red
Write-Host ""

if ($foundUrls.Count -gt 0) {
    # Save URLs to file
    $urlFile = Join-Path $OutputDir "Found_ECE_Paper_URLs.txt"
    $foundUrls | ForEach-Object {
        "Paper $($_.Number): $($_.Url)"
    } | Out-File -FilePath $urlFile -Encoding UTF8
    
    Write-Host "URL list saved to: $urlFile" -ForegroundColor Cyan
    Write-Host ""
    
    # Generate download script
    $downloadScript = Join-Path $OutputDir "Download_ECE_Papers.ps1"
    $scriptContent = @"
# Auto-generated ECE Paper Download Script
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "Downloading $($foundUrls.Count) ECE papers..." -ForegroundColor Yellow
Write-Host ""

"@
    
    foreach ($paper in $foundUrls) {
        $filename = "ECE_Paper_$($paper.Number).pdf"
        $scriptContent += @"
Write-Host "Downloading Paper $($paper.Number)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$($paper.Url)" -OutFile "$filename" -ErrorAction SilentlyContinue

"@
    }
    
    $scriptContent += @"

Write-Host ""
Write-Host "Download complete!" -ForegroundColor Green
"@
    
    $scriptContent | Out-File -FilePath $downloadScript -Encoding UTF8
    
    Write-Host "Download script created: $downloadScript" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To download all papers, run:" -ForegroundColor Yellow
    Write-Host "  cd $OutputDir" -ForegroundColor White
    Write-Host "  .\Download_ECE_Papers.ps1" -ForegroundColor White
    Write-Host ""
    
    # Generate report
    $reportPath = Join-Path $OutputDir "ECE_Papers_Report.md"
    $report = @"
# ECE Theory Papers - Access Report

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Papers Searched:** $StartPaper to $EndPaper
**Papers Found:** $successCount

---

## Found Papers

"@
    
    foreach ($paper in $foundUrls) {
        $report += "### ECE Paper $($paper.Number)`n"
        $report += "- **URL:** [$($paper.Url)]($($paper.Url))`n"
        if ($paper.Size) {
            $sizeKB = [math]::Round($paper.Size / 1KB, 2)
            $report += "- **Size:** $sizeKB KB`n"
        }
        $report += "`n"
    }
    
    $report += @"

---

## How to Download

### Method 1: Use Generated Script
``````powershell
cd $OutputDir
.\Download_ECE_Papers.ps1
``````

### Method 2: Manual Download
Click the URLs above to download individual papers

### Method 3: Bulk Download with PowerShell
``````powershell
"@
    
    foreach ($paper in $foundUrls | Select-Object -First 5) {
        $report += "Invoke-WebRequest -Uri '$($paper.Url)' -OutFile 'ECE_Paper_$($paper.Number).pdf'`n"
    }
    
    $report += @"
# ... (continue for all papers)
``````

---

## Access AIAS Website

**Official Site:** http://www.aias.us

For complete ECE theory (400+ papers), visit the official AIAS website.

---

*Report generated by ECE Paper Downloader Agent*
"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
    Write-Host ""
    
    # Open report
    Start-Process $reportPath
    
} else {
    Write-Host "No papers found with tested URL patterns." -ForegroundColor Red
    Write-Host ""
    Write-Host "Recommendations:" -ForegroundColor Yellow
    Write-Host "1. Visit http://www.aias.us directly in browser" -ForegroundColor White
    Write-Host "2. Check Archive.org for historical snapshots" -ForegroundColor White
    Write-Host "3. Contact AIAS for official paper access" -ForegroundColor White
    Write-Host ""
}

Write-Host "Done!" -ForegroundColor Green
Write-Host ""
