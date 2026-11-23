import csv
import sqlite3
from pathlib import Path

# Define relative paths so the script works on any machine
BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "retail_sales.db"
CSV_PATH = BASE_DIR / "data" / "raw" / "superstore.csv"
SCHEMA_PATH = BASE_DIR / "sql" / "01_schema_setup.sql"

def main():
    # Connect to SQLite database (creates file if it doesn't exist)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # 1. Execute the SQL schema script to create the table
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        cursor.executescript(f.read())

    # 2. Read the CSV and insert rows cleanly
    with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        rows = [
            (
                int(r["Row ID"]),
                r["Order ID"].strip(),
                r["Order Date"].strip(),
                r["Ship Date"].strip(),
                r["Ship Mode"].strip(),
                r["Customer ID"].strip(),
                r["Customer Name"].strip(),
                r["Segment"].strip(),
                r["Country"].strip(),
                r["City"].strip(),
                r["State"].strip(),
                r["Postal Code"].strip(),
                r["Region"].strip(),
                r["Product ID"].strip(),
                r["Category"].strip(),
                r["Sub-Category"].strip(),
                r["Product Name"].strip(),
                float(r["Sales"]),
                int(r["Quantity"]),
                float(r["Discount"]),
                float(r["Profit"]),
            )
            for r in reader
        ]

    insert_sql = """
        INSERT INTO raw_superstore VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
        )
    """
    cursor.executemany(insert_sql, rows)
    conn.commit()

    # 3. Verify loaded row count
    cursor.execute("SELECT COUNT(*) FROM raw_superstore;")
    count = cursor.fetchone()[0]
    print(f"Success! Loaded {count} rows into {DB_PATH.name}.")
    conn.close()

if __name__ == "__main__":
    main()