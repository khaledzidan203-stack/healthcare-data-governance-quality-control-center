$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$powerbiRoot = Join-Path $root "powerbi"
$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

Set-Location $root

try {

    $lines = New-Object System.Collections.Generic.List[string]

    function Add-Line {
        param([string]$Text = "")
        $script:lines.Add($Text)
    }

    function Add-Section {
        param([string]$Title)
        Add-Line ""
        Add-Line "======================================================================"
        Add-Line $Title
        Add-Line "======================================================================"
    }

    # ============================================================
    # PBIP DISCOVERY
    # ============================================================

    $pbipFiles = @(
        Get-ChildItem $powerbiRoot -Recurse -File -Filter "*.pbip" -ErrorAction SilentlyContinue
    )

    if ($pbipFiles.Count -eq 0) {
        throw "No PBIP file found under: $powerbiRoot"
    }

    if ($pbipFiles.Count -gt 1) {
        throw "More than one PBIP file found. Audit requires one canonical PBIP."
    }

    $pbip = $pbipFiles[0]

    Add-Line "CP12-C RESULT"
    Add-Line ""
    Add-Line "PBIP ENVIRONMENT AUDIT:"
    Add-Line "RUNNING"

    Add-Section "1. PBIP DISCOVERY"

    Add-Line "PBIP file:"
    Add-Line $pbip.FullName

    Add-Line ""
    Add-Line "PBIP size bytes:"
    Add-Line ([string]$pbip.Length)

    $pbipText = Get-Content $pbip.FullName -Raw -Encoding UTF8

    try {
        $pbipJson = $pbipText | ConvertFrom-Json
        Add-Line ""
        Add-Line "PBIP JSON:"
        Add-Line "VALID"
    }
    catch {
        throw "PBIP file is not valid JSON."
    }

    # ============================================================
    # PROJECT STRUCTURE
    # ============================================================

    Add-Section "2. POWER BI PROJECT STRUCTURE"

    $allDirs = @(
        Get-ChildItem $powerbiRoot -Recurse -Directory -ErrorAction SilentlyContinue
    )

    $semanticDirs = @(
        $allDirs | Where-Object { $_.Name -like "*.SemanticModel" }
    )

    $reportDirs = @(
        $allDirs | Where-Object { $_.Name -like "*.Report" }
    )

    Add-Line "SemanticModel folders:"
    Add-Line ([string]$semanticDirs.Count)

    foreach ($d in $semanticDirs) {
        Add-Line ("- " + $d.FullName)
    }

    Add-Line ""
    Add-Line "Report folders:"
    Add-Line ([string]$reportDirs.Count)

    foreach ($d in $reportDirs) {
        Add-Line ("- " + $d.FullName)
    }

    if ($semanticDirs.Count -ne 1) {
        throw "Expected exactly one SemanticModel folder."
    }

    if ($reportDirs.Count -ne 1) {
        throw "Expected exactly one Report folder."
    }

    $semanticRoot = $semanticDirs[0].FullName
    $reportRoot = $reportDirs[0].FullName

    # ============================================================
    # SEMANTIC MODEL FORMAT
    # ============================================================

    Add-Section "3. SEMANTIC MODEL FORMAT"

    $tmdlFiles = @(
        Get-ChildItem $semanticRoot -Recurse -File -Filter "*.tmdl" -ErrorAction SilentlyContinue
    )

    $modelBim = @(
        Get-ChildItem $semanticRoot -Recurse -File -Filter "model.bim" -ErrorAction SilentlyContinue
    )

    $definitionPbism = @(
        Get-ChildItem $semanticRoot -Recurse -File -Filter "definition.pbism" -ErrorAction SilentlyContinue
    )

    if ($tmdlFiles.Count -gt 0) {
        $modelFormat = "TMDL"
    }
    elseif ($modelBim.Count -gt 0) {
        $modelFormat = "MODEL.BIM"
    }
    else {
        $modelFormat = "UNKNOWN"
    }

    Add-Line "Semantic model format:"
    Add-Line $modelFormat

    Add-Line ""
    Add-Line "TMDL files:"
    Add-Line ([string]$tmdlFiles.Count)

    Add-Line ""
    Add-Line "definition.pbism:"
    Add-Line $(if ($definitionPbism.Count -gt 0) { "FOUND" } else { "NOT FOUND" })

    Add-Line ""
    Add-Line "model.bim:"
    Add-Line $(if ($modelBim.Count -gt 0) { "FOUND" } else { "NOT FOUND" })

    # ============================================================
    # TMDL MODEL INSPECTION
    # ============================================================

    Add-Section "4. TABLES / MEASURES / RELATIONSHIPS"

    $tableNames = @()
    $measureNames = @()
    $relationshipCount = 0
    $expressionCount = 0

    if ($modelFormat -eq "TMDL") {

        $tableDir = Join-Path $semanticRoot "definition\tables"

        if (Test-Path $tableDir) {

            $tableFiles = @(
                Get-ChildItem $tableDir -File -Filter "*.tmdl"
            )

            foreach ($file in $tableFiles) {

                $text = Get-Content $file.FullName -Raw -Encoding UTF8

                $tableMatch = [regex]::Match(
                    $text,
                    "(?m)^\s*table\s+(.+?)\s*$"
                )

                if ($tableMatch.Success) {
                    $name = $tableMatch.Groups[1].Value.Trim()
                    $tableNames += $name
                }
                else {
                    $tableNames += $file.BaseName
                }

                $measureMatches = [regex]::Matches(
                    $text,
                    "(?m)^\s*measure\s+(.+?)\s*="
                )

                foreach ($m in $measureMatches) {
                    $measureNames += $m.Groups[1].Value.Trim()
                }
            }
        }

        $relationshipsFile = Get-ChildItem $semanticRoot -Recurse -File -Filter "relationships.tmdl" -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($relationshipsFile) {

            $relationshipText = Get-Content $relationshipsFile.FullName -Raw -Encoding UTF8

            $relationshipCount = (
                [regex]::Matches(
                    $relationshipText,
                    "(?m)^\s*relationship\s+"
                )
            ).Count
        }

        $expressionsFile = Get-ChildItem $semanticRoot -Recurse -File -Filter "expressions.tmdl" -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($expressionsFile) {

            $expressionText = Get-Content $expressionsFile.FullName -Raw -Encoding UTF8

            $expressionCount = (
                [regex]::Matches(
                    $expressionText,
                    "(?m)^\s*expression\s+"
                )
            ).Count
        }
    }

    Add-Line "Tables detected:"
    Add-Line ([string]$tableNames.Count)

    foreach ($t in $tableNames) {
        Add-Line ("- " + $t)
    }

    Add-Line ""
    Add-Line "Measures detected:"
    Add-Line ([string]$measureNames.Count)

    foreach ($m in $measureNames) {
        Add-Line ("- " + $m)
    }

    Add-Line ""
    Add-Line "Relationships detected:"
    Add-Line ([string]$relationshipCount)

    Add-Line ""
    Add-Line "Power Query expressions detected:"
    Add-Line ([string]$expressionCount)

    # ============================================================
    # EXPECTED TABLE CHECK
    # ============================================================

    Add-Section "5. EXPECTED MODEL OBJECTS"

    $expectedTokens = @(
        "vw_PBI_FactCarrierProfile",
        "DimSex",
        "DimAgeCategory",
        "DimICD9",
        "DimHCPCS",
        "DimBETOS",
        "DimProviderType",
        "DimServiceType",
        "DimPlaceOfService"
    )

    $allSemanticText = ""

    foreach ($f in $tmdlFiles) {
        $allSemanticText += "`r`n" + (Get-Content $f.FullName -Raw -Encoding UTF8)
    }

    if ($modelBim.Count -gt 0) {
        $allSemanticText += "`r`n" + (Get-Content $modelBim[0].FullName -Raw -Encoding UTF8)
    }

    $expectedFound = 0

    foreach ($token in $expectedTokens) {

        if ($allSemanticText -match [regex]::Escape($token)) {
            Add-Line ("PASS | " + $token)
            $expectedFound++
        }
        else {
            Add-Line ("MISSING | " + $token)
        }
    }

    Add-Line ""
    Add-Line "Expected model objects found:"
    Add-Line "$expectedFound / 9"

    # ============================================================
    # DATA SOURCE CHECK
    # ============================================================

    Add-Section "6. DATA SOURCE / POWER QUERY"

    $sourceFiles = @(
        Get-ChildItem $semanticRoot -Recurse -File |
        Where-Object {
            $_.Extension -in @(".tmdl", ".json", ".bim")
        }
    )

    $sourceText = ""

    foreach ($f in $sourceFiles) {
        try {
            $sourceText += "`r`n" + (Get-Content $f.FullName -Raw -Encoding UTF8)
        }
        catch {}
    }

    $serverDetected = "NOT VERIFIED"
    $databaseDetected = "NOT VERIFIED"

    if ($sourceText -match "(?i)localhost") {
        $serverDetected = "localhost"
    }

    if ($sourceText -match "(?i)HealthcareGovernanceQC") {
        $databaseDetected = "HealthcareGovernanceQC"
    }

    Add-Line "SQL Server reference:"
    Add-Line $serverDetected

    Add-Line ""
    Add-Line "Database reference:"
    Add-Line $databaseDetected

    Add-Line ""
    Add-Line "Expected source view reference:"

    if ($sourceText -match "(?i)vw_PBI_FactCarrierProfile") {
        Add-Line "FOUND"
    }
    else {
        Add-Line "NOT VERIFIED"
    }

    # ============================================================
    # AUTO DATE / DATE TABLE RISK
    # ============================================================

    Add-Section "7. DATE / AUTO-DATE CHECK"

    $dateRiskTerms = @(
        "LocalDateTable",
        "DateTableTemplate",
        "AutoDateTime"
    )

    $dateRiskFound = @()

    foreach ($term in $dateRiskTerms) {

        if ($allSemanticText -match [regex]::Escape($term)) {
            $dateRiskFound += $term
        }
    }

    if ($dateRiskFound.Count -eq 0) {
        Add-Line "Auto-date artifacts detected:"
        Add-Line "NONE"
    }
    else {
        Add-Line "Auto-date artifacts detected:"
        foreach ($x in $dateRiskFound) {
            Add-Line ("- " + $x)
        }
    }

    # ============================================================
    # REPORT / PBIR INSPECTION
    # ============================================================

    Add-Section "8. REPORT / PBIR"

    $pageJsonFiles = @(
        Get-ChildItem $reportRoot -Recurse -File -Filter "page.json" -ErrorAction SilentlyContinue
    )

    $visualJsonFiles = @(
        Get-ChildItem $reportRoot -Recurse -File -Filter "visual.json" -ErrorAction SilentlyContinue
    )

    $pagesJson = @(
        Get-ChildItem $reportRoot -Recurse -File -Filter "pages.json" -ErrorAction SilentlyContinue
    )

    $reportJson = @(
        Get-ChildItem $reportRoot -Recurse -File -Filter "report.json" -ErrorAction SilentlyContinue
    )

    Add-Line "PBIR page.json files:"
    Add-Line ([string]$pageJsonFiles.Count)

    Add-Line ""
    Add-Line "PBIR visual.json files:"
    Add-Line ([string]$visualJsonFiles.Count)

    Add-Line ""
    Add-Line "pages.json:"
    Add-Line $(if ($pagesJson.Count -gt 0) { "FOUND" } else { "NOT FOUND" })

    Add-Line ""
    Add-Line "report.json:"
    Add-Line $(if ($reportJson.Count -gt 0) { "FOUND" } else { "NOT FOUND" })

    if ($pageJsonFiles.Count -gt 0) {

        Add-Line ""
        Add-Line "Pages:"

        foreach ($pageFile in $pageJsonFiles) {

            try {
                $page = Get-Content $pageFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json

                $displayName = $null

                if ($page.displayName) {
                    $displayName = $page.displayName
                }
                elseif ($page.name) {
                    $displayName = $page.name
                }
                else {
                    $displayName = $pageFile.Directory.Name
                }

                Add-Line ("- " + $displayName)
            }
            catch {
                Add-Line ("- INVALID JSON: " + $pageFile.FullName)
            }
        }
    }

    # ============================================================
    # JSON VALIDATION
    # ============================================================

    Add-Section "9. JSON STRUCTURAL VALIDATION"

    $jsonFiles = @(
        Get-ChildItem $powerbiRoot -Recurse -File -Filter "*.json" -ErrorAction SilentlyContinue
    )

    $validJson = 0
    $invalidJson = 0
    $invalidJsonList = @()

    foreach ($jf in $jsonFiles) {

        try {
            $null = Get-Content $jf.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $validJson++
        }
        catch {
            $invalidJson++
            $invalidJsonList += $jf.FullName
        }
    }

    Add-Line "JSON files:"
    Add-Line ([string]$jsonFiles.Count)

    Add-Line ""
    Add-Line "Valid JSON:"
    Add-Line ([string]$validJson)

    Add-Line ""
    Add-Line "Invalid JSON:"
    Add-Line ([string]$invalidJson)

    foreach ($bad in $invalidJsonList) {
        Add-Line ("- " + $bad)
    }

    # ============================================================
    # FILE INVENTORY
    # ============================================================

    Add-Section "10. POWER BI FILE INVENTORY"

    $pbiFiles = @(
        Get-ChildItem $powerbiRoot -Recurse -File -ErrorAction SilentlyContinue
    )

    Add-Line "Total Power BI project files:"
    Add-Line ([string]$pbiFiles.Count)

    Add-Line ""
    Add-Line "Extensions:"

    $extensionGroups = $pbiFiles |
        Group-Object Extension |
        Sort-Object Name

    foreach ($group in $extensionGroups) {

        $ext = $group.Name

        if ([string]::IsNullOrWhiteSpace($ext)) {
            $ext = "[no extension]"
        }

        Add-Line ("- {0}: {1}" -f $ext, $group.Count)
    }

    # ============================================================
    # GIT INSPECTION
    # ============================================================

    Add-Section "11. GIT STATUS"

    $gitStatus = @(git status --short)

    if ($gitStatus.Count -eq 0) {
        Add-Line "Working tree:"
        Add-Line "CLEAN"
    }
    else {
        Add-Line "Working tree:"
        foreach ($g in $gitStatus) {
            Add-Line $g
        }
    }

    Add-Line ""
    Add-Line "Current commit:"
    Add-Line ((git rev-parse HEAD).Trim())

    # ============================================================
    # AUDIT ASSESSMENT
    # ============================================================

    Add-Section "12. AUDIT ASSESSMENT"

    $blockingIssues = New-Object System.Collections.Generic.List[string]
    $reviewItems = New-Object System.Collections.Generic.List[string]

    if ($modelFormat -eq "UNKNOWN") {
        $blockingIssues.Add("Semantic model format not recognized.")
    }

    if ($expectedFound -ne 9) {
        $blockingIssues.Add("Not all 9 expected Power BI source objects were found.")
    }

    if ($invalidJson -gt 0) {
        $blockingIssues.Add("Invalid JSON exists in PBIP project.")
    }

    if ($serverDetected -ne "localhost") {
        $reviewItems.Add("SQL Server reference could not be verified as localhost.")
    }

    if ($databaseDetected -ne "HealthcareGovernanceQC") {
        $reviewItems.Add("Database reference could not be verified.")
    }

    if ($dateRiskFound.Count -gt 0) {
        $reviewItems.Add("Auto-date artifacts detected and require review.")
    }

    if ($relationshipCount -gt 0) {
        $reviewItems.Add("Relationships already exist; inspect before replacing or editing.")
    }

    if ($measureNames.Count -gt 0) {
        $reviewItems.Add("Measures already exist; inspect before adding governed measures.")
    }

    if ($blockingIssues.Count -eq 0) {
        Add-Line "Environment audit:"
        Add-Line "PASS FOR REVIEW"
    }
    else {
        Add-Line "Environment audit:"
        Add-Line "BLOCKED"
    }

    Add-Line ""
    Add-Line "Blocking issues:"
    if ($blockingIssues.Count -eq 0) {
        Add-Line "NONE"
    }
    else {
        foreach ($issue in $blockingIssues) {
            Add-Line ("- " + $issue)
        }
    }

    Add-Line ""
    Add-Line "Review items:"
    if ($reviewItems.Count -eq 0) {
        Add-Line "NONE"
    }
    else {
        foreach ($item in $reviewItems) {
            Add-Line ("- " + $item)
        }
    }

    Add-Line ""
    Add-Line "IMPORTANT:"
    Add-Line "NO PBIP FILE WAS MODIFIED BY THIS AUDIT."

    Add-Line ""
    Add-Line "NEXT:"
    Add-Line "Assistant review of CP12-C output before any relationships, DAX, formatting, or report edits."

    $lines | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-C audit completed."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP12-C RESULT

PBIP ENVIRONMENT AUDIT:
FAIL

ERROR:
$($_.Exception.Message)

PBIP modified:
NO

NEXT:
Fix audit before semantic-model editing.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-C audit failed."
    Write-Host "Output: $out"
    Write-Host ""
}