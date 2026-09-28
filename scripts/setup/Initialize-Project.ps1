[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [switch]$SkipPythonValidation,
    [switch]$OpenPowerBI
)

$ErrorActionPreference = "Stop"

$DatabaseName = "HealthcareGovernanceQC"
$SqlServer = "localhost"
$ExpectedSourceHash = "923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6"

$SqlDir = Join-Path $ProjectRoot "sql"
$SourceCsv = Join-Path $ProjectRoot "data\2010_BSA_Carrier_PUF.csv"
$Requirements = Join-Path $ProjectRoot "requirements.txt"
$PythonValidation = Join-Path $ProjectRoot "python\eda\cp9_python_validation.py"
$Pbip = Join-Path $ProjectRoot "powerbi\HealthcareGovernanceQC.pbip"
$VenvDir = Join-Path $ProjectRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

function Assert-Command {
    param([Parameter(Mandatory=$true)][string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "Required command not found: $Name"
    }

    return $command.Source
}

function Invoke-SqlFile {
    param(
        [Parameter(Mandatory=$true)][string]$SqlcmdPath,
        [Parameter(Mandatory=$true)][string]$Path
    )

    Write-Host ("Running SQL: " + (Split-Path $Path -Leaf))
    & $SqlcmdPath -S $SqlServer -E -C -b -r 1 -i $Path

    if ($LASTEXITCODE -ne 0) {
        throw "SQL execution failed: $Path"
    }
}

Write-Host ""
Write-Host "Healthcare Data Governance & Quality Control Center"
Write-Host "Fresh-environment setup"
Write-Host "=================================================="
Write-Host ""

if (-not (Test-Path $ProjectRoot -PathType Container)) {
    throw "Project root not found: $ProjectRoot"
}

if (-not (Test-Path $SourceCsv -PathType Leaf)) {
    throw @"
Required CMS source CSV was not found:

$SourceCsv

Download the official 2010 CMS BSA Carrier Line Items PUF and place the CSV at that exact path.
See docs\REPRODUCIBILITY.md for the official source link and source-governance notes.
"@
}

$actualHash = (Get-FileHash -Path $SourceCsv -Algorithm SHA256).Hash.ToLowerInvariant()

if ($actualHash -ne $ExpectedSourceHash) {
    throw "Source SHA-256 mismatch. Expected=$ExpectedSourceHash Actual=$actualHash"
}

Write-Host "PASS | Source SHA-256 verified"

$sqlcmd = Assert-Command -Name "sqlcmd"
$python = Assert-Command -Name "python"

Write-Host "PASS | sqlcmd found"
Write-Host "PASS | Python found"

$dbCheck = @(
    & $sqlcmd -S $SqlServer -E -C -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN DB_ID(N'$DatabaseName') IS NULL THEN 'MISSING' ELSE 'EXISTS' END;" 2>&1
)

if ($LASTEXITCODE -ne 0) {
    throw ("Cannot connect to SQL Server at localhost using Windows authentication. " + ($dbCheck -join " | "))
}

$dbState = $dbCheck |
    ForEach-Object { $_.ToString().Trim() } |
    Where-Object { $_ -in @("MISSING", "EXISTS") } |
    Select-Object -Last 1

if ($dbState -ne "MISSING") {
    throw @"
Safety stop: database [$DatabaseName] already exists.

This setup script is intentionally for a fresh environment and will not overwrite,
drop, rebuild, or mutate an existing validated database automatically.
Use a fresh SQL Server instance or remove/rename the existing database manually
only after you have intentionally backed it up.
"@
}

Write-Host "PASS | Fresh database boundary confirmed"

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("HealthcareGovernanceQC_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    $sql02 = Join-Path $SqlDir "02_load_raw_carrier.sql"
    $sql02Text = Get-Content $sql02 -Raw -Encoding UTF8

    $pattern = "FROM\s+'[^']*2010_BSA_Carrier_PUF\.csv'"
    $regex = [regex]::new(
        $pattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    $matchCount = $regex.Matches($sql02Text).Count

    if ($matchCount -ne 1) {
        throw "Expected exactly one governed CSV path in SQL 02. Found: $matchCount"
    }

    $escapedCsv = $SourceCsv.Replace("'", "''")
    $patchedSql02 = $regex.Replace(
        $sql02Text,
        "FROM '$escapedCsv'",
        1
    )

    $tempSql02 = Join-Path $tempDir "02_load_raw_carrier.sql"
    [System.IO.File]::WriteAllText(
        $tempSql02,
        $patchedSql02,
        (New-Object System.Text.UTF8Encoding($true))
    )

    for ($i = 1; $i -le 12; $i++) {
        $prefix = "{0:D2}_" -f $i
        $matches = @(
            Get-ChildItem -Path $SqlDir -File -Filter ($prefix + "*.sql")
        )

        if ($matches.Count -ne 1) {
            throw "Expected exactly one SQL script for step $i. Found: $($matches.Count)"
        }

        $sqlPath = $matches[0].FullName

        if ($i -eq 2) {
            $sqlPath = $tempSql02
        }

        Invoke-SqlFile -SqlcmdPath $sqlcmd -Path $sqlPath
    }

    Write-Host "PASS | SQL scripts 01-12 completed"

    $reconcileQuery = @"
USE [$DatabaseName];
SET NOCOUNT ON;

DECLARE @Profiles bigint;
DECLARE @Lines bigint;
DECLARE @Units bigint;
DECLARE @Payment decimal(38,2);
DECLARE @BlankProfiles bigint;
DECLARE @BlankLines bigint;
DECLARE @ZeroProfiles bigint;
DECLARE @ZeroLines bigint;

SELECT
    @Profiles = COUNT_BIG(*),
    @Lines = SUM(LineItemCount),
    @Units = SUM(CONVERT(bigint, ServiceCount) * LineItemCount),
    @Payment = SUM(CONVERT(decimal(38,2), MedicarePaymentAmount * LineItemCount)),
    @BlankProfiles = SUM(CASE WHEN IsBlankICD = 1 THEN 1 ELSE 0 END),
    @BlankLines = SUM(CASE WHEN IsBlankICD = 1 THEN LineItemCount ELSE 0 END),
    @ZeroProfiles = SUM(CASE WHEN IsZeroServiceCount = 1 THEN 1 ELSE 0 END),
    @ZeroLines = SUM(CASE WHEN IsZeroServiceCount = 1 THEN LineItemCount ELSE 0 END)
FROM analytics.FactCarrierProfile;

IF @Profiles <> 2801660 THROW 52001, 'Profile Count mismatch.', 1;
IF @Lines <> 70052393 THROW 52002, 'Represented Line Items mismatch.', 1;
IF @Units <> 105487211 THROW 52003, 'Represented Service Units mismatch.', 1;
IF @Payment <> CAST(3842966475.00 AS decimal(38,2)) THROW 52004, 'Represented Payment mismatch.', 1;
IF @BlankProfiles <> 502 THROW 52005, 'Blank ICD Profile mismatch.', 1;
IF @BlankLines <> 13506 THROW 52006, 'Blank ICD Line mismatch.', 1;
IF @ZeroProfiles <> 22 THROW 52007, 'Zero-Service Profile mismatch.', 1;
IF @ZeroLines <> 59 THROW 52008, 'Zero-Service Line mismatch.', 1;

SELECT 'PASS' AS CoreReconciliation;
"@

    $sqlValidation = @(
        & $sqlcmd -S $SqlServer -E -C -b -r 1 -Q $reconcileQuery 2>&1
    )

    if ($LASTEXITCODE -ne 0) {
        throw ("Core SQL reconciliation failed. " + ($sqlValidation -join " | "))
    }

    if (-not (($sqlValidation -join [Environment]::NewLine) -match "PASS")) {
        throw "Core SQL reconciliation did not return PASS."
    }

    Write-Host "PASS | Core SQL totals reconciled"

    if (-not $SkipPythonValidation) {
        if (-not (Test-Path $VenvPython -PathType Leaf)) {
            Write-Host "Creating Python virtual environment..."
            & $python -m venv $VenvDir

            if ($LASTEXITCODE -ne 0) {
                throw "Python virtual environment creation failed."
            }
        }

        Write-Host "Installing Python requirements..."
        & $VenvPython -m pip install --disable-pip-version-check -r $Requirements

        if ($LASTEXITCODE -ne 0) {
            throw "Python dependency installation failed."
        }

        Write-Host "Running independent Python reconciliation..."
        $pythonOutput = @(
            & $VenvPython $PythonValidation 2>&1
        )

        if ($LASTEXITCODE -ne 0) {
            throw ("Python validation failed. " + ($pythonOutput -join " | "))
        }

        $joined = $pythonOutput -join [Environment]::NewLine
        $requiredPythonEvidence = @(
            "Profile Count: 2801660",
            "Represented Line Items: 70052393",
            "Represented Service Units: 105487211",
            "Represented Rounded Medicare Payment: 3842966475.00",
            "Blank ICD Profiles: 502",
            "Blank ICD Lines: 13506",
            "Zero-Service Profiles: 22",
            "Zero-Service Lines: 59"
        )

        foreach ($expectedLine in $requiredPythonEvidence) {
            if ($joined -notmatch [regex]::Escape($expectedLine)) {
                throw "Python reconciliation missing expected evidence: $expectedLine"
            }
        }

        $pythonOutput | ForEach-Object { Write-Host $_ }
        Write-Host "PASS | Independent Python reconciliation"
    }
    else {
        Write-Host "SKIP | Independent Python reconciliation explicitly skipped"
    }

    if (-not (Test-Path $Pbip -PathType Leaf)) {
        throw "Power BI project file not found: $Pbip"
    }

    Write-Host ""
    Write-Host "SETUP RESULT: PASS"
    Write-Host "Database: $DatabaseName"
    Write-Host "Power BI project: $Pbip"
    Write-Host ""

    if ($OpenPowerBI) {
        Write-Host "Opening Power BI project..."
        Start-Process $Pbip
    }
    else {
        Write-Host "Next: open powerbi\HealthcareGovernanceQC.pbip in Power BI Desktop and refresh."
    }
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
