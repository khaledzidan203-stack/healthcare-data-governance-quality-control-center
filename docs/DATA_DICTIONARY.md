# DATA DICTIONARY

## Dataset

CMS 2010 BSA Carrier Line Items Public Use File

## Governed Grain

One physical CSV row represents one published analytical profile
across the ten analytical attributes.

`CAR_LINE_CNT` represents the number of underlying carrier line items
associated with that profile.

## Field Metadata

| Field | Business Meaning | Data Role | Expected Type | Nullable / Blank | Classification | Key / Grain Role | Aggregation |
|---|---|---|---|---|---|---|---|
| BENE_SEX_IDENT_CD | Beneficiary sex code | Categorical attribute | Integer-like code | No blanks observed | PUBLIC-DE-IDENTIFIED / DEMOGRAPHIC | Profile grain attribute | Do not sum |
| BENE_AGE_CAT_CD | Beneficiary age category | Categorical attribute | Integer-like code | No blanks observed | PUBLIC-DE-IDENTIFIED / DEMOGRAPHIC | Profile grain attribute | Do not sum |
| CAR_LINE_ICD9_DGNS_CD | ICD-9-CM diagnosis classification | Clinical code | Text/code | Blanks exist | PUBLIC-DE-IDENTIFIED / CLINICAL | Profile grain attribute | Do not sum |
| CAR_LINE_HCPCS_CD | HCPCS procedure/service code | Reference code | Text/code | No blanks observed | REFERENCE / CLINICAL SERVICE | Profile grain attribute | Do not sum |
| CAR_LINE_BETOS_CD | BETOS service classification | Reference code | Text/code | No blanks observed | REFERENCE | Profile grain attribute | Do not sum |
| CAR_LINE_SRVC_CNT | Count of services | Numeric measure | Integer-like numeric | No blanks observed | PUBLIC-DE-IDENTIFIED / UTILIZATION | Profile grain attribute | Weighted aggregation required |
| CAR_LINE_PRVDR_TYPE_CD | Provider type code | Reference code | Integer-like code | No blanks observed | REFERENCE | Profile grain attribute | Do not sum |
| CAR_LINE_CMS_TYPE_SRVC_CD | CMS type-of-service code | Reference code | Text/code | No blanks observed | REFERENCE | Profile grain attribute | Do not sum |
| CAR_LINE_PLACE_OF_SRVC_CD | Place-of-service code | Reference code | Integer-like code | No blanks observed | REFERENCE | Profile grain attribute | Do not sum |
| CAR_HCPS_PMT_AMT | Rounded Medicare payment amount | Numeric measure | Numeric | No blanks observed | PUBLIC-DE-IDENTIFIED / FINANCIAL | Profile grain attribute | Use with CAR_LINE_CNT weighting where required |
| CAR_LINE_CNT | Number of represented carrier line items | Weight / count | Positive integer | No blanks observed | PUBLIC-DE-IDENTIFIED / UTILIZATION | Profile weight | Sum allowed |

## Validated Metadata Baseline

| Metadata Item | Validated Value |
|---|---:|
| Physical rows | 2,801,660 |
| Columns | 11 |
| SUM(CAR_LINE_CNT) | 70,052,393 |
| Candidate profile duplicates | 0 |
| HCPCS distinct nonblank | 4,900 |
| BETOS distinct nonblank | 98 |
| Provider type distinct | 6 |
| CMS service type distinct | 20 |
| Place of service distinct | 28 |
| Blank ICD profiles | 502 |
| Blank ICD represented line items | 13,506 |

## Open Metadata Conflicts

- ICD-9 cardinality differs between CMS documentation sources.
- CAR_LINE_CNT total differs in one CMS Data Dictionary statement.
- Age category 6 frequency differs from observed data.
- Service-count documented range differs from observed zero values.

These remain `SOURCE_CONFLICT` until resolved or formally documented.

## Current release clarification

This is the source-field dictionary; the final semantic model is described separately in the [semantic contract](POWER_BI_SEMANTIC_MODEL_CONTRACT.md). Exact preserved documentation conflicts are ICD-9 926 vs 923 and HCPCS 4900 vs 4736; actual ICD members are 925 nonblank plus one blank, and BETOS remains 98. Observed zero-service profiles are 22, representing 59 lines. [Data contract](DATA_CONTRACT.md).
