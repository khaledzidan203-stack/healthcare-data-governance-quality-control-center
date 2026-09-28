# REFERENCE DATA / RDM ASSESSMENT

## Decision

Reference Data Management is applicable.

Master Data Management is currently NOT APPLICABLE because the
dataset contains no governed enterprise master entity such as
patient, provider master, customer or facility master.

## Reference Domains

| Domain | Observed Values | Decision |
|---|---:|---|
| Sex | 2 | Controlled reference domain |
| Age Category | 6 | Controlled reference domain |
| ICD-9 | 925 nonblank | External clinical reference-code domain |
| HCPCS | 4,900 | External clinical/service reference-code domain |
| BETOS | 98 | External service classification domain |
| Provider Type | 6 | Controlled reference domain |
| CMS Type of Service | 20 | Controlled reference domain |
| Place of Service | 28 | Controlled reference domain |

## Governance Rules

- Source codes must remain traceable to CMS source values.
- Reference labels must come from authoritative documentation.
- Unknown or unresolved mappings must not be invented.
- Reference mappings must not silently change historical interpretation.
- ICD-9 documentation cardinality conflict remains recorded separately.
- Blank ICD remains a DQ condition, not a reference value.

## Current Decision

RDM: REQUIRED

MDM: NOT APPLICABLE AT CURRENT SCOPE

Reference structures will be implemented in the analytical model
only where they improve interpretation and maintain source lineage.

## Release clarification

The future-tense reference implementation decision above is historical. Eight dimensions are now implemented; the blank-source ICD dimension member is preserved without representing a valid clinical code. See [final release validation](FINAL_RELEASE_VALIDATION.md).
