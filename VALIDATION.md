# VALIDATION

## CP5 - Governed SQL Foundation

Status: PASS

- RAW rows: 2,801,660
- STAGING rows: 2,801,660
- Represented line items: 70,052,393
- Exact staging profiles: 2,801,660
- Duplicate profiles: 0
- Blank ICD profiles preserved: 502
- Zero-service profiles preserved: 22
- RAW source modified: No
- Governance Source Registry and Load Run tracking implemented.

## CP7 - Canonical Analytical Model

Status: PASS

- Fact rows: 2,801,660
- Represented line items: 70,052,393
- Broken foreign keys: 0
- Blank ICD profiles preserved: 502
- Zero-service profiles preserved: 22
- All dimension cardinalities reconciled.
- Weighted demographic totals reconciled to source baseline.

## CP8 - KPI & Metric Contracts

Status: PASS

- 12 governed metric contracts defined.
- SQL KPI baseline view created.
- Weighted service/payment logic uses LineItemCount.
- Ratio metrics use ratio-of-totals.
- Profile Count and represented line-item volume remain distinct.
- Unsupported time-series metrics explicitly excluded.
