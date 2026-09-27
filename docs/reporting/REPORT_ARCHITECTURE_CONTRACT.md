# REPORT ARCHITECTURE CONTRACT
## Project
Healthcare Data Governance & Quality Control Center

## Status
APPROVED FOR BUILD

## Report Goal
Build an executive-grade Power BI report that presents healthcare data governance and data quality insights in a simple, visual, non-technical, storytelling-oriented structure.

## Required Navigation Pattern
- First page must be: `INDEX`
- Each page must contain a `Home / INDEX` navigation button at the top-right
- Navigation tooltip text must be in English
- Standard tooltip text pattern:
  - `Press Ctrl + Click to go to [Page Name]`

## Approved Page Inventory
1. INDEX
2. Executive Overview
3. Data Quality Overview
4. Coding Quality
5. Service & Payment Patterns
6. Demographic & Provider Mix
7. Quality Issues Monitor

## Page Roles

### 01. INDEX
Purpose:
- report landing page
- navigation gateway to all pages
- no analytical visuals
- no slicers

### 02. Executive Overview
Purpose:
- business summary
- first-read page
- top KPIs + general mix + quality snapshot

### 03. Data Quality Overview
Purpose:
- show the scale and concentration of quality issues
- focus on blank, missing, invalid, and suspicious signals

### 04. Coding Quality
Purpose:
- show coding completeness and coding distribution
- explore diagnosis / service coding quality patterns

### 05. Service & Payment Patterns
Purpose:
- show service volume and represented payment patterns
- compare operational volume vs payment concentration

### 06. Demographic & Provider Mix
Purpose:
- show population / provider / service mix
- compare where quality issues concentrate across segments

### 07. Quality Issues Monitor
Purpose:
- action-oriented page
- show highest-priority issue slices
- help focus review effort

## Visual Density Rule
Per page:
- 1 title zone
- 1 slicer zone
- 1 KPI row
- 2 to 4 main visuals
- maximum 1 detail matrix/table

## Slicer Placement Rule
Approved:
- horizontal slicer strip below page title

Rejected for version 1:
- side icon slicer panel

Reason:
- preserves page width
- reduces clutter
- improves scanability

## Technical Content Rule
The report must avoid technical overload.
Do not expose:
- model structure text
- engineering implementation details
- semantic-model terminology
- internal validation narratives

Allowed:
- clear business labels
- short subtitles
- action-oriented insights

## Storytelling Rule
Every page must communicate one primary message only.