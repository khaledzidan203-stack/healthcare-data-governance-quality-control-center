# CANONICAL ANALYTICAL MODEL

## Grain

One row in nalytics.FactCarrierProfile represents one governed
CMS analytical profile.

## Fact

nalytics.FactCarrierProfile

Rows: 2,801,660

Represented carrier line items: 70,052,393

## Dimensions

- DimSex: 2
- DimAgeCategory: 6
- DimICD9: 926 including governed blank-source member
- DimHCPCS: 4,900
- DimBETOS: 98
- DimProviderType: 6
- DimServiceType: 20
- DimPlaceOfService: 28

## Validation

- Broken foreign keys: 0
- Blank ICD profiles preserved: 502
- Zero-service profiles preserved: 22
- Male weighted lines: 29,066,890
- Female weighted lines: 40,985,503
- Age 85+ weighted lines: 11,289,369

## Modeling Rule

LineItemCount is the profile weight representing underlying
carrier line-item volume.

Codes are dimensions; numeric-looking codes must not be summed.

No unsupported reference descriptions were invented.
