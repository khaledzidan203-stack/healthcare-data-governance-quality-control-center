# CHANGELOG

## 2026-09-28 - Repository completion & automation

- Added recruiter-friendly Quick Start instructions to the README.
- Added a fail-safe one-command Windows setup script for a fresh SQL/Python/Power BI environment.
- Added a cross-platform static repository validator covering publication safety, Power BI JSON, report/page counts, semantic-model counts, screenshots, DAX reference counts, and relative Markdown links.
- Added GitHub Actions portfolio validation for every push and pull request.
- Added an automated, validation-gated v1.0.1 release workflow and release notes.
- Preserved all validated SQL, Python, PBIP/PBIR/TMDL, DAX, governance contracts, and report screenshots.

## 2026-09-28 - Public repository cleanup

- Removed obsolete historical checkpoint orchestration scripts from the public portfolio.
- Retained the useful Power BI runtime KPI reconciliation utility under `scripts/validation/` and made its project/output paths configurable.
- Updated README and reproducibility guidance to match the lean public repository layout.
- Preserved SQL, Python, PBIP/PBIR/TMDL, DAX, screenshots, governance contracts, and validation evidence.

## 2026-09-28 - Portfolio release

- Finalized seven-page PBIP portfolio documentation and seven original report screenshots.
- Preserved 10 semantic tables, 12 governed measures and 8 relationships.
- Rechecked static report/model contracts and SELECT-only SQL totals.
- Added reproducibility, case study and release validation evidence.
- Reconciled historical documentation/rate drift and hardened publication exclusions.
- Preserved report/model/DAX/SQL implementations.

## Completed CP13 page checkpoints

| Page | Commit |
|---|---|
| INDEX | 20f0b04 |
| Executive Overview | fd86882 |
| Data Quality Overview | c8cbbfb |
| Coding Quality | 8e72b6e |
| Service & Payment Patterns | a92aae0 |
| Demographic & Provider Mix | 20d561e |
| Quality Issues Monitor | ecfd43f |

Earlier entries below are historical checkpoint records.

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


## CP9 - Python EDA & Independent Validation

- Added independent Python validation against the governed SQL model.
- Recalculated critical KPIs without using the SQL KPI baseline view.
- Reconciled weighted demographic and Data Quality metrics.
- Added reproducible Python validation code.

## CP10 - Data Lineage

- Added governance.DataLineage registry.
- Added source-to-RAW lineage.
- Added RAW-to-STAGING transformation lineage.
- Added analytical dimension/fact lineage.
- Added KPI-level field lineage.
- Validated full source traceability for all governed KPI contracts.

## CP11 - BI Consumption Contract

- Added analytics.vw_BI_CarrierProfile.
- Defined BI grain, key, labels and units.
- Defined allowed and prohibited aggregations.
- Defined refresh and security inheritance rules.
- Preserved DQ flags in the BI consumption layer.
- Documented the 2010 source-grain time-intelligence restriction.

## CP12-B - Semantic Model Foundation

- Added analytics.vw_PBI_FactCarrierProfile.
- Added additive weighted semantic columns.
- Defined eight one-to-many single-direction relationships.
- Added 12 governed DAX measure definitions.
- Defined Power BI storage, summarization and date-model rules.
