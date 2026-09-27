$ErrorActionPreference = "Stop"

$root = "D:\analysis_projects\H.C_Data_Governance & Q.C_Center"
$out  = "D:\analysis_projects\output\H.C_Data_Governance & Q.C_Center_output.txt"

$sqlFile = Join-Path $root "sql\11_create_bi_consumption_contract.sql"
$docFile = Join-Path $root "docs\BI_CONSUMPTION_CONTRACT.md"

$server = "localhost"
$db = "HealthcareGovernanceQC"

Set-Location $root

try {

$sql = @'
USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

-- ------------------------------------------------------------
-- BI CONSUMPTION VIEW
-- ------------------------------------------------------------

EXEC(N'
CREATE OR ALTER VIEW analytics.vw_BI_CarrierProfile
AS
SELECT
    CAST(2010 AS smallint) AS ReferenceYear,

    f.ProfileKey,

    sx.SexCode,
    sx.SexLabel,

    ag.AgeCategoryCode,
    ag.AgeCategoryLabel,
    ag.SortOrder AS AgeCategorySortOrder,

    ic.ICD9Code,
    hc.HCPCSCode,
    bt.BETOSCode,
    pr.ProviderTypeCode,
    sv.ServiceTypeCode,
    ps.PlaceOfServiceCode,

    f.ServiceCount,

    f.MedicarePaymentAmount
        AS RoundedMedicarePaymentAmount,

    f.LineItemCount,

    f.IsBlankICD,
    f.IsZeroServiceCount

FROM analytics.FactCarrierProfile f

INNER JOIN analytics.DimSex sx
    ON f.SexKey = sx.SexKey

INNER JOIN analytics.DimAgeCategory ag
    ON f.AgeCategoryKey = ag.AgeCategoryKey

INNER JOIN analytics.DimICD9 ic
    ON f.ICD9Key = ic.ICD9Key

INNER JOIN analytics.DimHCPCS hc
    ON f.HCPCSKey = hc.HCPCSKey

INNER JOIN analytics.DimBETOS bt
    ON f.BETOSKey = bt.BETOSKey

INNER JOIN analytics.DimProviderType pr
    ON f.ProviderTypeKey = pr.ProviderTypeKey

INNER JOIN analytics.DimServiceType sv
    ON f.ServiceTypeKey = sv.ServiceTypeKey

INNER JOIN analytics.DimPlaceOfService ps
    ON f.PlaceOfServiceKey = ps.PlaceOfServiceKey;
');

-- ------------------------------------------------------------
-- VALIDATION
-- ------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS ViewRows,

    COUNT_BIG(DISTINCT ProfileKey)
        AS DistinctProfiles,

    SUM(LineItemCount)
        AS RepresentedLines,

    SUM(
        CASE WHEN IsBlankICD = 1
             THEN 1 ELSE 0 END
    ) AS BlankICDProfiles,

    SUM(
        CASE WHEN IsZeroServiceCount = 1
             THEN 1 ELSE 0 END
    ) AS ZeroServiceProfiles,

    SUM(
        CASE
            WHEN SexCode IS NULL
              OR SexLabel IS NULL
              OR AgeCategoryCode IS NULL
              OR AgeCategoryLabel IS NULL
              OR HCPCSCode IS NULL
              OR BETOSCode IS NULL
              OR ProviderTypeCode IS NULL
              OR ServiceTypeCode IS NULL
              OR PlaceOfServiceCode IS NULL
              OR LineItemCount IS NULL
              OR ServiceCount IS NULL
              OR RoundedMedicarePaymentAmount IS NULL
            THEN 1
            ELSE 0
        END
    ) AS UnexpectedNullRows,

    SUM(
        CASE
            WHEN ICD9Code IS NULL
             AND IsBlankICD = 0
            THEN 1
            ELSE 0
        END
    ) AS UnexpectedICDNullRows

FROM analytics.vw_BI_CarrierProfile;
'@

$sql | Set-Content $sqlFile -Encoding UTF8

$connString = "Server=$server;Database=$db;Integrated Security=True;TrustServerCertificate=True;"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandTimeout = 1200
$cmd.CommandText = $sql

$r = $cmd.ExecuteReader()

if (-not $r.Read()) {
    throw "BI consumption validation returned no result."
}

$rows = [int64]$r["ViewRows"]
$profiles = [int64]$r["DistinctProfiles"]
$lines = [int64]$r["RepresentedLines"]
$blank = [int64]$r["BlankICDProfiles"]
$zero = [int64]$r["ZeroServiceProfiles"]
$nulls = [int64]$r["UnexpectedNullRows"]
$icdNulls = [int64]$r["UnexpectedICDNullRows"]

$r.Close()
$conn.Close()

if ($rows -ne 2801660) {
    throw "BI view row reconciliation failed."
}

if ($profiles -ne 2801660) {
    throw "BI view ProfileKey uniqueness failed."
}

if ($lines -ne 70052393) {
    throw "BI represented line-item reconciliation failed."
}

if ($blank -ne 502) {
    throw "BI blank ICD reconciliation failed."
}

if ($zero -ne 22) {
    throw "BI zero-service reconciliation failed."
}

if ($nulls -ne 0) {
    throw "Unexpected nulls found in governed BI fields."
}

if ($icdNulls -ne 0) {
    throw "Unexpected ICD nulls found outside governed blank population."
}

# ------------------------------------------------------------
# BI CONSUMPTION CONTRACT
# ------------------------------------------------------------

$doc = @"
# BI CONSUMPTION CONTRACT

## Status

PASS

## Published Objects

### Detail Consumption View

analytics.vw_BI_CarrierProfile

### Governed KPI Baseline

analytics.vw_CarrierKPIBaseline

## Grain

One row in analytics.vw_BI_CarrierProfile represents one
unique governed CMS analytical profile.

Validated rows:

$rows

## Primary Key

ProfileKey

Validated distinct ProfileKey values:

$profiles

## Reference Period

2010

The governed source does not contain a valid analytical date
grain below the reference year.

Therefore:

- no fabricated daily date;
- no fabricated monthly date;
- no YoY;
- no MoM;
- no unsupported time intelligence.

## Published Dimensions

- Sex
- Age Category
- ICD-9 Code
- HCPCS Code
- BETOS Code
- Provider Type Code
- CMS Service Type Code
- Place of Service Code

Sex and Age expose governed labels.

Other reference domains expose governed source codes only
unless an authoritative label mapping is added later.

## Published Numeric Fields

### LineItemCount

Meaning:

Represented carrier line-item volume.

Allowed default aggregation:

SUM

Validated baseline:

$lines

### ServiceCount

Meaning:

Service-count value attached to the published analytical profile.

Default aggregation:

DO NOT SUM DIRECTLY.

Use the governed weighted KPI:

SUM(ServiceCount * LineItemCount)

### RoundedMedicarePaymentAmount

Meaning:

CMS rounded Medicare payment amount attached to the profile.

Default aggregation:

DO NOT SUM DIRECTLY.

Use the governed weighted KPI:

SUM(RoundedMedicarePaymentAmount * LineItemCount)

### ProfileKey

Do not SUM.

Use row count / distinct count only.

## Data Quality Flags

- IsBlankICD
- IsZeroServiceCount

Blank ICD profiles:

$blank

Zero-service profiles:

$zero

These flags must remain visible to the semantic model and must
not be silently filtered from the default analytical population.

## KPI Contract

All BI measures must reconcile to KPI_CONTRACT.md.

Current governed KPI baseline:

analytics.vw_CarrierKPIBaseline

The approved SQL baseline and independent Python baseline must
remain the reconciliation references for the semantic model.

## Aggregation Rules

Allowed:

- SUM(LineItemCount)
- COUNT / DISTINCTCOUNT(ProfileKey)
- governed weighted service-unit calculations
- governed weighted rounded-payment calculations
- ratio-of-totals for rates and averages

Not allowed:

- SUM of code fields
- SUM(ServiceCount) as represented service volume
- SUM(RoundedMedicarePaymentAmount) as represented payment
- average of pre-calculated row percentages
- fabricated time aggregations

## Refresh

Current source is a historical 2010 CMS PUF.

BI refresh should occur only after the governed SQL pipeline
has completed successfully.

No independent BI-side transformation should duplicate core
RAW/STAGING/ANALYTICS business logic.

## Security / Classification

BI inherits the approved project data-classification and
governance controls.

The consumption layer must not weaken SQL permissions,
classification controls, export restrictions or publication rules.

## KPI Ownership / Authority

Metric definitions:

KPI_CONTRACT.md

Technical governed baseline:

analytics.vw_CarrierKPIBaseline

Named business ownership remains governed by the project's
approved governance-control process.

## Validation

- View rows: $rows
- Distinct ProfileKey: $profiles
- Represented lines: $lines
- Unexpected required-field null rows: $nulls
- Unexpected ICD null rows: $icdNulls
- Blank ICD population preserved: $blank
- Zero-service population preserved: $zero
"@

$doc | Set-Content $docFile -Encoding UTF8

# ------------------------------------------------------------
# VALIDATION / CHANGELOG
# ------------------------------------------------------------

if (-not (Select-String "VALIDATION.md" -Pattern "CP11 - BI Consumption Contract" -Quiet)) {

@"

## CP11 - BI Consumption Contract

Status: PASS

- BI consumption view created.
- Grain validated at 2,801,660 unique profiles.
- Represented line-item baseline reconciled to 70,052,393.
- Required fields validated for unexpected nulls.
- Governed DQ populations preserved.
- Allowed aggregations documented.
- Unsupported time intelligence explicitly prohibited.
- BI KPI baseline linked to the approved SQL/Python validation architecture.
"@ | Add-Content "VALIDATION.md" -Encoding UTF8

}

if (-not (Select-String "CHANGELOG.md" -Pattern "CP11 - BI Consumption Contract" -Quiet)) {

@"

## CP11 - BI Consumption Contract

- Added analytics.vw_BI_CarrierProfile.
- Defined BI grain, key, labels and units.
- Defined allowed and prohibited aggregations.
- Defined refresh and security inheritance rules.
- Preserved DQ flags in the BI consumption layer.
- Documented the 2010 source-grain time-intelligence restriction.
"@ | Add-Content "CHANGELOG.md" -Encoding UTF8

}

# ------------------------------------------------------------
# GIT
# ------------------------------------------------------------

git add "sql\11_create_bi_consumption_contract.sql"
git add "docs\BI_CONSUMPTION_CONTRACT.md"
git add "scripts\checkpoints\CP11_BI_Consumption.ps1"
git add "VALIDATION.md"
git add "CHANGELOG.md"

if ($LASTEXITCODE -ne 0) {
    throw "git add failed."
}

$staged = git diff --cached --name-only

if ($staged) {

    git commit -m "checkpoint: complete CP11 BI consumption contract"

    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed."
    }
}

$commit = (git rev-parse HEAD).Trim()
$status = git status --short

# ------------------------------------------------------------
# OUTPUT
# ------------------------------------------------------------

@"
CP11 RESULT

BI CONSUMPTION CONTRACT:
PASS

Published detail view:
analytics.vw_BI_CarrierProfile

Published KPI baseline:
analytics.vw_CarrierKPIBaseline

View rows:
$rows

Distinct profiles:
$profiles

Represented line items:
$lines

Unexpected required-field null rows:
$nulls

Unexpected ICD null rows:
$icdNulls

Blank ICD profiles preserved:
$blank

Zero-service profiles preserved:
$zero

Reference period:
2010

Fabricated time intelligence:
PROHIBITED

Created:
- sql\11_create_bi_consumption_contract.sql
- docs\BI_CONSUMPTION_CONTRACT.md
- scripts\checkpoints\CP11_BI_Consumption.ps1

Git commit:
$commit

Working tree:
$status

CP11 STATUS:
COMPLETED

NEXT:
CP12 - Semantic Model / Power BI Foundation
"@ | Set-Content $out -Encoding UTF8

Write-Host ""
Write-Host "CP11 COMPLETED"
Write-Host "Output: $out"
Write-Host ""

}
catch {

    if ($conn -and $conn.State -eq "Open") {
        $conn.Close()
    }

@"
CP11 RESULT

BI CONSUMPTION CONTRACT:
FAIL

ERROR:
$($_.Exception.Message)

Git commit:
NOT PERFORMED

NEXT:
Fix CP11 before continuing
"@ | Set-Content $out -Encoding UTF8

Write-Host ""
Write-Host "CP11 FAILED"
Write-Host "Output: $out"
Write-Host ""
}
