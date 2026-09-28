# Healthcare Data Governance & Quality Control Center

## Overview

A production-style healthcare analytics and governance portfolio project by **Khaled Zidan**, built with SQL Server, Python and Power BI using the public **CMS 2010 BSA Carrier Line Items PUF**. The deliverable combines governed ingestion, traceable quality findings, an explicit semantic model and a seven-page analytical report.

![Report navigation index](docs/screenshots/01-index.png)

[Portfolio case study](docs/PORTFOLIO_CASE_STUDY.md) - [Release validation](docs/FINAL_RELEASE_VALIDATION.md) - [Reproduce the project](docs/REPRODUCIBILITY.md)

## Business / Governance Problem

Published-profile data is easy to misinterpret: counting rows is different from counting represented services, and financial totals require the correct weight. Source documentation can also disagree with itself. This project makes the grain, aggregation rules, quality exceptions and source conflicts visible from ingestion through reporting.

## Architecture

```mermaid
flowchart LR
    A[CMS public source] --> B[RAW: source preservation]
    B --> C[STAGING: types and DQ flags]
    C --> D[ANALYTICS: dimensions and fact]
    C --> G[GOVERNANCE: source registry and lineage]
    D --> G
    D --> E[Power BI semantic model: TMDL]
    E --> F[Seven-page Power BI report: PBIR]
    G --> V[Validation and portfolio evidence]
    F --> V
```

**Stack:** SQL Server, Python, Power BI PBIP, TMDL, PBIR, PowerShell and Git. Python independently reconciles weighted totals; explicit DAX measures carry the governed metric definitions into the report.

## Data Grain

**One source row = one unique published analytical profile.** It is not one patient, beneficiary, claim or individual claim line. `LineItemCount` is the number of carrier line items represented by that profile. Service units and rounded payment are weighted by this count.

## Validated Scale

| Governed metric | Value |
|---|---:|
| Published profiles | 2,801,660 |
| Represented line items | 70,052,393 |
| Represented service units | 105,487,211 |
| Represented rounded Medicare payment | 3,842,966,475.00 |
| Average service units per represented line | 1.505833 |
| Average rounded payment per represented line | 54.858461 |

These are totals for the published sample, not validated national estimates. Definitions and precise rates are in the [KPI contract](KPI_CONTRACT.md).

## Data Quality

| Signal | Profiles | Represented lines | Rate of represented lines |
|---|---:|---:|---:|
| Blank ICD | 502 | 13,506 | approximately 0.0192798553% |
| Zero-service | 22 | 59 | approximately 0.000084222676% |

The retained **global static DQ snapshot** is **19 rules: 16 PASS, 2 WARN, 1 SOURCE_CONFLICT, 0 FAIL**. Slicers affect issue KPIs/charts, not this historical rule snapshot. Exceptions are preserved, not silently deleted or imputed. See the [rule register](docs/DQ_RULE_REGISTER.md) and [execution evidence](docs/DQ_EXECUTION_RESULTS.md).

## Source Governance Conflicts

| Topic | Documented values / observation | Treatment |
|---|---|---|
| ICD-9 | General Documentation 926 vs Data Dictionary 923; model 926 members: 925 nonblank + one blank | Both source values retained |
| HCPCS | General Documentation 4,900 vs Data Dictionary 4,736; model 4,900 | Both source values retained |
| BETOS | 98 documented and observed | Consistent |
| Service Count | Documented 1-999; observed zero values | Preserve and report zero-service population |
| Age category 6 | Documented Data Dictionary typo | Preserve source conflict |

No silent reconciliation. The original source also has a recorded `CAR_LINE_CNT` documentation conflict. See the [data contract](docs/DATA_CONTRACT.md).

## Semantic Model

The star schema has **10 tables, 8 active single-direction dimension-to-fact relationships and 12 explicit governed measures**. Eight dimensions filter `FactCarrierProfile`; the disconnected `_Measures` table holds all measures and no business rows. Technical keys are hidden, age labels sort chronologically, and time intelligence is disabled.

