$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$semanticRoot = Join-Path $root "powerbi\HealthcareGovernanceQC.SemanticModel"
$definition = Join-Path $semanticRoot "definition"
$tableDir = Join-Path $definition "tables"

$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

Set-Location $root

function Read-Utf8 {
    param([string]$Path)

    return [System.IO.File]::ReadAllText(
        $Path,
        [System.Text.Encoding]::UTF8
    )
}

function Write-Utf8 {
    param(
        [string]$Path,
        [string]$Text
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $Path,
        $Text,
        $utf8
    )
}

function Update-Column {
    param(
        [string]$Text,
        [string]$ColumnName,
        [bool]$Hide = $false,
        [string]$Summarize = "",
        [string]$SortBy = ""
    )

    $escaped = [regex]::Escape($ColumnName)

    $pattern =
        "(?ms)(^\tcolumn\s+'?" +
        $escaped +
        "'?\s*\r?\n)(.*?)(?=^\t(?:column|partition|measure|hierarchy|annotation)\s|\z)"

    $m = [regex]::Match($Text, $pattern)

    if (-not $m.Success) {
        throw "Column not found: $ColumnName"
    }

    $header = $m.Groups[1].Value
    $body = $m.Groups[2].Value

    if ($Hide) {

        if ($body -notmatch "(?m)^\t\tisHidden\s*$") {

            if ($body -match "(?m)^\t\tdataType:.*$") {

                $body = [regex]::Replace(
                    $body,
                    "(?m)(^\t\tdataType:.*$\r?\n)",
                    '$1' + "`t`tisHidden`r`n",
                    1
                )
            }
            else {
                $body = "`t`tisHidden`r`n" + $body
            }
        }
    }

    if ($Summarize -ne "") {

        if ($body -match "(?m)^\t\tsummarizeBy:\s*\S+\s*$") {

            $body = [regex]::Replace(
                $body,
                "(?m)^\t\tsummarizeBy:\s*\S+\s*$",
                "`t`tsummarizeBy: $Summarize",
                1
            )
        }
        else {

            $body += "`t`tsummarizeBy: $Summarize`r`n"
        }
    }

    if ($SortBy -ne "") {

        if ($body -match "(?m)^\t\tsortByColumn:") {

            $body = [regex]::Replace(
                $body,
                "(?m)^\t\tsortByColumn:.*$",
                "`t`tsortByColumn: $SortBy",
                1
            )
        }
        else {

            $body += "`t`tsortByColumn: $SortBy`r`n"
        }
    }

    $newBlock = $header + $body

    return (
        $Text.Substring(0, $m.Index) +
        $newBlock +
        $Text.Substring($m.Index + $m.Length)
    )
}

