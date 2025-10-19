<#
.SYNOPSIS
    Complete Quantum Directory Restructure Agent
.DESCRIPTION
    Automatically organizes, deduplicates, and structures the quantum directory
.EXAMPLE
    .\restructure_quantum.ps1
#>

param([switch]$DryRun)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  QUANTUM DIRECTORY RESTRUCTURE AGENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE - No changes will be made]" -ForegroundColor Yellow
    Write-Host ""
}

$rootPath = Get-Location

# Step 1: Create folder structure
Write-Host "Step 1/6: Creating folder structure..." -ForegroundColor Green

$folders = @(
    "Theory_Papers\Consciousness_Mathematics",
    "Theory_Papers\Unified_Field_Theory",
    "Theory_Papers\Physics_Analysis",
    "Theory_Papers\Mathematics",
    "Theory_Papers\Cross_Disciplinary",
    "Theory_Papers\Analysis",
    "UAP_Research",
    "Source_Code\Python",
    "Source_Code\C",
    "Source_Code\Executables",
    "Automation_Agents",
    "Data",
    "Documentation",
    "LaTeX_Source\CONSCIOUSNESS_MATHEMATICS\build",
    "LaTeX_Source\Unification_Model\build",
    "Archive"
)

foreach ($folder in $folders) {
    $path = Join-Path $rootPath $folder
    if (-not (Test-Path $path)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
        Write-Host "  Created: $folder" -ForegroundColor Gray
    }
}

# Step 2: Move Theory Papers
Write-Host ""
Write-Host "Step 2/6: Organizing theory papers..." -ForegroundColor Green

$theoryFiles = @{
    "CONSCIOUSNESS_MATHEMATICS.md" = "Theory_Papers\Consciousness_Mathematics\"
    "CONSCIOUSNESS_MATHEMATICS.pdf" = "Theory_Papers\Consciousness_Mathematics\"
    "CONSCIOUSNESS_COLLAPSE_THEORY.md" = "Theory_Papers\Consciousness_Mathematics\"
    "unified-consciousness-reality-model.md" = "Theory_Papers\Consciousness_Mathematics\"
    "PROOF_OF_FREE_WILL.md" = "Theory_Papers\Consciousness_Mathematics\"
    "Unification_of_Scale_Invariant_and_Consciousness_Model.md" = "Theory_Papers\Unified_Field_Theory\"
    "Unification_of_Scale_Invariant_and_Consciousness_Model.pdf" = "Theory_Papers\Unified_Field_Theory\"
    "Scale_Invariant_Unifying_Resonant_Fields.pdf" = "Theory_Papers\Unified_Field_Theory\"
    "UC_MODEL_CONNECTIONS_DETAILED.md" = "Theory_Papers\Unified_Field_Theory\"
    "UC_MODEL_CONNECTIONS_PART2.md" = "Theory_Papers\Unified_Field_Theory\"
    "WHAT_PHYSICS_CANNOT_DO.md" = "Theory_Papers\Physics_Analysis\"
    "SOLVING_THE_SECOND_LAW.md" = "Theory_Papers\Physics_Analysis\"
    "WOLFRAM_AND_THE_SECOND_LAW.md" = "Theory_Papers\Physics_Analysis\"
    "ORDER_DISORDER_EXPLAINED.md" = "Theory_Papers\Physics_Analysis\"
    "TIME_TRAVEL_MECHANICS.md" = "Theory_Papers\Physics_Analysis\"
    "EQUATIONS_QUICK_REFERENCE.md" = "Theory_Papers\Mathematics\"
    "NEW_EQUATIONS_DETAILED.md" = "Theory_Papers\Mathematics\"
    "new_equations_and_proofs.md" = "Theory_Papers\Mathematics\"
    "IMPROVED_MATHEMATICS.md" = "Theory_Papers\Mathematics\"
    "geometric_proofs.md" = "Theory_Papers\Mathematics\"
    "aharonov_mathematical_framework.md" = "Theory_Papers\Mathematics\"
    "CROSS_TRADITION_MAPPING.md" = "Theory_Papers\Cross_Disciplinary\"
    "PRACTICAL_MYSTICAL_PROTOCOLS.md" = "Theory_Papers\Cross_Disciplinary\"
    "WHAT_THIS_MEANS_ABOUT_TIME.md" = "Theory_Papers\Cross_Disciplinary\"
    "analysis_summary.md" = "Theory_Papers\Analysis\"
    "CRITICAL_ANALYSIS_OBJECTIONS.md" = "Theory_Papers\Analysis\"
    "README_COMPLETE_ANALYSIS.md" = "Theory_Papers\Analysis\"
    "REMAINING_CHALLENGES_RESOLVED.md" = "Theory_Papers\Analysis\"
}

$moved = 0
foreach ($file in $theoryFiles.Keys) {
    $sourcePath = Join-Path $rootPath $file
    if (Test-Path $sourcePath) {
        if (-not $DryRun) {
            Move-Item -Path $sourcePath -Destination (Join-Path $rootPath $theoryFiles[$file]) -Force -ErrorAction SilentlyContinue
        }
        $moved++
    }
}
Write-Host "  Moved $moved theory papers" -ForegroundColor Gray

# Step 3: Move Source Code
Write-Host ""
Write-Host "Step 3/6: Organizing source code..." -ForegroundColor Green

