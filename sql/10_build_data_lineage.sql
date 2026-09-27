USE [HealthcareGovernanceQC];

SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- GOVERNANCE DATA LINEAGE REGISTRY
------------------------------------------------------------

IF OBJECT_ID('governance.DataLineage','U') IS NULL
BEGIN
    CREATE TABLE governance.DataLineage
    (
        LineageID bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_DataLineage PRIMARY KEY,

        ProjectScope varchar(100) NOT NULL,

        SourceLayer varchar(40) NOT NULL,
        SourceObject nvarchar(300) NOT NULL,
        SourceField nvarchar(128) NOT NULL,

        TargetLayer varchar(40) NOT NULL,
        TargetObject nvarchar(300) NOT NULL,
        TargetField nvarchar(128) NOT NULL,

        TransformationRule nvarchar(1000) NOT NULL,
        EvidenceArtifact nvarchar(260) NOT NULL,

        SourceSHA256 char(64) NULL,

        CreatedAt datetime2(0) NOT NULL
            CONSTRAINT DF_DataLineage_CreatedAt
            DEFAULT SYSUTCDATETIME()
    );
END;

DELETE FROM governance.DataLineage
WHERE ProjectScope = '2010_BSA_Carrier_PUF';

------------------------------------------------------------
-- SOURCE FILE -> RAW
------------------------------------------------------------

INSERT INTO governance.DataLineage
(
    ProjectScope,
    SourceLayer,
    SourceObject,
    SourceField,
    TargetLayer,
    TargetObject,
    TargetField,
    TransformationRule,
    EvidenceArtifact,
    SourceSHA256
)
VALUES

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','__ROW__',
 'RAW','raw.CarrierLineItems','__ROW__',
 'One physical CSV row loaded as one RAW row without analytical transformation.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','BENE_SEX_IDENT_CD',
 'RAW','raw.CarrierLineItems','BENE_SEX_IDENT_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','BENE_AGE_CAT_CD',
 'RAW','raw.CarrierLineItems','BENE_AGE_CAT_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_ICD9_DGNS_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_HCPCS_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_HCPCS_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_BETOS_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_BETOS_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_SRVC_CNT',
 'RAW','raw.CarrierLineItems','CAR_LINE_SRVC_CNT',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_PRVDR_TYPE_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_PRVDR_TYPE_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_CMS_TYPE_SRVC_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_CMS_TYPE_SRVC_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_PLACE_OF_SRVC_CD',
 'RAW','raw.CarrierLineItems','CAR_LINE_PLACE_OF_SRVC_CD',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_HCPS_PMT_AMT',
 'RAW','raw.CarrierLineItems','CAR_HCPS_PMT_AMT',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6'),

('2010_BSA_Carrier_PUF','SOURCE_FILE',
 '2010_BSA_Carrier_PUF.csv','CAR_LINE_CNT',
 'RAW','raw.CarrierLineItems','CAR_LINE_CNT',
 'Source text preserved.',
 'sql\02_load_raw_carrier.sql',
 '923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6');

------------------------------------------------------------
-- RAW -> STAGING
------------------------------------------------------------

