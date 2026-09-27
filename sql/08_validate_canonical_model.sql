USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

SELECT
    (SELECT COUNT_BIG(*) FROM analytics.FactCarrierProfile) AS FactRows,
    (SELECT SUM(LineItemCount) FROM analytics.FactCarrierProfile) AS LineItems,

    (SELECT COUNT_BIG(*) FROM analytics.FactCarrierProfile WHERE ICD9Key = 0) AS BlankICD,
    (SELECT COUNT_BIG(*) FROM analytics.FactCarrierProfile WHERE IsZeroServiceCount = 1) AS ZeroService,

    (SELECT SUM(f.LineItemCount)
     FROM analytics.FactCarrierProfile f
     JOIN analytics.DimSex d ON f.SexKey = d.SexKey
     WHERE d.SexCode = 1) AS MaleLines,

    (SELECT SUM(f.LineItemCount)
     FROM analytics.FactCarrierProfile f
     JOIN analytics.DimSex d ON f.SexKey = d.SexKey
     WHERE d.SexCode = 2) AS FemaleLines,

    (SELECT SUM(f.LineItemCount)
     FROM analytics.FactCarrierProfile f
     JOIN analytics.DimAgeCategory d ON f.AgeCategoryKey = d.AgeCategoryKey
     WHERE d.AgeCategoryCode = 6) AS Age85PlusLines,

    (SELECT COUNT(*) FROM analytics.DimSex) AS SexRows,
    (SELECT COUNT(*) FROM analytics.DimAgeCategory) AS AgeRows,
    (SELECT COUNT(*) FROM analytics.DimICD9) AS ICDRows,
    (SELECT COUNT(*) FROM analytics.DimHCPCS) AS HCPCSRows,
    (SELECT COUNT(*) FROM analytics.DimBETOS) AS BETOSRows,
    (SELECT COUNT(*) FROM analytics.DimProviderType) AS ProviderRows,
    (SELECT COUNT(*) FROM analytics.DimServiceType) AS ServiceRows,
    (SELECT COUNT(*) FROM analytics.DimPlaceOfService) AS POSRows,

    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimSex d ON f.SexKey = d.SexKey
        WHERE d.SexKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimAgeCategory d ON f.AgeCategoryKey = d.AgeCategoryKey
        WHERE d.AgeCategoryKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimICD9 d ON f.ICD9Key = d.ICD9Key
        WHERE d.ICD9Key IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimHCPCS d ON f.HCPCSKey = d.HCPCSKey
        WHERE d.HCPCSKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimBETOS d ON f.BETOSKey = d.BETOSKey
        WHERE d.BETOSKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimProviderType d ON f.ProviderTypeKey = d.ProviderTypeKey
        WHERE d.ProviderTypeKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimServiceType d ON f.ServiceTypeKey = d.ServiceTypeKey
        WHERE d.ServiceTypeKey IS NULL
    ) +
    (
        SELECT COUNT_BIG(*)
        FROM analytics.FactCarrierProfile f
        LEFT JOIN analytics.DimPlaceOfService d ON f.PlaceOfServiceKey = d.PlaceOfServiceKey
        WHERE d.PlaceOfServiceKey IS NULL
    ) AS BrokenForeignKeys;
