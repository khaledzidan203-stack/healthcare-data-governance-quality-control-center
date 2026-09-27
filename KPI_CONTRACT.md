# KPI & METRIC CONTRACT

## Governed Population

Source:

nalytics.FactCarrierProfile

Grain:

One row = one published CMS analytical profile.

Weight:

LineItemCount = number of represented carrier line items.

Reference year:

2010.

## KPI Contracts

| ID | Metric | Formula | Aggregation |
|---|---|---|---|
| KPI-001 | Profile Count | COUNTROWS(FactCarrierProfile) | Additive profile count |
| KPI-002 | Represented Line Items | SUM(LineItemCount) | Additive |
| KPI-003 | Represented Service Units | SUM(ServiceCount × LineItemCount) | Weighted additive |
| KPI-004 | Represented Rounded Medicare Payment | SUM(MedicarePaymentAmount × LineItemCount) | Weighted additive |
| KPI-005 | Avg Service Units per Represented Line | KPI-003 / KPI-002 | Ratio of totals |
| KPI-006 | Avg Rounded Payment per Represented Line | KPI-004 / KPI-002 | Ratio of totals |
| KPI-007 | Blank ICD Profiles | COUNT where IsBlankICD = 1 | Profile count |
| KPI-008 | Blank ICD Represented Lines | SUM(LineItemCount where IsBlankICD = 1) | Additive |
| KPI-009 | Blank ICD Line Rate | KPI-008 / KPI-002 | Ratio of totals |
| KPI-010 | Zero-Service Profiles | COUNT where IsZeroServiceCount = 1 | Profile count |
| KPI-011 | Zero-Service Represented Lines | SUM(LineItemCount where IsZeroServiceCount = 1) | Additive |
| KPI-012 | Zero-Service Line Rate | KPI-011 / KPI-002 | Ratio of totals |

## Validated Baseline

- Profile Count: 2801660
- Represented Line Items: 70052393
- Represented Service Units: 105487211
- Represented Rounded Medicare Payment: 3842966475.00
- Average Service Units / Line: 1.505833
- Average Rounded Payment / Line: 54.858461
- Blank ICD Profiles: 502
- Blank ICD Represented Lines: 13506
- Blank ICD Line Rate: 0.00019200
- Zero-Service Profiles: 22
- Zero-Service Represented Lines: 59
- Zero-Service Line Rate: 0.00000000

## Analytical Guardrails

- Profile Count and Represented Line Items are different metrics.
- Payment and service metrics must use LineItemCount weighting.
- Rates must use ratio-of-totals, not averages of row-level percentages.
- Medicare payment values in this PUF are rounded values.
- Do not describe weighted rounded payment as an exact national Medicare expenditure total.
- Do not multiply the 5% beneficiary sample by 20 and present the result as a validated national estimate.
- No date field exists in the governed analytical source beyond the 2010 reference year.
- Therefore YoY, MoM, monthly trends and fabricated date analysis are OUT OF SCOPE.
- Codes such as HCPCS, BETOS, provider type and place of service are dimensions, not numeric measures.
