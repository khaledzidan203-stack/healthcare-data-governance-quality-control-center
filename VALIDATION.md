# VALIDATION

## Current release evidence

See [FINAL_RELEASE_VALIDATION.md](docs/FINAL_RELEASE_VALIDATION.md) for fresh static and read-only SQL checks, the 7-page/142-visual baseline, and retained runtime evidence. Earlier sections below are HISTORICAL CHECKPOINT results, not unexecuted work.


## CP5 - Governed SQL Foundation

Status: PASS

- RAW rows: 2,801,660
- STAGING rows: 2,801,660
- Represented line items: 70,052,393
- Exact staging profiles: 2,801,660
- Duplicate profiles: 0
- Blank ICD profiles preserved: 502
- Zero-service profiles preserved: 22
- RAW source modified: No
- Governance Source Registry and Load Run tracking implemented.

## CP7 - Canonical Analytical Model

Status: PASS

- Fact rows: 2,801,660
- Represented line items: 70,052,393
- Broken foreign keys: 0
- Blank ICD profiles preserved: 502
- Zero-service profiles preserved: 22
- All dimension cardinalities reconciled.
- Weighted demographic totals reconciled to source baseline.

## CP8 - KPI & Metric Contracts

Status: PASS

- 12 governed metric contracts defined.
- SQL KPI baseline view created.
- Weighted service/payment logic uses LineItemCount.
- Ratio metrics use ratio-of-totals.
- Profile Count and represented line-item volume remain distinct.
- Unsupported time-series metrics explicitly excluded.


## CP9 - Python EDA & Independent Validation

Status: PASS

- Python independently recalculated the governed KPI baseline.
- Profile Count reconciled exactly.
- Represented Line Items reconciled exactly.
- Represented Service Units reconciled exactly.
- Represented Rounded Medicare Payment reconciled exactly.
- DQ counts reconciled exactly.
- Weighted demographic totals reconciled exactly.
- No unsupported time-series, causal or national extrapolation analysis performed.

## CP10 - Data Lineage

Status: PASS

- Governance lineage registry created.
- Total lineage edges: 68.
- Source -> RAW -> STAGING -> ANALYTICS -> KPI documented.
- KPI contracts with full source traceability: 12 / 12.
- Source SHA-256 retained as lineage evidence.

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

## CP12-B - Semantic Model Foundation

Status: PASS

- Power BI semantic fact view created.
- 2,801,660 profiles reconciled.
- 70,052,393 represented line items reconciled.
- 105,487,211 represented service units reconciled.
- 3,842,966,475.00 represented rounded Medicare payment reconciled.
- Eight-dimension star-schema contract defined.
- Twelve governed DAX measures prepared.
- Import mode selected.
- No fabricated Date table permitted.