INSERT INTO governance.DataLineage
(
    ProjectScope,
    SourceLayer,
    SourceObject,
    SourceField,
    TargetLayer,
    TargetObject,
    TargetField,
    TransformationRule,
    EvidenceArtifact
)
VALUES

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','__ROW__',
 'STAGING','staging.CarrierLineItems','StagingProfileKey',
 'System-generated surrogate key assigned one-to-one to governed staging row.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','BENE_SEX_IDENT_CD',
 'STAGING','staging.CarrierLineItems','BENE_SEX_IDENT_CD',
 'Trim and convert to tinyint.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','BENE_AGE_CAT_CD',
 'STAGING','staging.CarrierLineItems','BENE_AGE_CAT_CD',
 'Trim and convert to tinyint.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'Trim; blank source value converted to NULL without deleting row.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_HCPCS_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_HCPCS_CD',
 'Trim source code.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_BETOS_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_BETOS_CD',
 'Trim source code.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_SRVC_CNT',
 'STAGING','staging.CarrierLineItems','CAR_LINE_SRVC_CNT',
 'Trim and convert to int.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_PRVDR_TYPE_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_PRVDR_TYPE_CD',
 'Trim source code.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_CMS_TYPE_SRVC_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_CMS_TYPE_SRVC_CD',
 'Trim source code.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_PLACE_OF_SRVC_CD',
 'STAGING','staging.CarrierLineItems','CAR_LINE_PLACE_OF_SRVC_CD',
 'Trim source code.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_HCPS_PMT_AMT',
 'STAGING','staging.CarrierLineItems','CAR_HCPS_PMT_AMT',
 'Trim and convert to decimal(18,2).',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_CNT',
 'STAGING','staging.CarrierLineItems','CAR_LINE_CNT',
 'Trim and convert to bigint.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'STAGING','staging.CarrierLineItems','IsBlankICD',
 'DQ flag equals 1 when source ICD value is blank.',
 'sql\04_build_staging_carrier.sql'),

('2010_BSA_Carrier_PUF','RAW','raw.CarrierLineItems','CAR_LINE_SRVC_CNT',
 'STAGING','staging.CarrierLineItems','IsZeroServiceCount',
 'DQ flag equals 1 when typed service count equals zero.',
 'sql\04_build_staging_carrier.sql');

------------------------------------------------------------
-- STAGING -> DIMENSIONS
------------------------------------------------------------

INSERT INTO governance.DataLineage
(
    ProjectScope,
    SourceLayer,
    SourceObject,
    SourceField,
    TargetLayer,
    TargetObject,
    TargetField,
    TransformationRule,
    EvidenceArtifact
)
VALUES

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','BENE_SEX_IDENT_CD',
 'ANALYTICS_DIMENSION','analytics.DimSex','SexCode',
 'Governed reference mapping.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','BENE_AGE_CAT_CD',
 'ANALYTICS_DIMENSION','analytics.DimAgeCategory','AgeCategoryCode',
 'Governed reference mapping.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'ANALYTICS_DIMENSION','analytics.DimICD9','ICD9Code',
 'Distinct nonblank ICD-9 codes; blank source values use governed key 0.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_HCPCS_CD',
 'ANALYTICS_DIMENSION','analytics.DimHCPCS','HCPCSCode',
 'Distinct governed reference code.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_BETOS_CD',
 'ANALYTICS_DIMENSION','analytics.DimBETOS','BETOSCode',
 'Distinct governed reference code.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_PRVDR_TYPE_CD',
 'ANALYTICS_DIMENSION','analytics.DimProviderType','ProviderTypeCode',
 'Distinct governed reference code.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_CMS_TYPE_SRVC_CD',
 'ANALYTICS_DIMENSION','analytics.DimServiceType','ServiceTypeCode',
 'Distinct governed reference code.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_PLACE_OF_SRVC_CD',
 'ANALYTICS_DIMENSION','analytics.DimPlaceOfService','PlaceOfServiceCode',
 'Distinct governed reference code.',
 'sql\07_build_canonical_analytical_model.sql');

------------------------------------------------------------
-- STAGING -> FACT
------------------------------------------------------------

