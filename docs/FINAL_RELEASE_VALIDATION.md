# Final Release Validation

## Release baseline

Date: **2026-09-28**. Implementation baseline before this documentation/screenshots release: **ecfd43f96348bd10c53f11dad7ce9b4c05ab6b02** (`checkpoint: finalize quality issues monitor`), branch `master`.

This release changes documentation, publication exclusions and report screenshots. It does not redesign the report or change SQL/DAX/TMDL logic. The release commit can be located by `release: finalize healthcare governance portfolio`; its identifier is recorded in Git and the final publication output, avoiding a self-referential commit hash in this file.

## Fresh release checks

| Check | Result |
|---|---|
| Report pages | 7 |
| Visual containers | 142 |
| Slicers | 24 |
| Page order / opening page | Approved seven-page order; INDEX |
| Invalid Power BI JSON | 0 |
| Navigation buttons / broken targets | 12 / 0 |
| Missing semantic bindings | 0 |
| Visuals outside 1600 x 900 canvases | 0 |
| Full-canvas selectable visuals | 0 |
| Analytical visualHeader arrays | 73 / 73; transparency 100% |
| Unexpected mobile.json | 0 |
| Semantic tables / measures / relationships | 10 / 12 / 8 |
| Relationships involving _Measures | 0 |
| Time intelligence | Disabled |
| Age sort | Existing AgeCategoryLabel -> SortOrder; explicit ascending age chart sorts |
| Display labels | Existing age, sex, provider, service and place labels retained |

All seven page subtrees match their final CP13 checkpoint versions. Structured JSON references, including native TopN aliases, were checked against current TMDL declarations. TopN filters remain root-level filterConfig objects. No Microsoft schema-engine certification or new Desktop interactive smoke test is claimed.

Power BI Desktop was already user-opened at release preflight. It was not launched, killed or used to modify the report by the release process. Preflight tracked files were clean; only seven user-created screenshot copies were untracked. These were preserved outside the repository, while byte-identical copies were placed under `docs/screenshots/` with release filenames.

## Fresh SQL reconciliation

A Windows-authenticated, **SELECT-only** aggregate query against `HealthcareGovernanceQC.analytics.FactCarrierProfile` succeeded during this release. No DDL/DML, load/rebuild script, CP10 or CP11 execution occurred. The first sandbox connection failed with an SSPI context error; the same authorized read-only query succeeded outside that sandbox.

| Metric | Fresh SQL result | Expected | Difference |
|---|---:|---:|---:|
| Profile Count | 2,801,660 | 2,801,660 | 0 |
| Represented Line Items | 70,052,393 | 70,052,393 | 0 |
| Represented Service Units | 105,487,211 | 105,487,211 | 0 |
| Represented Rounded Medicare Payment | 3,842,966,475.00 | 3,842,966,475.00 | 0 |
| Blank ICD Profiles | 502 | 502 | 0 |
| Blank ICD Represented Lines | 13,506 | 13,506 | 0 |
| Zero-Service Profiles | 22 | 22 | 0 |
| Zero-Service Represented Lines | 59 | 59 | 0 |

The query counted profiles, summed LineItemCount, summed ServiceCount * LineItemCount and MedicarePaymentAmount * LineItemCount, and used the two governed boolean DQ flags for affected counts/lines. It did not execute or rewrite the SQL KPI view.

Ratios derived from these totals agree with retained DAX runtime evidence: average units 1.5058330841032084; average rounded payment 54.858461080694276; blank-ICD rate 0.00019279855293451574 (0.019279855293451574%); zero-service rate 8.4222676019076182E-07 (0.00008422267601907618%). These ratios were not a fresh DAX execution. Older rounded documentation was corrected; DAX was unchanged.

## Historical evidence retained

- [Python reconciliation](PYTHON_EDA_VALIDATION.md): independent weighted calculation; not rerun during this release.
- [CP12 DAX runtime reconciliation](validation/CP12_G2B_RUNTIME_KPI_RECONCILIATION.md): 12/12 governed measures passed; not a fresh release runtime test.
- [Semantic closeout](validation/CP12_G3_FINAL_SEMANTIC_MODEL_CLOSEOUT.md): historical pre-report snapshot.
- [DQ execution](DQ_EXECUTION_RESULTS.md): historical 19-rule global snapshot, not freshly rerun.
- Each analytical page previously passed user Desktop visual/runtime review and saved-state validation before its CP13 commit. See [changelog](../CHANGELOG.md).

