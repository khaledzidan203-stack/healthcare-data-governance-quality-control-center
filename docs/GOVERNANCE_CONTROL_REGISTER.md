# GOVERNANCE CONTROL REGISTER

## Project

Healthcare Data Governance & Quality Control Center

## Governance-by-Design Gate

| ID | Control Area | Current State | Evidence / Decision | Status |
|---|---|---|---|---|
| GOV-01 | Purpose / Decision | Defined | Build a governed, quality-controlled healthcare analytics environment using CMS public-use data | PASS |
| GOV-02 | Source Authority | Defined | CMS is the authoritative external publisher of the source dataset | PASS |
| GOV-03 | Approved Use | Defined | Governance, Data Quality, analytics engineering, BI and public portfolio demonstration | PASS |
| GOV-04 | Classification | Defined | PUBLIC - DE-IDENTIFIED HEALTHCARE DATA | PASS |
| GOV-05 | Privacy Scope | Defined | No re-identification, Patient 360, claim reconstruction or unsupported linkage | PASS |
| GOV-06 | Access / IAM | Formal project IAM not required yet for local public-data development | Reassess if deployment, shared environments or restricted sources are introduced | OPEN |
| GOV-07 | Lifecycle / Retention | Not yet formally defined | Raw source retention, generated evidence retention and destruction policy still required | OPEN |
| GOV-08 | Metadata | Data Contract, Data Dictionary and Classification created | Current metadata baseline established | PASS |
| GOV-09 | Lineage | Source fingerprints and source-to-field metadata exist | Full transformation lineage begins when ingestion/transformation starts | OPEN |
| GOV-10 | Master Data | No legitimate master entity currently identified | Do not introduce MDM unless later evidence justifies it | NOT_APPLICABLE |
| GOV-11 | Reference Data | HCPCS, BETOS, provider type, service type and place-of-service are reference-data candidates | Formal RDM structures deferred until relational design | OPEN |
| GOV-12 | Data Quality | Source profiling completed and findings registered | Formal six-dimension rules and thresholds will be defined in the DQ checkpoint | OPEN |
| GOV-13 | Security / CIA | Public de-identified source; raw data excluded from Git | Formal CIA assessment still required before deployment/public release | OPEN |
| GOV-14 | Regulatory / Contractual | No unsupported legal/compliance requirement asserted | Applicability must be verified before any compliance claim | NOT_VERIFIED |
| GOV-15 | Validation Evidence | CP1 and CP2 validated and committed to Git | Reconciliation, metadata and source integrity evidence exists | PASS |

## Current Gate Decision

The project may continue to controlled design work.

Open governance controls must remain visible and must be resolved
before they become relevant to implementation or release.

## Rules

- Do not silently convert OPEN controls to PASS.
- Do not claim HIPAA or other regulatory compliance without verified applicability.
- Public/de-identified data does not mean zero privacy risk.
- Classification and privacy rules must survive downstream transformations.
- Reference and master data controls must be evidence-driven.
- All material transformations must later have lineage evidence.

## Release clarification

The original control table is a HISTORICAL CHECKPOINT. Later lineage, RDM and DQ implementation evidence exists in the repository, but OPEN retention/security/deployment controls are not automatically closed. This local public-data portfolio release excludes raw data/caches and makes no regulatory certification claim. Shared deployment requires a separate control review. See [final release validation](FINAL_RELEASE_VALIDATION.md).
