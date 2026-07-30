# Airbnb NYC Data Cleaning & Analysis — MySQL + Python + Power BI

Project completed: October 2025 (SQL) · January 2026 (Python + Power BI)
Tools: MySQL · MySQL Workbench · Python · Pandas · Jupyter Notebook · Power BI Desktop
Domain: Data Cleaning · SQL · Python · Data Engineering · Data Visualisation

---

## Overview

An end-to-end data project on the Airbnb Open Data (New York City) dataset —
covering SQL-based structural cleaning, Python-based imputation and validation,
and a Power BI dashboard for business insights.

The raw CSV is first processed through a 6-stage MySQL pipeline handling structural
quality issues. The SQL-cleaned output is then passed through a Python notebook for
null imputation, outlier handling, and final preparation. The resulting clean dataset
powers an interactive Power BI dashboard.

**Output:** A fully cleaned, imputed, analysis-ready dataset and a Power BI dashboard
visualising key Airbnb NYC metrics across neighbourhoods, pricing, availability, and reviews.

---

## Problem Statement

Real-world datasets are rarely clean. The Airbnb NYC dataset contains:

- Duplicate records across all 26 columns
- NULL and blank values in critical columns (neighbourhood, host identity, price)
- Currency strings instead of numeric types ($1,200 instead of 1200)
- Inconsistent categorical encodings (unconfirmed vs Not Verified)
- Invalid future dates in the last review column
- Negative values in numeric columns (minimum nights, availability)
- Values exceeding logical boundaries (availability > 365)
- Free-text columns with no analytical value

This project demonstrates a two-layer cleaning approach — structural cleaning in SQL
followed by statistical imputation and validation in Python.

---

## Project Architecture

```
Raw CSV (Kaggle)
      ↓
MySQL 6-Stage Pipeline      ← Structural cleaning, deduplication, type casting
      ↓
Python Notebook             ← Null imputation, outlier removal, boundary fixing
      ↓
Clean CSV
      ↓
Power BI Dashboard          ← Business insights and visualisation
```

---

## Stage 1 — MySQL Cleaning Pipeline

### Pipeline Architecture

| Stage Table | Purpose |
|---|---|
| airbnb_open_data_dirty | Raw import — untouched source |
| stag_airbnb | Deduplication via ROW_NUMBER() window function |
| stag2 | Host identity standardisation via LAG() imputation |
| stag3 | Neighbourhood NULL-fill via LAG(); lat/long/country cleaned |
| stag4 | Booking flags fixed; cancellation_policy context-based imputation |
| stag5 | Numeric & date cleaning; helper columns dropped — final output |

Each stage uses CREATE TABLE AS SELECT — the raw table is never modified.
This allows rollback to any prior stage without re-importing the data.

### Key SQL Techniques

**1. Deduplication with ROW_NUMBER()**
Identified and removed duplicate rows by partitioning across all 26 columns.
id was then promoted to PRIMARY KEY after deduplication was confirmed.

**2. LAG() Window Function for NULL Imputation**
Four sparse columns — host_identity_verified, neighbourhood group,
instant_bookable, Construction year — were imputed using LAG(),
carrying the previous row's value forward with a seed default for the first row.

**3. Context-Based Imputation for cancellation_policy**
Rather than a generic mode fill, blank cancellation policies were imputed
based on the logically related instant_bookable column:
- instant_bookable = FALSE → strict
- instant_bookable = TRUE → flexible

**4. Currency String Parsing**
Price and service fee were stored as formatted strings ($1,200).
SUBSTR() stripped the $ prefix, REPLACE() removed comma separators,
then columns were cast to INT.

**5. Date Parsing and Validation**
last_review was stored as M/D/YYYY strings. Cleaned via STR_TO_DATE(),
cast to DATE type, then rows with future dates deleted as logically invalid.

**6. Dropped Columns**
host name, house_rules, license, and NAME were dropped —
free-text or non-essential fields with no analytical value.

