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

2801660

## Primary Key

ProfileKey

Validated distinct ProfileKey values:

2801660

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

70052393

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

502

Zero-service profiles:

22

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

- View rows: 2801660
- Distinct ProfileKey: 2801660
- Represented lines: 70052393
- Unexpected required-field null rows: 0
- Unexpected ICD null rows: 0
- Blank ICD population preserved: 502
- Zero-service population preserved: 22

## Release clarification

The codes-only description applies to the SQL consumption contract. The final Power BI semantic layer also contains provider, service and place-of-service calculated labels. SQL logic was not changed for release. See [final release validation](FINAL_RELEASE_VALIDATION.md).
