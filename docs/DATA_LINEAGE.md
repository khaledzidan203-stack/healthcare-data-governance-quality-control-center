# DATA LINEAGE

## Status

PASS

## Governed Lineage Path

Source CSV
-> RAW
-> STAGING
-> Analytical Dimensions / Fact
-> Governed KPI Baseline

## Source

2010_BSA_Carrier_PUF.csv

SHA-256:

923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6

## Registry

SQL object:

governance.DataLineage

Total lineage edges:

68

## Coverage

- Source -> RAW: 12
- RAW -> STAGING: 14
- STAGING -> Dimensions: 8
- STAGING -> Fact: 14
- Fact -> KPI: 20

## KPI Traceability

Governed KPI contracts:

12

Fully source-traceable KPI contracts:

12 / 12

## Governance Rules

- RAW values remain source-preserving.
- STAGING transformations are explicitly documented.
- DQ flags remain traceable to original source fields.
- Analytical fact fields remain traceable to staging.
- KPI formulas identify their material fact inputs.
- Source SHA-256 is retained as lineage evidence.
- Blank ICD values are governed, not silently discarded.
- Zero service-count conditions are governed, not silently discarded.
