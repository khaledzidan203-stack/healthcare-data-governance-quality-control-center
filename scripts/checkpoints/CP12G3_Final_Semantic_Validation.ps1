$ErrorActionPreference = "Stop"

# ============================================================
# CP12-G3A
# FINAL POWER BI SEMANTIC MODEL VALIDATION
# READ ONLY
# ============================================================

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$semanticRoot = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.SemanticModel"

$definition = Join-Path $semanticRoot "definition"

$modelFile = Join-Path $definition "model.tmdl"

$relationshipFile = Join-Path $definition "relationships.tmdl"

$tablesDir = Join-Path $definition "tables"

$factFile = Join-Path $tablesDir "FactCarrierProfile.tmdl"

$measureFile = Join-Path $tablesDir "_Measures.tmdl"

$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$queryFile = "D:\analysis_projects\output\CP12G3_Runtime_Query.dax"

$csvFile = "D:\analysis_projects\output\CP12G3_Runtime_Result.csv"

$pbipName = "HealthcareGovernanceQC.pbip"

Set-Location $root


# ============================================================
# HELPERS
# ============================================================

function Find-Dscmd {

    $command = Get-Command "dscmd.exe" -ErrorAction SilentlyContinue

    if ($command) {
        return $command.Source
    }

    $candidates = @(
        "$env:ProgramFiles\DAX Studio\dscmd.exe",
        "${env:ProgramFiles(x86)}\DAX Studio\dscmd.exe",
        "$env:LOCALAPPDATA\Programs\DAX Studio\dscmd.exe",
        "$env:LOCALAPPDATA\DAX Studio\dscmd.exe"
    )

    foreach ($candidate in $candidates) {

        if (
            -not [string]::IsNullOrWhiteSpace($candidate) -and
            (Test-Path $candidate)
        ) {
            return $candidate
        }
    }

    return $null
}


function Get-ColumnBlock {

    param(
        [string]$Text,
        [string]$ColumnName
    )

    $escaped = [regex]::Escape($ColumnName)

    $pattern =
        "(?ms)^\tcolumn\s+$escaped\r?\n" +
        "(.*?)(?=^\t(?:column|measure|partition)\s|\z)"

    $match = [regex]::Match(
        $Text,
        $pattern
    )

    if (-not $match.Success) {
        throw "Column block not found: $ColumnName"
    }

    return $match.Groups[1].Value
}


function Parse-Number {

    param(
        [string]$Text
    )

    [double]$value = 0

    $style =
        [System.Globalization.NumberStyles]::Float `
        -bor `
        [System.Globalization.NumberStyles]::AllowThousands

    $ok = [double]::TryParse(
        $Text.Trim(),
        $style,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref]$value
    )

    if (-not $ok) {

        $ok = [double]::TryParse(
            $Text.Trim(),
            $style,
            [System.Globalization.CultureInfo]::CurrentCulture,
            [ref]$value
        )
    }

    if (-not $ok) {
        throw "Cannot parse runtime numeric value: $Text"
    }

    return $value
}


# ============================================================
# MAIN
# ============================================================

