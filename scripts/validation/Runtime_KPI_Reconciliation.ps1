$ErrorActionPreference = "Stop"

# ============================================================
# CP12-G2B
# LIVE POWER BI DAX KPI RECONCILIATION
# ============================================================

param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [string]$OutputRoot = (Join-Path (Split-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path -Parent) "output")
)

$root = $ProjectRoot
$out = Join-Path $OutputRoot "H.C_Data_Governance & Q.C_Center_output.txt"
$queryFile = Join-Path $OutputRoot "CP12G2B_Runtime_Query.dax"
$csvFile   = Join-Path $OutputRoot "CP12G2B_Runtime_Result.csv"

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

    $searchRoots = @(
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        "$env:LOCALAPPDATA\Programs"
    )

    foreach ($searchRoot in $searchRoots) {

        if (
            [string]::IsNullOrWhiteSpace($searchRoot) -or
            -not (Test-Path $searchRoot)
        ) {
            continue
        }

        $found = Get-ChildItem `
            -Path $searchRoot `
            -Filter "dscmd.exe" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($found) {
            return $found.FullName
        }
    }

    return $null
}


function Parse-Number {

    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        throw "Runtime KPI returned a blank numeric value."
    }

    $clean = $Text.Trim()

    [double]$value = 0

    $style =
        [System.Globalization.NumberStyles]::Float `
        -bor `
        [System.Globalization.NumberStyles]::AllowThousands

    $invariant =
        [System.Globalization.CultureInfo]::InvariantCulture

    $parsed = [double]::TryParse(
        $clean,
        $style,
        $invariant,
        [ref]$value
    )

    if (-not $parsed) {

        $parsed = [double]::TryParse(
            $clean,
            $style,
            [System.Globalization.CultureInfo]::CurrentCulture,
            [ref]$value
        )
    }

    if (-not $parsed) {
        throw "Cannot parse runtime numeric value: $Text"
    }

    return $value
}


function Format-Number {

    param(
        [double]$Value
    )

    return $Value.ToString(
        "G17",
        [System.Globalization.CultureInfo]::InvariantCulture
    )
}

# ============================================================
# MAIN
# ============================================================

try {

    # ----------------------------------------------------------
    # 1. PREFLIGHT
    # ----------------------------------------------------------

    New-Item `
        -ItemType Directory `
        -Path (Split-Path $out) `
        -Force |
        Out-Null

    $pbiProcesses = @(
        Get-Process PBIDesktop -ErrorAction SilentlyContinue
    )

    if ($pbiProcesses.Count -eq 0) {
        throw "Power BI Desktop is not open. Open HealthcareGovernanceQC.pbip first."
    }

    # ----------------------------------------------------------
    # 2. LOCATE DAX STUDIO CLI
    # ----------------------------------------------------------

    $dscmd = Find-Dscmd

    if ([string]::IsNullOrWhiteSpace($dscmd)) {
        throw "dscmd.exe was not found. DAX Studio CLI is required."
    }

    # ----------------------------------------------------------
    # 3. BUILD GOVERNED DAX QUERY
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

    $utf8 = New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $queryFile,
        $query,
        $utf8
    )

    if (Test-Path $csvFile) {
        Remove-Item $csvFile -Force
    }

    # ----------------------------------------------------------
    # 4. CONNECT DIRECTLY TO THE OPEN PBIP
    #
    # NO PORT DISCOVERY
    # NO msmdsrv.port.txt
    # ----------------------------------------------------------

    $cliOutput = @(
        & $dscmd `
            CSV `
            $csvFile `
            --server $pbipName `
            --file $queryFile `
            2>&1
    )

    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {

        throw (
            "DAX Studio CLI failed. ExitCode=$exitCode | " +
            ($cliOutput -join " | ")
        )
    }

    if (-not (Test-Path $csvFile)) {
        throw "DAX query completed without creating the expected CSV file."
    }

    # ----------------------------------------------------------
    # 5. READ RUNTIME RESULT
    # ----------------------------------------------------------

    $runtimeRows = @(
        Import-Csv $csvFile
    )

    if ($runtimeRows.Count -ne 1) {
        throw "Expected exactly 1 KPI result row. Found: $($runtimeRows.Count)"
    }

    $row = $runtimeRows[0]

    $runtimeValues = @{}

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

        $runtimeValues[$name] = $property.Value
    }

    # ----------------------------------------------------------
    # 6. GOVERNED CP8 BASELINE
    # ----------------------------------------------------------

    [double]$profileCount = 2801660
    [double]$lineItems    = 70052393
    [double]$serviceUnits = 105487211
    [double]$payment      = 3842966475.00

    [double]$blankProfiles = 502
    [double]$blankLines    = 13506

    [double]$zeroProfiles = 22
    [double]$zeroLines    = 59

    $tests = @(

        [pscustomobject]@{
            Name      = "Profile Count"
            Expected  = $profileCount
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Represented Line Items"
            Expected  = $lineItems
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Represented Service Units"
            Expected  = $serviceUnits
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Represented Rounded Medicare Payment"
            Expected  = $payment
            Tolerance = 0.01
        },

        [pscustomobject]@{
            Name      = "Avg Service Units per Represented Line"
            Expected  = ($serviceUnits / $lineItems)
            Tolerance = 0.000000001
        },

        [pscustomobject]@{
            Name      = "Avg Rounded Payment per Represented Line"
            Expected  = ($payment / $lineItems)
            Tolerance = 0.000000001
        },

        [pscustomobject]@{
            Name      = "Blank ICD Profiles"
            Expected  = $blankProfiles
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Blank ICD Represented Lines"
            Expected  = $blankLines
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Blank ICD Line Rate"
            Expected  = ($blankLines / $lineItems)
            Tolerance = 0.000000000001
        },

        [pscustomobject]@{
            Name      = "Zero-Service Profiles"
            Expected  = $zeroProfiles
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Zero-Service Represented Lines"
            Expected  = $zeroLines
            Tolerance = 0
        },

        [pscustomobject]@{
            Name      = "Zero-Service Line Rate"
            Expected  = ($zeroLines / $lineItems)
            Tolerance = 0.000000000001
        }
    )

    # ----------------------------------------------------------
    # 7. RECONCILE 12 / 12
    # ----------------------------------------------------------

    $passCount = 0
    $failCount = 0
    $resultLines = @()

    foreach ($test in $tests) {

        if (-not $runtimeValues.ContainsKey($test.Name)) {
            throw "Runtime result is missing KPI: $($test.Name)"
        }

        $actual = Parse-Number `
            ([string]$runtimeValues[$test.Name])

        $difference = [math]::Abs(
            $actual - [double]$test.Expected
        )

        $passed =
            $difference -le [double]$test.Tolerance

        if ($passed) {

            $status = "PASS"
            $passCount++
        }
        else {

            $status = "FAIL"
            $failCount++
        }

        $resultLines += (
            "{0} | {1} | Expected={2} | Actual={3} | Diff={4}" -f `
            $status,
            $test.Name,
            (Format-Number ([double]$test.Expected)),
            (Format-Number $actual),
            (Format-Number $difference)
        )
    }

    if ($failCount -eq 0) {
        $overall = "PASS"
    }
    else {
        $overall = "FAIL"
    }

    # ----------------------------------------------------------
    # 8. GIT STATE — READ ONLY
    # ----------------------------------------------------------

    $gitStatus = @(
        git status --short
    )

    # ----------------------------------------------------------
    # 9. OUTPUT
    # ----------------------------------------------------------

