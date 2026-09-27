$ErrorActionPreference = "Stop"

# ============================================================
# CP13-B
# BUILD INDEX PAGE + ANALYTICAL PAGE SHELLS
# CLEAN REBUILD
# ============================================================

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$reportRoot = Join-Path $root `
    "powerbi\HealthcareGovernanceQC.Report"

$definition = Join-Path $reportRoot "definition"
$pagesRoot  = Join-Path $definition "pages"
$pagesFile  = Join-Path $pagesRoot "pages.json"

$scriptPath = Join-Path $root `
    "scripts\checkpoints\CP13B_Build_INDEX.ps1"

$out = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

Set-Location $root


# ============================================================
# SCHEMAS
# ============================================================

$pageSchema =
    "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.0.0/schema.json"

$pagesSchema =
    "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.0.0/schema.json"

$visualSchema =
    "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.9.0/schema.json"


# ============================================================
# CANVAS
# ============================================================

$canvasWidth  = 1600
$canvasHeight = 900


# ============================================================
# DESIGN PALETTE
# ============================================================

$ColorCanvas      = "#F4F7FB"
$ColorPanel       = "#EAF1FA"
$ColorWhite       = "#FFFFFF"

$ColorNavy        = "#173B63"
$ColorIndigo      = "#506CF0"
$ColorTeal        = "#1E9E96"
$ColorAmber       = "#C98A2E"
$ColorRed         = "#D45757"
$ColorDarkNeutral = "#3C4B63"

$ColorText        = "#22324A"
$ColorSecondary   = "#6B7A90"


# ============================================================
# HELPERS
# ============================================================

function New-Literal {

    param(
        [string]$Value
    )

    return @{
        expr = @{
            Literal = @{
                Value = $Value
            }
        }
    }
}


function New-SolidColor {

    param(
        [string]$Color
    )

    return @{
        solid = @{
            color = (
                New-Literal "'$Color'"
            )
        }
    }
}


function Write-JsonFile {

    param(
        [string]$Path,
        [object]$Object
    )

    $json =
        $Object |
        ConvertTo-Json -Depth 100

    # Local JSON syntax validation
    $null =
        $json |
        ConvertFrom-Json

    $encoding =
        New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $Path,
        $json,
        $encoding
    )
}


function New-ReportPage {

    param(
        [string]$Name,
        [string]$DisplayName
    )

    return [ordered]@{

        '$schema' = $pageSchema

        name = $Name

        displayName = $DisplayName

        displayOption = "FitToPage"

        height = $canvasHeight

        width = $canvasWidth

        visibility = "AlwaysVisible"

        objects = @{

            background = @(
                @{
                    properties = @{
                        color = (
                            New-SolidColor $ColorCanvas
                        )

                        transparency = (
                            New-Literal "0D"
                        )
                    }
                }
            )
        }

        howCreated = "Default"
    }
}


function New-StaticTextbox {

    param(
        [string]$Name,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [double]$Z,
        [double]$TabOrder,
        [string]$TextValue,
        [string]$FontSize,
        [string]$FontColor,
        [string]$Alignment = "center",
        [string]$BackgroundColor = ""
    )

    $containerObjects = @{

        border = @(
            @{
                properties = @{
                    show = (
                        New-Literal "false"
                    )
                }
            }
        )

        padding = @(
            @{
                properties = @{
                    top = (
                        New-Literal "0D"
                    )

                    bottom = (
                        New-Literal "0D"
                    )

                    left = (
                        New-Literal "0D"
                    )

                    right = (
                        New-Literal "0D"
                    )
                }
            }
        )
    }

    if (
        [string]::IsNullOrWhiteSpace(
            $BackgroundColor
        )
    ) {

        $containerObjects["background"] = @(
            @{
                properties = @{
                    show = (
                        New-Literal "false"
                    )
                }
            }
        )
    }
    else {

        $containerObjects["background"] = @(
            @{
                properties = @{
                    show = (
                        New-Literal "true"
                    )

                    color = (
                        New-SolidColor $BackgroundColor
                    )

                    transparency = (
                        New-Literal "0D"
                    )
                }
            }
        )
    }

    return [ordered]@{

        '$schema' = $visualSchema

        name = $Name

        position = @{
            x = $X
            y = $Y
            z = $Z
            height = $Height
            width = $Width
            tabOrder = $TabOrder
        }

        visual = @{

            visualType = "textbox"

            objects = @{

                general = @(
                    @{
                        properties = @{

                            paragraphs = @(
                                @{
                                    textRuns = @(
                                        @{
                                            value = $TextValue

                                            textStyle = @{
                                                fontFamily = "Segoe UI"
                                                fontSize   = $FontSize
                                                color      = $FontColor
                                            }
                                        }
                                    )

                                    horizontalTextAlignment =
                                        $Alignment
                                }
                            )
                        }
                    }
                )
            }

            visualContainerObjects =
                $containerObjects
        }

        howCreated = "Default"
    }
}


