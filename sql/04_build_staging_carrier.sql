USE [HealthcareGovernanceQC];

SET NOCOUNT ON;

IF OBJECT_ID('staging.CarrierLineItems','U') IS NULL
BEGIN
    CREATE TABLE staging.CarrierLineItems
    (
        StagingProfileKey bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Staging_CarrierLineItems PRIMARY KEY,

        BENE_SEX_IDENT_CD tinyint NOT NULL,
        BENE_AGE_CAT_CD tinyint NOT NULL,

        CAR_LINE_ICD9_DGNS_CD varchar(20) NULL,
        CAR_LINE_HCPCS_CD varchar(30) NOT NULL,
        CAR_LINE_BETOS_CD varchar(30) NOT NULL,

        CAR_LINE_SRVC_CNT int NOT NULL,

        CAR_LINE_PRVDR_TYPE_CD varchar(20) NOT NULL,
        CAR_LINE_CMS_TYPE_SRVC_CD varchar(20) NOT NULL,
        CAR_LINE_PLACE_OF_SRVC_CD varchar(20) NOT NULL,

        CAR_HCPS_PMT_AMT decimal(18,2) NOT NULL,
        CAR_LINE_CNT bigint NOT NULL,

        IsBlankICD bit NOT NULL,
        IsZeroServiceCount bit NOT NULL,

        GovernanceRunID bigint NOT NULL,

        CONSTRAINT CK_Staging_Sex
            CHECK (BENE_SEX_IDENT_CD IN (1,2)),

        CONSTRAINT CK_Staging_Age
            CHECK (BENE_AGE_CAT_CD BETWEEN 1 AND 6),

        CONSTRAINT CK_Staging_LineCount
            CHECK (CAR_LINE_CNT > 0),

        CONSTRAINT FK_Staging_GovernanceRun
            FOREIGN KEY (GovernanceRunID)
            REFERENCES governance.LoadRun(RunID)
    );
END;

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
    'STAGING_LOAD',
    @SourceID,
    SYSUTCDATETIME(),
    'RUNNING',
    '4db0ab7dc034a9d04fad1bcebf7af0361209a999',
    'CP5-E typed governed staging transformation'
);

SET @RunID = SCOPE_IDENTITY();

BEGIN TRY

    TRUNCATE TABLE staging.CarrierLineItems;

    DBCC CHECKIDENT
    (
        'staging.CarrierLineItems',
        RESEED,
        0
    ) WITH NO_INFOMSGS;

    INSERT INTO staging.CarrierLineItems WITH (TABLOCK)
    (
        BENE_SEX_IDENT_CD,
        BENE_AGE_CAT_CD,
        CAR_LINE_ICD9_DGNS_CD,
        CAR_LINE_HCPCS_CD,
        CAR_LINE_BETOS_CD,
        CAR_LINE_SRVC_CNT,
        CAR_LINE_PRVDR_TYPE_CD,
        CAR_LINE_CMS_TYPE_SRVC_CD,
        CAR_LINE_PLACE_OF_SRVC_CD,
        CAR_HCPS_PMT_AMT,
        CAR_LINE_CNT,
        IsBlankICD,
        IsZeroServiceCount,
        GovernanceRunID
    )
    SELECT
        TRY_CONVERT(tinyint, LTRIM(RTRIM(BENE_SEX_IDENT_CD))),
        TRY_CONVERT(tinyint, LTRIM(RTRIM(BENE_AGE_CAT_CD))),

        NULLIF(LTRIM(RTRIM(CAR_LINE_ICD9_DGNS_CD)), ''),

        LTRIM(RTRIM(CAR_LINE_HCPCS_CD)),
        LTRIM(RTRIM(CAR_LINE_BETOS_CD)),

        TRY_CONVERT(int, LTRIM(RTRIM(CAR_LINE_SRVC_CNT))),

        LTRIM(RTRIM(CAR_LINE_PRVDR_TYPE_CD)),
        LTRIM(RTRIM(CAR_LINE_CMS_TYPE_SRVC_CD)),
        LTRIM(RTRIM(CAR_LINE_PLACE_OF_SRVC_CD)),

        TRY_CONVERT(decimal(18,2), LTRIM(RTRIM(CAR_HCPS_PMT_AMT))),
        TRY_CONVERT(bigint, LTRIM(RTRIM(CAR_LINE_CNT))),

        CASE
            WHEN NULLIF(LTRIM(RTRIM(CAR_LINE_ICD9_DGNS_CD)), '') IS NULL
            THEN 1 ELSE 0
        END,

        CASE
            WHEN TRY_CONVERT(int, LTRIM(RTRIM(CAR_LINE_SRVC_CNT))) = 0
            THEN 1 ELSE 0
        END,

        @RunID

    FROM raw.CarrierLineItems;

    DECLARE @Rows bigint;
    DECLARE @Lines bigint;
    DECLARE @BlankICD bigint;
    DECLARE @BlankICDLines bigint;
    DECLARE @ZeroService bigint;
    DECLARE @ZeroServiceLines bigint;

    SELECT
        @Rows = COUNT_BIG(*),
        @Lines = SUM(CAR_LINE_CNT),

        @BlankICD =
            SUM(CASE WHEN IsBlankICD = 1 THEN 1 ELSE 0 END),

        @BlankICDLines =
            SUM(CASE WHEN IsBlankICD = 1 THEN CAR_LINE_CNT ELSE 0 END),

        @ZeroService =
            SUM(CASE WHEN IsZeroServiceCount = 1 THEN 1 ELSE 0 END),

        @ZeroServiceLines =
            SUM(CASE WHEN IsZeroServiceCount = 1 THEN CAR_LINE_CNT ELSE 0 END)

    FROM staging.CarrierLineItems;

    IF @Rows <> 2801660
        THROW 51010, 'STAGING row-count reconciliation failed.', 1;

    IF @Lines <> 70052393
        THROW 51011, 'STAGING line-count reconciliation failed.', 1;

    IF @BlankICD <> 502
        THROW 51012, 'STAGING blank ICD reconciliation failed.', 1;

    IF @BlankICDLines <> 13506
        THROW 51013, 'STAGING blank ICD weighted reconciliation failed.', 1;

    IF @ZeroService <> 22
        THROW 51014, 'STAGING zero-service reconciliation failed.', 1;

    IF @ZeroServiceLines <> 59
        THROW 51015, 'STAGING zero-service weighted reconciliation failed.', 1;

    UPDATE governance.LoadRun
    SET
        CompletedAt = SYSUTCDATETIME(),
        RunStatus = 'SUCCESS',
        SourceRowCount = 2801660,
        LoadedRowCount = @Rows,
        ErrorCount = 0,
        Notes = 'CP5-E STAGING typed transformation reconciled successfully.'
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
