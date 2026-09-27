USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

SELECT 'Sex' AS DomainName,
       COUNT(DISTINCT BENE_SEX_IDENT_CD) AS DistinctValues
FROM staging.CarrierLineItems

UNION ALL

SELECT 'Age Category',
       COUNT(DISTINCT BENE_AGE_CAT_CD)
FROM staging.CarrierLineItems

UNION ALL

SELECT 'ICD-9',
       COUNT(DISTINCT CAR_LINE_ICD9_DGNS_CD)
FROM staging.CarrierLineItems
WHERE CAR_LINE_ICD9_DGNS_CD IS NOT NULL

UNION ALL

SELECT 'HCPCS',
       COUNT(DISTINCT CAR_LINE_HCPCS_CD)
FROM staging.CarrierLineItems

UNION ALL

SELECT 'BETOS',
       COUNT(DISTINCT CAR_LINE_BETOS_CD)
FROM staging.CarrierLineItems

UNION ALL

SELECT 'Provider Type',
       COUNT(DISTINCT CAR_LINE_PRVDR_TYPE_CD)
FROM staging.CarrierLineItems

UNION ALL

SELECT 'CMS Type of Service',
       COUNT(DISTINCT CAR_LINE_CMS_TYPE_SRVC_CD)
FROM staging.CarrierLineItems

UNION ALL

SELECT 'Place of Service',
       COUNT(DISTINCT CAR_LINE_PLACE_OF_SRVC_CD)
FROM staging.CarrierLineItems;