try {

    # ----------------------------------------------------------
    # 1. PREFLIGHT
    # ----------------------------------------------------------

    if (-not (Get-Process PBIDesktop -ErrorAction SilentlyContinue)) {
        throw "Power BI Desktop is not open."
    }

    $requiredFiles = @(
        $modelFile,
        $relationshipFile,
        $factFile,
        $measureFile
    )

    foreach ($file in $requiredFiles) {

        if (-not (Test-Path $file)) {
            throw "Required semantic file missing: $file"
        }
    }


    # ----------------------------------------------------------
    # 2. TABLE INVENTORY
    # ----------------------------------------------------------

    $tableFiles = @(
        Get-ChildItem `
            -Path $tablesDir `
            -Filter "*.tmdl" `
            -File
    )

    if ($tableFiles.Count -ne 10) {
        throw "Expected 10 semantic table files. Found: $($tableFiles.Count)"
    }

    $expectedTables = @(
        "FactCarrierProfile",
        "DimSex",
        "DimAgeCategory",
        "DimICD9",
        "DimHCPCS",
        "DimBETOS",
        "DimProviderType",
        "DimServiceType",
        "DimPlaceOfService",
        "_Measures"
    )

    $missingTables = @()

    foreach ($table in $expectedTables) {

        $file = Join-Path $tablesDir "$table.tmdl"

        if (-not (Test-Path $file)) {
            $missingTables += $table
        }
    }

    if ($missingTables.Count -gt 0) {
        throw "Missing semantic tables: $($missingTables -join ', ')"
    }


    # ----------------------------------------------------------
    # 3. MODEL REFERENCES
    # ----------------------------------------------------------

    $modelText = Get-Content $modelFile -Raw -Encoding UTF8

    $tableReferenceCount = (
        [regex]::Matches(
            $modelText,
            "(?m)^\s*ref table\s+"
        )
    ).Count

    if ($tableReferenceCount -ne 10) {
        throw "Expected 10 model table references. Found: $tableReferenceCount"
    }

    foreach ($table in $expectedTables) {

        $pattern =
            "(?m)^\s*ref table\s+'?" +
            [regex]::Escape($table) +
            "'?\s*\r?$"

        if ($modelText -notmatch $pattern) {
            throw "Missing model table reference: $table"
        }
    }


    # ----------------------------------------------------------
    # 4. TIME INTELLIGENCE
    # ----------------------------------------------------------

    $timeIntelligenceDisabled =
        $modelText.Contains("__PBI_TimeIntelligenceEnabled = 0")

    if (-not $timeIntelligenceDisabled) {
        throw "Time intelligence is not explicitly disabled."
    }


    # ----------------------------------------------------------
    # 5. RELATIONSHIP VALIDATION
    # ----------------------------------------------------------

    $relationshipText =
        Get-Content $relationshipFile -Raw -Encoding UTF8

    $relationshipCount = (
        [regex]::Matches(
            $relationshipText,
            "(?m)^\s*relationship\s+"
        )
    ).Count

    if ($relationshipCount -ne 8) {
        throw "Expected 8 relationships. Found: $relationshipCount"
    }

    $measureRelationships = (
        [regex]::Matches(
            $relationshipText,
            "_Measures"
        )
    ).Count

    if ($measureRelationships -ne 0) {
        throw "_Measures must have zero relationships."
    }

    $bidirectionalDetected =
        $relationshipText -match "(?i)crossFilteringBehavior:\s*both"

    if ($bidirectionalDetected) {
        throw "Bidirectional relationship detected."
    }


    # ----------------------------------------------------------
    # 6. FACT COLUMN GOVERNANCE
    # ----------------------------------------------------------

    $factText =
        Get-Content $factFile -Raw -Encoding UTF8

    $nonAdditiveColumns = @(
        "ProfileKey",
        "ServiceCount",
        "MedicarePaymentAmount"
    )

    foreach ($column in $nonAdditiveColumns) {

        $block = Get-ColumnBlock `
            -Text $factText `
            -ColumnName $column

        if ($block -notmatch "(?m)^\s*summarizeBy:\s*none\s*$") {
            throw "$column must use summarizeBy: none."
        }

        if ($block -notmatch "(?m)^\s*isHidden\s*$") {
            throw "$column must remain hidden."
        }
    }

    $additiveColumns = @(
        "LineItemCount",
        "RepresentedServiceUnits",
        "RepresentedRoundedMedicarePayment"
    )

    foreach ($column in $additiveColumns) {

        $block = Get-ColumnBlock `
            -Text $factText `
            -ColumnName $column

        if ($block -notmatch "(?m)^\s*summarizeBy:\s*sum\s*$") {
            throw "$column must use summarizeBy: sum."
        }
    }


    # ----------------------------------------------------------
    # 7. TECHNICAL KEY VISIBILITY
    # ----------------------------------------------------------

    $keyChecks = @{

        "DimSex.tmdl" =
            @("SexKey")

        "DimAgeCategory.tmdl" =
            @("AgeCategoryKey", "SortOrder")

        "DimICD9.tmdl" =
            @("ICD9Key")

        "DimHCPCS.tmdl" =
            @("HCPCSKey")

        "DimBETOS.tmdl" =
            @("BETOSKey")

        "DimProviderType.tmdl" =
            @("ProviderTypeKey")

        "DimServiceType.tmdl" =
            @("ServiceTypeKey")

        "DimPlaceOfService.tmdl" =
            @("PlaceOfServiceKey")
    }

    foreach ($fileName in $keyChecks.Keys) {

        $path = Join-Path $tablesDir $fileName

        $text = Get-Content $path -Raw -Encoding UTF8

        foreach ($column in $keyChecks[$fileName]) {

            $block = Get-ColumnBlock `
                -Text $text `
                -ColumnName $column

            if ($block -notmatch "(?m)^\s*isHidden\s*$") {
                throw "$fileName -> $column must remain hidden."
            }

            if ($block -notmatch "(?m)^\s*summarizeBy:\s*none\s*$") {
                throw "$fileName -> $column must use summarizeBy: none."
            }
        }
    }


    # ----------------------------------------------------------
    # 8. MEASURE HOST VALIDATION
    # ----------------------------------------------------------

    $measureText =
        Get-Content $measureFile -Raw -Encoding UTF8

    $measureCount = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*measure\s+"
        )
    ).Count

    $formatCount = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*formatString:"
        )
    ).Count

    $folderCount = (
        [regex]::Matches(
            $measureText,
            "(?m)^\s*displayFolder:"
        )
    ).Count

    if ($measureCount -ne 12) {
        throw "Expected 12 governed measures. Found: $measureCount"
    }

    if ($formatCount -ne 12) {
        throw "Expected 12 measure format strings. Found: $formatCount"
    }

    if ($folderCount -ne 12) {
        throw "Expected 12 measure display folders. Found: $folderCount"
    }

    $placeholderBlock = Get-ColumnBlock `
        -Text $measureText `
        -ColumnName "Placeholder"

    if ($placeholderBlock -notmatch "(?m)^\s*isHidden\s*$") {
        throw "_Measures Placeholder must be hidden."
    }

    if ($placeholderBlock -notmatch "(?m)^\s*summarizeBy:\s*none\s*$") {
        throw "_Measures Placeholder summarization must be none."
    }

    if (
        -not $measureText.Contains(
            "#table(type table [Placeholder = text], {})"
        )
    ) {
        throw "_Measures zero-row M partition not found."
    }


    # ----------------------------------------------------------
    # 9. DISPLAY FOLDER VALIDATION
    # ----------------------------------------------------------

    $folderCore = (
        [regex]::Matches(
            $measureText,
            'displayFolder:\s*"01 Core KPIs"'
        )
    ).Count

    $folderBlank = (
        [regex]::Matches(
            $measureText,
            'displayFolder:\s*"02 Blank ICD Quality"'
        )
    ).Count

    $folderZero = (
        [regex]::Matches(
            $measureText,
            'displayFolder:\s*"03 Zero-Service Quality"'
        )
    ).Count

    if ($folderCore -ne 6) {
        throw "01 Core KPIs must contain 6 measures."
    }

    if ($folderBlank -ne 3) {
        throw "02 Blank ICD Quality must contain 3 measures."
    }

    if ($folderZero -ne 3) {
        throw "03 Zero-Service Quality must contain 3 measures."
    }


    # ----------------------------------------------------------
    # 10. FIND DAX STUDIO CLI
    # ----------------------------------------------------------

    $dscmd = Find-Dscmd

    if ([string]::IsNullOrWhiteSpace($dscmd)) {
        throw "dscmd.exe not found."
    }


    # ----------------------------------------------------------
    # 11. LIVE RUNTIME DAX QUERY
    # ----------------------------------------------------------

    $query = @'
EVALUATE
ROW (
    "Profile Count", [Profile Count],
    "Represented Line Items", [Represented Line Items],
    "Represented Service Units", [Represented Service Units],
    "Represented Rounded Medicare Payment", [Represented Rounded Medicare Payment],
    "Avg Service Units per Represented Line", [Avg Service Units per Represented Line],
    "Avg Rounded Payment per Represented Line", [Avg Rounded Payment per Represented Line],
    "Blank ICD Profiles", [Blank ICD Profiles],
    "Blank ICD Represented Lines", [Blank ICD Represented Lines],
    "Blank ICD Line Rate", [Blank ICD Line Rate],
    "Zero-Service Profiles", [Zero-Service Profiles],
    "Zero-Service Represented Lines", [Zero-Service Represented Lines],
    "Zero-Service Line Rate", [Zero-Service Line Rate]
)
'@

    $utf8 =
        New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $queryFile,
        $query,
        $utf8
    )

    if (Test-Path $csvFile) {
        Remove-Item $csvFile -Force
    }

    $cliOutput = @(
        & $dscmd `
            CSV `
            $csvFile `
            --server $pbipName `
            --file $queryFile `
            2>&1
    )

    if ($LASTEXITCODE -ne 0) {

        throw (
            "Runtime DAX query failed. " +
            ($cliOutput -join " | ")
        )
    }

    if (-not (Test-Path $csvFile)) {
        throw "Runtime KPI CSV was not created."
    }

    $runtimeRows = @(
        Import-Csv $csvFile
    )

    if ($runtimeRows.Count -ne 1) {
        throw "Expected one runtime KPI row. Found: $($runtimeRows.Count)"
    }

    $row = $runtimeRows[0]

    $runtime = @{}

    foreach ($property in $row.PSObject.Properties) {

        $name = $property.Name.Trim()

        if (
            $name.StartsWith("[") -and
            $name.EndsWith("]")
        ) {

            $name = $name.Substring(
                1,
                $name.Length - 2
            )
        }

        $runtime[$name] = $property.Value
    }


    # ----------------------------------------------------------
    # 12. EXACT KPI RECONCILIATION
    # ----------------------------------------------------------

    [double]$lines   = 70052393
    [double]$units   = 105487211
    [double]$payment = 3842966475.00

    $tests = @(

        @{
            Name = "Profile Count"
            Expected = 2801660
            Tolerance = 0
        },

        @{
            Name = "Represented Line Items"
            Expected = $lines
            Tolerance = 0
        },

        @{
            Name = "Represented Service Units"
            Expected = $units
            Tolerance = 0
        },

        @{
            Name = "Represented Rounded Medicare Payment"
            Expected = $payment
            Tolerance = 0.01
        },

        @{
            Name = "Avg Service Units per Represented Line"
            Expected = ($units / $lines)
            Tolerance = 0.000000001
        },

        @{
            Name = "Avg Rounded Payment per Represented Line"
            Expected = ($payment / $lines)
            Tolerance = 0.000000001
        },

        @{
            Name = "Blank ICD Profiles"
            Expected = 502
            Tolerance = 0
        },

        @{
            Name = "Blank ICD Represented Lines"
            Expected = 13506
            Tolerance = 0
        },

        @{
            Name = "Blank ICD Line Rate"
            Expected = (13506 / $lines)
            Tolerance = 0.000000000001
        },

        @{
            Name = "Zero-Service Profiles"
            Expected = 22
            Tolerance = 0
        },

        @{
            Name = "Zero-Service Represented Lines"
            Expected = 59
            Tolerance = 0
        },

        @{
            Name = "Zero-Service Line Rate"
            Expected = (59 / $lines)
            Tolerance = 0.000000000001
        }
    )

    $runtimePass = 0
    $runtimeFail = 0
    $runtimeLines = @()

    foreach ($test in $tests) {

        if (-not $runtime.ContainsKey($test.Name)) {
            throw "Runtime KPI missing: $($test.Name)"
        }

        $actual = Parse-Number `
            ([string]$runtime[$test.Name])

        $difference = [math]::Abs(
            $actual - [double]$test.Expected
        )

        if (
            $difference -le
            [double]$test.Tolerance
        ) {

            $status = "PASS"
            $runtimePass++
        }
        else {

            $status = "FAIL"
            $runtimeFail++
        }

        $runtimeLines += (
            "{0} | {1} | Diff={2}" -f `
            $status,
            $test.Name,
            $difference.ToString(
                "G17",
                [System.Globalization.CultureInfo]::InvariantCulture
            )
        )
    }

    if ($runtimeFail -ne 0) {
        throw "$runtimeFail runtime KPI reconciliation test(s) failed."
    }


    # ----------------------------------------------------------
    # 13. REPORT STATE
    # No dashboard build should exist yet
    # ----------------------------------------------------------

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

    $pageCount = $pageFiles.Count
    $visualCount = $visualFiles.Count

    if ($visualCount -ne 0) {
        throw "Report visuals already exist. Expected 0 before dashboard design approval."
    }


    # ----------------------------------------------------------
    # 14. GIT STATE
    # Script itself may be untracked
    # ----------------------------------------------------------

    $gitStatus = @(
        git status --short
    )

    $unexpectedGitChanges = @()

    foreach ($line in $gitStatus) {

        if (
            $line -notmatch
            "scripts/checkpoints/CP12G3_Final_Semantic_Validation\.ps1$"
        ) {

            $unexpectedGitChanges += $line
        }
    }

    if ($unexpectedGitChanges.Count -gt 0) {

        throw (
            "Unexpected Git changes detected: " +
            ($unexpectedGitChanges -join " | ")
        )
    }


    # ----------------------------------------------------------
    # 15. CLEAN TEMP FILES
    # ----------------------------------------------------------

    Remove-Item `
        $queryFile `
        -Force `
        -ErrorAction SilentlyContinue

    Remove-Item `
        $csvFile `
        -Force `
        -ErrorAction SilentlyContinue


    # ----------------------------------------------------------
    # 16. FINAL OUTPUT
    # ----------------------------------------------------------

