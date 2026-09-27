# CHANGELOG

## 2026-09-27 - CP1 Source Discovery

- Source fingerprint validated.
- Deep profiling completed.
- Source-document conflicts identified.
- CP1 baseline documented.

## CP2 - Data Contract, Metadata & Classification

- Data Contract created and validated.
- Data Classification created.
- Data Dictionary created.
- Source SHA-256 revalidated.
- Header contract validated.
- Raw data remained unchanged.

## CP3 - Governance-by-Design

- Governance Control Register created.
- 15 governance controls assessed.
- Open controls preserved explicitly.
- No unsupported compliance claims made.
- Raw data remained unchanged.

## CP4 - Data Quality Rule Framework

- 19 governed DQ rules defined across 6 dimensions.
- DQ rules executed against the complete source.
- Result: 16 PASS, 2 WARN, 1 SOURCE_CONFLICT, 0 FAIL.
- Raw data remained unchanged.

## CP5 - Governed SQL Foundation

- Created governed SQL Server database foundation.
- Implemented RAW, STAGING, ANALYTICS and GOVERNANCE schemas.
- Loaded 2,801,660 CMS source profiles.
- Built typed STAGING layer with DQ flags.
- Reconciled 70,052,393 represented line items.
- Validated exact profile uniqueness in SQL.

## CP6 - Reference Data / RDM Assessment

- Assessed eight candidate reference domains.
- RDM confirmed applicable.
- MDM classified as not applicable to the current dataset scope.
- Reference cardinalities reconciled to governed staging data.
- No unsupported code descriptions or mappings were invented.

## CP7 - Canonical Analytical Model

- Built governed star schema.
- Created one canonical fact and eight dimensions.
- Preserved source DQ flags and lineage.
- Validated zero broken foreign keys.
- Reconciled fact totals and dimension cardinalities.

## CP8 - KPI & Metric Contracts

- Created 12 governed KPI/metric contracts.
- Added SQL baseline view analytics.vw_CarrierKPIBaseline.
- Defined weighted service and rounded-payment metrics.
- Defined DQ profile and represented-line metrics.
- Explicitly blocked unsupported time-series and national extrapolation claims.