### Columns Processed

All 26 columns cleaned — highlights include:

| Column | Action |
|---|---|
| id | Set as PRIMARY KEY after deduplication |
| host_identity_verified | Standardised + NULL-filled via LAG() |
| neighbourhood group | NULL-filled via LAG() |
| neighbourhood | Rows with unresolvable NULLs deleted |
| lat / long | Rounded to 2 decimal places |
| country / country code | Defaulted to United States / US |
| cancellation_policy | Context-based imputation |
| price / service fee | Currency strings → INT |
| last review | String → DATE; future dates deleted |
| house_rules, license, NAME | Dropped — no analytical value |

---

## Stage 2 — Python Cleaning & Imputation

After SQL cleaning, the dataset was loaded into Python (Pandas) for a second
layer of validation, imputation, and boundary correction.

### Issues Fixed

| Column | Issue | Fix Applied |
|---|---|---|
| last review | 15,784 nulls (listings never reviewed) | Filled with 'No Review' — valid business state |
| minimum nights | Negative values (typos) | Deleted — no logical fix possible |
| minimum nights | Values above 90 (417 rows) | Deleted — not realistic for Airbnb platform |
| availability 365 | Negative values | Converted to positive using .abs() |
| availability 365 | Values above 365 | Capped at 365 using .clip(upper=365) |

### Key Python Operations

```python
# Null fill — last review
df['last review'].fillna('No Review', inplace=True)

# Remove negative minimum nights
df = df[df['minimum nights'] > 0]

# Remove extreme minimum nights
df = df[df['minimum nights'] <= 90]

# Fix availability boundaries
df['availability 365'] = df['availability 365'].abs()
df['availability 365'] = df['availability 365'].clip(upper=365)

# Export final clean file
df.to_csv('cleaned_filled_airbnb_data.csv', index=False)
```

### Final Dataset Stats

| Metric | Value |
|---|---|
| Original rows | 101,707 |
| Rows after cleaning | ~101,280 (approx) |
| Columns | 22 |
| Nulls remaining | 0 |

---

## Repository Structure

```
airbnb-data-cleaning-sql/
│
├── data/
│   ├── raw/
│   │   └── airbnb_dirty_data.csv
│   ├── sql_cleaned/
│   │   └── airbnb_sql_cleaned.csv
│   └── python_cleaned/
│       └── cleaned_filled_airbnb_data.csv
│
├── notebooks/
│   └── cleaning_imputation.ipynb
│
├── sql/
│   └── airbnb_cleaning.sql
│
├── Airbnb_MySQL_Documentation.pdf
└── README.md
```

---

## Design Decisions

- **Staging table pipeline over in-place updates** — every intermediate state is preserved
- **LAG() over mean/mode imputation** — adjacent NYC listings share similar characteristics, making forward-fill more defensible than a global average
- **Neighbourhood NULLs deleted, not imputed** — neighbourhood is a key grouping variable; an incorrect imputation would corrupt geographic analysis
- **Context-aware cancellation_policy fill** — more analytically defensible than mode-based fill
- **minimum nights capped at 90** — Airbnb is a short-to-medium term platform; values above 90 nights represent fewer than 0.4% of data and skew analysis
- **availability 365 capped not deleted** — boundary violations here are likely data entry errors, not corrupt rows; rest of the record is valid

---

## Dataset

Sourced from Kaggle — Airbnb Open Data NYC.
Download and import via LOAD DATA LOCAL INFILE as shown in the documentation.

---

## Skills Demonstrated

**SQL:** MySQL · Data Cleaning · Window Functions · ROW_NUMBER() · LAG() · COALESCE()
· STR_TO_DATE() · Staging Tables · NULL Imputation · Data Type Casting
· Context-Based Imputation · MySQL Workbench

**Python:** Pandas · Null Handling · Outlier Detection · Boundary Validation
· Data Imputation · Jupyter Notebook · CSV Export

