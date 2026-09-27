USE [HealthcareGovernanceQC];

SET NOCOUNT ON;

DECLARE @Rows bigint;
DECLARE @DistinctProfiles bigint;
DECLARE @LineTotal bigint;

DECLARE @ServiceParseFailures bigint;
DECLARE @PaymentParseFailures bigint;
DECLARE @LineCountParseFailures bigint;

SELECT
    @Rows = COUNT_BIG(*),

    @LineTotal =
        SUM(TRY_CONVERT(bigint, NULLIF(LTRIM(RTRIM(CAR_LINE_CNT)), ''))),

    @ServiceParseFailures =
        SUM(CASE
            WHEN TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(CAR_LINE_SRVC_CNT)), '')) IS NULL
            THEN 1 ELSE 0 END),

    @PaymentParseFailures =
        SUM(CASE
            WHEN TRY_CONVERT(decimal(18,2), NULLIF(LTRIM(RTRIM(CAR_HCPS_PMT_AMT)), '')) IS NULL
            THEN 1 ELSE 0 END),

    @LineCountParseFailures =
        SUM(CASE
            WHEN TRY_CONVERT(bigint, NULLIF(LTRIM(RTRIM(CAR_LINE_CNT)), '')) IS NULL
            THEN 1 ELSE 0 END)

FROM raw.CarrierLineItems;

SELECT
    @DistinctProfiles = COUNT_BIG(*)
FROM
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
    FROM raw.CarrierLineItems
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
) P;

SELECT
    @Rows AS PhysicalRows,
    @DistinctProfiles AS DistinctProfiles,
    (@Rows - @DistinctProfiles) AS DuplicateExtraRows,
    @LineTotal AS RepresentedLines,
    @ServiceParseFailures AS ServiceParseFailures,
    @PaymentParseFailures AS PaymentParseFailures,
    @LineCountParseFailures AS LineCountParseFailures,

    SUM(CASE WHEN BENE_SEX_IDENT_CD = '1'
        THEN TRY_CONVERT(bigint, CAR_LINE_CNT) ELSE 0 END) AS MaleWeightedLines,

    SUM(CASE WHEN BENE_SEX_IDENT_CD = '2'
        THEN TRY_CONVERT(bigint, CAR_LINE_CNT) ELSE 0 END) AS FemaleWeightedLines,

    SUM(CASE WHEN BENE_AGE_CAT_CD = '6'
        THEN TRY_CONVERT(bigint, CAR_LINE_CNT) ELSE 0 END) AS Age85PlusWeightedLines

FROM raw.CarrierLineItems;
