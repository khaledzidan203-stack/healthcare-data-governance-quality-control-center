USE [master];

IF DB_ID(N'HealthcareGovernanceQC') IS NULL
BEGIN
    CREATE DATABASE [HealthcareGovernanceQC];
END;
GO

USE [HealthcareGovernanceQC];
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'raw')
    EXEC('CREATE SCHEMA raw');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'analytics')
    EXEC('CREATE SCHEMA analytics');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'governance')
    EXEC('CREATE SCHEMA governance');
GO

IF OBJECT_ID('governance.SourceRegistry', 'U') IS NULL
BEGIN
    CREATE TABLE governance.SourceRegistry
    (
        SourceID            int IDENTITY(1,1) PRIMARY KEY,
        SourceName          nvarchar(255) NOT NULL,
        SourceFileName      nvarchar(255) NOT NULL,
        SourceSHA256        char(64) NOT NULL,
        SourceClassification nvarchar(100) NOT NULL,
        SourceAuthority     nvarchar(255) NULL,
        ReferenceYear       smallint NULL,
        RegisteredAt        datetime2(0) NOT NULL
            CONSTRAINT DF_SourceRegistry_RegisteredAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_SourceRegistry_SHA256 UNIQUE (SourceSHA256)
    );
END;
GO

IF OBJECT_ID('governance.LoadRun', 'U') IS NULL
BEGIN
    CREATE TABLE governance.LoadRun
    (
        RunID               bigint IDENTITY(1,1) PRIMARY KEY,
        RunType             nvarchar(100) NOT NULL,
        SourceID            int NULL,
        StartedAt           datetime2(0) NOT NULL,
        CompletedAt         datetime2(0) NULL,
        RunStatus           nvarchar(30) NOT NULL,
        SourceRowCount      bigint NULL,
        LoadedRowCount      bigint NULL,
        ErrorCount          bigint NULL,
        GitCommit           varchar(40) NULL,
        Notes               nvarchar(1000) NULL,

        CONSTRAINT FK_LoadRun_SourceRegistry
            FOREIGN KEY (SourceID)
            REFERENCES governance.SourceRegistry(SourceID)
    );
END;
GO

IF OBJECT_ID('governance.DQRule', 'U') IS NULL
BEGIN
    CREATE TABLE governance.DQRule
    (
        RuleID              varchar(30) PRIMARY KEY,
        DimensionName       nvarchar(50) NOT NULL,
        RuleName            nvarchar(255) NOT NULL,
        RuleDescription     nvarchar(1000) NOT NULL,
        ThresholdDefinition nvarchar(255) NULL,
        Severity            nvarchar(30) NOT NULL,
        FailureAction       nvarchar(255) NOT NULL,
        RuleStatus          nvarchar(30) NOT NULL
    );
END;
GO

IF OBJECT_ID('governance.DQResult', 'U') IS NULL
BEGIN
    CREATE TABLE governance.DQResult
    (
        ResultID            bigint IDENTITY(1,1) PRIMARY KEY,
        RunID               bigint NOT NULL,
        RuleID              varchar(30) NOT NULL,
        ResultStatus        nvarchar(30) NOT NULL,
        ObservedValue       nvarchar(255) NULL,
        ExceptionCount      bigint NULL,
        EvaluatedAt         datetime2(0) NOT NULL
            CONSTRAINT DF_DQResult_EvaluatedAt DEFAULT SYSUTCDATETIME(),
        Notes               nvarchar(1000) NULL,

        CONSTRAINT FK_DQResult_LoadRun
            FOREIGN KEY (RunID)
            REFERENCES governance.LoadRun(RunID),

        CONSTRAINT FK_DQResult_DQRule
            FOREIGN KEY (RuleID)
            REFERENCES governance.DQRule(RuleID)
    );
END;
GO
