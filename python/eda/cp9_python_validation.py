"""
CP9 - Independent Python Validation

Purpose:
Independently recalculate governed analytical KPIs from
analytics.FactCarrierProfile without using the SQL KPI baseline view.
"""

from decimal import Decimal
import pyodbc


drivers = pyodbc.drivers()

if "ODBC Driver 18 for SQL Server" in drivers:
    DRIVER = "ODBC Driver 18 for SQL Server"

elif "ODBC Driver 17 for SQL Server" in drivers:
    DRIVER = "ODBC Driver 17 for SQL Server"

else:
    raise RuntimeError(
        "Microsoft ODBC Driver 17/18 for SQL Server not found."
    )


conn = pyodbc.connect(
    f"DRIVER={{{DRIVER}}};"
    "SERVER=localhost;"
    "DATABASE=HealthcareGovernanceQC;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

cursor = conn.cursor()

cursor.execute("""
SELECT
    SexKey,
    AgeCategoryKey,
    ServiceCount,
    MedicarePaymentAmount,
    LineItemCount,
    IsBlankICD,
    IsZeroServiceCount
FROM analytics.FactCarrierProfile;
""")

profile_count = 0
line_items = 0
service_units = 0
weighted_payment = Decimal("0")

blank_profiles = 0
blank_lines = 0

zero_profiles = 0
zero_lines = 0

male_lines = 0
female_lines = 0
age85_lines = 0


while True:

    rows = cursor.fetchmany(50000)

    if not rows:
        break

    for row in rows:

        sex = int(row.SexKey)
        age = int(row.AgeCategoryKey)

        service_count = int(row.ServiceCount)
        payment = Decimal(str(row.MedicarePaymentAmount))
        represented_lines = int(row.LineItemCount)

        profile_count += 1
        line_items += represented_lines

        service_units += (
            service_count *
            represented_lines
        )

        weighted_payment += (
            payment *
            represented_lines
        )

        if sex == 1:
            male_lines += represented_lines

        elif sex == 2:
            female_lines += represented_lines

        if age == 6:
            age85_lines += represented_lines

        if bool(row.IsBlankICD):
            blank_profiles += 1
            blank_lines += represented_lines

        if bool(row.IsZeroServiceCount):
            zero_profiles += 1
            zero_lines += represented_lines


cursor.close()
conn.close()


avg_service = (
    Decimal(service_units) /
    Decimal(line_items)
)

avg_payment = (
    weighted_payment /
    Decimal(line_items)
)

blank_rate = (
    Decimal(blank_lines) /
    Decimal(line_items)
)

zero_rate = (
    Decimal(zero_lines) /
    Decimal(line_items)
)


print("Profile Count:", profile_count)
print("Represented Line Items:", line_items)
print("Represented Service Units:", service_units)
print(
    "Represented Rounded Medicare Payment:",
    weighted_payment
)
print(
    "Average Service Units / Line:",
    f"{avg_service:.6f}"
)
print(
    "Average Rounded Payment / Line:",
    f"{avg_payment:.6f}"
)
print("Blank ICD Profiles:", blank_profiles)
print("Blank ICD Lines:", blank_lines)
print("Blank ICD Rate:", f"{blank_rate:.8f}")
print("Zero-Service Profiles:", zero_profiles)
print("Zero-Service Lines:", zero_lines)
print("Zero-Service Rate:", f"{zero_rate:.8f}")
print("Male Lines:", male_lines)
print("Female Lines:", female_lines)
print("Age 85+ Lines:", age85_lines)
