USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

-- ------------------------------------------------------------
-- BI CONSUMPTION VIEW
-- ------------------------------------------------------------

EXEC(N'
CREATE OR ALTER VIEW analytics.vw_BI_CarrierProfile
AS
SELECT
    CAST(2010 AS smallint) AS ReferenceYear,

    f.ProfileKey,

    sx.SexCode,
    sx.SexLabel,

    ag.AgeCategoryCode,
    ag.AgeCategoryLabel,
    ag.SortOrder AS AgeCategorySortOrder,

    ic.ICD9Code,
    hc.HCPCSCode,
    bt.BETOSCode,
    pr.ProviderTypeCode,
    sv.ServiceTypeCode,
    ps.PlaceOfServiceCode,

    f.ServiceCount,

    f.MedicarePaymentAmount
        AS RoundedMedicarePaymentAmount,

    f.LineItemCount,

    f.IsBlankICD,
    f.IsZeroServiceCount

FROM analytics.FactCarrierProfile f

INNER JOIN analytics.DimSex sx
    ON f.SexKey = sx.SexKey

INNER JOIN analytics.DimAgeCategory ag
    ON f.AgeCategoryKey = ag.AgeCategoryKey

INNER JOIN analytics.DimICD9 ic
    ON f.ICD9Key = ic.ICD9Key

INNER JOIN analytics.DimHCPCS hc
    ON f.HCPCSKey = hc.HCPCSKey

INNER JOIN analytics.DimBETOS bt
    ON f.BETOSKey = bt.BETOSKey

INNER JOIN analytics.DimProviderType pr
    ON f.ProviderTypeKey = pr.ProviderTypeKey

INNER JOIN analytics.DimServiceType sv
    ON f.ServiceTypeKey = sv.ServiceTypeKey

INNER JOIN analytics.DimPlaceOfService ps
    ON f.PlaceOfServiceKey = ps.PlaceOfServiceKey;
');

-- ------------------------------------------------------------
-- VALIDATION
-- ------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS ViewRows,

    COUNT_BIG(DISTINCT ProfileKey)
        AS DistinctProfiles,

    SUM(LineItemCount)
        AS RepresentedLines,

    SUM(
        CASE WHEN IsBlankICD = 1
             THEN 1 ELSE 0 END
    ) AS BlankICDProfiles,

    SUM(
        CASE WHEN IsZeroServiceCount = 1
             THEN 1 ELSE 0 END
    ) AS ZeroServiceProfiles,

    SUM(
        CASE
            WHEN SexCode IS NULL
              OR SexLabel IS NULL
              OR AgeCategoryCode IS NULL
              OR AgeCategoryLabel IS NULL
              OR HCPCSCode IS NULL
              OR BETOSCode IS NULL
              OR ProviderTypeCode IS NULL
              OR ServiceTypeCode IS NULL
              OR PlaceOfServiceCode IS NULL
              OR LineItemCount IS NULL
              OR ServiceCount IS NULL
              OR RoundedMedicarePaymentAmount IS NULL
            THEN 1
            ELSE 0
        END
    ) AS UnexpectedNullRows,

    SUM(
        CASE
            WHEN ICD9Code IS NULL
             AND IsBlankICD = 0
            THEN 1
            ELSE 0
        END
    ) AS UnexpectedICDNullRows

FROM analytics.vw_BI_CarrierProfile;