INSERT INTO governance.DataLineage
(
    ProjectScope,
    SourceLayer,
    SourceObject,
    SourceField,
    TargetLayer,
    TargetObject,
    TargetField,
    TransformationRule,
    EvidenceArtifact
)
VALUES

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','StagingProfileKey',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','ProfileKey',
 'One-to-one governed profile key.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','BENE_SEX_IDENT_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','SexKey',
 'Lookup against DimSex.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','BENE_AGE_CAT_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','AgeCategoryKey',
 'Lookup against DimAgeCategory.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_ICD9_DGNS_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','ICD9Key',
 'Lookup against DimICD9; blank source values map to key 0.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_HCPCS_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','HCPCSKey',
 'Lookup against DimHCPCS.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_BETOS_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','BETOSKey',
 'Lookup against DimBETOS.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_PRVDR_TYPE_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','ProviderTypeKey',
 'Lookup against DimProviderType.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_CMS_TYPE_SRVC_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','ServiceTypeKey',
 'Lookup against DimServiceType.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_PLACE_OF_SRVC_CD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','PlaceOfServiceKey',
 'Lookup against DimPlaceOfService.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_SRVC_CNT',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','ServiceCount',
 'Typed governed service count.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_HCPS_PMT_AMT',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','MedicarePaymentAmount',
 'Typed rounded Medicare payment value.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','CAR_LINE_CNT',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','LineItemCount',
 'Governed represented line-item weight.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','IsBlankICD',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','IsBlankICD',
 'DQ flag preserved.',
 'sql\07_build_canonical_analytical_model.sql'),

('2010_BSA_Carrier_PUF','STAGING','staging.CarrierLineItems','IsZeroServiceCount',
 'ANALYTICS_FACT','analytics.FactCarrierProfile','IsZeroServiceCount',
 'DQ flag preserved.',
 'sql\07_build_canonical_analytical_model.sql');

------------------------------------------------------------
-- FACT -> KPI BASELINE
------------------------------------------------------------

INSERT INTO governance.DataLineage
(
    ProjectScope,
    SourceLayer,
    SourceObject,
    SourceField,
    TargetLayer,
    TargetObject,
    TargetField,
    TransformationRule,
    EvidenceArtifact
)
VALUES

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','ProfileKey',
 'KPI','analytics.vw_CarrierKPIBaseline','ProfileCount',
 'COUNT_BIG of governed profiles.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','RepresentedLineItemCount',
 'SUM of represented line-item weight.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','ServiceCount',
 'KPI','analytics.vw_CarrierKPIBaseline','RepresentedServiceUnits',
 'ServiceCount multiplied by LineItemCount then summed.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','RepresentedServiceUnits',
 'Weight input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','MedicarePaymentAmount',
 'KPI','analytics.vw_CarrierKPIBaseline','RepresentedRoundedMedicarePayment',
 'Rounded payment multiplied by LineItemCount then summed.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','RepresentedRoundedMedicarePayment',
 'Weight input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','ServiceCount',
 'KPI','analytics.vw_CarrierKPIBaseline','AvgServiceUnitsPerRepresentedLine',
 'Weighted ratio-of-totals numerator input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','AvgServiceUnitsPerRepresentedLine',
 'Weight and denominator input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','MedicarePaymentAmount',
 'KPI','analytics.vw_CarrierKPIBaseline','AvgRoundedPaymentPerRepresentedLine',
 'Weighted ratio-of-totals numerator input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','AvgRoundedPaymentPerRepresentedLine',
 'Weight and denominator input.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsBlankICD',
 'KPI','analytics.vw_CarrierKPIBaseline','BlankICDProfiles',
 'Count profiles where blank ICD flag equals 1.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsBlankICD',
 'KPI','analytics.vw_CarrierKPIBaseline','BlankICDRepresentedLines',
 'Defines blank-ICD population.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','BlankICDRepresentedLines',
 'SUM LineItemCount for blank-ICD profiles.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsBlankICD',
 'KPI','analytics.vw_CarrierKPIBaseline','BlankICDLineRate',
 'Defines numerator population.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','BlankICDLineRate',
 'Blank represented lines divided by all represented lines.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsZeroServiceCount',
 'KPI','analytics.vw_CarrierKPIBaseline','ZeroServiceProfiles',
 'Count profiles where zero-service flag equals 1.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsZeroServiceCount',
 'KPI','analytics.vw_CarrierKPIBaseline','ZeroServiceRepresentedLines',
 'Defines zero-service population.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','ZeroServiceRepresentedLines',
 'SUM LineItemCount for zero-service profiles.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','IsZeroServiceCount',
 'KPI','analytics.vw_CarrierKPIBaseline','ZeroServiceLineRate',
 'Defines numerator population.',
 'sql\09_create_kpi_baseline.sql'),

