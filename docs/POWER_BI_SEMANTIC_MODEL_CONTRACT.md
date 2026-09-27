# POWER BI SEMANTIC MODEL CONTRACT

## Status

READY FOR PBIP CREATION

## Storage Mode

Import.

Rationale:

- historical 2010 source;
- no real-time requirement;
- governed SQL transformation already exists;
- 2,801,660 profile rows are suitable for an imported analytical model.

## Fact

Power BI source:

analytics.vw_PBI_FactCarrierProfile

Semantic model name:

FactCarrierProfile

Validated rows:

2801660

## Dimensions

Use:

- analytics.DimSex
- analytics.DimAgeCategory
- analytics.DimICD9
- analytics.DimHCPCS
- analytics.DimBETOS
- analytics.DimProviderType
- analytics.DimServiceType
- analytics.DimPlaceOfService

## Relationships

All relationships:

Dimension 1 -> * FactCarrierProfile

Filter direction:

Single direction from Dimension to Fact.

Relationships:

DimSex[SexKey]
-> FactCarrierProfile[SexKey]

DimAgeCategory[AgeCategoryKey]
-> FactCarrierProfile[AgeCategoryKey]

DimICD9[ICD9Key]
-> FactCarrierProfile[ICD9Key]

DimHCPCS[HCPCSKey]
-> FactCarrierProfile[HCPCSKey]

DimBETOS[BETOSKey]
-> FactCarrierProfile[BETOSKey]

DimProviderType[ProviderTypeKey]
-> FactCarrierProfile[ProviderTypeKey]

DimServiceType[ServiceTypeKey]
-> FactCarrierProfile[ServiceTypeKey]

DimPlaceOfService[PlaceOfServiceKey]
-> FactCarrierProfile[PlaceOfServiceKey]

## Measure Host

Create a dedicated table:

_Measures

It must have no relationships.

All governed measures should be stored there.

Measure definitions:

powerbi/GOVERNED_MEASURES.dax

## Default Summarization

LineItemCount:
SUM

RepresentedServiceUnits:
SUM

RepresentedRoundedMedicarePayment:
SUM

ProfileKey:
Do not summarize

ServiceCount:
Do not summarize

MedicarePaymentAmount:
Do not summarize

All dimension keys and codes:
Do not summarize

## Hidden Technical Columns

Hide from normal report authoring:

- ProfileKey
- all surrogate foreign keys
- ServiceCount
- MedicarePaymentAmount

Keep DQ flags visible for governed analysis.

## Time Model

No Date table.

Reference period:

2010

Do not fabricate daily/monthly dates.

No YoY / MoM / YTD / MTD measures.

## Governed KPI Baselines

Profile Count:
2801660

Represented Line Items:
70052393

Represented Service Units:
105487211

Represented Rounded Medicare Payment:
3842966475.00

Blank ICD Profiles:
502

Zero-Service Profiles:
22

## Validation Requirement

Before building analytical report pages:

1. Create semantic model.
2. Create all 12 governed measures.
3. Validate them against SQL baseline.
4. Validate them independently with DAX Studio.
5. Only then proceed to report visuals.