## Governance preserved

One source row is a published analytical profile, not a patient, beneficiary, claim or individual claim line. The 2010 public-use file represents a 5% beneficiary sample with rounded/coarsened payment and suppression. Do not extrapolate these totals into certified national estimates.

Global DQ snapshot: **19 rules, 16 PASS, 2 WARN, 1 SOURCE_CONFLICT, 0 FAIL**. Literal snapshot text is static; dynamic quality measures remain filterable.

ICD-9 926 vs 923 and HCPCS 4900 vs 4736 remain source-document conflicts. Actual ICD dimension: 926 including 925 nonblank codes plus one blank member. BETOS: 98. Documented service count 1-999 conflicts with observed zeros. Age-code-6 and CAR_LINE_CNT documentation findings are retained. No silent reconciliation.

## Screenshot evidence

Seven user-supplied report images were visually inspected and copied unchanged. Their titles/content correspond to the seven report pages, with default All slicers where visible. Screenshot display units round exact values. The Service & Payment Patterns capture includes a small visible title scrollbar; the approved report was not redesigned for this release. No certificate or synthetic/generated screenshot is included.

| Published file | SHA-256 |
|---|---|
| [01-index.png](screenshots/01-index.png) | `e70d4d58f684e4a2c0634e4987932448cb460fc0473bc072917cb121235ded34` |
| [02-executive-overview.png](screenshots/02-executive-overview.png) | `3d94f06879e6fc3d4646bab21d12994560342781ff1ebf7072c6da3b50a1b220` |
| [03-data-quality-overview.png](screenshots/03-data-quality-overview.png) | `f70234f5f7ee05e95edf3505bae8a2beb733317ffd9b854bfbf43c147a33f5e1` |
| [04-coding-quality.png](screenshots/04-coding-quality.png) | `34146e310b9da87e0df5bf34d0ef7b7572e76a0522db3977eed792fea3e88f85` |
| [05-service-payment-patterns.png](screenshots/05-service-payment-patterns.png) | `bb466b4c3f9ed62700ec5d2b11a7ad38c042aaf8ed8d729ab4de1cd764097f51` |
| [06-demographic-provider-mix.png](screenshots/06-demographic-provider-mix.png) | `5589bd9cace4cceb540e30ec5e13633069d03ba205982e9c46970fa50b1870ed` |
| [07-quality-issues-monitor.png](screenshots/07-quality-issues-monitor.png) | `04ef21123f91637deb99f2d1cb6e1d4e8aa2edb036607cd74a8fe46a2886c038` |

## Release QA and scope

The final gate checks Markdown relative links, screenshot hashes, JSON parsing, unchanged analytical files, staged allowlist and excluded data/cache/certificate paths. Publication uses Git history and the reviewed tracked files, never a whole-workspace ZIP. A targeted scan of the current publication files and 282 reachable historical Git blobs found no candidate secrets using private-key, common GitHub/API token and quoted credential patterns. All 50 repository-relative Markdown links resolved. Protected analytical paths had no diff. No candidate values were printed. This does not constitute a universal security certification.

## Remaining limitations

- Historical Python/DAX/Desktop approvals are retained, not represented as fresh runtime tests.
- Source CSV/PDF bytes and all 19 DQ rules were not rerun in this release.
- Static parsing/binding checks cannot prove every future Desktop version will render identically.
- SQL baseline-view decimal precision was not separately revalidated; this release's numeric evidence comes directly from fact aggregates and retained runtime ratios.
- Existing display-label mappings are retained, not newly certified against every authoritative code entry.
- Reproduction requires separately acquired source files, SQL Server, supported Desktop and local connection configuration.
- Open deployment/retention/regulatory controls remain explicit; no compliance certification or identifiable patient analysis is claimed.
- No new open-source license grant or source-data redistribution is included.
