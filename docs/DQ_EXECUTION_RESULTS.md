# DATA QUALITY EXECUTION RESULTS

## Current Source

Physical rows: 2,801,660
SUM(CAR_LINE_CNT): 70,052,393

## Key Findings

- Blank ICD profiles: 502
- Blank ICD represented lines: 13,506
- Zero service-count profiles: 22
- Zero service-count represented lines: 59
- Duplicate candidate profiles: 0
- Payment rounding failures: 0
- ICD distinct nonblank: 925
- HCPCS distinct: 4,900
- BETOS distinct: 98
- Provider types: 6
- Service types: 20
- Place-of-service values: 28

## Rule Results

| Rule | Status |
|---|---|
| DQ-001 | PASS |
| DQ-002 | PASS |
| DQ-003 | WARN |
| DQ-004 | PASS |
| DQ-005 | PASS |
| DQ-006 | WARN |
| DQ-007 | PASS |
| DQ-008 | PASS |
| DQ-009 | PASS |
| DQ-010 | PASS |
| DQ-011 | PASS |
| DQ-012 | PASS |
| DQ-013 | PASS |
| DQ-014 | PASS |
| DQ-015 | PASS |
| DQ-016 | SOURCE_CONFLICT |
| DQ-017 | PASS |
| DQ-018 | PASS |
| DQ-019 | PASS |

## Summary

PASS: 16
WARN: 2
SOURCE_CONFLICT: 1
FAIL: 0
