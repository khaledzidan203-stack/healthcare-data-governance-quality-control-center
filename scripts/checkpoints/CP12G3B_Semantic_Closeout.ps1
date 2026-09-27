$ErrorActionPreference = "Stop"

# ============================================================
# CP12-G3B
# FINAL SEMANTIC MODEL CLOSEOUT
# ============================================================

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$out  = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$definition = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.SemanticModel\definition"

$tablesDir = Join-Path $definition "tables"

$modelFile = Join-Path $definition "model.tmdl"
$relFile   = Join-Path $definition "relationships.tmdl"
$measureFile = Join-Path $tablesDir "_Measures.tmdl"

$g3aScript = Join-Path $root `
    "scripts\checkpoints\CP12G3_Final_Semantic_Validation.ps1"

$g3bScript = Join-Path $root `
    "scripts\checkpoints\CP12G3B_Semantic_Closeout.ps1"

$docDir = Join-Path $root "docs\validation"

$docFile = Join-Path $docDir `
    "CP12_G3_FINAL_SEMANTIC_MODEL_CLOSEOUT.md"

Set-Location $root

try {

    # ============================================================
    # 1. PREFLIGHT
    # ============================================================

    if (Get-Process PBIDesktop -ErrorAction SilentlyContinue) {
        throw "Power BI Desktop is still open."
    }

    $requiredFiles = @(
        $modelFile,
        $relFile,
        $measureFile,
        $g3aScript,
        $g3bScript
    )

    foreach ($file in $requiredFiles) {

        if (-not (Test-Path $file)) {
            throw "Required file missing: $file"
        }
    }

    # ============================================================
    # 2. STATIC FINAL VALIDATION
    # ============================================================

    $tableFiles = @(
        Get-ChildItem `
            -Path $tablesDir `
            -Filter "*.tmdl" `
            -File
    )

    if ($tableFiles.Count -ne 10) {
        throw "Expected 10 semantic tables. Found: $($tableFiles.Count)"
    }

    $modelText = Get-Content $modelFile -Raw -Encoding UTF8
    $relText   = Get-Content $relFile -Raw -Encoding UTF8
    $measureText = Get-Content $measureFile -Raw -Encoding UTF8

    $tableRefs = (
        [regex]::Matches(
            $modelText,
            "(?m)^\s*ref table\s+"
        )
    ).Count

    $relationships = (
        [regex]::Matches(
            $relText,
            "(?m)^\s*relationship\s+"
        )
    ).Count

    $measureRelationships = (
        [regex]::Matches(
            $relText,
            "_Measures"
        )
    ).Count

    $measures = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*measure\s+"
        )
    ).Count

    $formats = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*formatString:"
        )
    ).Count

    $folders = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*displayFolder:"
        )
    ).Count

    if ($tableRefs -ne 10) {
        throw "Expected 10 model table references. Found: $tableRefs"
    }

    if ($relationships -ne 8) {
        throw "Expected 8 relationships. Found: $relationships"
    }

    if ($measureRelationships -ne 0) {
        throw "_Measures must remain disconnected."
    }

    if ($measures -ne 12) {
        throw "Expected 12 governed measures. Found: $measures"
    }

    if ($formats -ne 12) {
        throw "Expected 12 format strings. Found: $formats"
    }

    if ($folders -ne 12) {
        throw "Expected 12 display folders. Found: $folders"
    }

    if (-not $modelText.Contains("__PBI_TimeIntelligenceEnabled = 0")) {
        throw "Time intelligence is not disabled."
    }

    # ============================================================
    # 3. REPORT MUST STILL BE UNBUILT
    # ============================================================

    $reportRoot = Join-Path $root `
        "powerbi\HealthcareGovernanceQC.Report"

    $pageFiles = @(
        Get-ChildItem `
            -Path $reportRoot `
            -Filter "page.json" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue
    )

    $visualFiles = @(
        Get-ChildItem `
            -Path $reportRoot `
            -Filter "visual.json" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue
    )

    if ($visualFiles.Count -ne 0) {
        throw "Report visuals already exist. Dashboard design has not been approved yet."
    }

    # ============================================================
    # 4. CHECK FOR UNEXPECTED GIT CHANGES
    # ============================================================

    $allowedPaths = @(
        "scripts/checkpoints/CP12G3_Final_Semantic_Validation.ps1",
        "scripts/checkpoints/CP12G3B_Semantic_Closeout.ps1",
        "docs/validation/CP12_G3_FINAL_SEMANTIC_MODEL_CLOSEOUT.md"
    )

    $gitBefore = @(
        git status --short
    )

    $unexpected = @()

    foreach ($line in $gitBefore) {

        $path = $line.Substring(3).Trim()

        if ($allowedPaths -notcontains $path) {
            $unexpected += $line
        }
    }

    if ($unexpected.Count -gt 0) {

        throw (
            "Unexpected Git changes detected: " +
            ($unexpected -join " | ")
        )
    }

    # ============================================================
    # 5. CREATE FINAL CLOSEOUT DOCUMENT
    # ============================================================

    New-Item `
        -ItemType Directory `
        -Path $docDir `
        -Force |
        Out-Null

    $doc = @'
