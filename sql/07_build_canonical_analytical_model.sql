USE [HealthcareGovernanceQC];

SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- DIMENSIONS
------------------------------------------------------------

IF OBJECT_ID('analytics.DimSex','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimSex
    (
        SexKey tinyint PRIMARY KEY,
        SexCode tinyint NOT NULL UNIQUE,
        SexLabel varchar(20) NOT NULL
    );
END;

IF OBJECT_ID('analytics.DimAgeCategory','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimAgeCategory
    (
        AgeCategoryKey tinyint PRIMARY KEY,
        AgeCategoryCode tinyint NOT NULL UNIQUE,
        AgeCategoryLabel varchar(30) NOT NULL,
        SortOrder tinyint NOT NULL
    );
END;

IF OBJECT_ID('analytics.DimICD9','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimICD9
    (
        ICD9Key int PRIMARY KEY,
        ICD9Code varchar(20) NULL,
        IsBlankSourceValue bit NOT NULL
    );

    CREATE UNIQUE INDEX UX_DimICD9_Code
        ON analytics.DimICD9(ICD9Code)
        WHERE ICD9Code IS NOT NULL;
END;

IF OBJECT_ID('analytics.DimHCPCS','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimHCPCS
    (
        HCPCSKey int PRIMARY KEY,
        HCPCSCode varchar(30) NOT NULL UNIQUE
    );
END;

IF OBJECT_ID('analytics.DimBETOS','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimBETOS
    (
        BETOSKey int PRIMARY KEY,
        BETOSCode varchar(30) NOT NULL UNIQUE
    );
END;

IF OBJECT_ID('analytics.DimProviderType','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimProviderType
    (
        ProviderTypeKey int PRIMARY KEY,
        ProviderTypeCode varchar(20) NOT NULL UNIQUE
    );
END;

IF OBJECT_ID('analytics.DimServiceType','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimServiceType
    (
        ServiceTypeKey int PRIMARY KEY,
        ServiceTypeCode varchar(20) NOT NULL UNIQUE
    );
END;

IF OBJECT_ID('analytics.DimPlaceOfService','U') IS NULL
BEGIN
    CREATE TABLE analytics.DimPlaceOfService
    (
        PlaceOfServiceKey int PRIMARY KEY,
        PlaceOfServiceCode varchar(20) NOT NULL UNIQUE
    );
END;

------------------------------------------------------------
-- FACT
------------------------------------------------------------

IF OBJECT_ID('analytics.FactCarrierProfile','U') IS NULL
BEGIN
    CREATE TABLE analytics.FactCarrierProfile
    (
        ProfileKey bigint NOT NULL
            CONSTRAINT PK_FactCarrierProfile PRIMARY KEY,

        SexKey tinyint NOT NULL,
        AgeCategoryKey tinyint NOT NULL,
        ICD9Key int NOT NULL,
        HCPCSKey int NOT NULL,
        BETOSKey int NOT NULL,
        ProviderTypeKey int NOT NULL,
        ServiceTypeKey int NOT NULL,
        PlaceOfServiceKey int NOT NULL,

        ServiceCount int NOT NULL,
        MedicarePaymentAmount decimal(18,2) NOT NULL,
        LineItemCount bigint NOT NULL,

        IsBlankICD bit NOT NULL,
        IsZeroServiceCount bit NOT NULL,

        GovernanceRunID bigint NOT NULL,

        CONSTRAINT FK_Fact_Sex
            FOREIGN KEY (SexKey)
            REFERENCES analytics.DimSex(SexKey),

        CONSTRAINT FK_Fact_Age
            FOREIGN KEY (AgeCategoryKey)
            REFERENCES analytics.DimAgeCategory(AgeCategoryKey),

        CONSTRAINT FK_Fact_ICD9
            FOREIGN KEY (ICD9Key)
            REFERENCES analytics.DimICD9(ICD9Key),

        CONSTRAINT FK_Fact_HCPCS
            FOREIGN KEY (HCPCSKey)
            REFERENCES analytics.DimHCPCS(HCPCSKey),

        CONSTRAINT FK_Fact_BETOS
            FOREIGN KEY (BETOSKey)
            REFERENCES analytics.DimBETOS(BETOSKey),

        CONSTRAINT FK_Fact_Provider
            FOREIGN KEY (ProviderTypeKey)
            REFERENCES analytics.DimProviderType(ProviderTypeKey),

        CONSTRAINT FK_Fact_Service
            FOREIGN KEY (ServiceTypeKey)
            REFERENCES analytics.DimServiceType(ServiceTypeKey),

        CONSTRAINT FK_Fact_POS
            FOREIGN KEY (PlaceOfServiceKey)
            REFERENCES analytics.DimPlaceOfService(PlaceOfServiceKey),

        CONSTRAINT FK_Fact_Run
            FOREIGN KEY (GovernanceRunID)
            REFERENCES governance.LoadRun(RunID)
    );
END;

------------------------------------------------------------
-- GOVERNANCE RUN
------------------------------------------------------------

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
    'ANALYTICS_BUILD',
    @SourceID,
    SYSUTCDATETIME(),
    'RUNNING',
    '8d87d718a17c01e763441bc12148d302a7497606',
    'CP7-A canonical analytical star model'
);

SET @RunID = SCOPE_IDENTITY();

BEGIN TRY

    BEGIN TRANSACTION;

    TRUNCATE TABLE analytics.FactCarrierProfile;

    DELETE FROM analytics.DimSex;
    DELETE FROM analytics.DimAgeCategory;
    DELETE FROM analytics.DimICD9;
    DELETE FROM analytics.DimHCPCS;
    DELETE FROM analytics.DimBETOS;
    DELETE FROM analytics.DimProviderType;
    DELETE FROM analytics.DimServiceType;
    DELETE FROM analytics.DimPlaceOfService;

    --------------------------------------------------------
    -- CONTROLLED DOCUMENTED DIMENSIONS
    --------------------------------------------------------

    INSERT INTO analytics.DimSex
    (
        SexKey,
        SexCode,
        SexLabel
    )
    VALUES
        (1,1,'Male'),
        (2,2,'Female');

    INSERT INTO analytics.DimAgeCategory
    (
        AgeCategoryKey,
        AgeCategoryCode,
        AgeCategoryLabel,
        SortOrder
    )
    VALUES
        (1,1,'Under 65',1),
        (2,2,'65-69',2),
        (3,3,'70-74',3),
        (4,4,'75-79',4),
        (5,5,'80-84',5),
        (6,6,'85 and older',6);

    --------------------------------------------------------
    -- SOURCE-DERIVED REFERENCE DIMENSIONS
    --------------------------------------------------------

    INSERT INTO analytics.DimICD9
    (
        ICD9Key,
        ICD9Code,
        IsBlankSourceValue
    )
    VALUES
        (0,NULL,1);

    INSERT INTO analytics.DimICD9
    (
        ICD9Key,
        ICD9Code,
        IsBlankSourceValue
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_ICD9_DGNS_CD),
        CAR_LINE_ICD9_DGNS_CD,
        0
    FROM
    (
        SELECT DISTINCT CAR_LINE_ICD9_DGNS_CD
        FROM staging.CarrierLineItems
        WHERE CAR_LINE_ICD9_DGNS_CD IS NOT NULL
    ) d;

    INSERT INTO analytics.DimHCPCS
    (
        HCPCSKey,
        HCPCSCode
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_HCPCS_CD),
        CAR_LINE_HCPCS_CD
    FROM
    (
        SELECT DISTINCT CAR_LINE_HCPCS_CD
        FROM staging.CarrierLineItems
    ) d;

    INSERT INTO analytics.DimBETOS
    (
        BETOSKey,
        BETOSCode
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_BETOS_CD),
        CAR_LINE_BETOS_CD
    FROM
    (
        SELECT DISTINCT CAR_LINE_BETOS_CD
        FROM staging.CarrierLineItems
    ) d;

    INSERT INTO analytics.DimProviderType
    (
        ProviderTypeKey,
        ProviderTypeCode
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_PRVDR_TYPE_CD),
        CAR_LINE_PRVDR_TYPE_CD
    FROM
    (
        SELECT DISTINCT CAR_LINE_PRVDR_TYPE_CD
        FROM staging.CarrierLineItems
    ) d;

    INSERT INTO analytics.DimServiceType
    (
        ServiceTypeKey,
        ServiceTypeCode
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_CMS_TYPE_SRVC_CD),
        CAR_LINE_CMS_TYPE_SRVC_CD
    FROM
    (
        SELECT DISTINCT CAR_LINE_CMS_TYPE_SRVC_CD
        FROM staging.CarrierLineItems
    ) d;

    INSERT INTO analytics.DimPlaceOfService
    (
        PlaceOfServiceKey,
        PlaceOfServiceCode
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAR_LINE_PLACE_OF_SRVC_CD),
        CAR_LINE_PLACE_OF_SRVC_CD
    FROM
    (
        SELECT DISTINCT CAR_LINE_PLACE_OF_SRVC_CD
        FROM staging.CarrierLineItems
    ) d;

    --------------------------------------------------------
    -- FACT LOAD
    --------------------------------------------------------

    INSERT INTO analytics.FactCarrierProfile WITH (TABLOCK)
    (
        ProfileKey,
        SexKey,
        AgeCategoryKey,
        ICD9Key,
        HCPCSKey,
        BETOSKey,
        ProviderTypeKey,
        ServiceTypeKey,
        PlaceOfServiceKey,
        ServiceCount,
        MedicarePaymentAmount,
        LineItemCount,
        IsBlankICD,
        IsZeroServiceCount,
        GovernanceRunID
    )
    SELECT
        s.StagingProfileKey,
        sx.SexKey,
        ag.AgeCategoryKey,
        COALESCE(ic.ICD9Key,0),
        hc.HCPCSKey,
        bt.BETOSKey,
        pr.ProviderTypeKey,
        sv.ServiceTypeKey,
        ps.PlaceOfServiceKey,
        s.CAR_LINE_SRVC_CNT,
        s.CAR_HCPS_PMT_AMT,
        s.CAR_LINE_CNT,
        s.IsBlankICD,
        s.IsZeroServiceCount,
        @RunID

    FROM staging.CarrierLineItems s

    JOIN analytics.DimSex sx
      ON sx.SexCode = s.BENE_SEX_IDENT_CD

    JOIN analytics.DimAgeCategory ag
      ON ag.AgeCategoryCode = s.BENE_AGE_CAT_CD

    LEFT JOIN analytics.DimICD9 ic
      ON ic.ICD9Code = s.CAR_LINE_ICD9_DGNS_CD

    JOIN analytics.DimHCPCS hc
      ON hc.HCPCSCode = s.CAR_LINE_HCPCS_CD

    JOIN analytics.DimBETOS bt
      ON bt.BETOSCode = s.CAR_LINE_BETOS_CD

    JOIN analytics.DimProviderType pr
      ON pr.ProviderTypeCode = s.CAR_LINE_PRVDR_TYPE_CD

    JOIN analytics.DimServiceType sv
      ON sv.ServiceTypeCode = s.CAR_LINE_CMS_TYPE_SRVC_CD

    JOIN analytics.DimPlaceOfService ps
      ON ps.PlaceOfServiceCode = s.CAR_LINE_PLACE_OF_SRVC_CD;

    --------------------------------------------------------
    -- VALIDATION
    --------------------------------------------------------

    DECLARE @FactRows bigint;
    DECLARE @Lines bigint;
    DECLARE @BlankICD bigint;

    SELECT
        @FactRows = COUNT_BIG(*),
        @Lines = SUM(LineItemCount),
        @BlankICD = SUM(CASE WHEN ICD9Key = 0 THEN 1 ELSE 0 END)
    FROM analytics.FactCarrierProfile;

    IF @FactRows <> 2801660
        THROW 51100, 'Analytical fact row reconciliation failed.', 1;

    IF @Lines <> 70052393
        THROW 51101, 'Analytical line-item reconciliation failed.', 1;

    IF @BlankICD <> 502
        THROW 51102, 'Analytical blank ICD reconciliation failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimSex) <> 2
        THROW 51103, 'DimSex cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimAgeCategory) <> 6
        THROW 51104, 'DimAgeCategory cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimICD9) <> 926
        THROW 51105, 'DimICD9 cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimHCPCS) <> 4900
        THROW 51106, 'DimHCPCS cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimBETOS) <> 98
        THROW 51107, 'DimBETOS cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimProviderType) <> 6
        THROW 51108, 'DimProviderType cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimServiceType) <> 20
        THROW 51109, 'DimServiceType cardinality failed.', 1;

    IF (SELECT COUNT(*) FROM analytics.DimPlaceOfService) <> 28
        THROW 51110, 'DimPlaceOfService cardinality failed.', 1;

    COMMIT TRANSACTION;

    UPDATE governance.LoadRun
    SET
        CompletedAt = SYSUTCDATETIME(),
        RunStatus = 'SUCCESS',
        SourceRowCount = 2801660,
        LoadedRowCount = @FactRows,
        ErrorCount = 0,
        Notes = 'CP7-A canonical analytical star model reconciled successfully.'
    WHERE RunID = @RunID;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    UPDATE governance.LoadRun
    SET
        CompletedAt = SYSUTCDATETIME(),
        RunStatus = 'FAILED',
        ErrorCount = 1,
        Notes = ERROR_MESSAGE()
    WHERE RunID = @RunID;

    THROW;

END CATCH;