@"
CP12-G3A RESULT

FINAL SEMANTIC MODEL VALIDATION:
PASS

============================================================
MODEL STRUCTURE
============================================================

Semantic tables:
10 / 10

Expected tables:
PASS

Model table references:
10 / 10

Relationships:
8

Relationships to _Measures:
0

Bidirectional relationships:
0

Time intelligence:
DISABLED

============================================================
FACT GOVERNANCE
============================================================

ProfileKey implicit aggregation:
NONE

ServiceCount implicit aggregation:
NONE

MedicarePaymentAmount implicit aggregation:
NONE

Additive fact measures:
LineItemCount = SUM
RepresentedServiceUnits = SUM
RepresentedRoundedMedicarePayment = SUM

Technical key visibility:
PASS

============================================================
MEASURE HOST
============================================================

Measure host:
_Measures

Governed measures:
12 / 12

Format strings:
12 / 12

Display folders:
12 / 12

01 Core KPIs:
$folderCore / 6

02 Blank ICD Quality:
$folderBlank / 3

03 Zero-Service Quality:
$folderZero / 3

Measure-host relationships:
0

Zero-row M partition:
PASS

Hidden placeholder:
PASS

============================================================
RUNTIME KPI VALIDATION
============================================================

Runtime connection:
DIRECT OPEN PBIP

