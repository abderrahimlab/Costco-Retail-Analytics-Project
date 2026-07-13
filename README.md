# Costco-Retail-Analytics-Project

# Costco Enterprise Retail Analytics: End-to-End ETL, SQL, and Power BI Solution

## 1. Project Overview
This project delivers an end-to-end data engineering and business intelligence solution for Costco Wholesale retail data. It automates the ingestion of raw, multi-year transactional datasets, executes database-level engineering in PostgreSQL, and structures a high-performance Star Schema model for executive reporting in Power BI.

---

## 2. Technical Architecture & Workflow
* **Ingestion & ETL (Python):** Automated extraction, schema standardization, column type-casting, and direct database appending of raw CSV/Excel files.
* **Data Engineering (PostgreSQL):** Transactional deduplication via database system features, modal imputation for missing target fields, and integrity constraint enforcement.
* **BI Architecture (Power BI & Figma):** Star Schema optimization, robust DAX engineering for Year-over-Year (YoY) target tracking, and layout prototyping in Figma to eliminate visual rendering latency.

---

## 3. Dataset & Repository Structure
The pipeline processes 6 core source files containing transactional history from 2020 to 2024:
* **Fact Table:** `sales` (Merged transactional history)
* **Dimension Tables:** `customers`, `products`, `calander`

```text
├── app.py                 # Automated Python ETL & DB ingestion pipeline
├── costco_cleaning.sql    # PostgreSQL data processing & cleaning scripts
├── Costco_Dashboard.pbix  # Structured Power BI data model & dashboard
└── README.md              # Documentation

```

---

## 4. Pipeline Execution

### Step 1: Automated Ingestion via Python (`app.py`)

A robust script utilizing `pandas` and `sqlalchemy` standardizes column names, converts date fields, cleans string white spaces, handles text anomalies (`UTF-8`/`Latin-1`), and writes directly to PostgreSQL.

```python
import pandas as pd
from sqlalchemy import create_engine
import os
import re

DB_CONFIG = {
    'user': 'postgres',
    'pass': '2501',
    'host': '127.0.0.1',
    'port': '5432',
    'db_name': 'costco_data'
}

DB_URL = f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['pass']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['db_name']}"
engine = create_engine(DB_URL)

def clean_dataframe(df):
    df.columns = [c.strip().replace(' ', '_').lower() for c in df.columns]
    rename_map = {
        'shipmode': 'ship_mode', 'orderdate': 'order_date',
        'shipdate': 'ship_date', 'productid': 'product_id',
        'customerid': 'customer_id', 'orderid': 'order_id'
    }
    df = df.rename(columns={k: v for k, v in rename_map.items() if k in df.columns})
    
    for col in df.columns:
        if 'date' in col.lower():
            df[col] = pd.to_datetime(df[col], errors='coerce')
        elif df[col].dtype == 'object':
            if df[col].str.contains(r'[\$,]', na=False).any():
                df[col] = df[col].replace(r'[\$,]', '', regex=True).astype(float)
            else:
                df[col] = df[col].str.strip()
    return df

# (Pipeline loop automatically stacks yearly files to 'sales' table and isolates dimensions)
```

### Step 2: Database Optimization (`costco_cleaning.sql`)

* **Deduplication utilizing Window Functions:**

```sql
WITH cta AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER(
            PARTITION BY order_id 
            ORDER BY order_date DESC
        ) AS row_num
    FROM sales
)
DELETE FROM sales
WHERE ctid IN (SELECT ctid FROM cta WHERE row_num > 1);
```

* **Modal Imputation for Missing Metrics:** Preserves business logic without dropping rows by replacing NULLs with the most frequent transaction quantity density.

```sql
UPDATE sales
SET qty = (
    SELECT qty 
    FROM (
        SELECT qty, count(*) AS frequency
        FROM sales
        GROUP BY qty
        ORDER BY frequency DESC
        LIMIT 1
    ) sub
)
WHERE qty IS NULL;
```

### Step 3: Star Schema Data Modeling

Data is loaded directly into Power BI Desktop via native SQL Server connection strings, forming an optimized Star Schema:

* **Fact Table:** `sales` (joined via `Customer ID` and `Product ID`)
* **Dimension Tables:** `customers`, `products`, and a dedicated `calander` table (`Order Date`).
* **Multiplicity:** Strict 1-to-many ($1 \rightarrow *$) single-direction relationship filters.

---

## 5. Key Metrics & DAX Formulations

Advanced KPIs were isolated inside a dedicated `measure_table`:

* **Profit Margin:**

$$\text{Profit Margin} = \frac{\text{Total Profit}}{\text{Total Revenue}}$$


* **Year-over-Year (YoY) Revenue Growth:**

```dax
revenue_yoy = 
VAR current_year_revenue = 
    TOTALYTD([Total Revenue], calander[Date])

VAR last_year_revenue = 
    CALCULATE(
        [Total Revenue],
        DATESYTD(DATEADD(calander[Date], -1, YEAR))
    )

VAR diff = current_year_revenue - last_year_revenue 
VAR diff_ratio = DIVIDE(diff, last_year_revenue)
VAR abs_diff = ABS(diff_ratio)

VAR result = 
    IF(
        ISBLANK(last_year_revenue),
        "no sales last year",
        IF(
            diff_ratio > 0,
            FORMAT(abs_diff, "0.0%") & " more than last year (▲)",
            FORMAT(abs_diff, "0.0%") & " less than last year (▼)"
        )
    )

RETURN 
    result
```

---

## 6. Executive UI/UX Design & Insights

* **Figma Decoupling:** Grids and canvas layouts were built in Figma and imported as flat canvas backgrounds. This eliminates native visual asset calculation overhead and ensures zero dashboard rendering latency.
* **Target Discrepancies:** Built visual matrices matching monthly performance directly against scaled annual targets.
* **Geographic & Logistics Analysis:** Isolated global volume densities using map charts and tied margin leakages back to shipping fulfillment paths (`Ship Mode`).

---

## Author

**Abderrahim Labdaoui**

*Statistical Engineer & Data Analyst | Business Intelligence | SQL & Power BI Specialist*
