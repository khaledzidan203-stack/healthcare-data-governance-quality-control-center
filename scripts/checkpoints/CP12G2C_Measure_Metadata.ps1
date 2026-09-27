$ErrorActionPreference = "Stop"

# ============================================================
# CP12-G2C
# GOVERNED MEASURE PRESENTATION METADATA
# Format Strings + Display Folders
# ============================================================

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

    if (-not (Test-Path $relFile)) {
        throw "relationships.tmdl not found."
    }

    $lines = @(
        Get-Content $measureFile -Encoding UTF8
    )

    # ============================================================
    # 2. EXPECTED GOVERNED METADATA
    # ============================================================

    $metadata = @{

        "Profile Count" = @{
            Format = "#,##0"
            Folder = "01 Core KPIs"
        }

        "Represented Line Items" = @{
            Format = "#,##0"
            Folder = "01 Core KPIs"
        }

        "Represented Service Units" = @{
            Format = "#,##0"
            Folder = "01 Core KPIs"
        }

        "Represented Rounded Medicare Payment" = @{
            Format = "#,##0.00"
            Folder = "01 Core KPIs"
        }

        "Avg Service Units per Represented Line" = @{
            Format = "0.000000"
            Folder = "01 Core KPIs"
        }

        "Avg Rounded Payment per Represented Line" = @{
            Format = "0.000000"
            Folder = "01 Core KPIs"
        }

        "Blank ICD Profiles" = @{
            Format = "#,##0"
            Folder = "02 Blank ICD Quality"
        }

        "Blank ICD Represented Lines" = @{
            Format = "#,##0"
            Folder = "02 Blank ICD Quality"
        }

        "Blank ICD Line Rate" = @{
            Format = "0.000000%"
            Folder = "02 Blank ICD Quality"
        }

        "Zero-Service Profiles" = @{
            Format = "#,##0"
            Folder = "03 Zero-Service Quality"
        }

        "Zero-Service Represented Lines" = @{
            Format = "#,##0"
            Folder = "03 Zero-Service Quality"
        }

        "Zero-Service Line Rate" = @{
            Format = "0.000000%"
            Folder = "03 Zero-Service Quality"
        }
    }

    # ============================================================
    # 3. ENSURE CLEAN STARTING STATE
    # ============================================================

    $measureDeclarations = @(
        $lines | Where-Object {
            $_ -match "^\tmeasure\s+"
        }
    )

    if ($measureDeclarations.Count -ne 12) {
        throw "Expected 12 measure declarations. Found: $($measureDeclarations.Count)"
    }

    $existingFormatCount = @(
        $lines | Where-Object {
            $_ -match "^\t\tformatString:"
        }
    ).Count

    $existingFolderCount = @(
        $lines | Where-Object {
            $_ -match "^\t\tdisplayFolder:"
        }
    ).Count

    if ($existingFormatCount -ne 0) {
        throw "Existing measure formatString metadata found. Count: $existingFormatCount"
    }

    if ($existingFolderCount -ne 0) {
        throw "Existing displayFolder metadata found. Count: $existingFolderCount"
    }

    # ============================================================
    # 4. INSERT FORMAT + DISPLAY FOLDER
    # ============================================================

    $newLines = New-Object System.Collections.Generic.List[string]

    $matchedNames = @()

    foreach ($line in $lines) {

        $newLines.Add($line)

        if (
            $line -match "^\tmeasure\s+'([^']+)'\s*="
        ) {

            $measureName = $Matches[1]

            if (-not $metadata.ContainsKey($measureName)) {
                throw "Unexpected governed measure: $measureName"
            }

            $format = $metadata[$measureName].Format
            $folder = $metadata[$measureName].Folder

            $newLines.Add(
                "`t`tformatString: $format"
            )

            $newLines.Add(
                "`t`tdisplayFolder: `"$folder`""
            )

            $matchedNames += $measureName
        }
    }

    # ============================================================
    # 5. VALIDATE ALL 12 WERE MATCHED
    # ============================================================

    if ($matchedNames.Count -ne 12) {
        throw "Only $($matchedNames.Count) measures were updated."
    }

    $missingNames = @()

    foreach ($name in $metadata.Keys) {

        if ($matchedNames -notcontains $name) {
            $missingNames += $name
        }
    }

    if ($missingNames.Count -gt 0) {
        throw "Missing measures: $($missingNames -join ', ')"
    }

    # ============================================================
    # 6. WRITE TMDL
    # ============================================================

    Write-Utf8NoBom `
        -Path $measureFile `
        -Text ($newLines -join "`r`n")

    # ============================================================
    # 7. POST-WRITE STATIC VALIDATION
    # ============================================================

    $check = @(
        Get-Content $measureFile -Encoding UTF8
    )

    $finalMeasureCount = @(
        $check | Where-Object {
            $_ -match "^\tmeasure\s+"
        }
    ).Count

    $finalFormatCount = @(
        $check | Where-Object {
            $_ -match "^\t\tformatString:"
        }
    ).Count

    $finalFolderCount = @(
        $check | Where-Object {
            $_ -match "^\t\tdisplayFolder:"
        }
    ).Count

    if ($finalMeasureCount -ne 12) {
        throw "Measure count changed unexpectedly."
    }

    if ($finalFormatCount -ne 12) {
        throw "Expected 12 format strings. Found: $finalFormatCount"
    }

    if ($finalFolderCount -ne 12) {
        throw "Expected 12 display folders. Found: $finalFolderCount"
    }

    # ============================================================
    # 8. CONFIRM DAX EXPRESSIONS STILL PRESENT
    # ============================================================

    $text = Get-Content $measureFile -Raw -Encoding UTF8

    $requiredDax = @(
        "COUNTROWS ( FactCarrierProfile )",
        "SUM ( FactCarrierProfile[LineItemCount] )",
        "SUM ( FactCarrierProfile[RepresentedServiceUnits] )",
        "SUM ( FactCarrierProfile[RepresentedRoundedMedicarePayment] )",
        "FactCarrierProfile[IsBlankICD] = TRUE ()",
        "FactCarrierProfile[IsZeroServiceCount] = TRUE ()"
    )

    $missingDax = @()

    foreach ($expression in $requiredDax) {

        if (-not $text.Contains($expression)) {
            $missingDax += $expression
        }
    }

    if ($missingDax.Count -gt 0) {
        throw "Governed DAX dependency changed or missing."
    }

    # ============================================================
    # 9. RELATIONSHIP SAFETY
    # ============================================================

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

    # ============================================================
    # 10. GIT STATUS — NO COMMIT YET
    # ============================================================

    $gitStatus = @(
        git status --short
    )

@"
CP12-G2C RESULT

MEASURE METADATA:
PASS - PENDING POWER BI DESKTOP VALIDATION

Governed measures:
$finalMeasureCount

Format strings:
$finalFormatCount / 12

Display folders:
$finalFolderCount / 12

Folder structure:
01 Core KPIs
02 Blank ICD Quality
03 Zero-Service Quality

Payment currency symbol added:
NO

Rates formatted as percentage:
YES

DAX expressions modified:
NO

Relationships:
$relationshipCount

Relationships to _Measures:
$measureRelationships

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

NEXT:
Open HealthcareGovernanceQC.pbip in Power BI Desktop.

If it opens without error:
Save and close.

DO NOT create visuals yet.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G2C completed."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP12-G2C RESULT

MEASURE METADATA:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
Do not open Power BI until reviewed.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G2C failed."
    Write-Host "Output: $out"
    Write-Host ""
}