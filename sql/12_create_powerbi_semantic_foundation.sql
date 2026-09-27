USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

EXEC(N'
CREATE OR ALTER VIEW analytics.vw_PBI_FactCarrierProfile
AS
SELECT
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

    CONVERT(
        bigint,
        CONVERT(bigint, ServiceCount) * LineItemCount
    ) AS RepresentedServiceUnits,

    CONVERT(
        decimal(19,2),
        MedicarePaymentAmount * LineItemCount
    ) AS RepresentedRoundedMedicarePayment,

    IsBlankICD,
    IsZeroServiceCount

FROM analytics.FactCarrierProfile;
');

SELECT
    COUNT_BIG(*) AS FactRows,

    COUNT_BIG(DISTINCT ProfileKey)
        AS DistinctProfiles,

    SUM(LineItemCount)
        AS RepresentedLines,

    SUM(RepresentedServiceUnits)
        AS RepresentedServiceUnits,

    SUM(RepresentedRoundedMedicarePayment)
        AS RepresentedPayment,

    SUM(
        CASE WHEN IsBlankICD = 1
             THEN 1 ELSE 0 END
    ) AS BlankICDProfiles,

    SUM(
        CASE WHEN IsZeroServiceCount = 1
             THEN 1 ELSE 0 END
    ) AS ZeroServiceProfiles

FROM analytics.vw_PBI_FactCarrierProfile;
