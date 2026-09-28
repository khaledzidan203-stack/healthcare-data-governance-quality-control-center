# Reproducibility

## Prerequisites

Use Windows with SQL Server, SQL Server Management Studio or another SQL client, Power BI Desktop supporting PBIP/PBIR/TMDL, Python 3 with `pyodbc`, Microsoft ODBC Driver 17 or 18 for SQL Server, PowerShell and Git. DAX Studio CLI (`dscmd`) is optional for live semantic reconciliation. Versions are not fully pinned; validate compatibility in your environment.

## Recommended one-command setup

For a fresh local environment, first place the official 2010 CMS CSV at `data/2010_BSA_Carrier_PUF.csv`, then run from the repository root:

```powershell
.\scripts\setup\Initialize-Project.ps1
```

The setup script is deliberately fail-safe:

- verifies the governed source SHA-256 before any database work;
- requires SQL Server to be reachable as `localhost`;
- refuses to continue if `HealthcareGovernanceQC` already exists, so it cannot silently overwrite an existing database;
- changes the historical source-file path only in a temporary copy of SQL script 02;
- executes the canonical SQL scripts 01–12 in order with `sqlcmd -b`;
- validates core SQL totals after the build;
- creates `.venv`, installs `requirements.txt`, and runs the independent Python reconciliation;
- never modifies the committed PBIP/PBIR/TMDL/DAX artifacts.

Use `-SkipPythonValidation` only when intentionally performing the SQL/Power BI setup without the independent Python pass. Use `-OpenPowerBI` to open the PBIP after a successful build.


## Acquire the source separately

Use the official [CMS BSA Carrier Line Items PUF download page](https://www.cms.gov/data-research/statistics-trends-and-reports/basic-stand-alone-medicare-claims-public-use-files/bsa-carrier-line-items-puf), selecting the **2010** CSV and documentation. The [2010 General Documentation](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/bsapufs/downloads/2010_carrier_gendoc.pdf) provides source context. CMS files are not bundled here.

Place the extracted project source at `data/2010_BSA_Carrier_PUF.csv`. Expected SHA-256 from the governed ingestion evidence:

```text
923810243278103455c9408fedcf9981a1234f4f9f216902a877977bfc02e7f6
```

Verify with `Get-FileHash -Algorithm SHA256`. Stop on a mismatch; do not silently substitute a different year/export. Preserve original values and documentation conflicts. Source grain in this project is one published analytical profile weighted by `CAR_LINE_CNT`.

## Database build order - new isolated database only

Database name: `HealthcareGovernanceQC`. Historical scripts assume a local SQL Server and Windows integrated authentication. The canonical SQL 02 file retains the original governed workstation path as historical implementation evidence. The recommended setup script replaces that path only in a temporary execution copy. The SQL Server service must still be able to read the selected local CSV path.

| Order | Script | Role |
|---|---|---|
| 01 | `sql/01_create_database_foundation.sql` | Database and schemas |
| 02 | `sql/02_load_raw_carrier.sql` | RAW ingestion and load governance |
| 03 | `sql/03_validate_raw_grain.sql` | Read-only RAW grain check |
| 04 | `sql/04_build_staging_carrier.sql` | Typed staging and DQ flags |
| 05 | `sql/05_validate_staging.sql` | Read-only layer reconciliation |
| 06 | `sql/06_reference_data_assessment.sql` | Read-only reference assessment |
| 07 | `sql/07_build_canonical_analytical_model.sql` | Dimensions and fact |
| 08 | `sql/08_validate_canonical_model.sql` | Read-only model/FK checks |
| 09 | `sql/09_create_kpi_baseline.sql` | Governed KPI view |
| 10 | `sql/10_build_data_lineage.sql` | Lineage registry |
| 11 | `sql/11_create_bi_consumption_contract.sql` | BI consumption views |
| 12 | `sql/12_create_powerbi_semantic_foundation.sql` | Power BI fact view |

Build scripts contain DDL/DML and some replace existing data. This order documents reproduction; it is not permission to rerun them against an existing validated database. The release did not execute these builders.

## Python environment

From the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe python/eda/cp9_python_validation.py
```

The script performs a SELECT against `analytics.FactCarrierProfile` and prints independent weighted totals. Compare output to [KPI_CONTRACT.md](../KPI_CONTRACT.md); it does not implement a full assertion harness. Demographic checks assume the original surrogate-key mapping; verify dimensions if rebuilding. No credentials are embedded: the connection uses Windows trusted authentication. `TrustServerCertificate` is a local development setting, not a deployment security recommendation.

## Power BI

Open `powerbi/HealthcareGovernanceQC.pbip`. Its relative report-to-model reference must remain intact. Nine imported objects use `Sql.Database("localhost", "HealthcareGovernanceQC")`. Configure the corresponding local instance/Windows credentials or intentionally adapt connection settings in your own copy. Refresh only after SQL validation. Do not rely on excluded `.pbi/cache.abf` for reproducibility.

The `_Measures` table is intentionally empty/disconnected. Do not add a Date table, change governed DAX or reconstruct identities. Age sorting and label columns are already present. Opening page is INDEX; Ctrl+Click navigation is used in Desktop editing mode.

## Safe validation entrypoints

- SQL 03, 05, 06 and 08 are SELECT-only checks; inspect returned values against documented baselines.
- CP9 Python recalculates core/DQ totals independently.
- `scripts/validation/Runtime_KPI_Reconciliation.ps1` requires the matching open PBIP and DAX Studio CLI. It is project/model read-only, writes temporary DAX/CSV files only to the configured external output directory, and does not stage or commit changes.
- Historical mutating checkpoint orchestrators are intentionally excluded from the public portfolio. Reproduction should use the canonical `sql/` build definitions plus the retained validation/documentation evidence, rather than historical automation scripts.

Validate JSON, bindings, navigation, canvas bounds and the 7-page/142-visual/10-table/12-measure/8-relationship contract. Runtime rendering still needs Desktop. Save/close and review Git changes before any commit; Desktop may serialize unrelated files.

## Publication boundary

Publish only reviewed Git-tracked files. Exclude data, PDFs, caches, PBIX, database backups, personal credentials and certificates. Screenshots under `docs/screenshots/` are report evidence only. The retained runtime validator uses configurable project/output paths and contains no embedded credentials. No whole-workspace ZIP is part of this release.