@"
CP12-G2B RESULT

RUNTIME KPI RECONCILIATION:
$overall

Connection method:
DIRECT OPEN PBIP

Power BI project:
$pbipName

Port discovery used:
NO

DAX Studio CLI:
$dscmd

Governed KPI measures tested:
12

Passed:
$passCount

Failed:
$failCount

============================================================
KPI RESULTS
============================================================

$($resultLines -join "`r`n")

============================================================

Expected CP8 baseline:

Profile Count:
2801660

Represented Line Items:
70052393

Represented Service Units:
105487211

Represented Rounded Medicare Payment:
3842966475.00

Blank ICD:
Profiles = 502
Lines = 13506

Zero Service:
Profiles = 22
Lines = 59

============================================================

PBIP modified:
NO

Semantic model modified:
NO

Git commit:
NOT PERFORMED

Working tree:
$(if ($gitStatus.Count -eq 0) { "CLEAN" } else { $gitStatus -join "`r`n" })

NEXT:
$(if ($overall -eq "PASS") { "Validation complete - review and retain the output as runtime evidence." } else { "STOP - Review runtime KPI mismatch" })
"@ | Set-Content $out -Encoding UTF8

    # ----------------------------------------------------------
    # 10. CLEAN TEMP FILES
    # ----------------------------------------------------------

    Remove-Item `
        $queryFile `
        -Force `
        -ErrorAction SilentlyContinue

    Remove-Item `
        $csvFile `
        -Force `
        -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "CP12-G2B Runtime Reconciliation: $overall"
    Write-Host "Passed: $passCount / 12"
    Write-Host "Output: $out"
    Write-Host ""
}
catch {

    $gitStatus = @(
        git status --short
    )

@"
CP12-G2B RESULT

RUNTIME KPI RECONCILIATION:
FAIL

ERROR:
$($_.Exception.Message)

Connection method:
DIRECT OPEN PBIP

Port discovery used:
NO

PBIP modified:
NO

Semantic model modified:
NO

Git commit:
NOT PERFORMED

Working tree:
$(if ($gitStatus.Count -eq 0) { "CLEAN" } else { $gitStatus -join "`r`n" })

NEXT:
STOP - Review this output before any further Power BI changes.
"@ | Set-Content $out -Encoding UTF8

    Write-Host ""
    Write-Host "CP12-G2B failed."
    Write-Host "Output: $out"
    Write-Host ""
}