try {

    # ----------------------------------------------------------
    # POWER BI MUST BE CLOSED
    # ----------------------------------------------------------

    $pbi = Get-Process PBIDesktop -ErrorAction SilentlyContinue

    if ($pbi) {
        throw "Power BI Desktop is still open. Save and close it before running CP12-F2."
    }

    # ----------------------------------------------------------
    # EXPECTED BASELINE
    # ----------------------------------------------------------

    $modelFile = Join-Path $definition "model.tmdl"
    $relationshipsFile = Join-Path $definition "relationships.tmdl"

    if (-not (Test-Path $modelFile)) {
        throw "model.tmdl not found."
    }

    if (-not (Test-Path $relationshipsFile)) {
        throw "relationships.tmdl not found."
    }

    # ----------------------------------------------------------
    # CLEAN TABLE NAME MAP
    # ----------------------------------------------------------

    $renameMap = [ordered]@{
        "analytics vw_PBI_FactCarrierProfile" = "FactCarrierProfile"
        "analytics DimSex"                    = "DimSex"
        "analytics DimAgeCategory"            = "DimAgeCategory"
        "analytics DimICD9"                   = "DimICD9"
        "analytics DimHCPCS"                  = "DimHCPCS"
        "analytics DimBETOS"                  = "DimBETOS"
        "analytics DimProviderType"           = "DimProviderType"
        "analytics DimServiceType"            = "DimServiceType"
        "analytics DimPlaceOfService"         = "DimPlaceOfService"
    }

    # ----------------------------------------------------------
    # UPDATE ALL TMDL REFERENCES
    # ----------------------------------------------------------

    $tmdlFiles = @(
        Get-ChildItem $definition -Recurse -File -Filter "*.tmdl"
    )

    foreach ($file in $tmdlFiles) {

        $text = Read-Utf8 $file.FullName

        foreach ($oldName in $renameMap.Keys) {

            $newName = $renameMap[$oldName]

            $text = $text.Replace(
                "'$oldName'",
                "'$newName'"
            )

            $text = $text.Replace(
                '"' + $oldName + '"',
                '"' + $newName + '"'
            )
        }

        Write-Utf8 $file.FullName $text
    }

    # ----------------------------------------------------------
    # UPDATE DIAGRAM LAYOUT IF PRESENT
    # ----------------------------------------------------------

    $diagram = Join-Path $semanticRoot "diagramLayout.json"

    if (Test-Path $diagram) {

        $diagramText = Read-Utf8 $diagram

        foreach ($oldName in $renameMap.Keys) {
            $diagramText = $diagramText.Replace(
                $oldName,
                $renameMap[$oldName]
            )
        }

        Write-Utf8 $diagram $diagramText
    }

    # ----------------------------------------------------------
    # RENAME TABLE FILES
    # ----------------------------------------------------------

    foreach ($oldName in $renameMap.Keys) {

        $oldFile = Join-Path $tableDir ($oldName + ".tmdl")
        $newFile = Join-Path $tableDir ($renameMap[$oldName] + ".tmdl")

        if (Test-Path $oldFile) {

            if (Test-Path $newFile) {
                throw "Target table file already exists: $newFile"
            }

            Move-Item $oldFile $newFile
        }
    }

    # ----------------------------------------------------------
    # DISABLE UNSUPPORTED TIME INTELLIGENCE
    # ----------------------------------------------------------

    $modelText = Read-Utf8 $modelFile

    if ($modelText -match "annotation __PBI_TimeIntelligenceEnabled = 1") {

        $modelText = $modelText.Replace(
            "annotation __PBI_TimeIntelligenceEnabled = 1",
            "annotation __PBI_TimeIntelligenceEnabled = 0"
        )
    }
    elseif ($modelText -notmatch "annotation __PBI_TimeIntelligenceEnabled = 0") {

        throw "__PBI_TimeIntelligenceEnabled annotation not found."
    }

    Write-Utf8 $modelFile $modelText

    # ----------------------------------------------------------
    # DIMENSION COLUMN HYGIENE
    # ----------------------------------------------------------

    $dimensionKeyMap = [ordered]@{
        "DimSex.tmdl"            = "SexKey"
        "DimAgeCategory.tmdl"    = "AgeCategoryKey"
        "DimICD9.tmdl"           = "ICD9Key"
        "DimHCPCS.tmdl"          = "HCPCSKey"
        "DimBETOS.tmdl"          = "BETOSKey"
        "DimProviderType.tmdl"   = "ProviderTypeKey"
        "DimServiceType.tmdl"    = "ServiceTypeKey"
        "DimPlaceOfService.tmdl" = "PlaceOfServiceKey"
    }

    foreach ($fileName in $dimensionKeyMap.Keys) {

        $path = Join-Path $tableDir $fileName

        if (-not (Test-Path $path)) {
            throw "Expected dimension table missing: $fileName"
        }

        $text = Read-Utf8 $path

        $text = Update-Column `
            -Text $text `
            -ColumnName $dimensionKeyMap[$fileName] `
            -Hide $true `
            -Summarize "none"

        Write-Utf8 $path $text
    }

    # ----------------------------------------------------------
    # AGE CATEGORY SORTING
    # ----------------------------------------------------------

    $ageFile = Join-Path $tableDir "DimAgeCategory.tmdl"
    $ageText = Read-Utf8 $ageFile

    $ageText = Update-Column `
        -Text $ageText `
        -ColumnName "SortOrder" `
        -Hide $true `
        -Summarize "none"

    $ageText = Update-Column `
        -Text $ageText `
        -ColumnName "AgeCategoryLabel" `
        -SortBy "SortOrder"

    Write-Utf8 $ageFile $ageText

    # ----------------------------------------------------------
    # FACT COLUMN HYGIENE
    # ----------------------------------------------------------

    $factFile = Join-Path $tableDir "FactCarrierProfile.tmdl"

    if (-not (Test-Path $factFile)) {
        throw "FactCarrierProfile.tmdl not found after rename."
    }

    $factText = Read-Utf8 $factFile

    $factHidden = @(
        "ProfileKey",
        "SexKey",
        "AgeCategoryKey",
        "ICD9Key",
        "HCPCSKey",
        "BETOSKey",
        "ProviderTypeKey",
        "ServiceTypeKey",
        "PlaceOfServiceKey",
        "ServiceCount",
        "MedicarePaymentAmount"
    )

    foreach ($column in $factHidden) {

        $factText = Update-Column `
            -Text $factText `
            -ColumnName $column `
            -Hide $true
    }

    # Unsafe implicit aggregations disabled

    $factText = Update-Column `
        -Text $factText `
        -ColumnName "ProfileKey" `
        -Summarize "none"

    $factText = Update-Column `
        -Text $factText `
        -ColumnName "ServiceCount" `
        -Summarize "none"

    $factText = Update-Column `
        -Text $factText `
        -ColumnName "MedicarePaymentAmount" `
        -Summarize "none"

    Write-Utf8 $factFile $factText

    # ----------------------------------------------------------
    # VALIDATION
    # ----------------------------------------------------------

    $definitionText = ""

    $allTmdl = @(
        Get-ChildItem $definition -Recurse -File -Filter "*.tmdl"
    )

    foreach ($file in $allTmdl) {
        $definitionText += "`r`n" + (Read-Utf8 $file.FullName)
    }

    $oldNameOccurrences = 0

    foreach ($oldName in $renameMap.Keys) {

        $oldNameOccurrences += (
            [regex]::Matches(
                $definitionText,
                [regex]::Escape($oldName)
            )
        ).Count
    }

    $relationshipText = Read-Utf8 $relationshipsFile

    $relationshipCount = (
        [regex]::Matches(
            $relationshipText,
            "(?m)^\s*relationship\s+"
        )
    ).Count

    $modelText = Read-Utf8 $modelFile
    $factText = Read-Utf8 $factFile
    $ageText = Read-Utf8 $ageFile

    $timeDisabled =
        $modelText -match "annotation __PBI_TimeIntelligenceEnabled = 0"

    $factProfileSafe =
        $factText -match "(?ms)column ProfileKey.*?summarizeBy:\s*none"

    $factServiceSafe =
        $factText -match "(?ms)column ServiceCount.*?summarizeBy:\s*none"

    $factPaymentSafe =
        $factText -match "(?ms)column MedicarePaymentAmount.*?summarizeBy:\s*none"

    $ageSortValid =
        $ageText -match "(?ms)column AgeCategoryLabel.*?sortByColumn:\s*SortOrder"

    $hiddenCount = (
        [regex]::Matches(
            $definitionText,
            "(?m)^\s*isHidden\s*$"
        )
    ).Count

    $cleanTables = @(
        "FactCarrierProfile",
        "DimSex",
        "DimAgeCategory",
        "DimICD9",
        "DimHCPCS",
        "DimBETOS",
        "DimProviderType",
        "DimServiceType",
        "DimPlaceOfService"
    )

    $missingCleanTables = @()

    foreach ($name in $cleanTables) {

        $path = Join-Path $tableDir ($name + ".tmdl")

        if (-not (Test-Path $path)) {
            $missingCleanTables += $name
        }
    }

    if ($oldNameOccurrences -ne 0) {
        throw "Old semantic table names still exist in TMDL."
    }

    if ($missingCleanTables.Count -ne 0) {
        throw "One or more renamed table files are missing."
    }

    if ($relationshipCount -ne 8) {
        throw "Relationship count changed unexpectedly."
    }

    if (-not $timeDisabled) {
        throw "Time intelligence annotation was not disabled."
    }

    if (
        -not $factProfileSafe -or
        -not $factServiceSafe -or
        -not $factPaymentSafe
    ) {
        throw "Fact summarization hardening validation failed."
    }

    if (-not $ageSortValid) {
        throw "AgeCategoryLabel sort configuration failed."
    }

    # ----------------------------------------------------------
    # GIT DIFF ONLY — DO NOT COMMIT YET
    # ----------------------------------------------------------

    $gitStatus = @(git status --short)

@"
CP12-F2 RESULT

SEMANTIC MODEL HARDENING:
PASS - PENDING POWER BI DESKTOP VALIDATION

Clean semantic tables:
9 / 9

Old analytics-prefixed semantic names remaining:
$oldNameOccurrences

Relationships preserved:
$relationshipCount

Time intelligence enabled:
NO

ProfileKey implicit aggregation:
NONE

ServiceCount implicit aggregation:
NONE

MedicarePaymentAmount implicit aggregation:
NONE

AgeCategoryLabel sort:
SortOrder

Hidden semantic fields detected:
$hiddenCount

Measure creation:
NOT STARTED

Report visuals modified:
NO

Git commit:
NOT PERFORMED YET

Working tree:
$($gitStatus -join "`r`n")

NEXT:
Open HealthcareGovernanceQC.pbip in Power BI Desktop and verify that the project loads successfully.

DO NOT create measures or visuals yet.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-F2 completed."
    Write-Host "Open the PBIP in Power BI Desktop for validation."
    Write-Host "Output: $out"
}
catch {

@"
CP12-F2 RESULT

SEMANTIC MODEL HARDENING:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
Do not open/edit the model until this failure is reviewed.
"@ | Set-Content $out -Encoding UTF8

    Write-Host "CP12-F2 failed."
    Write-Host "Output: $out"
}