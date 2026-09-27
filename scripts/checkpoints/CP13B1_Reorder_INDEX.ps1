$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$pagesRoot = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.Report\definition\pages"

$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

Set-Location $root

function Write-JsonFile {

    param(
        [string]$Path,
        [object]$Object
    )

    $json =
        $Object |
        ConvertTo-Json -Depth 100

    $null =
        $json |
        ConvertFrom-Json

    $enc =
        New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $Path,
        $json,
        $enc
    )
}

try {

    # ============================================================
    # 1. PREFLIGHT
    # ============================================================

    if (
        Get-Process PBIDesktop -ErrorAction SilentlyContinue
    ) {
        throw "Power BI Desktop is still open."
    }

    $indexPageFile =
        Get-ChildItem `
            -Path $pagesRoot `
            -Filter "page.json" `
            -File `
            -Recurse |
        Where-Object {

            $p =
                Get-Content $_.FullName -Raw |
                ConvertFrom-Json

            $p.displayName -eq "INDEX"
        } |
        Select-Object -First 1

    if (-not $indexPageFile) {
        throw "INDEX page not found."
    }

    $indexFolder =
        Split-Path `
            $indexPageFile.FullName `
            -Parent

    $visualsRoot =
        Join-Path `
            $indexFolder `
            "visuals"


    # ============================================================
    # 2. NEW STORY ORDER
    # ============================================================

    $layout = @{

        "exec" = @{
            Number = "01"
            Label = "Executive Overview"
            X = 110
            Y = 250
        }

        "dq" = @{
            Number = "02"
            Label = "Data Quality Overview"
            X = 580
            Y = 250
        }

        "coding" = @{
            Number = "03"
            Label = "Coding Quality"
            X = 1050
            Y = 250
        }

        "service" = @{
            Number = "04"
            Label = "Service & Payment Patterns"
            X = 110
            Y = 500
        }

        "demo" = @{
            Number = "05"
            Label = "Demographic & Provider Mix"
            X = 580
            Y = 500
        }

        "monitor" = @{
            Number = "06"
            Label = "Quality Issues Monitor"
            X = 1050
            Y = 500
        }
    }


    # ============================================================
    # 3. UPDATE EACH TILE + DESCRIPTION
    # ============================================================

    foreach ($key in $layout.Keys) {

        $cfg =
            $layout[$key]

        # --------------------------------------------------------
        # Button
        # --------------------------------------------------------

        $buttonFile =
            Join-Path `
                $visualsRoot `
                "idx_btn_$key\visual.json"

        if (-not (Test-Path $buttonFile)) {
            throw "Button not found: idx_btn_$key"
        }

        $button =
            Get-Content `
                $buttonFile `
                -Raw |
            ConvertFrom-Json

        $button.position.x =
            $cfg.X

        $button.position.y =
            $cfg.Y

        $buttonLabel =
            "$($cfg.Number)  $($cfg.Label)"

        $button.visual.objects.text[1].properties.text.expr.Literal.Value =
            "'$buttonLabel'"

        $button.visual.visualContainerObjects.visualLink[0].properties.tooltip.expr.Literal.Value =
            "'Press Ctrl + Click to go to $($cfg.Label)'"

        Write-JsonFile `
            -Path $buttonFile `
            -Object $button


        # --------------------------------------------------------
        # Description
        # --------------------------------------------------------

        $descriptionFile =
            Join-Path `
                $visualsRoot `
                "idx_desc_$key\visual.json"

        if (-not (Test-Path $descriptionFile)) {
            throw "Description not found: idx_desc_$key"
        }

        $description =
            Get-Content `
                $descriptionFile `
                -Raw |
            ConvertFrom-Json

        $description.position.x =
            $cfg.X

        $description.position.y =
            ($cfg.Y + 68)

        Write-JsonFile `
            -Path $descriptionFile `
            -Object $description
    }


    # ============================================================
    # 4. VALIDATE ORDER
    # ============================================================

    $expected = @(
        "01  Executive Overview",
        "02  Data Quality Overview",
        "03  Coding Quality",
        "04  Service & Payment Patterns",
        "05  Demographic & Provider Mix",
        "06  Quality Issues Monitor"
    )

    $found = @()

    foreach ($key in @(
        "exec",
        "dq",
        "coding",
        "service",
        "demo",
        "monitor"
    )) {

        $buttonFile =
            Join-Path `
                $visualsRoot `
                "idx_btn_$key\visual.json"

        $button =
            Get-Content `
                $buttonFile `
                -Raw |
            ConvertFrom-Json

        $label =
            [string]$button.visual.objects.text[1].properties.text.expr.Literal.Value

        $found +=
            $label.Trim("'")
    }

    for ($i = 0; $i -lt 6; $i++) {

        if ($found[$i] -ne $expected[$i]) {

            throw (
                "INDEX ordering validation failed at position " +
                ($i + 1)
            )
        }
    }


    # ============================================================
    # 5. JSON VALIDATION
    # ============================================================

    $invalid = @()

    $jsonFiles =
        Get-ChildItem `
            -Path $indexFolder `
            -Filter "*.json" `
            -File `
            -Recurse

    foreach ($file in $jsonFiles) {

        try {

            $null =
                Get-Content `
                    $file.FullName `
                    -Raw |
                ConvertFrom-Json
        }
        catch {

            $invalid +=
                $file.FullName
        }
    }

    if ($invalid.Count -gt 0) {
        throw "Invalid INDEX JSON detected."
    }


    # ============================================================
    # 6. OUTPUT
    # ============================================================

    $gitStatus =
        @(git status --short)

@"
CP13-B1 RESULT

INDEX STORY ORDER:
PASS - PENDING POWER BI DESKTOP REVIEW

Row 1:
01 Executive Overview
02 Data Quality Overview
03 Coding Quality

Row 2:
04 Service & Payment Patterns
05 Demographic & Provider Mix
06 Quality Issues Monitor

Navigation tooltips:
UPDATED

Navigation targets:
UNCHANGED

INDEX JSON invalid:
0

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

NEXT:
Open Power BI Desktop and visually review INDEX only.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-B1 completed."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP13-B1 RESULT

STATUS:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
STOP - Review before opening Power BI.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-B1 failed."
    Write-Host "Output: $out"
    Write-Host ""
}