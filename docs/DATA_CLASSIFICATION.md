# DATA CLASSIFICATION

## Dataset Classification

**PUBLIC - DE-IDENTIFIED HEALTHCARE DATA**

## Approved Use

- Data Governance portfolio work
- Data Quality assessment
- Metadata management
- Analytical engineering
- BI / reporting
- Reproducible public portfolio documentation

## Restricted / Prohibited Use

- Re-identification attempts
- Beneficiary reconstruction
- Claim reconstruction
- Patient 360
- Unsupported cross-PUF linkage
- Linking to external data for identification

## Field-Level Classification

| Column | Classification |
|---|---|
| BENE_SEX_IDENT_CD | PUBLIC-DE-IDENTIFIED / DEMOGRAPHIC |
| BENE_AGE_CAT_CD | PUBLIC-DE-IDENTIFIED / DEMOGRAPHIC |
| CAR_LINE_ICD9_DGNS_CD | PUBLIC-DE-IDENTIFIED / CLINICAL |
| CAR_LINE_HCPCS_CD | REFERENCE / CLINICAL SERVICE |
| CAR_LINE_BETOS_CD | REFERENCE |
| CAR_LINE_SRVC_CNT | PUBLIC-DE-IDENTIFIED / UTILIZATION |
| CAR_LINE_PRVDR_TYPE_CD | REFERENCE |
| CAR_LINE_CMS_TYPE_SRVC_CD | REFERENCE |
| CAR_LINE_PLACE_OF_SRVC_CD | REFERENCE |
| CAR_HCPS_PMT_AMT | PUBLIC-DE-IDENTIFIED / FINANCIAL |
| CAR_LINE_CNT | PUBLIC-DE-IDENTIFIED / UTILIZATION |

## Governance Rule

De-identification does not mean zero privacy risk.

Classification must remain attached to derived datasets throughout
RAW -> STAGING -> ANALYTICAL -> BI.
