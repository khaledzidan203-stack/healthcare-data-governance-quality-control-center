$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$relativeModel = "powerbi/HealthcareGovernanceQC.SemanticModel/definition/model.tmdl"

$semanticRoot = Join-Path $root "powerbi\HealthcareGovernanceQC.SemanticModel"
$definition   = Join-Path $semanticRoot "definition"
$tableDir     = Join-Path $definition "tables"

$modelFile   = Join-Path $definition "model.tmdl"
$measureFile = Join-Path $tableDir "_Measures.tmdl"
$relFile     = Join-Path $definition "relationships.tmdl"

$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

Set-Location $root

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Text
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $Path,
        $Text,
        $encoding
    )
}

try {

    # ============================================================
    # 1. PREFLIGHT
    # ============================================================

    if (Get-Process PBIDesktop -ErrorAction SilentlyContinue) {
        throw "Power BI Desktop is still open. Close it first."
    }

    if (-not (Test-Path $modelFile)) {
        throw "model.tmdl not found."
    }

    if (-not (Test-Path $relFile)) {
        throw "relationships.tmdl not found."
    }

    if (-not (Test-Path $tableDir)) {
        throw "Semantic model tables folder not found."
    }

    # ============================================================
    # 2. FULL CLEANUP OF OLD CP12-G1 ATTEMPTS
    # ============================================================

    # Restore model.tmdl exactly from last committed healthy baseline
    git restore --source=HEAD -- $relativeModel

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to restore model.tmdl from Git baseline."
    }

    # Remove any old/stale _Measures file
    if (Test-Path $measureFile) {
        Remove-Item $measureFile -Force
    }

    # Confirm stale ref is gone
    $baselineModel = Get-Content $modelFile -Raw -Encoding UTF8

    if ($baselineModel -match "(?m)^\s*ref table _Measures\s*\r?$") {
        throw "Old _Measures reference still exists after Git restore."
    }

    # ============================================================
    # 3. CREATE CLEAN _Measures.tmdl
    # ============================================================

    $measureLines = @(
        "table _Measures"
        ""
        "`tcolumn Placeholder"
        "`t`tdataType: string"
        "`t`tisHidden"
        "`t`tsummarizeBy: none"
        "`t`tsourceColumn: Placeholder"
        ""
        "`tpartition _Measures = m"
        "`t`tmode: import"
        "`t`tsource ="
        "`t`t`tlet"
        "`t`t`t`tSource = #table(type table [Placeholder = text], {})"
        "`t`t`tin"
        "`t`t`t`tSource"
        ""
    )

    $measureText = $measureLines -join "`r`n"

    Write-Utf8NoBom `
        -Path $measureFile `
        -Text $measureText

    # ============================================================
    # 4. REGISTER _Measures IN model.tmdl
    # ============================================================

    $modelLines = @(
        Get-Content $modelFile -Encoding UTF8
    )

    $lastTableRefIndex = -1

    for ($i = 0; $i -lt $modelLines.Count; $i++) {

        if ($modelLines[$i] -match '^\s*ref table\s+') {
            $lastTableRefIndex = $i
        }
    }

    if ($lastTableRefIndex -lt 0) {
        throw "No existing ref table entries found in model.tmdl."
    }

    $newModelLines = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $modelLines.Count; $i++) {

        $newModelLines.Add($modelLines[$i])

        if ($i -eq $lastTableRefIndex) {
            $newModelLines.Add("ref table _Measures")
        }
    }

    Write-Utf8NoBom `
        -Path $modelFile `
        -Text ($newModelLines -join "`r`n")

    # ============================================================
    # 5. STATIC VALIDATION
    # ============================================================

    $hostText = Get-Content $measureFile -Raw -Encoding UTF8
    $modelText = Get-Content $modelFile -Raw -Encoding UTF8
    $relText = Get-Content $relFile -Raw -Encoding UTF8

    $tableOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^table _Measures\r?$"
        )
    ).Count -eq 1

    $columnOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^\tcolumn Placeholder\r?$"
        )
    ).Count -eq 1

    $hiddenOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^\t\tisHidden\r?$"
        )
    ).Count -eq 1

    $summarizeOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^\t\tsummarizeBy:\s*none\r?$"
        )
    ).Count -eq 1

    $partitionOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^\tpartition _Measures = m\r?$"
        )
    ).Count -eq 1

    $modeOk = (
        [regex]::Matches(
            $hostText,
            "(?m)^\t\tmode:\s*import\r?$"
        )
    ).Count -eq 1

    $zeroRowOk = $hostText.Contains(
        "#table(type table [Placeholder = text], {})"
    )

    $measureRefCount = (
        [regex]::Matches(
            $modelText,
            "(?m)^\s*ref table _Measures\s*\r?$"
        )
    ).Count

    $allTableRefCount = (
        [regex]::Matches(
            $modelText,
            "(?m)^\s*ref table\s+"
        )
    ).Count

    $relationshipCount = (
        [regex]::Matches(
            $relText,
            "(?m)^\s*relationship\s+"
        )
    ).Count

    $measureRelationshipCount = (
        [regex]::Matches(
            $relText,
            "_Measures"
        )
    ).Count

    $measureCount = (
        [regex]::Matches(
            $hostText,
            "(?m)^\tmeasure\s+"
        )
    ).Count

    if (-not $tableOk) {
        throw "_Measures table definition is invalid."
    }

    if (-not $columnOk) {
        throw "Placeholder column definition is invalid."
    }

    if (-not $hiddenOk) {
        throw "Placeholder is not hidden."
    }

    if (-not $summarizeOk) {
        throw "Placeholder summarization is not NONE."
    }

    if (-not $partitionOk) {
        throw "_Measures partition definition is invalid."
    }

    if (-not $modeOk) {
        throw "_Measures storage mode is not IMPORT."
    }

    if (-not $zeroRowOk) {
        throw "Zero-row M source was not found."
    }

    if ($measureRefCount -ne 1) {
        throw "_Measures model reference count is $measureRefCount."
    }

    if ($allTableRefCount -ne 10) {
        throw "Expected 10 semantic table references after adding _Measures. Found: $allTableRefCount"
    }

    if ($relationshipCount -ne 8) {
        throw "Existing relationship count changed. Found: $relationshipCount"
    }

    if ($measureRelationshipCount -ne 0) {
        throw "_Measures has an unexpected relationship."
    }

    if ($measureCount -ne 0) {
        throw "_Measures should contain zero measures at CP12-G1."
    }

    # ============================================================
    # 6. OUTPUT — NO COMMIT YET
    # ============================================================

    $gitStatus = @(git status --short)

@"
CP12-G1 RESULT

MEASURE HOST:
PASS - PENDING POWER BI DESKTOP VALIDATION

Reset from clean Git baseline:
YES

Old CP12-G1 artifacts removed:
YES

Table:
_Measures

Semantic tables after creation:
$allTableRefCount

Business rows:
0

Placeholder column:
PASS

Placeholder hidden:
YES

Placeholder summarization:
NONE

Storage mode:
IMPORT

Zero-row M partition:
PASS

Relationships total:
$relationshipCount

Relationships to _Measures:
$measureRelationshipCount

Measures:
$measureCount

model.tmdl _Measures references:
$measureRefCount

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

NEXT:
Power BI Desktop runtime validation.

DO NOT create measures or visuals yet.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G1 completed."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP12-G1 RESULT

MEASURE HOST:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
Do not open Power BI until this failure is reviewed.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G1 failed."
    Write-Host "Output: $out"
    Write-Host ""
}