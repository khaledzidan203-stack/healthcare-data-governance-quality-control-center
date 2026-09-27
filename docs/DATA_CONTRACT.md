# DATA CONTRACT ? CMS 2010 BSA Carrier Line Items PUF

## Dataset

CMS 2010 Basic Stand Alone (BSA) Carrier Line Items Public Use File

## Current Governed Grain

One physical CSV row represents one published analytical profile
across the ten analytical attributes.

`CAR_LINE_CNT` represents the number of underlying carrier line items
associated with that profile.

Status: PROVISIONAL ? exact relational uniqueness will be revalidated later.

## Columns

| Column | Business Meaning | Role | Governed Notes |
|---|---|---|---|
| BENE_SEX_IDENT_CD | Beneficiary sex | Categorical code | CMS documented values: 1=Male, 2=Female |
| BENE_AGE_CAT_CD | Beneficiary age category | Categorical code | Six CMS categories coded 1?6 |
| CAR_LINE_ICD9_DGNS_CD | ICD-9-CM diagnosis classification | Clinical code | Coarsened for privacy; blanks exist and must be preserved pending investigation |
| CAR_LINE_HCPCS_CD | HCPCS procedure/service code | Reference code | CMS documented 4,900 observed values |
| CAR_LINE_BETOS_CD | BETOS service classification | Reference code | CMS documented 98 observed values |
| CAR_LINE_SRVC_CNT | Count of services associated with profile/line-item attributes | Numeric measure | Actual source range includes 0?999; source documentation contains a range inconsistency |
| CAR_LINE_PRVDR_TYPE_CD | Provider type code | Reference code | CMS documented 6 observed values |
| CAR_LINE_CMS_TYPE_SRVC_CD | CMS type-of-service code | Reference code | CMS documented 20 observed values |
| CAR_LINE_PLACE_OF_SRVC_CD | Place-of-service code | Reference code | CMS documented 28 observed values |
| CAR_HCPS_PMT_AMT | Rounded Medicare payment amount | Numeric measure | CMS rounding rules apply |
| CAR_LINE_CNT | Number of carrier line items represented by the profile | Weight / count | SUM reconciles to 70,052,393 line items |

## Source Constraints

- Data is historical 2010 CMS public-use data.
- Source is privacy-protected / de-identified.
- Beneficiary identities are not available.
- Claims cannot be reconstructed or linked by beneficiary.
- Line items cannot be linked back to the same claim.
- Cross-PUF beneficiary linkage is not supported.
- No Patient 360 reconstruction is allowed.

## Open Source Conflicts

1. ICD-9 cardinality differs across CMS documentation.
2. Data Dictionary CAR_LINE_CNT total conflicts with actual data and General Documentation.
3. Age category 6 frequency contains a documentation inconsistency.
4. Service-count documented range conflicts with observed zero values.

These remain recorded as `SOURCE_CONFLICT`.
