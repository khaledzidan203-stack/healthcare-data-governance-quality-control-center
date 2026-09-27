USE [HealthcareGovernanceQC];

SET NOCOUNT ON;

WITH StagingProfiles AS
(
    SELECT
        BENE_SEX_IDENT_CD,
        BENE_AGE_CAT_CD,
        CAR_LINE_ICD9_DGNS_CD,
        CAR_LINE_HCPCS_CD,
        CAR_LINE_BETOS_CD,
        CAR_LINE_SRVC_CNT,
        CAR_LINE_PRVDR_TYPE_CD,
        CAR_LINE_CMS_TYPE_SRVC_CD,
        CAR_LINE_PLACE_OF_SRVC_CD,
        CAR_HCPS_PMT_AMT
    FROM staging.CarrierLineItems
    GROUP BY
        BENE_SEX_IDENT_CD,
        BENE_AGE_CAT_CD,
        CAR_LINE_ICD9_DGNS_CD,
        CAR_LINE_HCPCS_CD,
        CAR_LINE_BETOS_CD,
        CAR_LINE_SRVC_CNT,
        CAR_LINE_PRVDR_TYPE_CD,
        CAR_LINE_CMS_TYPE_SRVC_CD,
        CAR_LINE_PLACE_OF_SRVC_CD,
        CAR_HCPS_PMT_AMT
)
SELECT
    (SELECT COUNT_BIG(*) FROM raw.CarrierLineItems) AS RawRows,
    (SELECT COUNT_BIG(*) FROM staging.CarrierLineItems) AS StagingRows,

    (SELECT SUM(TRY_CONVERT(bigint,CAR_LINE_CNT))
     FROM raw.CarrierLineItems) AS RawLines,

    (SELECT SUM(CAR_LINE_CNT)
     FROM staging.CarrierLineItems) AS StagingLines,

    (SELECT COUNT_BIG(*)
     FROM StagingProfiles) AS DistinctStagingProfiles,

    (SELECT COUNT_BIG(*)
     FROM staging.CarrierLineItems)
     -
    (SELECT COUNT_BIG(*)
     FROM StagingProfiles) AS DuplicateExtraRows,

    (SELECT SUM(CASE WHEN IsBlankICD = 1 THEN 1 ELSE 0 END)
     FROM staging.CarrierLineItems) AS BlankICDProfiles,

    (SELECT SUM(CASE WHEN IsZeroServiceCount = 1 THEN 1 ELSE 0 END)
     FROM staging.CarrierLineItems) AS ZeroServiceProfiles,

    (SELECT COUNT(*)
     FROM governance.SourceRegistry) AS SourceRegistryRows,

    (SELECT COUNT(*)
     FROM governance.LoadRun
     WHERE RunStatus = 'SUCCESS') AS SuccessfulRuns;
