# Agent to query literature sources and log findings for the Unified Framework project.
# Requires PowerShell 5.1+.
param(
    [Parameter(Mandatory = $true)][string]$Query,
    [int]$MaxResults = 5,
    [string]$OutputDir = "C:\Users\bob43\Downloads\quantum\Unified_Framework\research_logs",
    [switch]$Arxiv,
    [switch]$Crossref,
    [switch]$Web,
    [switch]$SaveRaw,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web

if (-not ($Arxiv -or $Crossref -or $Web)) {
    $Arxiv = $true
    $Crossref = $true
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
    if ($DryRun) {
        Write-Warning "Output directory $OutputDir not found (dry run)."
    } else {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }
}

$rawDir = Join-Path $OutputDir 'raw'
if ($SaveRaw -and -not (Test-Path -LiteralPath $rawDir) -and -not $DryRun) {
    New-Item -ItemType Directory -Path $rawDir | Out-Null
}

function Get-Slug {
    param([string]$Text)
    $normalized = $Text.ToLowerInvariant()
    $normalized = [regex]::Replace($normalized, '[^a-z0-9]+', '-')
    $normalized = $normalized.Trim('-')
    if ([string]::IsNullOrWhiteSpace($normalized)) { return 'query' }
    return $normalized.Substring(0, [Math]::Min($normalized.Length, 40))
}

function Compress-Whitespace {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }
    return ([regex]::Replace($Text, '\s+', ' ')).Trim()
}

function Limit-Text {
    param([string]$Text, [int]$MaxLength = 400)
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    if ($Text.Length -le $MaxLength) { return $Text }
    return $Text.Substring(0, $MaxLength).Trim() + '...'
}

function Save-RawPayload {
    param(
        [string]$Source,
        $Payload,
        [string]$Format = 'json'
    )
    if (-not $SaveRaw -or $DryRun) { return }
    $timestamp = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
    $slug = Get-Slug -Text $Query
    $extension = switch ($Format.ToLowerInvariant()) {
        'xml' { 'xml' }
        'txt' { 'txt' }
        default { 'json' }
    }
    $rawPath = Join-Path $rawDir "${timestamp}_${slug}_${Source}.$extension"
    switch ($extension) {
        'xml' { $Payload | Set-Content -LiteralPath $rawPath -Encoding UTF8 }
        'txt' { $Payload | Set-Content -LiteralPath $rawPath -Encoding UTF8 }
        default {
            $Payload | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $rawPath -Encoding UTF8
        }
    }
}

function Invoke-ArxivSearch {
    param([string]$SearchQuery, [int]$Limit)

    $encoded = [System.Web.HttpUtility]::UrlEncode($SearchQuery)
    $uri = "http://export.arxiv.org/api/query?search_query=all:$encoded&start=0&max_results=$Limit"
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri
    $body = $response.Content
    [xml]$xml = $body
    $entries = @()
    foreach ($entry in $xml.feed.entry) {
        $authors = $entry.author | ForEach-Object { $_.name } | Where-Object { $_ } | ForEach-Object { $_.Trim() }
        $summary = Compress-Whitespace -Text ($entry.summary)
        $entries += [pscustomobject]@{
            Source    = 'arXiv'
            Title     = Compress-Whitespace -Text ($entry.title)
            Url       = ($entry.id)
            Published = [datetime]$entry.published
            Authors   = ($authors -join '; ')
            Summary   = Limit-Text -Text $summary
            Identifier= ($entry.id)
        }
    }
    Save-RawPayload -Source 'arxiv' -Payload $body -Format 'xml'
    return $entries
}

function Invoke-CrossrefSearch {
    param([string]$SearchQuery, [int]$Limit)

    $encoded = [System.Web.HttpUtility]::UrlEncode($SearchQuery)
    $uri = "https://api.crossref.org/works?query=$encoded&rows=$Limit&sort=issued&order=desc"
    $response = Invoke-RestMethod -Uri $uri -Method Get
    Save-RawPayload -Source 'crossref' -Payload $response
    $items = $response.message.items
    $results = @()
    foreach ($item in $items) {
        if (-not ($item -is [psobject])) { continue }

        $title = ''
        if ($item.PSObject.Properties['title'] -and $item.title) {
            $title = $item.title[0]
        } elseif ($item.PSObject.Properties['container-title'] -and $item.'container-title') {
            $title = ($item.'container-title') -join ' '
        }
        $title = Compress-Whitespace -Text $title
        if ([string]::IsNullOrWhiteSpace($title)) { continue }

        $authors = @()
        if ($item.PSObject.Properties['author'] -and $item.author) {
            foreach ($author in $item.author) {
                if (-not ($author -is [psobject])) { continue }
                $parts = @()
                if ($author.PSObject.Properties['given'] -and $author.given) { $parts += $author.given }
                if ($author.PSObject.Properties['family'] -and $author.family) { $parts += $author.family }
                if ($parts.Count -gt 0) { $authors += ($parts -join ' ') }
            }
        }

        $issued = $null
        if ($item.PSObject.Properties['issued'] -and $item.issued.'date-parts') {
            $dateParts = $item.issued.'date-parts'[0]
            $year = $dateParts[0]
            $month = if ($dateParts.Count -gt 1) { $dateParts[1] } else { 1 }
            $day = if ($dateParts.Count -gt 2) { $dateParts[2] } else { 1 }
            $issued = Get-Date -Year $year -Month $month -Day $day
        }

        $summary = ''
        if ($item.PSObject.Properties['abstract'] -and $item.abstract) {
            $summary = Compress-Whitespace -Text ($item.abstract -replace '<.*?>', '')
        }

        $url = ''
        if ($item.PSObject.Properties['URL'] -and $item.URL) {
            $url = $item.URL
        } elseif ($item.PSObject.Properties['DOI'] -and $item.DOI) {
            $url = "https://doi.org/$($item.DOI)"
        }

        $doi = ''
        if ($item.PSObject.Properties['DOI'] -and $item.DOI) {
            $doi = $item.DOI
        }

        $results += [pscustomobject]@{
            Source    = 'Crossref'
            Title     = $title
            Url       = $url
            Published = $issued
            Authors   = ($authors -join '; ')
            Summary   = Limit-Text -Text $summary
            Identifier= $doi
        }
    }
    return $results
}