DAX measures tested:
12

Runtime PASS:
$runtimePass / 12

Runtime FAIL:
$runtimeFail

$($runtimeLines -join "`r`n")

============================================================
REPORT STATE
============================================================

Report pages currently present:
$pageCount

Report visuals:
$visualCount

Dashboard / page build:
NOT STARTED

Design approval required before report build:
YES

============================================================
GIT
============================================================

Unexpected working-tree changes:
NONE

Git commit:
NOT PERFORMED

============================================================

CP12-G3A:
PASS

NEXT:
Close Power BI Desktop.

Then CP12-G3B will document and commit the final semantic-model closeout.

NO dashboard or report page will be built before joint design approval.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G3A FINAL SEMANTIC VALIDATION: PASS"
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

    Remove-Item `
        $queryFile `
        -Force `
        -ErrorAction SilentlyContinue

    Remove-Item `
        $csvFile `
        -Force `
        -ErrorAction SilentlyContinue

@"
CP12-G3A RESULT

FINAL SEMANTIC MODEL VALIDATION:
FAIL

ERROR:
$($_.Exception.Message)

Semantic model modified:
NO

Report modified:
NO

Git commit:
NOT PERFORMED

NEXT:
STOP - Review this output before continuing.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G3A failed."
    Write-Host "Output: $out"
    Write-Host ""
}