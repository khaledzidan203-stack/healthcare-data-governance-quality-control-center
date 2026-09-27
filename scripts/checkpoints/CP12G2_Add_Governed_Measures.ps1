$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$measureFile = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.SemanticModel\definition\tables\_Measures.tmdl"

$relFile = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.SemanticModel\definition\relationships.tmdl"

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
        throw "Power BI Desktop is still open."
    }

    if (-not (Test-Path $measureFile)) {
        throw "_Measures.tmdl not found."
    }

    $original = Get-Content $measureFile -Raw -Encoding UTF8

    # Must still be clean CP12-G1 state
    $existingMeasures = (
        [regex]::Matches(
            $original,
            "(?m)^\tmeasure\s+"
        )
    ).Count

    if ($existingMeasures -ne 0) {
        throw "Expected zero existing measures. Found: $existingMeasures"
    }

    $partitionAnchor = "`tpartition _Measures = m"

    if (-not $original.Contains($partitionAnchor)) {
        throw "_Measures partition anchor not found."
    }

    # ============================================================
    # 2. GOVERNED 12 MEASURES
    # ============================================================

    $measureBlock = @(
        "`tmeasure 'Profile Count' = COUNTROWS ( FactCarrierProfile )"
        ""
        "`tmeasure 'Represented Line Items' = SUM ( FactCarrierProfile[LineItemCount] )"
        ""
        "`tmeasure 'Represented Service Units' = SUM ( FactCarrierProfile[RepresentedServiceUnits] )"
        ""
        "`tmeasure 'Represented Rounded Medicare Payment' = SUM ( FactCarrierProfile[RepresentedRoundedMedicarePayment] )"
        ""
        "`tmeasure 'Avg Service Units per Represented Line' = DIVIDE ( [Represented Service Units], [Represented Line Items] )"
        ""
        "`tmeasure 'Avg Rounded Payment per Represented Line' = DIVIDE ( [Represented Rounded Medicare Payment], [Represented Line Items] )"
        ""
        "`tmeasure 'Blank ICD Profiles' = CALCULATE ( [Profile Count], FactCarrierProfile[IsBlankICD] = TRUE () )"
        ""
        "`tmeasure 'Blank ICD Represented Lines' = CALCULATE ( [Represented Line Items], FactCarrierProfile[IsBlankICD] = TRUE () )"
        ""
        "`tmeasure 'Blank ICD Line Rate' = DIVIDE ( [Blank ICD Represented Lines], [Represented Line Items] )"
        ""
        "`tmeasure 'Zero-Service Profiles' = CALCULATE ( [Profile Count], FactCarrierProfile[IsZeroServiceCount] = TRUE () )"
        ""
        "`tmeasure 'Zero-Service Represented Lines' = CALCULATE ( [Represented Line Items], FactCarrierProfile[IsZeroServiceCount] = TRUE () )"
        ""
        "`tmeasure 'Zero-Service Line Rate' = DIVIDE ( [Zero-Service Represented Lines], [Represented Line Items] )"
        ""
    ) -join "`r`n"

    $newText = $original.Replace(
        $partitionAnchor,
        $measureBlock + "`r`n" + $partitionAnchor
    )

    Write-Utf8NoBom `
        -Path $measureFile `
        -Text $newText

    # ============================================================
    # 3. STATIC VALIDATION
    # ============================================================

    $check = Get-Content $measureFile -Raw -Encoding UTF8

    $expectedNames = @(
        "Profile Count",
        "Represented Line Items",
        "Represented Service Units",
        "Represented Rounded Medicare Payment",
        "Avg Service Units per Represented Line",
        "Avg Rounded Payment per Represented Line",
        "Blank ICD Profiles",
        "Blank ICD Represented Lines",
        "Blank ICD Line Rate",
        "Zero-Service Profiles",
        "Zero-Service Represented Lines",
        "Zero-Service Line Rate"
    )

    $measureCount = (
        [regex]::Matches(
            $check,
            "(?m)^\tmeasure\s+"
        )
    ).Count

    if ($measureCount -ne 12) {
        throw "Expected 12 measures. Found: $measureCount"
    }

    $missing = @()

    foreach ($name in $expectedNames) {

        $escaped = [regex]::Escape(
            "`tmeasure '$name' ="
        )

        if ($check -notmatch $escaped) {
            $missing += $name
        }
    }

    if ($missing.Count -gt 0) {
        throw "Missing measures: $($missing -join ', ')"
    }

    # Validate required fact dependencies
    $requiredDependencies = @(
        "FactCarrierProfile[LineItemCount]",
        "FactCarrierProfile[RepresentedServiceUnits]",
        "FactCarrierProfile[RepresentedRoundedMedicarePayment]",
        "FactCarrierProfile[IsBlankICD]",
        "FactCarrierProfile[IsZeroServiceCount]"
    )

    $missingDependencies = @()

    foreach ($dependency in $requiredDependencies) {

        if (-not $check.Contains($dependency)) {
            $missingDependencies += $dependency
        }
    }

    if ($missingDependencies.Count -gt 0) {
        throw "Missing governed dependencies: $($missingDependencies -join ', ')"
    }

    # Ensure _Measures remains disconnected
    $relText = Get-Content $relFile -Raw -Encoding UTF8

    $relationshipCount = (
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

    if ($relationshipCount -ne 8) {
        throw "Relationship count changed. Found: $relationshipCount"
    }

    if ($measureRelationships -ne 0) {
        throw "_Measures must remain disconnected."
    }

    $gitStatus = @(git status --short)

@"
CP12-G2A RESULT

GOVERNED DAX INSERTION:
PASS - PENDING POWER BI DESKTOP VALIDATION

Measure host:
_Measures

Measures expected:
12

Measures found:
$measureCount

Missing governed measures:
$(if ($missing.Count -eq 0) { "NONE" } else { $missing -join ", " })

Missing governed dependencies:
$(if ($missingDependencies.Count -eq 0) { "NONE" } else { $missingDependencies -join ", " })

Relationships total:
$relationshipCount

Relationships to _Measures:
$measureRelationships

Format strings added:
NO

Display folders added:
NO

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

NEXT:
Power BI Desktop runtime validation.

DO NOT create or edit measures manually.
"@ | Set-Content $out -Encoding UTF8

    Write-Host "CP12-G2A completed."
    Write-Host "Output: $out"
}
catch {

@"
CP12-G2A RESULT

STATUS:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
Do not open Power BI until reviewed.
"@ | Set-Content $out -Encoding UTF8

    Write-Host "CP12-G2A failed."
    Write-Host "Output: $out"
}