function Invoke-WebSearch {
    param([string]$SearchQuery, [int]$Limit)

    $endpoint = $env:UNIFIED_WEB_SEARCH_ENDPOINT
    $key = $env:UNIFIED_WEB_SEARCH_KEY
    if (-not $endpoint -or -not $key) {
        Write-Warning 'Web search skipped: set UNIFIED_WEB_SEARCH_ENDPOINT and UNIFIED_WEB_SEARCH_KEY.'
        return @()
    }
    $uri = "$endpoint?q=$([System.Web.HttpUtility]::UrlEncode($SearchQuery))&count=$Limit"
    $headers = @{ 'Ocp-Apim-Subscription-Key' = $key }
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    Save-RawPayload -Source 'web' -Payload $response
    $items = @()
    if ($response.value) {
        $items = $response.value
    } elseif ($response.webPages.value) {
        $items = $response.webPages.value
    }
    $results = @()
    foreach ($item in $items) {
        $results += [pscustomobject]@{
            Source    = 'Web'
            Title     = Compress-Whitespace -Text $item.name
            Url       = $item.url
            Published = $null
            Authors   = ''
            Summary   = Limit-Text -Text (Compress-Whitespace -Text $item.snippet)
            Identifier= $item.url
        }
    }
    return $results
}

$records = @()
if ($Arxiv) {
    try {
        $records += Invoke-ArxivSearch -SearchQuery $Query -Limit $MaxResults
    } catch {
        Write-Warning "arXiv search failed: $($_.Exception.Message)"
    }
}
if ($Crossref) {
    try {
        $records += Invoke-CrossrefSearch -SearchQuery $Query -Limit $MaxResults
    } catch {
        Write-Warning "Crossref search failed: $($_.Exception.Message)"
    }
}
if ($Web) {
    try {
        $records += Invoke-WebSearch -SearchQuery $Query -Limit $MaxResults
    } catch {
        Write-Warning "Web search failed: $($_.Exception.Message)"
    }
}

if ($records.Count -eq 0) {
    Write-Warning 'No records retrieved.'
    return
}

$timestamp = Get-Date
$slug = Get-Slug -Text $Query
$fileName = "{0}_{1}.md" -f $timestamp.ToString('yyyy-MM-dd_HHmm'), $slug
$logPath = Join-Path $OutputDir $fileName

$records = $records | Sort-Object -Property Published -Descending

$lines = @()
$lines += "# Research Sweep - $($timestamp.ToString('yyyy-MM-dd HH:mm'))"
$lines += ""
$lines += ('**Query:** `{0}`' -f $Query)
$lines += ""
$lines += '**Sources:** ' + ((($records | Select-Object -ExpandProperty Source -Unique) -join ', '))
$lines += ""
$lines += "## Summary"
$lines += ""
foreach ($entry in $records) {
    $dateText = if ($entry.Published) { $entry.Published.ToString('yyyy-MM-dd') } else { 'n/a' }
    $lines += "- [$($entry.Title)]($($entry.Url)) - $dateText ($($entry.Source))"
}
$lines += ""
$lines += "## Details"
$lines += ""
$lines += "| Source | Date | Title | Authors | Identifier | Summary |"
$lines += "|--------|------|-------|---------|------------|---------|"
foreach ($entry in $records) {
    $dateText = if ($entry.Published) { $entry.Published.ToString('yyyy-MM-dd') } else { 'n/a' }
    $authors = if ([string]::IsNullOrWhiteSpace($entry.Authors)) { 'n/a' } else { $entry.Authors }
    $identifier = if ([string]::IsNullOrWhiteSpace($entry.Identifier)) { 'n/a' } else { $entry.Identifier }
    $summary = if ([string]::IsNullOrWhiteSpace($entry.Summary)) { 'n/a' } else { $entry.Summary }
    $lines += "| $($entry.Source) | $dateText | [$($entry.Title)]($($entry.Url)) | $authors | $identifier | $summary |"
}
$lines += ""
$lines += "## Agent Notes"
$lines += ""
$completed = Get-Date
$lines += "- Runtime: $([Math]::Round(($completed - $timestamp).TotalSeconds,2)) s"
$lines += "- Max results requested: $MaxResults"
$lines += "- Raw payloads saved: $(if ($SaveRaw -and -not $DryRun) { 'yes' } else { 'no' })"
$lines += ""
$lines += "## Reviewer Checklist"
$lines += ""
$lines += "- [ ] Findings reviewed"
$lines += "- [ ] Linked to derivations/tests"
$lines += "- [ ] Follow-up tasks created"
$lines += ""

if ($DryRun) {
    Write-Host "--- Preview ---" -ForegroundColor Yellow
    $lines | ForEach-Object { Write-Host $_ }
    Write-Host "--- End Preview ---" -ForegroundColor Yellow
    return
}

$lines | Set-Content -LiteralPath $logPath -Encoding UTF8
Write-Host "Report written to $logPath" -ForegroundColor Green
