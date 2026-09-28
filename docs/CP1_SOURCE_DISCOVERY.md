# CP1 - Source Discovery

> HISTORICAL CHECKPOINT - retained as evidence of that phase. For current state see [final release validation](FINAL_RELEASE_VALIDATION.md).

## Validated Baseline

- Physical CSV rows: 2,801,660
- Columns: 11
- SUM(CAR_LINE_CNT): 70,052,393
- Candidate profile duplicates: 0
- HCPCS distinct: 4,900
- BETOS distinct: 98
- Provider types: 6
- Service types: 20
- Place-of-service codes: 28
- Blank ICD profiles: 502
- Blank ICD represented line items: 13,506
- Zero service-count profiles: 22
- Zero service-count represented line items: 59
- Payment rounding failures: 0

## Open Governance Findings

1. ICD-9 documentation cardinality conflict.
2. CAR_LINE_CNT documentation conflict.
3. Age category 6 documentation conflict.
4. Service-count range conflict.

Raw source was not modified.
