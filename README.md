# Airbnb NYC Data Cleaning — MySQL

**Project completed:** October 2025  
**Tools:** MySQL · MySQL Workbench  
**Domain:** Data Cleaning · SQL · Data Engineering

---

## Overview

An end-to-end SQL data cleaning project on the **Airbnb Open Data (New York City)** dataset.  
The raw CSV is imported into MySQL and processed through a **6-stage pipeline of staging tables**,  
each handling a specific layer of quality issues across all 26 columns.

**Output:** A fully cleaned, analysis-ready table with consistent data types,  
no duplicates, no invalid values, and standardised categorical encodings.

---

## Problem Statement

Real-world datasets are rarely clean. The Airbnb NYC dataset contains:
- Duplicate records across all 26 columns
- NULL and blank values in critical columns (neighbourhood, host identity, price)
- Currency strings instead of numeric types (`$1,200` instead of `1200`)
- Inconsistent categorical encodings (`unconfirmed` vs `Not Verified`)
- Invalid future dates in the `last review` column
- Free-text columns with no analytical value

This project demonstrates a **production-style cleaning pipeline** using best-practice SQL —  
no in-place modifications to the raw table, full rollback capability at every stage.

---

## Pipeline Architecture

| Stage Table | Purpose |
|---|---|
| `airbnb_open_data_dirty` | Raw import — untouched source |
| `stag_airbnb` | Deduplication via `ROW_NUMBER()` window function |
| `stag2` | Host identity standardisation via `LAG()` imputation |
| `stag3` | Neighbourhood NULL-fill via `LAG()`; lat/long/country cleaned |
| `stag4` | Booking flags fixed; `cancellation_policy` context-based imputation |
| `stag5` | Numeric & date cleaning; helper columns dropped — final output |

> Each stage uses `CREATE TABLE AS SELECT` — the raw table is never modified.  
> This allows rollback to any prior stage without re-importing the data.

---

## Key SQL Techniques

### 1. Deduplication with ROW_NUMBER()
Identified and removed duplicate rows by partitioning across all 26 columns.  
`id` was then promoted to PRIMARY KEY after deduplication was confirmed.

### 2. LAG() Window Function for NULL Imputation
Four sparse columns — `host_identity_verified`, `neighbourhood group`,  
`instant_bookable`, `Construction year` — were imputed using `LAG()`,  
carrying the previous row's value forward with a seed default for the first row.

### 3. Context-Based Imputation for cancellation_policy
Rather than a generic mode fill, blank cancellation policies were imputed  
based on the logically related `instant_bookable` column:
- `instant_bookable = FALSE` → `strict`
- `instant_bookable = TRUE` → `flexible`

### 4. Currency String Parsing
Price and service fee were stored as formatted strings (`$1,200`).  
`SUBSTR()` stripped the `$` prefix, `REPLACE()` removed comma separators,  
then columns were cast to `INT`.

### 5. Date Parsing and Validation
`last review` was stored as `M/D/YYYY` strings. Cleaned via `STR_TO_DATE()`,  
cast to `DATE` type, then rows with future dates deleted as logically invalid.

### 6. Dropped Columns
`host name`, `house_rules`, `license`, and `NAME` were dropped —  
free-text or non-essential fields with no analytical value.

---

## Columns Processed

All 26 columns cleaned — highlights include:

| Column | Action |
|---|---|
| `id` | Set as PRIMARY KEY after deduplication |
| `host_identity_verified` | Standardised + NULL-filled via LAG() |
| `neighbourhood group` | NULL-filled via LAG() |
| `neighbourhood` | Rows with unresolvable NULLs deleted |
| `lat` / `long` | Rounded to 2 decimal places |
| `country` / `country code` | Defaulted to `United States` / `US` |
| `cancellation_policy` | Context-based imputation |
| `price` / `service fee` | Currency strings → INT |
| `last review` | String → DATE; future dates deleted |
| `house_rules`, `license`, `NAME` | Dropped — no analytical value |

---

## Design Decisions

- **Staging table pipeline over in-place updates** — every intermediate state is preserved
- **LAG() over mean/mode imputation** — adjacent NYC listings share similar characteristics, making forward-fill more defensible than a global average
- **Neighbourhood NULLs deleted, not imputed** — neighbourhood is a key grouping variable; an incorrect imputation would corrupt geographic analysis
- **Context-aware cancellation_policy fill** — more analytically defensible than mode-based fill

---

## Repository Structure

```
airbnb-data-cleaning-sql/
├── airbnb_cleaning.sql           # Full SQL cleaning script
├── Airbnb_MySQL_Documentation.pdf  # Detailed project documentation
└── README.md
```

> Dataset sourced from Kaggle — [Airbnb Open Data NYC](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata)  
> Download and import via `LOAD DATA LOCAL INFILE` as shown in the documentation.

---

## Skills Demonstrated

`MySQL` `Data Cleaning` `Window Functions` `ROW_NUMBER()` `LAG()` `COALESCE()`  
`STR_TO_DATE()` `Staging Tables` `NULL Imputation` `Data Type Casting`  
`Context-Based Imputation` `MySQL Workbench`

---

*Part of my Data Analytics portfolio — [github.com/Dev-2004-DA](https://github.com/Dev-2004-DA)*