$codeFiles = @{
    "hoffman_research_environment.py" = "Source_Code\Python\"
    "hoffman_research_environment2.py" = "Source_Code\Python\"
    "latex_to_markdown.py" = "Source_Code\Python\"
    "markdown_to_html.py" = "Source_Code\Python\"
    "consciousness_math_test.c" = "Source_Code\C\"
    "rk4_lorenz.c" = "Source_Code\C\"
    "rk4_lorenz.exe" = "Source_Code\C\"
    "consciousness_test" = "Source_Code\Executables\"
    "consciousness_ultimate" = "Source_Code\Executables\"
}

$moved = 0
foreach ($file in $codeFiles.Keys) {
    $sourcePath = Join-Path $rootPath $file
    if (Test-Path $sourcePath) {
        if (-not $DryRun) {
            Move-Item -Path $sourcePath -Destination (Join-Path $rootPath $codeFiles[$file]) -Force -ErrorAction SilentlyContinue
        }
        $moved++
    }
}
Write-Host "  Moved $moved source files" -ForegroundColor Gray

# Step 4: Move Automation Scripts
Write-Host ""
Write-Host "Step 4/6: Organizing automation agents..." -ForegroundColor Green

$scripts = @(
    "add_codex_to_path.ps1",
    "enable_github_pages.ps1",
    "research_agent.ps1",
    "list_agents.ps1",
    "extract_scientist_works.ps1",
    "get_ece_papers.ps1",
    "download_ece_papers.ps1",
    "fix_codex_extension.ps1",
    "fix_codex_timeout.ps1",
    "test_codex_mcp.ps1"
)

$moved = 0
foreach ($script in $scripts) {
    $sourcePath = Join-Path $rootPath $script
    if (Test-Path $sourcePath) {
        if (-not $DryRun) {
            Move-Item -Path $sourcePath -Destination "Automation_Agents\" -Force -ErrorAction SilentlyContinue
        }
        $moved++
    }
}
Write-Host "  Moved $moved automation agents" -ForegroundColor Gray

# Step 5: Move Other Files
Write-Host ""
Write-Host "Step 5/6: Organizing remaining files..." -ForegroundColor Green

$otherFiles = @{
    "UAP_Propulsion_Signatures_Research_Brief.pdf" = "UAP_Research\"
    "lorenz_attractor.csv" = "Data\"
    "CONSCIOUSNESS_MATHEMATICS.tex" = "LaTeX_Source\CONSCIOUSNESS_MATHEMATICS\"
    "Unification_of_Scale_Invariant_and_Consciousness_Model.tex" = "LaTeX_Source\Unification_Model\"
    "Hoffman.txt" = "Archive\"
    "the quauntum.txt" = "Archive\"
    "CLAUDE.md" = "Archive\"
    "conversation.pdf" = "Archive\"
    "conversation_latest.pdf" = "Archive\"
    "ENABLE_GITHUB_PAGES.md" = "Archive\"
    "GITHUB_PAGES_AGENT_GUIDE.md" = "Archive\"
}

$moved = 0
foreach ($file in $otherFiles.Keys) {
    $sourcePath = Join-Path $rootPath $file
    if (Test-Path $sourcePath) {
        if (-not $DryRun) {
            Move-Item -Path $sourcePath -Destination (Join-Path $rootPath $otherFiles[$file]) -Force -ErrorAction SilentlyContinue
        }
        $moved++
    }
}
Write-Host "  Moved $moved other files" -ForegroundColor Gray

# Step 6: Cleanup
Write-Host ""
Write-Host "Step 6/6: Cleaning up duplicates and artifacts..." -ForegroundColor Yellow

$toDelete = @(
    "Unification_of_Scale_Invariant_and_Consciousness_Model.html",
    "Unification_of_Scale_Invariant_and_Consciousness_Model.txt",
    "CONSCIOUSNESS_MATHEMATICS.aux",
    "CONSCIOUSNESS_MATHEMATICS.log",
    "CONSCIOUSNESS_MATHEMATICS.out",
    "CONSCIOUSNESS_MATHEMATICS.toc",
    "Unification_of_Scale_Invariant_and_Consciousness_Model.aux",
    "Unification_of_Scale_Invariant_and_Consciousness_Model.log",
    "Unification_of_Scale_Invariant_and_Consciousness_Model.out"
)

$deleted = 0
foreach ($file in $toDelete) {
    $path = Join-Path $rootPath $file
    if (Test-Path $path) {
        if (-not $DryRun) {
            Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        }
        $deleted++
    }
}

$emptyDirs = @("ECE_Papers", "__pycache__")
foreach ($dir in $emptyDirs) {
    $path = Join-Path $rootPath $dir
    if (Test-Path $path) {
        if (-not $DryRun) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "  Removed $deleted duplicates/artifacts" -ForegroundColor Gray

# Migrate docs to Documentation
if (Test-Path "docs") {
    if (-not $DryRun) {
        Get-ChildItem "docs" | ForEach-Object {
            Move-Item -Path $_.FullName -Destination "Documentation\" -Force -ErrorAction SilentlyContinue
        }
        Remove-Item "docs" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  Migrated /docs to /Documentation" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESTRUCTURE COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "This was a DRY RUN - no changes were made" -ForegroundColor Yellow
} else {
    Write-Host "Directory is now fully organized!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: Review with 'explorer .' or commit to git" -ForegroundColor White
}

Write-Host ""