function New-NavigationButton {

    param(
        [string]$Name,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [double]$Z,
        [double]$TabOrder,
        [string]$Label,
        [string]$FillColor,
        [string]$HoverColor,
        [string]$TargetPage,
        [string]$Tooltip
    )

    return [ordered]@{

        '$schema' = $visualSchema

        name = $Name

        position = @{
            x = $X
            y = $Y
            z = $Z
            height = $Height
            width = $Width
            tabOrder = $TabOrder
        }

        visual = @{

            visualType = "actionButton"

            objects = @{

                text = @(

                    @{
                        properties = @{
                            show = (
                                New-Literal "true"
                            )
                        }
                    },

                    @{
                        properties = @{

                            text = (
                                New-Literal "'$Label'"
                            )

                            fontSize = (
                                New-Literal "12D"
                            )

                            fontColor = (
                                New-SolidColor $ColorWhite
                            )

                            horizontalAlignment = (
                                New-Literal "'center'"
                            )
                        }

                        selector = @{
                            id = "default"
                        }
                    }
                )

                icon = @(

                    @{
                        properties = @{
                            show = (
                                New-Literal "false"
                            )
                        }
                    },

                    @{
                        properties = @{

                            shapeType = (
                                New-Literal "'blank'"
                            )

                            placement = (
                                New-Literal "'left'"
                            )
                        }

                        selector = @{
                            id = "default"
                        }
                    }
                )

                fill = @(

                    @{
                        properties = @{
                            show = (
                                New-Literal "true"
                            )
                        }
                    },

                    @{
                        properties = @{
                            fillColor = (
                                New-SolidColor $FillColor
                            )
                        }

                        selector = @{
                            id = "default"
                        }
                    },

                    @{
                        properties = @{
                            fillColor = (
                                New-SolidColor $HoverColor
                            )
                        }

                        selector = @{
                            id = "hover"
                        }
                    }
                )

                outline = @(
                    @{
                        properties = @{
                            show = (
                                New-Literal "false"
                            )
                        }
                    }
                )

                shape = @(

                    @{
                        properties = @{

                            tileShape = (
                                New-Literal "'rectangleRounded'"
                            )

                            roundEdge = (
                                New-Literal "10L"
                            )
                        }
                    },

                    @{
                        properties = @{
                            tileShape = (
                                New-Literal "'rectangleRounded'"
                            )
                        }

                        selector = @{
                            id = "default"
                        }
                    }
                )
            }

            visualContainerObjects = @{

                background = @(
                    @{
                        properties = @{
                            show = (
                                New-Literal "false"
                            )
                        }
                    }
                )

                border = @(
                    @{
                        properties = @{
                            show = (
                                New-Literal "false"
                            )
                        }
                    }
                )

                visualLink = @(
                    @{
                        properties = @{

                            show = (
                                New-Literal "true"
                            )

                            type = (
                                New-Literal "'PageNavigation'"
                            )

                            navigationSection = (
                                New-Literal "'$TargetPage'"
                            )

                            tooltip = (
                                New-Literal "'$Tooltip'"
                            )
                        }
                    }
                )
            }

            drillFilterOtherVisuals = $true
        }

        howCreated = "InsertVisualButton"
    }
}


function Write-ReportVisual {

    param(
        [string]$PageFolder,
        [object]$Visual
    )

    $visualsDir =
        Join-Path $PageFolder "visuals"

    New-Item `
        -ItemType Directory `
        -Path $visualsDir `
        -Force |
        Out-Null

    $visualName =
        [string]$Visual.name

    $visualFolder =
        Join-Path $visualsDir $visualName

    New-Item `
        -ItemType Directory `
        -Path $visualFolder `
        -Force |
        Out-Null

    Write-JsonFile `
        -Path (
            Join-Path $visualFolder "visual.json"
        ) `
        -Object $Visual
}