('2010_BSA_Carrier_PUF','ANALYTICS_FACT',
 'analytics.FactCarrierProfile','LineItemCount',
 'KPI','analytics.vw_CarrierKPIBaseline','ZeroServiceLineRate',
 'Zero-service represented lines divided by all represented lines.',
 'sql\09_create_kpi_baseline.sql');

------------------------------------------------------------
-- VALIDATION
------------------------------------------------------------

DECLARE @TotalEdges int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
);

DECLARE @SourceToRaw int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND SourceLayer = 'SOURCE_FILE'
      AND TargetLayer = 'RAW'
);

DECLARE @RawToStaging int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND SourceLayer = 'RAW'
      AND TargetLayer = 'STAGING'
);

DECLARE @DimensionEdges int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND TargetLayer = 'ANALYTICS_DIMENSION'
);

DECLARE @FactEdges int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND TargetLayer = 'ANALYTICS_FACT'
);

DECLARE @KPIEdges int =
(
    SELECT COUNT(*)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND TargetLayer = 'KPI'
);

DECLARE @KPIContracts int =
(
    SELECT COUNT(DISTINCT TargetField)
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND TargetLayer = 'KPI'
);

IF @TotalEdges <> 68
    THROW 51200, 'Unexpected lineage edge count.', 1;

IF @SourceToRaw <> 12
    THROW 51201, 'Source-to-RAW lineage failed.', 1;

IF @RawToStaging <> 14
    THROW 51202, 'RAW-to-STAGING lineage failed.', 1;

IF @DimensionEdges <> 8
    THROW 51203, 'Dimension lineage failed.', 1;

IF @FactEdges <> 14
    THROW 51204, 'Fact lineage failed.', 1;

IF @KPIEdges <> 20
    THROW 51205, 'KPI lineage edge validation failed.', 1;

IF @KPIContracts <> 12
    THROW 51206, 'KPI lineage contract coverage failed.', 1;

------------------------------------------------------------
-- END-TO-END SOURCE TRACEABILITY
------------------------------------------------------------

;WITH LineagePaths AS
(
    SELECT
        SourceLayer,
        SourceObject,
        SourceField,
        TargetLayer,
        TargetObject,
        TargetField,
        1 AS Depth
    FROM governance.DataLineage
    WHERE ProjectScope = '2010_BSA_Carrier_PUF'
      AND SourceLayer = 'SOURCE_FILE'

    UNION ALL

    SELECT
        p.SourceLayer,
        p.SourceObject,
        p.SourceField,
        e.TargetLayer,
        e.TargetObject,
        e.TargetField,
        p.Depth + 1
    FROM LineagePaths p

    INNER JOIN governance.DataLineage e
        ON e.ProjectScope = '2010_BSA_Carrier_PUF'
       AND e.SourceLayer = p.TargetLayer
       AND e.SourceObject = p.TargetObject
       AND e.SourceField = p.TargetField

    WHERE p.Depth < 10
)
SELECT DISTINCT TargetField
INTO #TraceableKPIs
FROM LineagePaths
WHERE TargetLayer = 'KPI'
OPTION (MAXRECURSION 100);

DECLARE @FullyTraceableKPIs int =
(
    SELECT COUNT(*)
    FROM #TraceableKPIs
);

DROP TABLE #TraceableKPIs;

IF @FullyTraceableKPIs <> 12
    THROW 51207, 'End-to-end KPI traceability failed.', 1;

SELECT
    @TotalEdges AS TotalEdges,
    @SourceToRaw AS SourceToRaw,
    @RawToStaging AS RawToStaging,
    @DimensionEdges AS DimensionEdges,
    @FactEdges AS FactEdges,
    @KPIEdges AS KPIEdges,
    @KPIContracts AS KPIContracts,
    @FullyTraceableKPIs AS FullyTraceableKPIs;
