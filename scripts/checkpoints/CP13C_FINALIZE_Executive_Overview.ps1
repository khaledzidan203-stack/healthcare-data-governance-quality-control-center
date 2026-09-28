$ErrorActionPreference = "Stop"

# ============================================================
# CP13-C FINALIZE
# EXECUTIVE OVERVIEW
# Desktop validation -> cleanup -> final Git commit
# ============================================================

$root =
    "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$out =
    "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$reportRel =
    "powerbi/HealthcareGovernanceQC.Report"

$semanticRel =
    "powerbi/HealthcareGovernanceQC.SemanticModel"

$pageRel =
    "$reportRel/definition/pages/p_exec_overview"

$pageRoot =
    Join-Path $root $pageRel

$visualsRoot =
    Join-Path $pageRoot "visuals"

$tablesRoot =
    Join-Path $root `
        "$semanticRel/definition/tables"

$ageRel =
    "$semanticRel/definition/tables/DimAgeCategory.tmdl"

$providerRel =
    "$semanticRel/definition/tables/DimProviderType.tmdl"

$serviceRel =
    "$semanticRel/definition/tables/DimServiceType.tmdl"

$posRel =
    "$semanticRel/definition/tables/DimPlaceOfService.tmdl"

$measureRel =
    "$semanticRel/definition/tables/_Measures.tmdl"

$relationshipRel =
    "$semanticRel/definition/relationships.tmdl"

$finalScriptRel =
    "scripts/checkpoints/CP13C_FINAL2_Rebuild_Executive_Overview.ps1"

$thisScriptRel =
    "scripts/checkpoints/CP13C_FINALIZE_Executive_Overview.ps1"

Set-Location $root


# ============================================================
# HELPER
# ============================================================

function Test-Binding {

    param(
        [array]$Files,
        [string]$Entity,
        [string]$Property
    )

    foreach ($file in $Files) {

        $v =
            Get-Content `
                $file.FullName `
                -Raw |
            ConvertFrom-Json

        $json =
            $v |
            ConvertTo-Json `
                -Depth 100 `
                -Compress

        $entityPattern =
            '"Entity":"' +
            [regex]::Escape($Entity) +
            '"'

        $propertyPattern =
            '"Property":"' +
            [regex]::Escape($Property) +
            '"'

        if (
            $json -match $entityPattern -and
            $json -match $propertyPattern
        ) {
            return $true
        }
    }

    return $false
}


try {

    # ========================================================
    # 1. POWER BI MUST BE CLOSED
    # ========================================================

    if (
        Get-Process PBIDesktop -ErrorAction SilentlyContinue
    ) {
        throw "Power BI Desktop is still open."
    }


    # ========================================================
    # 2. REMOVE SUPERSEDED FAILED SCRIPTS
    # Keep only the successful FINAL2 builder.
    # ========================================================

    $supersededScripts = @(

        "scripts/checkpoints/CP13C_Build_Executive_Overview.ps1",

        "scripts/checkpoints/CP13C_FULL_Rebuild_Executive_Overview.ps1",

        "scripts/checkpoints/CP13C_FINAL_Rebuild_Executive_Overview.ps1",

        "scripts/checkpoints/CP13C1_Semantic_UX.ps1",

        "scripts/checkpoints/CP13C1R_Repair_Semantic_UX.ps1"
    )

    foreach ($relativePath in $supersededScripts) {

        $fullPath =
            Join-Path $root $relativePath

        if (Test-Path $fullPath) {

            Remove-Item `
                $fullPath `
                -Force
        }
    }


    # ========================================================
    # 3. RESTORE UNRELATED DESKTOP ROUNDTRIP FILES
    #
    # We only want:
    # - Executive Overview
    # - four semantic UX tables
    # - final successful builder
    # - this finalizer
    # ========================================================

    # INDEX page folder
    $pagesRoot =
        Join-Path `
            $root `
            "$reportRel/definition/pages"

    $indexPageFile =
        Get-ChildItem `
            -Path $pagesRoot `
            -Filter "page.json" `
            -File `
            -Recurse |
        Where-Object {

            $p =
                Get-Content `
                    $_.FullName `
                    -Raw |
                ConvertFrom-Json

            $p.displayName -eq "INDEX"
        } |
        Select-Object -First 1


    if ($indexPageFile) {

        $indexFolder =
            Split-Path `
                $indexPageFile.FullName `
                -Parent

        $indexRel =
            $indexFolder.Substring(
                $root.Length + 1
            ).Replace("\","/")

        git restore `
            --source=HEAD `
            -- `
            $indexRel
    }


    # Restore saved active-page / UI metadata.
    git restore `
        --source=HEAD `
        -- `
        "$reportRel/definition/pages/pages.json" `
        "$reportRel/definition/report.json" `
        $measureRel `
        "$semanticRel/diagramLayout.json"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to restore unrelated Desktop roundtrip files."
    }


    # ========================================================
    # 4. EXECUTIVE PAGE INVENTORY
    # ========================================================

    $visualFiles =
        @(
            Get-ChildItem `
                -Path $visualsRoot `
                -Filter "visual.json" `
                -File `
                -Recurse
        )


    if ($visualFiles.Count -ne 18) {

        throw (
            "Expected 18 Executive visuals. Found: " +
            $visualFiles.Count
        )
    }


    # ========================================================
    # 5. JSON / VISUAL COUNTS
    # ========================================================

    $invalid =
        0

    $slicers =
        0

    $cards =
        0

    $charts =
        0

    $textboxes =
        0

    $buttons =
        0

    $headerArrays =
        0

    $header100 =
        0


    foreach ($file in $visualFiles) {

        $raw =
            Get-Content `
                $file.FullName `
                -Raw

        try {

            $v =
                $raw |
                ConvertFrom-Json
        }
        catch {

            $invalid++
            continue
        }


        $type =
            [string]$v.visual.visualType


        switch ($type) {

            "slicer" {
                $slicers++
            }

            "cardVisual" {
                $cards++
            }

            "clusteredColumnChart" {
                $charts++
            }

            "barChart" {
                $charts++
            }

            "textbox" {
                $textboxes++
            }

            "actionButton" {
                $buttons++
            }
        }


        if (
            $type -eq "slicer" -or
            $type -eq "cardVisual" -or
            $type -eq "clusteredColumnChart" -or
            $type -eq "barChart"
        ) {

            if (
                $raw -notmatch
                '"visualHeader"\s*:\s*\['
            ) {

                throw (
                    "visualHeader is not an ARRAY: " +
                    $file.FullName
                )
            }


            $headerArrays++


            $header =
                @(
                    $v.visual.visualContainerObjects.visualHeader
                )


            if ($header.Count -ne 1) {

                throw (
                    "Unexpected visualHeader instance count: " +
                    $file.FullName
                )
            }


            $transparency =
                [string]$header[0].properties.transparency.expr.Literal.Value


            if ($transparency -eq "100D") {

                $header100++
            }
            else {

                throw (
                    "Header transparency is not 100%: " +
                    $file.FullName
                )
            }
        }
    }


    if ($invalid -ne 0) {
        throw "Invalid Executive visual JSON detected."
    }

    if ($slicers -ne 4) {
        throw "Expected 4 slicers."
    }

    if ($cards -ne 8) {
        throw "Expected 8 cards."
    }

    if ($charts -ne 2) {
        throw "Expected 2 charts."
    }

    if ($textboxes -ne 3) {
        throw "Expected 3 textboxes."
    }

    if ($buttons -ne 1) {
        throw "Expected 1 INDEX button."
    }

    if ($headerArrays -ne 14) {
        throw "Expected 14 valid visualHeader arrays."
    }

    if ($header100 -ne 14) {
        throw "Expected Header Transparency 100% on 14 visuals."
    }


    # ========================================================
    # 6. SEMANTIC UX VALIDATION
    # ========================================================

    $ageText =
        Get-Content `
            (Join-Path $root $ageRel) `
            -Raw `
            -Encoding UTF8

    $providerText =
        Get-Content `
            (Join-Path $root $providerRel) `
            -Raw `
            -Encoding UTF8

    $serviceText =
        Get-Content `
            (Join-Path $root $serviceRel) `
            -Raw `
            -Encoding UTF8

    $posText =
        Get-Content `
            (Join-Path $root $posRel) `
            -Raw `
            -Encoding UTF8


    if (
        $ageText -notmatch
        "(?m)^\s*sortByColumn:\s*'?SortOrder'?\s*$"
    ) {

        throw "Desktop-authored Age SortOrder metadata is missing."
    }


    if (
        $providerText -notmatch
        "(?m)^\s*column\s+ProviderTypeLabel\s*="
    ) {

        throw "ProviderTypeLabel missing."
    }


    if (
        $serviceText -notmatch
        "(?m)^\s*column\s+ServiceTypeLabel\s*="
    ) {

        throw "ServiceTypeLabel missing."
    }


    if (
        $posText -notmatch
        "(?m)^\s*column\s+PlaceOfServiceLabel\s*="
    ) {

        throw "PlaceOfServiceLabel missing."
    }


    # ========================================================
    # 7. REQUIRED REPORT BINDINGS
    # ========================================================

    $requiredBindings = @(

        @("DimAgeCategory", "AgeCategoryLabel"),

        @("DimProviderType", "ProviderTypeLabel"),

        @("DimServiceType", "ServiceTypeLabel"),

        @("DimPlaceOfService", "PlaceOfServiceLabel"),

        @("_Measures", "Profile Count"),

        @("_Measures", "Represented Line Items"),

        @("_Measures", "Represented Service Units"),

        @("_Measures", "Represented Rounded Medicare Payment"),

        @("_Measures", "Blank ICD Line Rate"),

        @("_Measures", "Blank ICD Represented Lines"),

        @("_Measures", "Zero-Service Line Rate"),

        @("_Measures", "Zero-Service Represented Lines")
    )


    $missing =
        @()


    foreach ($binding in $requiredBindings) {

        $found =
            Test-Binding `
                -Files $visualFiles `
                -Entity $binding[0] `
                -Property $binding[1]


        if (-not $found) {

            $missing += (
                $binding[0] +
                "." +
                $binding[1]
            )
        }
    }


    if ($missing.Count -ne 0) {

        throw (
            "Missing Executive binding(s): " +
            ($missing -join ", ")
        )
    }


    # ========================================================
    # 8. GOVERNED MODEL SAFETY
    # ========================================================

    $relationships =
        Get-Content `
            (Join-Path $root $relationshipRel) `
            -Raw `
            -Encoding UTF8

    $measures =
        Get-Content `
            (Join-Path $root $measureRel) `
            -Raw `
            -Encoding UTF8


    $relationshipCount =
        (
            [regex]::Matches(
                $relationships,
                "(?m)^\s*relationship\s+"
            )
        ).Count


    $measureCount =
        (
            [regex]::Matches(
                $measures,
                "(?m)^\s*measure\s+"
            )
        ).Count


    if ($relationshipCount -ne 8) {

        throw (
            "Expected 8 relationships. Found: " +
            $relationshipCount
        )
    }


    if ($measureCount -ne 12) {

        throw (
            "Expected 12 governed measures. Found: " +
            $measureCount
        )
    }


    # ========================================================
    # 9. STAGE ONLY APPROVED CP13-C FILES
    # ========================================================

    git add `
        $pageRel `
        $ageRel `
        $providerRel `
        $serviceRel `
        $posRel `
        $finalScriptRel `
        $thisScriptRel


    if ($LASTEXITCODE -ne 0) {
        throw "git add failed."
    }


    $staged =
        @(git diff --cached --name-only)


    if ($staged.Count -eq 0) {
        throw "No CP13-C files staged."
    }


    # ========================================================
    # 10. ENSURE NO UNEXPECTED WORKING-TREE CHANGES REMAIN
    # ========================================================

    $unstaged =
        @(git diff --name-only)


    $untracked =
        @(
            git ls-files `
                --others `
                --exclude-standard
        )


    if ($unstaged.Count -gt 0) {

        throw (
            "Unexpected unstaged tracked files remain: " +
            ($unstaged -join ", ")
        )
    }


    if ($untracked.Count -gt 0) {

        throw (
            "Unexpected untracked files remain: " +
            ($untracked -join ", ")
        )
    }


    # ========================================================
    # 11. COMMIT
    # ========================================================

    git commit `
        -m "checkpoint: finalize executive overview report page"


    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed."
    }


    $commit =
        (git rev-parse HEAD).Trim()


    $status =
        @(git status --short)


    if ($status.Count -ne 0) {

        throw (
            "Working tree not clean after commit: " +
            ($status -join " | ")
        )
    }


    # ========================================================
    # 12. OUTPUT
    # ========================================================

@"
CP13-C FINAL RESULT

EXECUTIVE OVERVIEW:
COMPLETED

POWER BI DESKTOP VISUAL REVIEW:
PASS

============================================================
REPORT
============================================================

Total visuals:
$($visualFiles.Count) / 18

Slicers:
$slicers / 4

KPI cards:
$cards / 8

Charts:
$charts / 2

Textboxes:
$textboxes / 3

INDEX button:
$buttons / 1

Invalid JSON:
$invalid

Missing semantic bindings:
$($missing.Count)

============================================================
SEMANTIC UX
============================================================

Age Category:
AgeCategoryLabel

Age order:
SortOrder

Provider:
ProviderTypeLabel

Service:
ServiceTypeLabel

Place of Service:
PlaceOfServiceLabel

============================================================
HEADER ICONS
============================================================

visualHeader ARRAY:
$headerArrays / 14

Transparency 100%:
$header100 / 14

Runtime visible icons:
NONE IN APPROVED SCREENSHOT

============================================================
MODEL SAFETY
============================================================

Relationships:
$relationshipCount / 8

Governed measures:
$measureCount / 12

Existing KPI calculations changed:
NO

============================================================
DESIGN
============================================================

Centered KPI values:
PASS

White subtitle on dark header:
PASS

Magnitude-driven chart gradients:
PASS

Age chronological order:
PASS

Human-readable provider labels:
PASS

Quality rates presentation:
PASS

Full-page selectable background:
NO

============================================================
GIT
============================================================

Git commit:
$commit

Working tree:
CLEAN

CP13-C:
COMPLETED

============================================================

NEXT:
CP13-D - Data Quality Overview
"@ |
        Set-Content `
            $out `
            -Encoding UTF8


    Write-Host ""
    Write-Host "CP13-C FINALIZED."
    Write-Host "Commit: $commit"
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP13-C FINAL RESULT

STATUS:
FAIL

ERROR:
$($_.Exception.Message)

GIT COMMIT:
NOT PERFORMED OR NOT ACCEPTED

NEXT:
Upload this output before continuing.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8


    Write-Host ""
    Write-Host "CP13-C finalization failed."
    Write-Host "Output: $out"
    Write-Host ""
}