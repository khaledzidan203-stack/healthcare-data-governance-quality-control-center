USE [HealthcareGovernanceQC];
GO

IF OBJECT_ID('raw.CarrierLineItems','U') IS NULL
BEGIN
    CREATE TABLE raw.CarrierLineItems
    (
        BENE_SEX_IDENT_CD            varchar(20) NULL,
        BENE_AGE_CAT_CD              varchar(20) NULL,
        CAR_LINE_ICD9_DGNS_CD        varchar(20) NULL,
        CAR_LINE_HCPCS_CD             varchar(30) NULL,
        CAR_LINE_BETOS_CD             varchar(30) NULL,
        CAR_LINE_SRVC_CNT             varchar(30) NULL,
        CAR_LINE_PRVDR_TYPE_CD        varchar(20) NULL,
        CAR_LINE_CMS_TYPE_SRVC_CD     varchar(20) NULL,
        CAR_LINE_PLACE_OF_SRVC_CD     varchar(20) NULL,
        CAR_HCPS_PMT_AMT              varchar(50) NULL,
        CAR_LINE_CNT                  varchar(50) NULL
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM governance.SourceRegistry
    WHERE SourceSHA256 =
    '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'
)
BEGIN
    INSERT INTO governance.SourceRegistry
    (
        SourceName,
        SourceFileName,
        SourceSHA256,
        SourceClassification,
        SourceAuthority,
        ReferenceYear
    )
    VALUES
    (
        'CMS 2010 BSA Carrier Line Items PUF',
        '2010_BSA_Carrier_PUF.csv',
        '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6',
        'PUBLIC - DE-IDENTIFIED HEALTHCARE DATA',
        'Centers for Medicare & Medicaid Services (CMS)',
        2010
    );
END;
GO

DECLARE @SourceID int =
(
    SELECT SourceID
    FROM governance.SourceRegistry
    WHERE SourceSHA256 =
    '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'
);

DECLARE @RunID bigint;

INSERT INTO governance.LoadRun
(
    RunType,
    SourceID,
    StartedAt,
    RunStatus,
    GitCommit,
    Notes
)
VALUES
(
    'RAW_LOAD',
    @SourceID,
    SYSUTCDATETIME(),
    'RUNNING',
    '4db0ab7dc034a9d04fad1bcebf7af0361209a999',
    'CP5-C CMS Carrier RAW ingestion'
);

SET @RunID = SCOPE_IDENTITY();

BEGIN TRY

    DECLARE @ExistingRows bigint =
    (
        SELECT COUNT_BIG(*)
        FROM raw.CarrierLineItems
    );

    IF @ExistingRows = 0
    BEGIN

        BULK INSERT raw.CarrierLineItems
        FROM 'D:\analysis_projects\H.C_Data_Governance & Q.C_Center\data\2010_BSA_Carrier_PUF.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            CODEPAGE = '65001',
            TABLOCK
        );

    END
    ELSE IF @ExistingRows <> 2801660
    BEGIN
        THROW 51001,
        'RAW table contains an unexpected row count. Automatic overwrite is prohibited.',
        1;
    END;

    DECLARE @Rows bigint;
    DECLARE @LineTotal bigint;
    DECLARE @LineCountParseFailures bigint;

    SELECT
        @Rows = COUNT_BIG(*),

        @LineTotal =
            SUM
            (
                TRY_CONVERT
                (
                    bigint,
                    NULLIF(LTRIM(RTRIM(CAR_LINE_CNT)), '')
                )
            ),

        @LineCountParseFailures =
            SUM
            (
                CASE
                    WHEN TRY_CONVERT
                    (
                        bigint,
                        NULLIF(LTRIM(RTRIM(CAR_LINE_CNT)), '')
                    ) IS NULL
                    THEN 1
                    ELSE 0
                END
            )

    FROM raw.CarrierLineItems;

    IF @Rows <> 2801660
        THROW 51002, 'RAW row-count reconciliation failed.', 1;

    IF @LineTotal <> 70052393
        THROW 51003, 'CAR_LINE_CNT reconciliation failed.', 1;

    IF @LineCountParseFailures <> 0
        THROW 51004, 'CAR_LINE_CNT contains numeric parse failures.', 1;

    UPDATE governance.LoadRun
    SET
        CompletedAt = SYSUTCDATETIME(),
        RunStatus = 'SUCCESS',
        SourceRowCount = 2801660,
        LoadedRowCount = @Rows,
        ErrorCount = 0,
        Notes =
        'CP5-C RAW ingestion validated: rows and represented line-item total reconciled.'
    WHERE RunID = @RunID;

END TRY
BEGIN CATCH

    UPDATE governance.LoadRun
    SET
        CompletedAt = SYSUTCDATETIME(),
        RunStatus = 'FAILED',
        ErrorCount = 1,
        Notes = ERROR_MESSAGE()
    WHERE RunID = @RunID;

    THROW;

END CATCH;
GO
