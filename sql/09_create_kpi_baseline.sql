USE [HealthcareGovernanceQC];
SET NOCOUNT ON;

EXEC(N'
CREATE OR ALTER VIEW analytics.vw_CarrierKPIBaseline
AS

SELECT
    COUNT_BIG(*) AS ProfileCount,

    SUM(LineItemCount) AS RepresentedLineItemCount,

    SUM(
        CONVERT(bigint, ServiceCount) * LineItemCount
    ) AS RepresentedServiceUnits,

    SUM(
        CAST(
            MedicarePaymentAmount * LineItemCount
            AS decimal(38,2)
        )
    ) AS RepresentedRoundedMedicarePayment,

    CAST(
        SUM(CONVERT(decimal(38,6), ServiceCount) * LineItemCount)
        /
        NULLIF(SUM(CONVERT(decimal(38,6), LineItemCount)),0)
        AS decimal(18,6)
    ) AS AvgServiceUnitsPerRepresentedLine,

    CAST(
        SUM(CONVERT(decimal(38,6), MedicarePaymentAmount) * LineItemCount)
        /
        NULLIF(SUM(CONVERT(decimal(38,6), LineItemCount)),0)
        AS decimal(18,6)
    ) AS AvgRoundedPaymentPerRepresentedLine,

    SUM(
        CASE WHEN IsBlankICD = 1
             THEN 1 ELSE 0 END
    ) AS BlankICDProfiles,

    SUM(
        CASE WHEN IsBlankICD = 1
             THEN LineItemCount ELSE 0 END
    ) AS BlankICDRepresentedLines,

    CAST(
        SUM(
            CASE WHEN IsBlankICD = 1
                 THEN CONVERT(decimal(38,6),LineItemCount)
                 ELSE 0 END
        )
        /
        NULLIF(
            SUM(CONVERT(decimal(38,6),LineItemCount)),
            0
        )
        AS decimal(18,8)
    ) AS BlankICDLineRate,

    SUM(
        CASE WHEN IsZeroServiceCount = 1
             THEN 1 ELSE 0 END
    ) AS ZeroServiceProfiles,

    SUM(
        CASE WHEN IsZeroServiceCount = 1
             THEN LineItemCount ELSE 0 END
    ) AS ZeroServiceRepresentedLines,

    CAST(
        SUM(
            CASE WHEN IsZeroServiceCount = 1
                 THEN CONVERT(decimal(38,6),LineItemCount)
                 ELSE 0 END
        )
        /
        NULLIF(
            SUM(CONVERT(decimal(38,6),LineItemCount)),
            0
        )
        AS decimal(18,8)
    ) AS ZeroServiceLineRate

FROM analytics.FactCarrierProfile;
');
