#!/usr/bin/env python3
"""Static repository quality gate for the public portfolio.

This validator intentionally does not require SQL Server, Power BI Desktop, or
the excluded CMS source data. It verifies the source-controlled contract that
must remain stable on every push.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "powerbi" / "HealthcareGovernanceQC.Report"
SEMANTIC = ROOT / "powerbi" / "HealthcareGovernanceQC.SemanticModel"
PAGES_ROOT = REPORT / "definition" / "pages"
TABLES_ROOT = SEMANTIC / "definition" / "tables"

EXPECTED = {
    "pages": 7,
    "visuals": 142,
    "screenshots": 7,
    "tables": 10,
    "measures": 12,
    "relationships": 8,
}

EXPECTED_PAGE_ORDER = [
    "c82ca7e72ea060e788e6",
    "p_exec_overview",
    "p_data_quality",
    "p_coding_quality",
    "p_service_payment",
    "p_demographic_provider",
    "p_quality_monitor",
]

REQUIRED_FILES = [
    "README.md",
    "KPI_CONTRACT.md",
    "VALIDATION.md",
    "requirements.txt",
    "docs/FINAL_RELEASE_VALIDATION.md",
    "docs/PORTFOLIO_CASE_STUDY.md",
    "docs/REPRODUCIBILITY.md",
    "powerbi/HealthcareGovernanceQC.pbip",
    "powerbi/GOVERNED_MEASURES.dax",
    "python/eda/cp9_python_validation.py",
    "scripts/setup/Initialize-Project.ps1",
    "scripts/validation/Runtime_KPI_Reconciliation.ps1",
]

FORBIDDEN_SUFFIXES = {
    ".csv", ".xlsx", ".xls", ".pdf", ".abf", ".mdf", ".ldf",
    ".bak", ".pbix", ".zip",
}

FORBIDDEN_NAME_FRAGMENTS = [
    "data analyst associate certificate",
    "localsettings.json",
]

failures: list[str] = []
passes: list[str] = []


def check(condition: bool, label: str, detail: str = "") -> None:
    if condition:
        passes.append(label)
    else:
        suffix = f" | {detail}" if detail else ""
        failures.append(f"{label}{suffix}")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


for item in REQUIRED_FILES:
    check((ROOT / item).is_file(), f"required file: {item}")

for path in ROOT.rglob("*"):
    if not path.is_file() or ".git" in path.parts:
        continue
    low_name = path.name.lower()
    check(
        path.suffix.lower() not in FORBIDDEN_SUFFIXES,
        f"forbidden binary/source type absent: {rel(path)}",
    )
    for fragment in FORBIDDEN_NAME_FRAGMENTS:
        check(fragment not in low_name, f"forbidden artifact absent: {rel(path)}")

json_files = list((ROOT / "powerbi").rglob("*.json"))
json_errors: list[str] = []
for path in json_files:
    try:
        json.loads(path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        json_errors.append(f"{rel(path)}: {exc}")
check(not json_errors, "Power BI JSON parses", "; ".join(json_errors[:5]))

page_files = list(PAGES_ROOT.glob("*/page.json"))
visual_files = list(PAGES_ROOT.glob("*/visuals/*/visual.json"))
screenshot_files = sorted((ROOT / "docs" / "screenshots").glob("*.png"))

check(len(page_files) == EXPECTED["pages"], "page count", str(len(page_files)))
check(len(visual_files) == EXPECTED["visuals"], "visual count", str(len(visual_files)))
check(
    len(screenshot_files) == EXPECTED["screenshots"],
    "screenshot count",
    str(len(screenshot_files)),
)

pages_meta_path = PAGES_ROOT / "pages.json"
pages_meta = json.loads(pages_meta_path.read_text(encoding="utf-8-sig"))
check(
    pages_meta.get("pageOrder") == EXPECTED_PAGE_ORDER,
    "page order",
    repr(pages_meta.get("pageOrder")),
)
check(
    pages_meta.get("activePageName") == EXPECTED_PAGE_ORDER[0],
    "opening page is INDEX",
    str(pages_meta.get("activePageName")),
)

mobile_files = list(REPORT.rglob("mobile.json"))
check(len(mobile_files) == 0, "unexpected mobile.json absent", str(len(mobile_files)))

table_files = list(TABLES_ROOT.glob("*.tmdl"))
check(len(table_files) == EXPECTED["tables"], "semantic table count", str(len(table_files)))

measures_text = (TABLES_ROOT / "_Measures.tmdl").read_text(encoding="utf-8-sig")
measure_count = len(re.findall(r"(?m)^\s*measure\s+", measures_text))
check(measure_count == EXPECTED["measures"], "governed measure count", str(measure_count))

relationships_text = (
    SEMANTIC / "definition" / "relationships.tmdl"
).read_text(encoding="utf-8-sig")
relationship_count = len(re.findall(r"(?m)^relationship\s+", relationships_text))
check(
    relationship_count == EXPECTED["relationships"],
    "relationship count",
    str(relationship_count),
)
check("_Measures." not in relationships_text, "_Measures remains disconnected")

model_text = (SEMANTIC / "definition" / "model.tmdl").read_text(encoding="utf-8-sig")
check(
    "__PBI_TimeIntelligenceEnabled = 0" in model_text,
    "time intelligence disabled",
)

dax_text = (ROOT / "powerbi" / "GOVERNED_MEASURES.dax").read_text(
    encoding="utf-8-sig"
)
dax_measure_count = len(
    re.findall(r"(?m)^[A-Za-z][^\r\n=]*\s*=\s*$", dax_text)
)
check(
    dax_measure_count == EXPECTED["measures"],
    "DAX reference measure count",
    str(dax_measure_count),
)

readme_text = (ROOT / "README.md").read_text(encoding="utf-8")
check("## Quick Start" in readme_text, "README Quick Start present")
check("docs/REPRODUCIBILITY.md" in readme_text, "README reproducibility link present")
check("docs/screenshots/01-index.png" in readme_text, "README INDEX screenshot present")

link_pattern = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
broken_links: list[str] = []
for md in ROOT.rglob("*.md"):
    if ".git" in md.parts:
        continue
    text = md.read_text(encoding="utf-8-sig")
    for raw_target in link_pattern.findall(text):
        target = raw_target.strip().strip("<>")
        if not target or target.startswith("#"):
            continue
        if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", target):
            continue
        if target.startswith("mailto:"):
            continue
        target = unquote(target.split("#", 1)[0])
        if not target:
            continue
        resolved = (md.parent / target).resolve()
        try:
            resolved.relative_to(ROOT.resolve())
        except ValueError:
            broken_links.append(f"{rel(md)} -> {target} (escapes repository)")
            continue
        if not resolved.exists():
            broken_links.append(f"{rel(md)} -> {target}")

check(not broken_links, "relative Markdown links resolve", "; ".join(broken_links[:10]))

print("Healthcare Governance QC - Repository Validation")
print("=" * 52)
for label in passes:
    print(f"PASS | {label}")
for item in failures:
    print(f"FAIL | {item}")

print("-" * 52)
print(f"PASS checks: {len(passes)}")
print(f"FAIL checks: {len(failures)}")

if failures:
    sys.exit(1)

print("RESULT: PASS")
