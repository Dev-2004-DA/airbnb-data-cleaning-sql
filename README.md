# 🏙️ Airbnb Data Cleaning Project (MySQL Workbench)

## 📘 Overview
This project focuses on **cleaning a real-world Airbnb dataset** of New York City listings using **MySQL Workbench**.  
The dataset is taken from Kaggle and it contains nearly 100,000 rows and includes information about hosts, locations, prices, reviews, and availability.  
The goal was to perform **systematic data cleaning and transformation** to make the dataset analysis-ready.

---

## 🧩 About the Dataset
This dataset is part of the **Airbnb Inside initiative**, describing listing activities of homestays in **New York City**.  
It includes:
- **Listings:** property details, host info, price, location, etc.  
- **Reviews:** reviewer IDs, review text, and average scores.  
- **Calendar:** availability and pricing for each day.  

> 🗒️ *Note:* This dataset was modified intentionally to include data inconsistencies for learning and practicing **data cleaning techniques** such as handling missing values, outliers, and inconsistent text formats.  
> Original data source: [Inside Airbnb](http://insideairbnb.com/explore/)

---

## 🧠 Project Objective
The purpose of this project was to:
- Identify and fix missing or incorrect values  
- Handle data type mismatches  
- Remove duplicates and invalid entries  
- Standardize text and numeric formats  
- Prepare the dataset for analysis and visualization in tools like Power BI or Python  

---

## ⚙️ Tools & Technologies
- **MySQL Workbench** – for SQL queries and data cleaning
---

## 🧾 Cleaning Stages
**Tables Created:**
| Table Name | Description |
|-------------|--------------|
| `airbnb_open_data_dirty` | Original imported dataset |
| `stag_airbnb` | Duplicate removal and base cleanup |
| `stag2` | Host identity cleaning |
| `stag3` | Neighbourhood and location cleaning |
| `stag4` | Booking and cancellation policy cleanup |
| `stag5` | Price, date, and numerical column cleanup |
| `airbnb_cleaned_dataset` | Final cleaned dataset ready for analysis |
---
## ⚙️ SQL Functions Used
`ROW_NUMBER()` • `TRIM()` • `COALESCE()` • `LAG()` • `STR_TO_DATE()` • `CAST()` • `REPLACE()` • `CONCAT()` • `UPDATE` • `ALTER TABLE` • `RENAME TABLE`
etc
## 📊 Key Outcomes
- ✅ Cleaned and standardized 100,000+ Airbnb records  
- ✅ Improved data consistency and readability  
- ✅ Prepared final dataset for further analysis  
---
