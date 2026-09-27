# DATA QUALITY RULE REGISTER

## Framework

Dimensions used:

- Completeness
- Validity
- Uniqueness
- Consistency
- Timeliness
- Accuracy

## Rules

| Rule_ID | Dimension | Field / Scope | Rule | Threshold | Severity | Failure Action | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| DQ-001 | Completeness | Dataset | Source file must exist and match approved fingerprint | 100% match | Critical | Stop pipeline | Data Steward | ACTIVE |
| DQ-002 | Completeness | CSV structure | Expected 11 columns must be present | Exactly 11 | Critical | Stop pipeline | Data Steward | ACTIVE |
| DQ-003 | Completeness | CAR_LINE_ICD9_DGNS_CD | Measure and report blanks; do not delete automatically | Observed baseline only | Warning | Investigate and classify | Data Steward | ACTIVE |
| DQ-004 | Validity | BENE_SEX_IDENT_CD | Allowed codes must be 1 or 2 | 100% valid | High | Quarantine invalid rows | Data Steward | ACTIVE |
| DQ-005 | Validity | BENE_AGE_CAT_CD | Allowed codes must be 1 through 6 | 100% valid | High | Quarantine invalid rows | Data Steward | ACTIVE |
| DQ-006 | Validity | CAR_LINE_SRVC_CNT | Must be numeric integer and within observed/documented supported range | Review 0?999 | High | Flag exceptions; do not silently fix | Data Steward | ACTIVE |
| DQ-007 | Validity | CAR_LINE_CNT | Must be positive integer | > 0 | Critical | Stop affected load | Data Engineer | ACTIVE |
| DQ-008 | Validity | CAR_HCPS_PMT_AMT | Must conform to CMS payment rounding pattern | 100% conforming | High | Flag exceptions | Data Steward | ACTIVE |
| DQ-009 | Uniqueness | Profile grain | Ten analytical attributes should form unique physical profiles | 0 duplicates | Critical | Stop canonical load and investigate | Data Engineer | ACTIVE |
| DQ-010 | Consistency | CAR_LINE_CNT | SUM(CAR_LINE_CNT) must reconcile to approved source baseline | 70,052,393 | Critical | Stop release | Data Steward | ACTIVE |
| DQ-011 | Consistency | HCPCS cardinality | Actual nonblank distinct values compared with CMS documentation | Expected 4,900 | High | Record SOURCE_CONFLICT if mismatch | Data Steward | ACTIVE |
| DQ-012 | Consistency | BETOS cardinality | Actual nonblank distinct values compared with CMS documentation | Expected 98 | High | Record SOURCE_CONFLICT if mismatch | Data Steward | ACTIVE |
| DQ-013 | Consistency | Provider type cardinality | Actual distinct values compared with CMS documentation | Expected 6 | Medium | Investigate mismatch | Data Steward | ACTIVE |
| DQ-014 | Consistency | CMS service type cardinality | Actual distinct values compared with CMS documentation | Expected 20 | Medium | Investigate mismatch | Data Steward | ACTIVE |
| DQ-015 | Consistency | Place-of-service cardinality | Actual distinct values compared with CMS documentation | Expected 28 | Medium | Investigate mismatch | Data Steward | ACTIVE |
| DQ-016 | Consistency | ICD-9 metadata | Preserve conflict between actual data and CMS documentation | No forced reconciliation | Warning | Record SOURCE_CONFLICT | Data Steward | ACTIVE |
| DQ-017 | Timeliness | Dataset | Historical reference year must remain explicitly documented as 2010 | 2010 documented | Medium | Block misleading current-state reporting | Data Owner | ACTIVE |
| DQ-018 | Accuracy | Source identity | Source must reconcile to approved CMS files and fingerprints | 100% fingerprint match | Critical | Stop pipeline | Data Steward | ACTIVE |
| DQ-019 | Accuracy | Published totals | Critical totals must reconcile across source, governed layer and downstream outputs | Exact unless tolerance documented | Critical | Stop release | Data Steward | ACTIVE |

## Status Definitions

- PASS ? rule satisfied
- WARN ? issue requires review but does not automatically block processing
- FAIL ? blocking control failed
- SOURCE_CONFLICT ? source documentation and observed data disagree
- NOT_APPLICABLE ? rule does not apply
- NOT_VERIFIED ? evidence is insufficient

## Governance Rule

Do not invent thresholds when the source or approved business contract does not support one.

Do not delete, impute or normalize anomalous values before their meaning is understood and documented.
