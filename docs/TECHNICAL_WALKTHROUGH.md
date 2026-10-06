# Technical Walkthrough — 60–90 seconds

This walkthrough summarizes the implemented architecture, governance controls, analytical model, validation evidence and reporting layer without changing the validated project implementation.

## 0–10 sec — Project scope

This project converts the CMS 2010 BSA Carrier Line Items Public Use File into a governed healthcare analytics environment using SQL Server, Python and Power BI. The objective is to preserve source meaning, make data-quality exceptions explicit and expose only governed analytical metrics.

## 10–25 sec — Grain and source governance

The critical modeling rule is that one physical source row is one published analytical profile, not one patient, claim or individual claim line. `CAR_LINE_CNT` is the weight representing underlying carrier line items. The source fingerprint is governed and source-document conflicts are preserved rather than silently corrected.

## 25–45 sec — Architecture

The pipeline follows RAW → STAGING → ANALYTICS with a separate GOVERNANCE layer. RAW preserves the source, STAGING applies controlled typing and DQ flags, ANALYTICS builds eight dimensions plus `FactCarrierProfile`, and GOVERNANCE records source identity, load runs and field-level lineage. Python independently recalculates the governed weighted KPIs.

## 45–65 sec — Data quality and analytics

The retained global DQ snapshot contains 19 rules: 16 PASS, 2 WARN, 1 SOURCE_CONFLICT and 0 FAIL. Blank ICD and zero-service populations remain visible rather than being removed. The Power BI model contains 10 tables, 8 active single-direction relationships and 12 governed measures, with time intelligence intentionally disabled because the governed source has no valid sub-year date grain.

## 65–80 sec — Reporting and validation

The seven-page Power BI report covers executive scale, data quality, coding quality, service and payment patterns, demographic/provider mix and quality issue monitoring. The final release validation separately distinguishes fresh structural and SQL checks from retained Python, DAX and Desktop runtime evidence.

## 80–90 sec — Engineering outcome

The implementation demonstrates governance-by-design across source identity, grain control, weighted metric definitions, reference-data handling, lineage, independent reconciliation, semantic modeling, reproducibility and automated repository validation.

## Suggested presentation order

1. Repository overview and Project at a Glance.
2. Architecture diagram.
3. Data Grain and KPI contract.
4. Data Quality and source-conflict controls.
5. Executive Overview screenshot.
6. Data Quality Overview or Quality Issues Monitor.
7. Semantic model / validation section.
8. GitHub Actions validation badge.

## Presentation boundaries

- Do not describe analytical profiles as patients, beneficiaries or claims.
- Do not present weighted rounded payment as exact national Medicare expenditure.
- Do not multiply the 5% sample by 20 and claim a validated national estimate.
- Do not fabricate monthly, YoY or other unsupported time analysis.
- Do not imply HIPAA or regulatory certification.
- Preserve source-document conflicts and historical validation boundaries exactly as documented.