function Assert-VisualInsideCanvas {

    param(
        [object]$Visual,
        [string]$Path
    )

    $position =
        $Visual.position

    if (
        $position.x -lt 0 -or
        $position.y -lt 0 -or
        ($position.x + $position.width) -gt $canvasWidth -or
        ($position.y + $position.height) -gt $canvasHeight
    ) {

        throw "Visual outside canvas: $Path"
    }
}


# ============================================================
# MAIN
# ============================================================

try {

    # ========================================================
    # 1. PREFLIGHT
    # ========================================================

    if (
        Get-Process `
            PBIDesktop `
            -ErrorAction SilentlyContinue
    ) {
        throw "Power BI Desktop is still open."
    }

    if (-not (Test-Path $pagesRoot)) {
        throw "PBIR pages folder not found."
    }

    if (-not (Test-Path $pagesFile)) {
        throw "pages.json not found."
    }

    if (-not (Test-Path $scriptPath)) {
        throw "CP13-B script file not found."
    }

    # Previous failed attempt rolled report changes back.
    # Only the current script itself is allowed to be untracked.
    $gitBefore =
        @(git status --short)

    $unexpectedBefore =
        @()

    foreach ($statusLine in $gitBefore) {

        if ($statusLine.Length -lt 4) {
            continue
        }

        $changedPath =
            $statusLine.Substring(3).Trim()

        if (
            $changedPath -ne
            "scripts/checkpoints/CP13B_Build_INDEX.ps1"
        ) {

            $unexpectedBefore +=
                $statusLine
        }
    }

    if ($unexpectedBefore.Count -gt 0) {

        throw (
            "Unexpected working-tree changes before CP13-B: " +
            ($unexpectedBefore -join " | ")
        )
    }


    # ========================================================
    # 2. CONFIRM CLEAN REPORT BASELINE
    # ========================================================

    $existingPageFiles =
        @(
            Get-ChildItem `
                -Path $pagesRoot `
                -Filter "page.json" `
                -File `
                -Recurse
        )

    if ($existingPageFiles.Count -ne 1) {

        throw (
            "Expected exactly 1 baseline report page. Found: " +
            $existingPageFiles.Count
        )
    }

    $existingVisualFiles =
        @(
            Get-ChildItem `
                -Path $pagesRoot `
                -Filter "visual.json" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue
        )

    if ($existingVisualFiles.Count -ne 0) {

        throw (
            "Expected 0 baseline report visuals. Found: " +
            $existingVisualFiles.Count
        )
    }


    # ========================================================
    # 3. DISCOVER EXISTING BLANK PAGE
    # ========================================================

    $indexPageFile =
        $existingPageFiles[0].FullName

    $indexPageFolder =
        Split-Path `
            $indexPageFile `
            -Parent

    $existingIndex =
        Get-Content `
            $indexPageFile `
            -Raw |
        ConvertFrom-Json

    $indexPageId =
        [string]$existingIndex.name

    if (
        [string]::IsNullOrWhiteSpace(
            $indexPageId
        )
    ) {
        throw "Baseline page ID is missing."
    }


    # ========================================================
    # 4. PAGE MAP
    # ========================================================

    $pageMap = [ordered]@{

        "INDEX" =
            $indexPageId

        "Executive Overview" =
            "p_exec_overview"

        "Data Quality Overview" =
            "p_data_quality"

        "Coding Quality" =
            "p_coding_quality"

        "Service & Payment Patterns" =
            "p_service_payment"

        "Demographic & Provider Mix" =
            "p_demographic_provider"

        "Quality Issues Monitor" =
            "p_quality_monitor"
    }


    # ========================================================
    # 5. REBUILD INDEX PAGE METADATA
    #
    # IMPORTANT:
    # Native page background only.
    # No full-page selectable decorative shape.
    # ========================================================

    $indexPageObject =
        New-ReportPage `
            -Name $indexPageId `
            -DisplayName "INDEX"

    Write-JsonFile `
        -Path $indexPageFile `
        -Object $indexPageObject


    # ========================================================
    # 6. CREATE SIX ANALYTICAL PAGE SHELLS
    # ========================================================

    foreach (
        $pageDisplayName in
        $pageMap.Keys
    ) {

        if (
            $pageDisplayName -eq
            "INDEX"
        ) {
            continue
        }

        $pageId =
            $pageMap[$pageDisplayName]

        $pageFolder =
            Join-Path `
                $pagesRoot `
                $pageId

        if (Test-Path $pageFolder) {

            throw (
                "Unexpected existing page folder: " +
                $pageId
            )
        }

        New-Item `
            -ItemType Directory `
            -Path $pageFolder `
            -Force |
            Out-Null

        $pageObject =
            New-ReportPage `
                -Name $pageId `
                -DisplayName $pageDisplayName

        Write-JsonFile `
            -Path (
                Join-Path `
                    $pageFolder `
                    "page.json"
            ) `
            -Object $pageObject
    }


    # ========================================================
    # 7. INDEX PAGE HEADER
    # ========================================================

    $indexTitle =
        New-StaticTextbox `
            -Name "idx_title" `
            -X 160 `
            -Y 36 `
            -Width 1280 `
            -Height 76 `
            -Z 10 `
            -TabOrder 0 `
            -TextValue "Healthcare Data Governance & Quality Control Center" `
            -FontSize "34px" `
            -FontColor $ColorNavy `
            -Alignment "center" `
            -BackgroundColor $ColorPanel

    Write-ReportVisual `
        -PageFolder $indexPageFolder `
        -Visual $indexTitle


    $indexSubtitle =
        New-StaticTextbox `
            -Name "idx_subtitle" `
            -X 250 `
            -Y 122 `
            -Width 1100 `
            -Height 38 `
            -Z 11 `
            -TabOrder 1 `
            -TextValue "Data quality, coding, utilization and payment insights from the CMS Carrier PUF" `
            -FontSize "15px" `
            -FontColor $ColorSecondary `
            -Alignment "center"

    Write-ReportVisual `
        -PageFolder $indexPageFolder `
        -Visual $indexSubtitle


    # ========================================================
    # 8. INDEX NAVIGATION TILES
    #
    # Clickable colored title bar
    # + concise description below.
    # ========================================================

    $tiles = @(

        @{
            Id = "exec"
            Page = "Executive Overview"
            X = 110
            Y = 250
            Fill = $ColorNavy
            Hover = $ColorIndigo
            Description =
                "Scale, utilization, payment and key quality signals."
        },

        @{
            Id = "dq"
            Page = "Data Quality Overview"
            X = 580
            Y = 250
            Fill = $ColorAmber
            Hover = "#A96F20"
            Description =
                "Completeness, blank coding and zero-service exceptions."
        },

        @{
            Id = "monitor"
            Page = "Quality Issues Monitor"
            X = 1050
            Y = 250
            Fill = $ColorRed
            Hover = "#B64242"
            Description =
                "Priority issue slices for focused investigation."
        },

        @{
            Id = "coding"
            Page = "Coding Quality"
            X = 110
            Y = 500
            Fill = $ColorIndigo
            Hover = "#3F58CC"
            Description =
                "ICD-9, HCPCS and BETOS distribution and completeness."
        },

        @{
            Id = "service"
            Page = "Service & Payment Patterns"
            X = 580
            Y = 500
            Fill = $ColorTeal
            Hover = "#177D76"
            Description =
                "Service volume and represented Medicare payment patterns."
        },

        @{
            Id = "demo"
            Page = "Demographic & Provider Mix"
            X = 1050
            Y = 500
            Fill = $ColorDarkNeutral
            Hover = $ColorNavy
            Description =
                "Age, sex, provider and place-of-service composition."
        }
    )

    $tileTabOrder = 10
    $tileZOrder   = 20

    foreach ($tile in $tiles) {

        $destinationPageId =
            $pageMap[$tile.Page]

        $navigationTooltip =
            "Press Ctrl + Click to go to $($tile.Page)"

        $tileButton =
            New-NavigationButton `
                -Name "idx_btn_$($tile.Id)" `
                -X $tile.X `
                -Y $tile.Y `
                -Width 440 `
                -Height 54 `
                -Z $tileZOrder `
                -TabOrder $tileTabOrder `
                -Label $tile.Page `
                -FillColor $tile.Fill `
                -HoverColor $tile.Hover `
                -TargetPage $destinationPageId `
                -Tooltip $navigationTooltip

        Write-ReportVisual `
            -PageFolder $indexPageFolder `
            -Visual $tileButton


        $tileDescription =
            New-StaticTextbox `
                -Name "idx_desc_$($tile.Id)" `
                -X $tile.X `
                -Y ($tile.Y + 68) `
                -Width 440 `
                -Height 58 `
                -Z ($tileZOrder + 1) `
                -TabOrder ($tileTabOrder + 1) `
                -TextValue $tile.Description `
                -FontSize "13px" `
                -FontColor $ColorSecondary `
                -Alignment "center"

        Write-ReportVisual `
            -PageFolder $indexPageFolder `
            -Visual $tileDescription

        $tileTabOrder += 2
        $tileZOrder   += 2
    }


    # ========================================================
    # 9. ANALYTICAL PAGE SHELL CHROME
    #
    # IMPORTANT:
    # variable name is $indexButton
    # NOT $home because $HOME is a PowerShell constant.
    # ========================================================

    foreach (
        $pageDisplayName in
        $pageMap.Keys
    ) {

        if (
            $pageDisplayName -eq
            "INDEX"
        ) {
            continue
        }

        $pageId =
            $pageMap[$pageDisplayName]

        $pageFolder =
            Join-Path `
                $pagesRoot `
                $pageId


        $analyticalPageTitle =
            New-StaticTextbox `
                -Name "hdr_page_title" `
                -X 250 `
                -Y 28 `
                -Width 1100 `
                -Height 70 `
                -Z 10 `
                -TabOrder 0 `
                -TextValue $pageDisplayName `
                -FontSize "30px" `
                -FontColor $ColorNavy `
                -Alignment "center" `
                -BackgroundColor $ColorPanel

        Write-ReportVisual `
            -PageFolder $pageFolder `
            -Visual $analyticalPageTitle


        $indexButton =
            New-NavigationButton `
                -Name "hdr_index_button" `
                -X 1380 `
                -Y 38 `
                -Width 160 `
                -Height 48 `
                -Z 20 `
                -TabOrder 1 `
                -Label "INDEX" `
                -FillColor $ColorNavy `
                -HoverColor $ColorIndigo `
                -TargetPage $indexPageId `
                -Tooltip "Press Ctrl + Click to go to INDEX"

        Write-ReportVisual `
            -PageFolder $pageFolder `
            -Visual $indexButton
    }


    # ========================================================
    # 10. UPDATE PAGE ORDER
    # ========================================================

    $pageOrder = @(

        $indexPageId,

        $pageMap[
            "Executive Overview"
        ],

        $pageMap[
            "Data Quality Overview"
        ],

        $pageMap[
            "Coding Quality"
        ],

        $pageMap[
            "Service & Payment Patterns"
        ],

        $pageMap[
            "Demographic & Provider Mix"
        ],

        $pageMap[
            "Quality Issues Monitor"
        ]
    )

    $pagesMetadata = [ordered]@{

        '$schema' =
            $pagesSchema

        pageOrder =
            $pageOrder

        activePageName =
            $indexPageId
    }

    Write-JsonFile `
        -Path $pagesFile `
        -Object $pagesMetadata


    # ========================================================
    # 11. VALIDATE PAGE COUNT
    # ========================================================

    $finalPageFiles =
        @(
            Get-ChildItem `
                -Path $pagesRoot `
                -Filter "page.json" `
                -File `
                -Recurse
        )

    if ($finalPageFiles.Count -ne 7) {

        throw (
            "Expected 7 pages. Found: " +
            $finalPageFiles.Count
        )
    }


    # ========================================================
    # 12. VALIDATE VISUAL COUNT
    #
    # INDEX:
    #   2 header textboxes
    #   6 navigation buttons
    #   6 descriptions
    #   = 14
    #
    # 6 analytical pages:
    #   title + INDEX button = 2 each
    #   = 12
    #
    # TOTAL = 26
    # ========================================================

    $finalVisualFiles =
        @(
            Get-ChildItem `
                -Path $pagesRoot `
                -Filter "visual.json" `
                -File `
                -Recurse
        )

    if ($finalVisualFiles.Count -ne 26) {

        throw (
            "Expected 26 visuals. Found: " +
            $finalVisualFiles.Count
        )
    }


    # ========================================================
    # 13. VALIDATE ALL JSON FILES
    # ========================================================

    $allJsonFiles =
        @(
            Get-ChildItem `
                -Path $definition `
                -Filter "*.json" `
                -File `
                -Recurse
        )

    $invalidJson =
        @()

    foreach ($jsonFile in $allJsonFiles) {

        try {

            $null =
                Get-Content `
                    $jsonFile.FullName `
                    -Raw |
                ConvertFrom-Json
        }
        catch {

            $invalidJson +=
                $jsonFile.FullName
        }
    }

    if ($invalidJson.Count -gt 0) {

        throw (
            "Invalid JSON detected: " +
            ($invalidJson -join " | ")
        )
    }


    # ========================================================
    # 14. VALIDATE PAGE METADATA
    # ========================================================

    $pageIds =
        @()

    $nativeBackgroundCount =
        0

    foreach ($pageFile in $finalPageFiles) {

        $pageObject =
            Get-Content `
                $pageFile.FullName `
                -Raw |
            ConvertFrom-Json

        $pageIds +=
            [string]$pageObject.name

        if (
            $pageObject.width -ne
            $canvasWidth
        ) {

            throw (
                "Unexpected page width: " +
                $pageObject.displayName
            )
        }

        if (
            $pageObject.height -ne
            $canvasHeight
        ) {

            throw (
                "Unexpected page height: " +
                $pageObject.displayName
            )
        }

        if (
            $null -ne
            $pageObject.objects.background
        ) {

            $nativeBackgroundCount++
        }
    }

    if ($nativeBackgroundCount -ne 7) {

        throw (
            "Expected native background on all 7 pages."
        )
    }


    # ========================================================
    # 15. VALIDATE VISUAL BOUNDS + TYPES + NAVIGATION
    # ========================================================

    $navigationButtonCount =
        0

    $textboxCount =
        0

    $brokenTargets =
        @()

    $fullCanvasVisualCount =
        0

    foreach ($visualFile in $finalVisualFiles) {

        $visualObject =
            Get-Content `
                $visualFile.FullName `
                -Raw |
            ConvertFrom-Json

        Assert-VisualInsideCanvas `
            -Visual $visualObject `
            -Path $visualFile.FullName


        $visualType =
            [string]$visualObject.visual.visualType


        if (
            $visualType -eq
            "actionButton"
        ) {

            $navigationButtonCount++

            $links =
                @(
                    $visualObject.visual.visualContainerObjects.visualLink
                )

            if ($links.Count -ne 1) {

                throw (
                    "Invalid visualLink count: " +
                    $visualFile.FullName
                )
            }

            $rawTarget =
                [string]$links[0].properties.navigationSection.expr.Literal.Value

            $targetPageId =
                $rawTarget.Trim("'")

            if (
                $pageIds -notcontains
                $targetPageId
            ) {

                $brokenTargets +=
                    $targetPageId
            }
        }


        if (
            $visualType -eq
            "textbox"
        ) {

            $textboxCount++
        }


        $visualArea =
            [double]$visualObject.position.width *
            [double]$visualObject.position.height

        $canvasArea =
            [double]$canvasWidth *
            [double]$canvasHeight

        $visualAreaRatio =
            $visualArea /
            $canvasArea

        if ($visualAreaRatio -ge 0.80) {

            $fullCanvasVisualCount++
        }
    }


    if ($navigationButtonCount -ne 12) {

        throw (
            "Expected 12 navigation buttons. Found: " +
            $navigationButtonCount
        )
    }


    if ($textboxCount -ne 14) {

        throw (
            "Expected 14 textboxes. Found: " +
            $textboxCount
        )
    }


    if ($brokenTargets.Count -gt 0) {

        throw (
            "Broken navigation targets: " +
            ($brokenTargets -join ", ")
        )
    }


    # Critical protection against previous-project background bug
    if ($fullCanvasVisualCount -ne 0) {

        throw (
            "Full-canvas selectable visual detected."
        )
    }


    # ========================================================
    # 16. INDEX PAGE VALIDATION
    # ========================================================

    $indexVisualFiles =
        @(
            Get-ChildItem `
                -Path (
                    Join-Path `
                        $indexPageFolder `
                        "visuals"
                ) `
                -Filter "visual.json" `
                -File `
                -Recurse
        )

    if ($indexVisualFiles.Count -ne 14) {

        throw (
            "INDEX must contain 14 visuals. Found: " +
            $indexVisualFiles.Count
        )
    }

    $indexDestinationButtons =
        0

    foreach (
        $indexVisualFile in
        $indexVisualFiles
    ) {

        $indexVisualObject =
            Get-Content `
                $indexVisualFile.FullName `
                -Raw |
            ConvertFrom-Json

        if (
            $indexVisualObject.visual.visualType -eq
            "actionButton"
        ) {

            $indexDestinationButtons++
        }
    }

    if ($indexDestinationButtons -ne 6) {

        throw (
            "INDEX must contain 6 destination buttons."
        )
    }


    # ========================================================
    # 17. PAGES.JSON VALIDATION
    # ========================================================

    $pagesCheck =
        Get-Content `
            $pagesFile `
            -Raw |
        ConvertFrom-Json

    if (
        @($pagesCheck.pageOrder).Count -ne
        7
    ) {

        throw (
            "pages.json must contain exactly 7 page-order entries."
        )
    }

    if (
        [string]$pagesCheck.activePageName -ne
        $indexPageId
    ) {

        throw (
            "INDEX is not configured as the opening page."
        )
    }


    # ========================================================
    # 18. GIT STATUS
    # NO COMMIT BEFORE DESKTOP RENDER VALIDATION
    # ========================================================

    $gitStatus =
        @(git status --short)


    # ========================================================
    # 19. RESULT
    # ========================================================

@"
CP13-B RESULT

INDEX PAGE BUILD:
PASS - PENDING POWER BI DESKTOP VALIDATION

============================================================
REPORT STRUCTURE
============================================================

Pages:
7 / 7

Opening page:
INDEX

Canvas:
1600 x 900

Display mode:
FitToPage

Native page backgrounds:
$nativeBackgroundCount / 7

Full-canvas selectable background visuals:
$fullCanvasVisualCount

============================================================
INDEX
============================================================

INDEX visuals:
$($indexVisualFiles.Count)

Destination buttons:
$indexDestinationButtons / 6

Navigation targets:
6 / 6 VALID

Tooltip pattern:
Press Ctrl + Click to go to [Page Name]

INDEX title:
Healthcare Data Governance & Quality Control Center

============================================================
ANALYTICAL PAGE SHELLS
============================================================

Executive Overview:
CREATED

Data Quality Overview:
CREATED

Coding Quality:
CREATED

Service & Payment Patterns:
CREATED

Demographic & Provider Mix:
CREATED

Quality Issues Monitor:
CREATED

Each analytical page currently contains:
- centered page title
- INDEX button
- native page background
- NO analytical charts
- NO KPI visuals
- NO slicers yet

============================================================
PBIR STATIC VALIDATION
============================================================

JSON files invalid:
$($invalidJson.Count)

Navigation buttons:
$navigationButtonCount

Textboxes:
$textboxCount

Broken navigation targets:
$($brokenTargets.Count)

Visuals outside canvas:
0

============================================================
GIT
============================================================

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

============================================================

NEXT:
Assistant review of this output.

DO NOT open Power BI until the output is reviewed.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-B completed successfully."
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

    # ========================================================
    # SAFE REPORT ROLLBACK
    # ========================================================

    try {

        git restore -- `
            "powerbi/HealthcareGovernanceQC.Report/definition/pages"

        git clean -fd -- `
            "powerbi/HealthcareGovernanceQC.Report/definition/pages"
    }
    catch {
    }

@"
CP13-B RESULT

INDEX PAGE BUILD:
FAIL

ERROR:
$($_.Exception.Message)

REPORT CHANGES:
ROLLED BACK TO LAST GIT COMMIT

Git commit:
NOT PERFORMED

NEXT:
STOP - Review this output before opening Power BI.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8

    Write-Host ""
    Write-Host "CP13-B failed."
    Write-Host "Output: $out"
    Write-Host ""
}