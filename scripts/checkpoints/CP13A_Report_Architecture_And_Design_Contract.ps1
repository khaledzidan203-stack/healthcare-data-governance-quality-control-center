$ErrorActionPreference = "Stop"

# ============================================================
# CP13-A
# REPORT ARCHITECTURE + DESIGN CONTRACT
# ============================================================

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$out  = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$docsDir = Join-Path $root "docs\reporting"
$scriptPath = Join-Path $root "scripts\checkpoints\CP13A_Report_Architecture_And_Design_Contract.ps1"

$architectureFile = Join-Path $docsDir "REPORT_ARCHITECTURE_CONTRACT.md"
$designFile       = Join-Path $docsDir "REPORT_DESIGN_SYSTEM.md"

Set-Location $root

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Text
    )

    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

try {

    if (-not (Test-Path $scriptPath)) {
        throw "Checkpoint script file not found."
    }

    New-Item -ItemType Directory -Path $docsDir -Force | Out-Null

    # ============================================================
    # 1. REPORT ARCHITECTURE CONTRACT
    # ============================================================

    $architecture = @'
# REPORT ARCHITECTURE CONTRACT
## Project
Healthcare Data Governance & Quality Control Center

## Status
APPROVED FOR BUILD

## Report Goal
Build an executive-grade Power BI report that presents healthcare data governance and data quality insights in a simple, visual, non-technical, storytelling-oriented structure.

## Required Navigation Pattern
- First page must be: `INDEX`
- Each page must contain a `Home / INDEX` navigation button at the top-right
- Navigation tooltip text must be in English
- Standard tooltip text pattern:
  - `Press Ctrl + Click to go to [Page Name]`

## Approved Page Inventory
1. INDEX
2. Executive Overview
3. Data Quality Overview
4. Coding Quality
5. Service & Payment Patterns
6. Demographic & Provider Mix
7. Quality Issues Monitor

## Page Roles

### 01. INDEX
Purpose:
- report landing page
- navigation gateway to all pages
- no analytical visuals
- no slicers

### 02. Executive Overview
Purpose:
- business summary
- first-read page
- top KPIs + general mix + quality snapshot

### 03. Data Quality Overview
Purpose:
- show the scale and concentration of quality issues
- focus on blank, missing, invalid, and suspicious signals

### 04. Coding Quality
Purpose:
- show coding completeness and coding distribution
- explore diagnosis / service coding quality patterns

### 05. Service & Payment Patterns
Purpose:
- show service volume and represented payment patterns
- compare operational volume vs payment concentration

### 06. Demographic & Provider Mix
Purpose:
- show population / provider / service mix
- compare where quality issues concentrate across segments

### 07. Quality Issues Monitor
Purpose:
- action-oriented page
- show highest-priority issue slices
- help focus review effort

## Visual Density Rule
Per page:
- 1 title zone
- 1 slicer zone
- 1 KPI row
- 2 to 4 main visuals
- maximum 1 detail matrix/table

## Slicer Placement Rule
Approved:
- horizontal slicer strip below page title

Rejected for version 1:
- side icon slicer panel

Reason:
- preserves page width
- reduces clutter
- improves scanability

## Technical Content Rule
The report must avoid technical overload.
Do not expose:
- model structure text
- engineering implementation details
- semantic-model terminology
- internal validation narratives

Allowed:
- clear business labels
- short subtitles
- action-oriented insights

## Storytelling Rule
Every page must communicate one primary message only.
'@

    # ============================================================
    # 2. DESIGN SYSTEM
    # ============================================================

    $design = @'
# REPORT DESIGN SYSTEM
## Project
Healthcare Data Governance & Quality Control Center

## Design Direction
Executive / premium / clean / low-clutter / high-readability

## Layout Rules
- large page title centered
- small subtitle centered below the title
- top-right INDEX button
- slicers in one horizontal strip
- KPI cards directly below slicers
- visual groups separated by section title bars
- wide margins and consistent spacing
- no overlapping background shapes over visuals

## Page Background Rule
- use a single controlled page background system
- background shapes must be sent to back
- background must never cover or interfere with visuals
- no free-floating decorative shapes over chart area

## Title Rules
- page title centered
- visual/card title centered
- title area must have a contrasting header background
- titles must be short and clear
- avoid long technical wording

## Approved Color Palette

### Canvas / Neutral
- Canvas Background: #F4F7FB
- Card Background:   #FFFFFF
- Soft Panel:        #EEF3F9
- Border / Divider:  #D9E2EC
- Neutral Text:      #22324A
- Secondary Text:    #6B7A90

### Semantic Colors
- Structure / Header / Navigation: #173B63
- Comparative / Benchmark:         #506CF0
- Positive / Clean / Stable:       #1E9E96
- Watch / Caution:                 #C98A2E
- Issue / Risk / Bad Quality:      #D45757
- Dark Neutral Highlight:          #3C4B63

## KPI Color Rules
- raw volume KPIs -> structure / neutral
- positive quality KPIs -> teal
- caution KPIs -> amber
- issue KPIs -> red
- benchmark / comparison KPIs -> indigo

## Chart Color Rules
Use color by analytical meaning, not random color.

### Good-high metrics
higher is better:
- teal dominant scale

### Bad-high metrics
higher is worse:
- amber to red scale

### Benchmark / comparison metrics
- indigo dominant scale

### composition / mix visuals
- neutral palette with 1 semantic highlight

## Table Formatting Rules
- allow arrows only when a true directional comparison exists
- no arrows on raw counts without comparison
- arrow color must depend on KPI meaning:
  - if up is good -> up = teal / down = red
  - if down is good -> down = teal / up = red
- use soft heat or data bars only when it improves readability

## Density Rules
Avoid crowded pages.
Target:
- 5 to 6 information blocks maximum in a page
- one detail table only
- no excessive text

## Navigation Rules
- first page = INDEX
- each page includes INDEX button
- navigation tooltip text:
  - Press Ctrl + Click to go to [Page Name]

## Typography Rules
- page titles: strong, large, centered
- subtitles: small, muted
- KPI labels: uppercase or short title case
- section titles: short and direct
- table headers: clear, concise

## Visual Intent Rules
Use visuals only when they answer a real question:
- bar / column -> ranking or comparison
- matrix / table -> detail inspection
- cards -> headline KPI
- avoid decorative visuals

## Build Sequence
1. architecture contract
2. index page
3. executive overview
4. remaining analytical pages one by one
5. validation and refinement
'@

    Write-Utf8NoBom -Path $architectureFile -Text $architecture
    Write-Utf8NoBom -Path $designFile       -Text $design

    # ============================================================
    # 3. GIT
    # ============================================================

    git add `
        "scripts/checkpoints/CP13A_Report_Architecture_And_Design_Contract.ps1" `
        "docs/reporting/REPORT_ARCHITECTURE_CONTRACT.md" `
        "docs/reporting/REPORT_DESIGN_SYSTEM.md"

    if ($LASTEXITCODE -ne 0) {
        throw "git add failed."
    }

    $staged = @(git diff --cached --name-only)

    if ($staged.Count -eq 0) {
        throw "No CP13-A files staged."
    }

    git commit -m "checkpoint: approve report architecture and design system"

    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed."
    }

    $commit = (git rev-parse HEAD).Trim()
    $status = @(git status --short)

@"
CP13-A RESULT

REPORT ARCHITECTURE:
APPROVED

DESIGN SYSTEM:
APPROVED

Approved pages:
7

Pages:
1. INDEX
2. Executive Overview
3. Data Quality Overview
4. Coding Quality
5. Service & Payment Patterns
6. Demographic & Provider Mix
7. Quality Issues Monitor

Slicer layout:
TOP HORIZONTAL STRIP

Side icon slicer panel:
REJECTED FOR VERSION 1

Color palette:
APPROVED

Navigation pattern:
APPROVED

Git commit:
$commit

Working tree:
$(if ($status.Count -eq 0) { "CLEAN" } else { $status -join "`r`n" })

Created files:
docs\reporting\REPORT_ARCHITECTURE_CONTRACT.md
docs\reporting\REPORT_DESIGN_SYSTEM.md

NEXT:
CP13-B - Build INDEX page
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-A completed."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP13-A RESULT

STATUS:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
STOP - Review before continuing.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-A failed."
    Write-Host "Output: $out"
    Write-Host ""
}