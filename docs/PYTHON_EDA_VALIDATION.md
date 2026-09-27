# CP9 - Python EDA & Independent Validation

## Result

**PASS**

Python independently recalculated the governed analytical baseline
directly from `analytics.FactCarrierProfile`.

The SQL KPI baseline view was not used for these calculations.

## Core Reconciliation

| Metric | Python Result |
|---|---:|
| Profile Count | 2,801,660 |
| Represented Line Items | 70,052,393 |
| Represented Service Units | 105,487,211 |
| Represented Rounded Medicare Payment | 3,842,966,475.00 |
| Avg Service Units / Line | 1.505833 |
| Avg Rounded Payment / Line | 54.858461 |
| Blank ICD Profiles | 502 |
| Blank ICD Lines | 13,506 |
| Blank ICD Rate | 0.00019280 |
| Zero-Service Profiles | 22 |
| Zero-Service Lines | 59 |
| Zero-Service Rate | 0.00000084 |

## Demographic Reconciliation

| Population | Represented Line Items |
|---|---:|
| Male | 29,066,890 |
| Female | 40,985,503 |
| Age 85+ | 11,289,369 |

## Age Distribution

| Age Category | Represented Line Items |
|---:|---:|
| 1 | 11,414,343 |
| 2 | 12,130,165 |
| 3 | 12,885,504 |
| 4 | 11,786,740 |
| 5 | 10,546,272 |
| 6 | 11,289,369 |

## Validation Architecture

SQL governed analytical fact
? independent Python calculation
? approved SQL KPI baseline comparison
? exact reconciliation

## Guardrails

- `LineItemCount` is used as the analytical weight.
- Profile Count is not interpreted as represented line-item volume.
- Rates use represented line-item denominators.
- No monthly, quarterly, YoY or MoM analysis was performed.
- No date grain below reference year 2010 exists in the governed model.
- No causal inference was performed.
- No national extrapolation was performed.
