# Portfolio Case Study

**Khaled Zidan - Healthcare Data Governance & Quality Control Center**

## Challenge

Turn a historical public healthcare file into credible analytics without confusing published profiles with people or claims. Preserve conflicting documentation, weighted aggregation and small but meaningful data-quality populations.

## Solution and architecture

A SQL Server RAW -> STAGING -> ANALYTICS flow preserves source values, types data, records DQ flags and exposes a dimensional fact model. GOVERNANCE records source identity and lineage. Python independently reconciles weighted metrics. A ten-table Power BI semantic model exposes twelve governed measures to a seven-page PBIP report.

## Governance controls

Explicit profile grain, source fingerprint, hidden technical keys, disconnected measure host, single-direction relationships and disabled time intelligence prevent common interpretation errors. ICD-9 and HCPCS documentation disagreements remain visible instead of being silently corrected. No patient reconstruction or cross-PUF identity linkage is supported.

## Data quality

The retained static evaluation covers 19 rules: 16 PASS, 2 WARN, 1 SOURCE_CONFLICT and 0 FAIL. It preserves 502 blank-ICD profiles representing 13,506 lines and 22 zero-service profiles representing 59 lines. Dynamic report signals can be filtered; global rule status cannot.

## Power BI

INDEX connects six analytical pages covering executive scale, DQ, coding, service/payment, demographic/provider mix and quality monitoring. Human-readable labels, chronological age sorting and governed Top 10 comparisons make the model reviewable. [Screenshots and page guide](../README.md#screenshots) show the actual report.

## Validation

Historical SQL/Python/DAX and Desktop page checks are retained. The final release freshly validated structural bindings/navigation/canvas boundaries and executed a SELECT-only aggregate reconciliation. Report and semantic implementations were preserved. See [release evidence](FINAL_RELEASE_VALIDATION.md).

## Technical stack

SQL Server - Python/pyodbc - PowerShell - Power BI Desktop/PBIP - TMDL - PBIR - DAX - Git/GitHub.

## Key lessons

- Define the grain before choosing a KPI.
- Weight utilization/payment by represented line counts.
- Keep exceptions and documentation disagreements traceable.
- Separate static global validation from dynamic analytical filters.
- Distinguish historical runtime evidence from newly executed tests.
- Publish a reviewed artifact set, not raw data or local caches.

This is a portfolio demonstration with a historical 5% public-use sample and rounded/coarsened payment information. It does not establish patient-level outcomes, national expenditure estimates or regulatory certification.
