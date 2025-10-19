param(
    [string]$OutputFile = "ece_theory_complete_index.md"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ECE Theory Papers Extractor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Searching for ECE Theory papers by Myron W. Evans..." -ForegroundColor Yellow
Write-Host ""

# Try to access AIAS website and extract ECE paper links
$aiasUrls = @(
    "http://www.aias.us",
    "http://www.aias.us/documents/",
    "http://www.aias.us/papers/"
)

$allPapers = @()

foreach ($url in $aiasUrls) {
    Write-Host "Searching: $url" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        
        # Extract links that look like ECE papers
        $papers = $response.Links | Where-Object { 
            $_.href -match "ECE|ece|paper|\.pdf" -or 
            $_.innerText -match "ECE|paper|UFT"
        }
        
        $allPapers += $papers
        Write-Host "  Found $($papers.Count) potential papers" -ForegroundColor Green
    } catch {
        Write-Host "  Could not access: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Generating ECE Theory index..." -ForegroundColor Yellow

# Generate comprehensive ECE index
$report = @"
# ECE (Einstein-Cartan-Evans) Theory - Complete Paper Index

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Author:** Dr. Myron W. Evans
**Theory:** Einstein-Cartan-Evans Unified Field Theory

---

## ⚠️ Important Note

**The ECE Theory papers are primarily available from the AIAS website, NOT from arXiv.**

The arXiv search returned papers from various authors named "M. Evans" (statisticians, mathematicians, etc.), 
which are NOT the ECE theory papers by physicist Dr. Myron W. Evans.

---

## Where to Find the Complete ECE Papers

### Official Source: AIAS Website

**Alpha Institute for Advanced Studies (AIAS)**
- **Main Site:** http://www.aias.us
- **Document Archive:** http://www.aias.us/documents/
- **Papers Section:** http://www.aias.us/papers/

### ECE Theory Paper Collections

The ECE theory comprises **over 400 papers** organized into several series:

#### 1. Main ECE Series (Papers 1-400+)
- Sequential papers developing the unified field theory
- Each paper builds on previous work
- Available as individual PDFs

#### 2. UFT (Unified Field Theory) Series
- Continuation and extension of ECE theory
- Advanced topics and applications
- Numbered sequentially (UFT 1, UFT 2, etc.)

#### 3. PECE (Principles of ECE) Series
- Overview and foundational principles
- Easier entry point for newcomers
- Summarizes key concepts

#### 4. Omnia Opera
- Complete collected works
- Comprehensive compilation
- All papers in organized volumes

---

## ECE Theory Overview

### What is ECE Theory?

The Einstein-Cartan-Evans (ECE) theory is a unified field theory that:

1. **Extends General Relativity**
   - Incorporates torsion into spacetime geometry
   - Uses Cartan geometry and differential topology
   - Goes beyond Riemannian geometry

2. **Unifies Forces**
   - Gravitational field
   - Electromagnetic field
   - Quantum mechanical effects
   - All from single geometric framework

3. **Key Innovation: Torsion**
   - Spacetime has both curvature AND torsion
   - Torsion connects to electromagnetism
   - Curvature connects to gravity

### Mathematical Foundation

- **Cartan Geometry:** Differential forms and connections
- **Tetrad Formalism:** Frame fields in spacetime
- **Torsion Tensor:** New degree of freedom in spacetime
- **Gauge Theory:** Symmetry principles

---

## How to Access ECE Papers

### Step-by-Step Guide:

1. **Visit AIAS Website**
   ```
   http://www.aias.us
   ```

2. **Navigate to Documents/Papers Section**
   - Look for "Papers" or "Documents" link
   - Browse by paper number or topic

3. **Download Individual Papers**
   - Papers are typically in PDF format
   - Named sequentially (ECE 1, ECE 2, etc.)
   - Free download, no registration required

4. **Start with Foundational Papers**
   - Recommended: ECE Papers 1-20
   - Or start with PECE series for overview
   - Read in sequence for best understanding

### Recommended Reading Order:

1. **Introduction:** PECE series for overview
2. **Foundation:** ECE Papers 1-50 (core principles)
3. **Development:** ECE Papers 51-200 (theory expansion)
4. **Applications:** ECE Papers 201-400+ (specific topics)
5. **Advanced:** UFT series (latest developments)

---

## Papers Found from AIAS Website

"@

if ($allPapers.Count -gt 0) {
    $report += "`n### Direct Links Found ($($allPapers.Count) items)`n`n"
    
    $uniquePapers = $allPapers | Select-Object -Unique href | Select-Object -First 100
    
    foreach ($paper in $uniquePapers) {
        if ($paper.href) {
            $href = $paper.href
            if (-not $href.StartsWith("http")) {
                $href = "http://www.aias.us$href"
            }
            $text = if ($paper.innerText) { $paper.innerText.Trim() } else { "AIAS Document" }
            if ($text.Length -gt 0 -and $text.Length -lt 200) {
                $report += "- [$text]($href)`n"
            }
        }
    }
} else {
    $report += @"

### Unable to Extract Direct Links

The AIAS website structure may have changed or requires browser access.

**Manual Access:**
1. Go to http://www.aias.us directly in your web browser
2. Look for "Papers", "Documents", or "ECE Theory" sections
3. Download papers individually or in collections

"@
}

$report += @"

---

## ECE Theory Topics Covered

The 400+ ECE papers cover topics including:

### Theoretical Physics
- Spacetime geometry and torsion
- Gravitational field equations
- Electromagnetic field theory
- Quantum mechanics from geometry
- Particle physics
- Cosmology

### Mathematical Methods
- Cartan differential geometry
- Tensor calculus
- Differential topology
- Lie groups and algebras
- Gauge theory
- Variational principles

### Applications
- Electromagnetic phenomena
- Gravitational effects
- Atomic and molecular physics
- Optical effects
- Energy generation concepts
- Technological applications

---

## Key ECE Theory Predictions

1. **New electromagnetic effects** from spacetime torsion
2. **Gravitational-electromagnetic coupling**
3. **Modified quantum mechanics** from geometry
4. **Energy extraction** from spacetime geometry
5. **Explanation of anomalous phenomena**

---

## Alternative Access Methods

### Archive.org Wayback Machine
```
http://web.archive.org/web/*/http://www.aias.us
```
- Historical snapshots of AIAS website
- May contain older paper archives
- Useful if current site is down

### Research Communities
- AIAS discussion forums (if available)
- Alternative physics research groups
- Academia.edu or ResearchGate profiles

### Paper Collections
- Some papers may be mirrored on alternative sites
- University library systems
- Physics preprint servers

---

## Important Disclaimer

**Mainstream vs. Alternative Physics:**

The ECE theory is considered **alternative physics** and is not part of mainstream physics consensus. 
It represents an independent research program with:

- ✓ Extensive mathematical development (400+ papers)
- ✓ Systematic theoretical framework
- ✓ Open publication and discussion
- ✗ Limited acceptance in mainstream physics journals
- ✗ Ongoing scientific debate about validity

**For researchers:** 
- Evaluate critically using scientific method
- Compare with established physics
- Verify mathematical derivations independently
- Consider both supporting and critical analyses

---

## Summary

**To get ALL ECE papers:**

1. ✅ Go to http://www.aias.us
2. ✅ Navigate to Papers/Documents section  
3. ✅ Download individual papers (ECE 1, 2, 3, ... 400+)
4. ✅ Start with PECE series or ECE 1-20
5. ✅ Read systematically in sequence

**Total Papers:** 400+ ECE papers + UFT series + other publications

**Author:** Dr. Myron W. Evans (AIAS Director)

**Access:** Free download from AIAS website

---

**Report Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

*For the official and complete collection, always visit: http://www.aias.us*
"@

# Save report
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Report Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📄 Saved to: $OutputFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "   The ECE papers are NOT on arXiv" -ForegroundColor Red
Write-Host "   They are on: http://www.aias.us" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Total ECE Papers: 400+" -ForegroundColor White
Write-Host "🌐 Access: http://www.aias.us" -ForegroundColor White
Write-Host ""

# Open file
Start-Process $OutputFile

Write-Host "✓ Opening guide..." -ForegroundColor Green
Write-Host ""
