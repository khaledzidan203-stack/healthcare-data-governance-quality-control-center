# CP12-G2B — Power BI Runtime KPI Reconciliation

## Status

**PASS**

## Validation Method

The governed DAX measures were executed directly against the open:

`HealthcareGovernanceQC.pbip`

using DAX Studio CLI.

No manual port discovery was used.

## Runtime Results

| KPI | Expected | Actual | Difference |
|---|---:|---:|---:|
| Profile Count | 2,801,660 | 2,801,660 | 0 |
| Represented Line Items | 70,052,393 | 70,052,393 | 0 |
| Represented Service Units | 105,487,211 | 105,487,211 | 0 |
| Represented Rounded Medicare Payment | 3,842,966,475 | 3,842,966,475 | 0 |
| Avg Service Units per Represented Line | 1.5058330841032084 | 1.5058330841032084 | 0 |
| Avg Rounded Payment per Represented Line | 54.858461080694276 | 54.858461080694276 | 0 |
| Blank ICD Profiles | 502 | 502 | 0 |
| Blank ICD Represented Lines | 13,506 | 13,506 | 0 |
| Blank ICD Line Rate | 0.00019279855293451574 | 0.00019279855293451574 | 0 |
| Zero-Service Profiles | 22 | 22 | 0 |
| Zero-Service Represented Lines | 59 | 59 | 0 |
| Zero-Service Line Rate | 8.4222676019076182E-07 | 8.4222676019076182E-07 | 0 |

## Reconciliation Summary

- Governed measures tested: **12**
- Passed: **12**
- Failed: **0**
- Semantic model modified by validation: **No**
- PBIP modified by validation: **No**

## Conclusion

The Power BI semantic-model DAX implementation exactly reconciles to the governed CP8 KPI baseline.

**CP12-G2B: COMPLETED**