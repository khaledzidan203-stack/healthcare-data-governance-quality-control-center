# REPORT DESIGN SYSTEM
## Project
Healthcare Data Governance & Quality Control Center

## Design Direction
Executive / premium / clean / low-clutter / high-readability

## Layout Rules
- large page title centered
- small subtitle centered below the title
- top-right INDEX button
- slicers in one horizontal strip
- KPI cards directly below slicers
- visual groups separated by section title bars
- wide margins and consistent spacing
- no overlapping background shapes over visuals

## Page Background Rule
- use a single controlled page background system
- background shapes must be sent to back
- background must never cover or interfere with visuals
- no free-floating decorative shapes over chart area

## Title Rules
- page title centered
- visual/card title centered
- title area must have a contrasting header background
- titles must be short and clear
- avoid long technical wording

## Approved Color Palette

### Canvas / Neutral
- Canvas Background: #F4F7FB
- Card Background:   #FFFFFF
- Soft Panel:        #EEF3F9
- Border / Divider:  #D9E2EC
- Neutral Text:      #22324A
- Secondary Text:    #6B7A90

### Semantic Colors
- Structure / Header / Navigation: #173B63
- Comparative / Benchmark:         #506CF0
- Positive / Clean / Stable:       #1E9E96
- Watch / Caution:                 #C98A2E
- Issue / Risk / Bad Quality:      #D45757
- Dark Neutral Highlight:          #3C4B63

## KPI Color Rules
- raw volume KPIs -> structure / neutral
- positive quality KPIs -> teal
- caution KPIs -> amber
- issue KPIs -> red
- benchmark / comparison KPIs -> indigo

## Chart Color Rules
Use color by analytical meaning, not random color.

### Good-high metrics
higher is better:
- teal dominant scale

### Bad-high metrics
higher is worse:
- amber to red scale

### Benchmark / comparison metrics
- indigo dominant scale

### composition / mix visuals
- neutral palette with 1 semantic highlight

## Table Formatting Rules
- allow arrows only when a true directional comparison exists
- no arrows on raw counts without comparison
- arrow color must depend on KPI meaning:
  - if up is good -> up = teal / down = red
  - if down is good -> down = teal / up = red
- use soft heat or data bars only when it improves readability

## Density Rules
Avoid crowded pages.
Target:
- 5 to 6 information blocks maximum in a page
- one detail table only
- no excessive text

## Navigation Rules
- first page = INDEX
- each page includes INDEX button
- navigation tooltip text:
  - Press Ctrl + Click to go to [Page Name]

## Typography Rules
- page titles: strong, large, centered
- subtitles: small, muted
- KPI labels: uppercase or short title case
- section titles: short and direct
- table headers: clear, concise

## Visual Intent Rules
Use visuals only when they answer a real question:
- bar / column -> ranking or comparison
- matrix / table -> detail inspection
- cards -> headline KPI
- avoid decorative visuals

## Build Sequence
1. architecture contract
2. index page
3. executive overview
4. remaining analytical pages one by one
5. validation and refinement