# CP12-G3 — Final Semantic Model Closeout

## Status

**COMPLETED**

## Semantic Model

- Semantic tables: **10 / 10**
- Model table references: **10 / 10**
- Relationships: **8**
- Bidirectional relationships: **0**
- Relationships to `_Measures`: **0**
- Time Intelligence: **Disabled**

## Governed Measure Host

Dedicated table:

`_Measures`

Validated state:

- Business rows: **0**
- Relationships: **0**
- Hidden placeholder: **Yes**
- Zero-row M partition: **Yes**
- Governed measures: **12 / 12**
- Format strings: **12 / 12**
- Display folders: **12 / 12**

Display folders:

1. `01 Core KPIs`
2. `02 Blank ICD Quality`
3. `03 Zero-Service Quality`

## Runtime KPI Validation

The governed DAX implementation was executed against the live Power BI Desktop model.

Result:

- Measures tested: **12**
- Passed: **12**
- Failed: **0**
- KPI differences from governed CP8 baseline: **0**

Detailed runtime evidence:

`docs/validation/CP12_G2B_RUNTIME_KPI_RECONCILIATION.md`

## Fact Governance

Unsafe implicit aggregation remains disabled for:

- `ProfileKey`
- `ServiceCount`
- `MedicarePaymentAmount`

Approved additive columns remain:

- `LineItemCount` → SUM
- `RepresentedServiceUnits` → SUM
- `RepresentedRoundedMedicarePayment` → SUM

Technical keys remain hidden.

## Report State at Semantic Closeout

- Existing report pages: **1**
- Existing report visuals: **0**
- Dashboard build: **NOT STARTED**

No report page, visual, layout, navigation system, or dashboard design was created during CP12.

## Design Governance Boundary

The Power BI report will not be built until the page architecture is jointly approved.

Before implementation, agree on:

- report purpose;
- page inventory;
- role of each page;
- KPI placement;
- chart types;
- dimensions;
- slicers;
- drill/filter behavior;
- navigation;
- canvas/layout;
- design system;
- colors;
- typography;
- information hierarchy;
- user journey.

Only after approval will report construction begin.

## CP12 Final State

**Semantic Model / Power BI Foundation: COMPLETED**

Next phase:

**Report Architecture & Design Planning**
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $docFile,
        $doc,
        $encoding
    )

    # ============================================================
    # 6. COMMIT CLOSEOUT EVIDENCE
    # ============================================================

    git add `
        "scripts/checkpoints/CP12G3_Final_Semantic_Validation.ps1" `
        "scripts/checkpoints/CP12G3B_Semantic_Closeout.ps1" `
        "docs/validation/CP12_G3_FINAL_SEMANTIC_MODEL_CLOSEOUT.md"

    if ($LASTEXITCODE -ne 0) {
        throw "git add failed."
    }

    $staged = @(
        git diff --cached --name-only
    )

    if ($staged.Count -eq 0) {
        throw "No CP12-G3 closeout files staged."
    }

    git commit -m "checkpoint: close Power BI semantic model foundation"

    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed."
    }

    $commit = (git rev-parse HEAD).Trim()

    $status = @(
        git status --short
    )

    # ============================================================
    # 7. OUTPUT
    # ============================================================

@"
CP12-G3B FINAL RESULT

SEMANTIC MODEL CLOSEOUT:
PASS

Semantic tables:
$tableRefs / 10

Relationships:
$relationships

Relationships to _Measures:
$measureRelationships

Governed measures:
$measures / 12

Format strings:
$formats / 12

Display folders:
$folders / 12

Time intelligence:
DISABLED

Report pages:
$($pageFiles.Count)

Report visuals:
$($visualFiles.Count)

Dashboard build:
NOT STARTED

Closeout document:
docs\validation\CP12_G3_FINAL_SEMANTIC_MODEL_CLOSEOUT.md

Git commit:
$commit

Working tree:
$(if ($status.Count -eq 0) { "CLEAN" } else { $status -join "`r`n" })

CP12:
COMPLETED

NEXT:
Joint Report Architecture & Design Planning

NO REPORT BUILD BEFORE DESIGN APPROVAL.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12 semantic model closeout: PASS"
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP12-G3B FINAL RESULT

SEMANTIC MODEL CLOSEOUT:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
STOP - Review before continuing.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G3B failed."
    Write-Host "Output: $out"
    Write-Host ""
}