$ErrorActionPreference = "Stop"

# ================================================================
# CP13-C FINAL2
# EXECUTIVE OVERVIEW — COMPLETE CLEAN REBUILD
#
# FIXES:
# - Rebuild from committed report-page baseline
# - Preserve Desktop-created semantic UX columns
# - Human-readable labels
# - Age governed sorting
# - Correct PBIR visualHeader ARRAY
# - Header Icons: ON + Transparency 100%
# - Magnitude gradients
# - Centered KPI values
# - No patching of existing Executive visuals
#
# NO GIT COMMIT
# ================================================================


# ================================================================
# 1. PATHS
# ================================================================

$root =
    "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"

$out =
    "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$reportRoot =
    Join-Path $root `
        "powerbi\HealthcareGovernanceQC.Report"

$pagesRoot =
    Join-Path $reportRoot `
        "definition\pages"

$pageRoot =
    Join-Path $pagesRoot `
        "p_exec_overview"

$pageFile =
    Join-Path $pageRoot `
        "page.json"

$visualsRoot =
    Join-Path $pageRoot `
        "visuals"

$tablesRoot =
    Join-Path $root `
        "powerbi\HealthcareGovernanceQC.SemanticModel\definition\tables"

$ageFile =
    Join-Path $tablesRoot `
        "DimAgeCategory.tmdl"

$providerFile =
    Join-Path $tablesRoot `
        "DimProviderType.tmdl"

$serviceFile =
    Join-Path $tablesRoot `
        "DimServiceType.tmdl"

$posFile =
    Join-Path $tablesRoot `
        "DimPlaceOfService.tmdl"

Set-Location $root


# ================================================================
# 2. SCHEMA / CANVAS
# ================================================================

$schema =
"https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.9.0/schema.json"

$canvasW = 1600
$canvasH = 900


# ================================================================
# 3. DESIGN SYSTEM
# ================================================================

$White       = "#FFFFFF"
$Navy        = "#173B63"

$Indigo      = "#506CF0"
$IndigoLight = "#DDE4FF"

$Teal        = "#1E9E96"

$Amber       = "#C98A2E"
$AmberLight  = "#F7E6C5"

$QualityRed  = "#C65D5D"

$Dark        = "#3C4B63"

$Text        = "#22324A"
$Secondary   = "#6B7A90"
$Border      = "#D9E2EC"

$HeaderIcon  = "#333333"


# ================================================================
# 4. BASIC HELPERS
# ================================================================