[Semantic model contract](docs/POWER_BI_SEMANTIC_MODEL_CONTRACT.md) - [Analytical model](docs/ANALYTICAL_MODEL.md)

## Power BI Report

| Page | Purpose |
|---|---|
| INDEX | Opening page and six-page navigation |
| Executive Overview | Scale, weighted utilization/payment and quality signals |
| Data Quality Overview | Global DQ snapshot and affected profile/line volumes |
| Coding Quality | ICD-9, HCPCS and BETOS reference context and Top 10 distributions |
| Service & Payment Patterns | Service/place concentration, payment and intensity |
| Demographic & Provider Mix | Age, sex and provider distributions |
| Quality Issues Monitor | Static rule status, filterable exceptions and source conflicts |

The report contains **142 visuals and 24 slicers**, on 1600 x 900 canvases. Every analytical page links back to INDEX.

## Screenshots

User-provided Desktop captures, copied without visual edits. Display units round values; exact baselines are documented above. Images illustrate the saved report and are not a new interactive runtime test.

### Executive Overview
![Executive Overview](docs/screenshots/02-executive-overview.png)

### Data Quality Overview
![Data Quality Overview](docs/screenshots/03-data-quality-overview.png)

### Coding Quality
![Coding Quality](docs/screenshots/04-coding-quality.png)

### Service & Payment Patterns
![Service and Payment Patterns](docs/screenshots/05-service-payment-patterns.png)

### Demographic & Provider Mix
![Demographic and Provider Mix](docs/screenshots/06-demographic-provider-mix.png)

### Quality Issues Monitor
![Quality Issues Monitor](docs/screenshots/07-quality-issues-monitor.png)

## Validation

Validation spans source identity/grain, SQL reconciliation, independent Python calculations, semantic checks, PBIR structure/navigation/bindings, prior Desktop page review and Git/publication scope. The final release run freshly rechecked static artifacts and executed a read-only SQL aggregate query. Previous Python and Desktop/DAX runtime evidence is retained and explicitly distinguished from new testing.

This is not Microsoft schema certification. Static JSON validity alone does not prove rendering. See [final release validation](docs/FINAL_RELEASE_VALIDATION.md) and [historical validation record](VALIDATION.md).

## Repository Structure

- `sql/`: governed build definitions and separate read-only validation queries.
- `python/eda/`: independent weighted KPI reconciliation.
- `powerbi/`: PBIP, report definition, semantic model and governed DAX reference.
- `scripts/checkpoints/`: historical orchestration and retained validators; not a batch-run release pipeline.
- `docs/`: contracts, lineage, governance evidence, reproducibility and screenshots.

Raw CSV, source PDFs, database files and Power BI caches are excluded. The source dataset must be acquired separately.

## Reproducibility

Follow [REPRODUCIBILITY.md](docs/REPRODUCIBILITY.md) for prerequisites, source fingerprint, database build order, local connection configuration and safe validation entrypoints. Do not run historical builders against an already validated database as if they were audits.

## Limitations

- Historical public-use 2010 data from a 5% beneficiary sample.
- Payment rounding/coarsening and public-use suppression apply.
- Analytical profiles are not people; no patient-level conclusions.
- Source-document conflicts remain explicit.
- No date grain for meaningful monthly, YoY or other time-series analysis.
- No automatic multiplication by 20 to claim national expenditure.
- Raw CMS source is not distributed in this repository.
- Existing semantic labels are preserved; this release does not claim a new exhaustive label-to-source audit.

## Privacy / Ethical Use

No re-identification, beneficiary/claim reconstruction or cross-PUF individual linkage. This portfolio does not assert HIPAA certification or imply access to identifiable patient records. See [data classification](docs/DATA_CLASSIFICATION.md).

## Author / Portfolio

**Khaled Zidan** - healthcare data governance, data quality, analytics engineering and business intelligence portfolio work. No employer affiliation or CMS endorsement is implied. No separate open-source license is granted by this release; CMS source materials retain their own terms.