function Lit {

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


function Solid {

    param(
        [string]$Color
    )

    return @{
        solid = @{
            color = (
                Lit "'$Color'"
            )
        }
    }
}


function Write-Json {

    param(
        [string]$Path,
        [object]$Object
    )

    $json =
        $Object |
        ConvertTo-Json -Depth 100

    # Local syntax validation
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


function Write-Visual {

    param(
        [object]$Visual
    )

    $visualFolder =
        Join-Path `
            $visualsRoot `
            ([string]$Visual.name)

    New-Item `
        -ItemType Directory `
        -Path $visualFolder `
        -Force |
        Out-Null

    Write-Json `
        -Path (
            Join-Path `
                $visualFolder `
                "visual.json"
        ) `
        -Object $Visual
}


# ================================================================
# 5. SEMANTIC PROJECTIONS
# ================================================================

function MeasureProjection {

    param(
        [string]$Measure
    )

    return @{
        field = @{
            Measure = @{
                Expression = @{
                    SourceRef = @{
                        Entity = "_Measures"
                    }
                }

                Property =
                    $Measure
            }
        }

        queryRef =
            "_Measures.$Measure"

        nativeQueryRef =
            $Measure
    }
}


function ColumnProjection {

    param(
        [string]$Table,
        [string]$Column,
        [bool]$Active = $false
    )

    $result = @{
        field = @{
            Column = @{
                Expression = @{
                    SourceRef = @{
                        Entity = $Table
                    }
                }

                Property =
                    $Column
            }
        }

        queryRef =
            "$Table.$Column"

        nativeQueryRef =
            $Column
    }

    if ($Active) {

        $result["active"] =
            $true
    }

    return $result
}


# ================================================================
# 6. COMMON CONTAINER
#
# IMPORTANT:
# visualHeader is created HERE as an explicit ARRAY.
#
# Header icons rule:
# - Header icons ON
# - Background WHITE
# - Border WHITE
# - Icon DARK
# - Transparency 100%
# ================================================================

function New-CommonContainer {

    param(
        [bool]$WithVisualHeader = $true
    )

    $container = @{

        background = @(
            @{
                properties = @{
                    show =
                        Lit "true"

                    color =
                        Solid $White

                    transparency =
                        Lit "0D"
                }
            }
        )

        border = @(
            @{
                properties = @{
                    show =
                        Lit "true"

                    color =
                        Solid $Border

                    radius =
                        Lit "8D"
                }
            }
        )

        padding = @(
            @{
                properties = @{
                    top =
                        Lit "6D"

                    bottom =
                        Lit "6D"

                    left =
                        Lit "6D"

                    right =
                        Lit "6D"
                }
            }
        )
    }


    if ($WithVisualHeader) {

        # DO NOT replace this with a function return.
        # PBIR requires visualHeader to serialize as ARRAY.
        $container["visualHeader"] = @(
            @{
                properties = @{
                    show =
                        Lit "true"

                    background =
                        Solid $White

                    border =
                        Solid $White

                    foreground =
                        Solid $HeaderIcon

                    transparency =
                        Lit "100D"
                }
            }
        )
    }

    return $container
}


# ================================================================
# 7. TEXT BOX
# ================================================================

function New-Textbox {

    param(
        [string]$Name,

        [double]$X,
        [double]$Y,

        [double]$W,
        [double]$H,

        [double]$Z,
        [double]$Tab,

        [string]$Value,

        [string]$Size,
        [string]$Color,

        [string]$Background = ""
    )

    $vco = @{

        border = @(
            @{
                properties = @{
                    show =
                        Lit "false"
                }
            }
        )

        padding = @(
            @{
                properties = @{
                    top =
                        Lit "0D"

                    bottom =
                        Lit "0D"

                    left =
                        Lit "0D"

                    right =
                        Lit "0D"
                }
            }
        )
    }


    if (
        [string]::IsNullOrWhiteSpace(
            $Background
        )
    ) {

        $vco["background"] = @(
            @{
                properties = @{
                    show =
                        Lit "false"
                }
            }
        )
    }
    else {

        $vco["background"] = @(
            @{
                properties = @{
                    show =
                        Lit "true"

                    color =
                        Solid $Background

                    transparency =
                        Lit "0D"
                }
            }
        )
    }


    return [ordered]@{

        '$schema' =
            $schema

        name =
            $Name

        position = @{
            x =
                $X

            y =
                $Y

            z =
                $Z

            width =
                $W

            height =
                $H

            tabOrder =
                $Tab
        }

        visual = @{

            visualType =
                "textbox"

            objects = @{

                general = @(
                    @{
                        properties = @{

                            paragraphs = @(
                                @{
                                    textRuns = @(
                                        @{
                                            value =
                                                $Value

                                            textStyle = @{
                                                fontFamily =
                                                    "Segoe UI"

                                                fontSize =
                                                    $Size

                                                color =
                                                    $Color
                                            }
                                        }
                                    )

                                    horizontalTextAlignment =
                                        "center"
                                }
                            )
                        }
                    }
                )
            }

            visualContainerObjects =
                $vco
        }
    }
}


# ================================================================
# 8. INDEX BUTTON
# ================================================================

function New-IndexButton {

    param(
        [string]$TargetPage
    )

    return [ordered]@{

        '$schema' =
            $schema

        name =
            "exec_index_button"

        position = @{
            x =
                1390

            y =
                38

            z =
                100

            width =
                150

            height =
                50

            tabOrder =
                2
        }

        visual = @{

            visualType =
                "actionButton"

            objects = @{

                text = @(

                    @{
                        properties = @{
                            show =
                                Lit "true"
                        }
                    },

                    @{
                        properties = @{
                            text =
                                Lit "'INDEX'"

                            fontSize =
                                Lit "12D"

                            fontColor =
                                Solid $White

                            horizontalAlignment =
                                Lit "'center'"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )

                icon = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }
                    }
                )

                fill = @(

                    @{
                        properties = @{
                            show =
                                Lit "true"
                        }
                    },

                    @{
                        properties = @{
                            fillColor =
                                Solid $Indigo
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    },

                    @{
                        properties = @{
                            fillColor =
                                Solid $Navy
                        }

                        selector = @{
                            id =
                                "hover"
                        }
                    }
                )

                outline = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }
                    }
                )

                shape = @(
                    @{
                        properties = @{
                            tileShape =
                                Lit "'rectangleRounded'"

                            roundEdge =
                                Lit "10L"
                        }
                    }
                )
            }

            visualContainerObjects = @{

                background = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }
                    }
                )

                border = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }
                    }
                )

                visualLink = @(
                    @{
                        properties = @{
                            show =
                                Lit "true"

                            type =
                                Lit "'PageNavigation'"

                            navigationSection =
                                Lit "'$TargetPage'"

                            tooltip =
                                Lit "'Press Ctrl + Click to go to INDEX'"
                        }
                    }
                )
            }

            drillFilterOtherVisuals =
                $true
        }
    }
}


# ================================================================
# 9. SLICER
# ================================================================

function New-Slicer {

    param(
        [string]$Name,
        [double]$X,

        [double]$Z,
        [double]$Tab,

        [string]$Table,
        [string]$Column,

        [string]$Title
    )

    $vco =
        New-CommonContainer `
            -WithVisualHeader $true

    $vco["subTitle"] = @(
        @{
            properties = @{
                show =
                    Lit "false"
            }
        }
    )


    return [ordered]@{

        '$schema' =
            $schema

        name =
            $Name

        position = @{
            x =
                $X

            y =
                125

            z =
                $Z

            width =
                335

            height =
                72

            tabOrder =
                $Tab
        }

        visual = @{

            visualType =
                "slicer"

            query = @{
                queryState = @{
                    Values = @{
                        projections = @(
                            (
                                ColumnProjection `
                                    -Table $Table `
                                    -Column $Column
                            )
                        )
                    }
                }
            }

            objects = @{

                data = @(
                    @{
                        properties = @{
                            mode =
                                Lit "'Dropdown'"
                        }
                    }
                )

                header = @(
                    @{
                        properties = @{
                            show =
                                Lit "true"

                            text =
                                Lit "'$Title'"
                        }
                    }
                )
            }

            visualContainerObjects =
                $vco

            drillFilterOtherVisuals =
                $true
        }
    }
}


# ================================================================
# 10. KPI CARD
# ================================================================

function New-KpiCard {

    param(
        [string]$Name,

        [double]$X,
        [double]$Y,

        [double]$W,
        [double]$H,

        [double]$Z,
        [double]$Tab,

        [string]$Measure,
        [string]$Title,

        [string]$Accent,

        [double]$Units,
        [int]$Precision
    )

    $vco =
        New-CommonContainer `
            -WithVisualHeader $true


    $vco["title"] = @(
        @{
            properties = @{
                show =
                    Lit "true"

                text =
                    Lit "'$Title'"

                fontSize =
                    Lit "10D"

                fontColor =
                    Solid $White

                background =
                    Solid $Accent

                alignment =
                    Lit "'center'"
            }
        }
    )


    $vco["subTitle"] = @(
        @{
            properties = @{
                show =
                    Lit "false"
            }
        }
    )


    return [ordered]@{

        '$schema' =
            $schema

        name =
            $Name

        position = @{
            x =
                $X

            y =
                $Y

            z =
                $Z

            width =
                $W

            height =
                $H

            tabOrder =
                $Tab
        }

        visual = @{

            visualType =
                "cardVisual"

            query = @{
                queryState = @{
                    Data = @{
                        projections = @(
                            (
                                MeasureProjection `
                                    -Measure $Measure
                            )
                        )
                    }
                }
            }

            objects = @{

                value = @(
                    @{
                        properties = @{
                            fontSize =
                                Lit "24D"

                            fontColor =
                                Solid $Accent

                            horizontalAlignment =
                                Lit "'center'"

                            labelDisplayUnits =
                                Lit "$($Units)D"

                            labelPrecision =
                                Lit "$($Precision)L"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )

                label = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )

                accentBar = @(
                    @{
                        properties = @{
                            show =
                                Lit "false"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )

                padding = @(
                    @{
                        properties = @{
                            paddingUniform =
                                Lit "4D"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )

                layout = @(
                    @{
                        properties = @{
                            paddingUniform =
                                Lit "0D"

                            alignment =
                                Lit "'center'"

                            verticalAlignment =
                                Lit "'Middle'"
                        }

                        selector = @{
                            id =
                                "default"
                        }
                    }
                )
            }

            visualContainerObjects =
                $vco
        }
    }
}


# ================================================================
# 11. GRADIENT
# ================================================================

function New-Gradient {

    param(
        [string]$Measure,
        [string]$MinColor,
        [string]$MaxColor
    )

    return @{
        properties = @{
            fill = @{
                solid = @{
                    color = @{
                        expr = @{
                            FillRule = @{

                                Input = @{
                                    Measure = @{
                                        Expression = @{
                                            SourceRef = @{
                                                Entity =
                                                    "_Measures"
                                            }
                                        }

                                        Property =
                                            $Measure
                                    }
                                }

                                FillRule = @{
                                    linearGradient2 = @{

                                        min = @{
                                            color = @{
                                                Literal = @{
                                                    Value =
                                                        "'$MinColor'"
                                                }
                                            }
                                        }

                                        max = @{
                                            color = @{
                                                Literal = @{
                                                    Value =
                                                        "'$MaxColor'"
                                                }
                                            }
                                        }

                                        nullColoringStrategy = @{
                                            strategy = @{
                                                Literal = @{
                                                    Value =
                                                        "'noColor'"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        selector = @{
            data = @(
                @{
                    dataViewWildcard = @{
                        matchingOption =
                            1
                    }
                }
            )
        }
    }
}


# ================================================================
# 12. CHART
# ================================================================

function New-Chart {

    param(
        [string]$Name,
        [string]$Type,

        [double]$X,
        [double]$W,

        [double]$Z,
        [double]$Tab,

        [string]$CategoryTable,
        [string]$CategoryColumn,

        [string]$Measure,
        [string]$Title,

        [string]$TitleColor,

        [string]$GradientMin,
        [string]$GradientMax,

        [string]$SortMode,
        [string]$SortProperty,

        [double]$Units,
        [int]$Precision
    )

    $query = @{

        queryState = @{

            Category = @{
                projections = @(
                    (
                        ColumnProjection `
                            -Table $CategoryTable `
                            -Column $CategoryColumn `
                            -Active $true
                    )
                )
            }

            Y = @{
                projections = @(
                    (
                        MeasureProjection `
                            -Measure $Measure
                    )
                )
            }
        }
    }


    if ($SortMode -eq "Column") {

        $query["sortDefinition"] = @{
            sort = @(
                @{
                    field = @{
                        Column = @{
                            Expression = @{
                                SourceRef = @{
                                    Entity =
                                        $CategoryTable
                                }
                            }

                            Property =
                                $SortProperty
                        }
                    }

                    direction =
                        "Ascending"
                }
            )

            isDefaultSort =
                $true
        }
    }


    if ($SortMode -eq "Measure") {

        $query["sortDefinition"] = @{
            sort = @(
                @{
                    field = @{
                        Measure = @{
                            Expression = @{
                                SourceRef = @{
                                    Entity =
                                        "_Measures"
                                }
                            }

                            Property =
                                $SortProperty
                        }
                    }

                    direction =
                        "Descending"
                }
            )

            isDefaultSort =
                $true
        }
    }


    $vco =
        New-CommonContainer `
            -WithVisualHeader $true


    $vco["title"] = @(
        @{
            properties = @{
                show =
                    Lit "true"

                text =
                    Lit "'$Title'"

                fontSize =
                    Lit "11D"

                fontColor =
                    Solid $White

                background =
                    Solid $TitleColor

                alignment =
                    Lit "'center'"
            }
        }
    )


    $vco["subTitle"] = @(
        @{
            properties = @{
                show =
                    Lit "false"
            }
        }
    )


    return [ordered]@{

        '$schema' =
            $schema

        name =
            $Name

        position = @{
            x =
                $X

            y =
                330

            z =
                $Z

            width =
                $W

            height =
                310

            tabOrder =
                $Tab
        }

        visual = @{

            visualType =
                $Type

            query =
                $query

            objects = @{

                categoryAxis = @(
                    @{
                        properties = @{
                            show =
                                Lit "true"

                            showAxisTitle =
                                Lit "false"

                            fontSize =
                                Lit "9D"

                            labelColor =
                                Solid $Secondary
                        }
                    }
                )

                valueAxis = @(
                    @{
                        properties = @{
                            show =
                                Lit "true"

                            showAxisTitle =
                                Lit "false"

                            labelDisplayUnits =
                                Lit "$($Units)D"

                            labelPrecision =
                                Lit "$($Precision)L"

                            gridlineStyle =
                                Lit "'dotted'"

                            gridlineColor =
                                Solid $Border
                        }
                    }
                )

                labels = @(
                    @{
                        properties = @{
                            show =
                                Lit "true"

                            fontSize =
                                Lit "9D"

                            color =
                                Solid $Text

                            labelDisplayUnits =
                                Lit "$($Units)D"

                            labelPrecision =
                                Lit "$($Precision)L"
                        }
                    }
                )

                dataPoint = @(
                    (
                        New-Gradient `
                            -Measure $Measure `
                            -MinColor $GradientMin `
                            -MaxColor $GradientMax
                    )
                )
            }

            visualContainerObjects =
                $vco

            drillFilterOtherVisuals =
                $true
        }
    }
}


# ================================================================
# 13. BINDING VALIDATOR
# ================================================================

function Test-Binding {

    param(
        [array]$VisualFiles,
        [string]$Entity,
        [string]$Property
    )

    foreach ($file in $VisualFiles) {

        $visual =
            Get-Content `
                $file.FullName `
                -Raw |
            ConvertFrom-Json

        $compact =
            $visual |
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
            $compact -match $entityPattern -and
            $compact -match $propertyPattern
        ) {

            return $true
        }
    }

    return $false
}


# ================================================================
# MAIN
# ================================================================

try {

    # ------------------------------------------------------------
    # A. PREFLIGHT
    # ------------------------------------------------------------

    if (
        Get-Process PBIDesktop -ErrorAction SilentlyContinue
    ) {

        throw "Power BI Desktop is still open."
    }


    foreach ($file in @(
        $pageFile,
        $ageFile,
        $providerFile,
        $serviceFile,
        $posFile
    )) {

        if (-not (Test-Path $file)) {
            throw "Required file missing: $file"
        }
    }


    # ------------------------------------------------------------
    # B. VERIFY SEMANTIC UX CREATED IN DESKTOP
    # ------------------------------------------------------------

    $ageText =
        Get-Content `
            $ageFile `
            -Raw `
            -Encoding UTF8

    $providerText =
        Get-Content `
            $providerFile `
            -Raw `
            -Encoding UTF8

    $serviceText =
        Get-Content `
            $serviceFile `
            -Raw `
            -Encoding UTF8

    $posText =
        Get-Content `
            $posFile `
            -Raw `
            -Encoding UTF8


    if (
        $ageText -notmatch
        "(?m)^\s*sortByColumn:\s*'?SortOrder'?\s*$"
    ) {

        throw "AgeCategoryLabel SortOrder metadata not found."
    }


    if (
        $providerText -notmatch
        "(?m)^\s*column\s+ProviderTypeLabel\s*="
    ) {

        throw "ProviderTypeLabel not found."
    }


    if (
        $serviceText -notmatch
        "(?m)^\s*column\s+ServiceTypeLabel\s*="
    ) {

        throw "ServiceTypeLabel not found."
    }


    if (
        $posText -notmatch
        "(?m)^\s*column\s+PlaceOfServiceLabel\s*="
    ) {

        throw "PlaceOfServiceLabel not found."
    }


    # ------------------------------------------------------------
    # C. FIND INDEX PAGE
    # ------------------------------------------------------------

    $indexFile =
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


    if (-not $indexFile) {
        throw "INDEX page not found."
    }


    $indexPage =
        Get-Content `
            $indexFile.FullName `
            -Raw |
        ConvertFrom-Json


    $indexPageId =
        [string]$indexPage.name


    # ------------------------------------------------------------
    # D. CLEAN EXECUTIVE PAGE TO COMMITTED BASELINE
    # ------------------------------------------------------------

    git restore `
        --source=HEAD `
        -- `
        "powerbi/HealthcareGovernanceQC.Report/definition/pages/p_exec_overview"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not restore Executive page baseline."
    }


    git clean `
        -fd `
        -- `
        "powerbi/HealthcareGovernanceQC.Report/definition/pages/p_exec_overview"


    # Remove every visual from the baseline.
    if (Test-Path $visualsRoot) {

        Remove-Item `
            $visualsRoot `
            -Recurse `
            -Force
    }


    New-Item `
        -ItemType Directory `
        -Path $visualsRoot `
        -Force |
        Out-Null


    # ------------------------------------------------------------
    # E. HEADER
    # ------------------------------------------------------------

    Write-Visual (
        New-Textbox `
            -Name "exec_header_title" `
            -X 210 `
            -Y 28 `
            -W 1160 `
            -H 50 `
            -Z 10 `
            -Tab 0 `
            -Value "Executive Overview" `
            -Size "28px" `
            -Color $White `
            -Background $Navy
    )


    Write-Visual (
        New-Textbox `
            -Name "exec_header_subtitle" `
            -X 210 `
            -Y 78 `
            -W 1160 `
            -H 25 `
            -Z 11 `
            -Tab 1 `
            -Value "CMS 2010 Carrier PUF  •  Scale → Utilization → Payment → Data Quality" `
            -Size "12px" `
            -Color $White `
            -Background $Navy
    )


    Write-Visual (
        New-IndexButton `
            -TargetPage $indexPageId
    )


    # ------------------------------------------------------------
    # F. HUMAN-READABLE SLICERS
    # ------------------------------------------------------------

    Write-Visual (
        New-Slicer `
            -Name "exec_slicer_age" `
            -X 60 `
            -Z 20 `
            -Tab 10 `
            -Table "DimAgeCategory" `
            -Column "AgeCategoryLabel" `
            -Title "Age Category"
    )


    Write-Visual (
        New-Slicer `
            -Name "exec_slicer_provider" `
            -X 435 `
            -Z 21 `
            -Tab 11 `
            -Table "DimProviderType" `
            -Column "ProviderTypeLabel" `
            -Title "Provider Type"
    )


    Write-Visual (
        New-Slicer `
            -Name "exec_slicer_service" `
            -X 810 `
            -Z 22 `
            -Tab 12 `
            -Table "DimServiceType" `
            -Column "ServiceTypeLabel" `
            -Title "Service Type"
    )


    Write-Visual (
        New-Slicer `
            -Name "exec_slicer_pos" `
            -X 1185 `
            -Z 23 `
            -Tab 13 `
            -Table "DimPlaceOfService" `
            -Column "PlaceOfServiceLabel" `
            -Title "Place of Service"
    )


    # ------------------------------------------------------------
    # G. CORE KPIs
    # ------------------------------------------------------------

    Write-Visual (
        New-KpiCard `
            -Name "exec_kpi_profiles" `
            -X 60 -Y 210 `
            -W 350 -H 100 `
            -Z 30 -Tab 20 `
            -Measure "Profile Count" `
            -Title "PUBLISHED PROFILES" `
            -Accent $Navy `
            -Units 1000000 `
            -Precision 2
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_kpi_lines" `
            -X 435 -Y 210 `
            -W 350 -H 100 `
            -Z 31 -Tab 21 `
            -Measure "Represented Line Items" `
            -Title "REPRESENTED LINE ITEMS" `
            -Accent $Indigo `
            -Units 1000000 `
            -Precision 2
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_kpi_units" `
            -X 810 -Y 210 `
            -W 350 -H 100 `
            -Z 32 -Tab 22 `
            -Measure "Represented Service Units" `
            -Title "REPRESENTED SERVICE UNITS" `
            -Accent $Teal `
            -Units 1000000 `
            -Precision 2
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_kpi_payment" `
            -X 1185 -Y 210 `
            -W 350 -H 100 `
            -Z 33 -Tab 23 `
            -Measure "Represented Rounded Medicare Payment" `
            -Title "REPRESENTED ROUNDED MEDICARE PAYMENT" `
            -Accent $Amber `
            -Units 1000000000 `
            -Precision 2
    )


    # ------------------------------------------------------------
    # H. STORY CHARTS
    # ------------------------------------------------------------

    Write-Visual (
        New-Chart `
            -Name "exec_chart_age_lines" `
            -Type "clusteredColumnChart" `
            -X 60 `
            -W 745 `
            -Z 40 `
            -Tab 30 `
            -CategoryTable "DimAgeCategory" `
            -CategoryColumn "AgeCategoryLabel" `
            -Measure "Represented Line Items" `
            -Title "REPRESENTED LINE ITEMS BY AGE CATEGORY" `
            -TitleColor $Indigo `
            -GradientMin $IndigoLight `
            -GradientMax $Indigo `
            -SortMode "Column" `
            -SortProperty "SortOrder" `
            -Units 1000000 `
            -Precision 1
    )


    Write-Visual (
        New-Chart `
            -Name "exec_chart_provider_payment" `
            -Type "barChart" `
            -X 830 `
            -W 705 `
            -Z 41 `
            -Tab 31 `
            -CategoryTable "DimProviderType" `
            -CategoryColumn "ProviderTypeLabel" `
            -Measure "Represented Rounded Medicare Payment" `
            -Title "REPRESENTED ROUNDED MEDICARE PAYMENT BY PROVIDER TYPE" `
            -TitleColor $Amber `
            -GradientMin $AmberLight `
            -GradientMax $Amber `
            -SortMode "Measure" `
            -SortProperty "Represented Rounded Medicare Payment" `
            -Units 1000000000 `
            -Precision 2
    )


    # ------------------------------------------------------------
    # I. QUALITY SIGNALS
    # ------------------------------------------------------------

    Write-Visual (
        New-Textbox `
            -Name "exec_quality_header" `
            -X 60 `
            -Y 668 `
            -W 1475 `
            -H 32 `
            -Z 50 `
            -Tab 40 `
            -Value "DATA QUALITY SIGNALS — RATE + AFFECTED VOLUME" `
            -Size "12px" `
            -Color $White `
            -Background $Dark
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_quality_blank_rate" `
            -X 60 -Y 712 `
            -W 350 -H 100 `
            -Z 51 -Tab 41 `
            -Measure "Blank ICD Line Rate" `
            -Title "BLANK ICD LINE RATE" `
            -Accent $QualityRed `
            -Units 0 `
            -Precision 4
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_quality_blank_lines" `
            -X 435 -Y 712 `
            -W 350 -H 100 `
            -Z 52 -Tab 42 `
            -Measure "Blank ICD Represented Lines" `
            -Title "BLANK ICD REPRESENTED LINES" `
            -Accent $QualityRed `
            -Units 1000 `
            -Precision 1
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_quality_zero_rate" `
            -X 810 -Y 712 `
            -W 350 -H 100 `
            -Z 53 -Tab 43 `
            -Measure "Zero-Service Line Rate" `
            -Title "ZERO-SERVICE LINE RATE" `
            -Accent $Amber `
            -Units 0 `
            -Precision 6
    )


    Write-Visual (
        New-KpiCard `
            -Name "exec_quality_zero_lines" `
            -X 1185 -Y 712 `
            -W 350 -H 100 `
            -Z 54 -Tab 44 `
            -Measure "Zero-Service Represented Lines" `
            -Title "ZERO-SERVICE REPRESENTED LINES" `
            -Accent $Amber `
            -Units 0 `
            -Precision 0
    )


    # ------------------------------------------------------------
    # J. LOAD GENERATED VISUALS
    # ------------------------------------------------------------

    $files = @(
        Get-ChildItem `
            -Path $visualsRoot `
            -Filter "visual.json" `
            -File `
            -Recurse
    )


    if ($files.Count -ne 18) {

        throw (
            "Expected 18 visuals. Found: " +
            $files.Count
        )
    }


    # ------------------------------------------------------------
    # K. STRUCTURAL VALIDATION
    # ------------------------------------------------------------

    $invalid =
        0

    $outside =
        0

    $fullPage =
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

    $headerTransparency =
        0


    foreach ($file in $files) {

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


        $p =
            $v.position


        if (
            $p.x -lt 0 -or
            $p.y -lt 0 -or
            ($p.x + $p.width) -gt $canvasW -or
            ($p.y + $p.height) -gt $canvasH
        ) {

            $outside++
        }


        $ratio =
            (
                [double]$p.width *
                [double]$p.height
            ) /
            (
                $canvasW *
                $canvasH
            )


        if ($ratio -ge 0.80) {

            $fullPage++
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


        # Analytical visuals only:
        if (
            $type -eq "slicer" -or
            $type -eq "cardVisual" -or
            $type -eq "clusteredColumnChart" -or
            $type -eq "barChart"
        ) {

            # Critical schema check:
            # visualHeader MUST begin with [
            if (
                $raw -match
                '"visualHeader"\s*:\s*\['
            ) {

                $headerArrays++
            }
            else {

                throw (
                    "visualHeader is not an ARRAY: " +
                    $file.FullName
                )
            }


            $header =
                @(
                    $v.visual.visualContainerObjects.visualHeader
                )


            if ($header.Count -ne 1) {

                throw (
                    "Expected one visualHeader formatting instance: " +
                    $file.FullName
                )
            }


            $transparency =
                [string]$header[0].properties.transparency.expr.Literal.Value


            if ($transparency -eq "100D") {

                $headerTransparency++
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
        throw "Invalid JSON detected."
    }

    if ($outside -ne 0) {
        throw "Visual outside canvas detected."
    }

    if ($fullPage -ne 0) {
        throw "Full-page selectable visual detected."
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

        throw (
            "Expected 14 valid visualHeader arrays. Found: " +
            $headerArrays
        )
    }

    if ($headerTransparency -ne 14) {

        throw (
            "Expected Header Transparency 100% on 14 visuals. Found: " +
            $headerTransparency
        )
    }


    # ------------------------------------------------------------
    # L. BINDING VALIDATION
    # ------------------------------------------------------------

    $requiredBindings = @(

        @{
            Entity = "DimAgeCategory"
            Property = "AgeCategoryLabel"
        },

        @{
            Entity = "DimProviderType"
            Property = "ProviderTypeLabel"
        },

        @{
            Entity = "DimServiceType"
            Property = "ServiceTypeLabel"
        },

        @{
            Entity = "DimPlaceOfService"
            Property = "PlaceOfServiceLabel"
        },

        @{
            Entity = "_Measures"
            Property = "Profile Count"
        },

        @{
            Entity = "_Measures"
            Property = "Represented Line Items"
        },

        @{
            Entity = "_Measures"
            Property = "Represented Service Units"
        },

        @{
            Entity = "_Measures"
            Property = "Represented Rounded Medicare Payment"
        },

        @{
            Entity = "_Measures"
            Property = "Blank ICD Line Rate"
        },

        @{
            Entity = "_Measures"
            Property = "Blank ICD Represented Lines"
        },

        @{
            Entity = "_Measures"
            Property = "Zero-Service Line Rate"
        },

        @{
            Entity = "_Measures"
            Property = "Zero-Service Represented Lines"
        }
    )


    $missing =
        @()


    foreach ($binding in $requiredBindings) {

        $found =
            Test-Binding `
                -VisualFiles $files `
                -Entity $binding.Entity `
                -Property $binding.Property


        if (-not $found) {

            $missing += (
                $binding.Entity +
                "." +
                $binding.Property
            )
        }
    }


    if ($missing.Count -gt 0) {

        throw (
            "Missing binding(s): " +
            ($missing -join ", ")
        )
    }


    # ------------------------------------------------------------
    # M. AGE SORT QUERY CHECK
    # ------------------------------------------------------------

    $ageChartPath =
        Join-Path `
            $visualsRoot `
            "exec_chart_age_lines\visual.json"


    $ageChart =
        Get-Content `
            $ageChartPath `
            -Raw |
        ConvertFrom-Json


    $ageSort =
        $ageChart.visual.query.sortDefinition.sort[0].field.Column


    if (
        [string]$ageSort.Expression.SourceRef.Entity -ne
        "DimAgeCategory"
    ) {

        throw "Age chart sort table incorrect."
    }


    if (
        [string]$ageSort.Property -ne
        "SortOrder"
    ) {

        throw "Age chart is not sorted by SortOrder."
    }


    # ------------------------------------------------------------
    # N. FINAL OUTPUT
    # ------------------------------------------------------------

    $gitStatus =
        @(git status --short)


@"
CP13-C FINAL2 RESULT

EXECUTIVE OVERVIEW:
PASS - READY FOR POWER BI DESKTOP REVIEW

================================================================
REBUILD
================================================================

Patch:
NO

Previous invalid Executive visuals:
REMOVED

Executive visual layer rebuilt from zero:
YES

Semantic UX preserved:
YES

================================================================
HUMAN-READABLE UX
================================================================

Age Category:
AgeCategoryLabel

Provider Type:
ProviderTypeLabel

Service Type:
ServiceTypeLabel

Place of Service:
PlaceOfServiceLabel

Age sort:
SortOrder

================================================================
HEADER ICONS
================================================================

Header icons:
ON

Background:
WHITE

Border:
WHITE

Icon:
DARK

Transparency:
100%

PBIR visualHeader arrays:
$headerArrays / 14

Transparency validated:
$headerTransparency / 14

================================================================
PAGE CONTENT
================================================================

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

Total visuals:
$($files.Count) / 18

================================================================
VALIDATION
================================================================

Invalid JSON:
$invalid

Missing semantic bindings:
$($missing.Count)

Visuals outside canvas:
$outside

Full-page selectable visuals:
$fullPage

Age SortOrder binding:
PASS

visualHeader schema type:
ARRAY

================================================================
GIT
================================================================

Git commit:
NOT PERFORMED

Working tree:
$($gitStatus -join "`r`n")

================================================================

NEXT:

Assistant review.

DO NOT OPEN POWER BI UNTIL THIS OUTPUT IS REVIEWED.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8


    Write-Host ""
    Write-Host "CP13-C FINAL2: PASS"
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

@"
CP13-C FINAL2 RESULT

STATUS:
FAIL

ERROR:
$($_.Exception.Message)

AUTOMATIC ROLLBACK:
NO

GIT COMMIT:
NOT PERFORMED

NEXT:
Upload this output before opening Power BI.
"@ |
        Set-Content `
            $out `
            -Encoding UTF8


    Write-Host ""
    Write-Host "CP13-C FINAL2: FAIL"
    Write-Host "Output: $out"
    Write-Host ""
}