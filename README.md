# 🏗️ Data Warehouse & ETL Pipeline — Medallion Architecture

> A modern data warehouse implementing the **Medallion Architecture** (Bronze → Silver → Gold) to ingest, clean, transform, and model data for analytics and reporting.


## 📖 Overview

This project implements an end-to-end **ETL/ELT pipeline** and **data warehouse** following the **Medallion (Bronze/Silver/Gold) architecture** pattern. Raw data is ingested from source systems, progressively cleaned and enriched, and finally modeled into analytics-ready tables for BI and reporting.

**Goals of this project:**
- Build a reliable, scalable pipeline from raw data to trusted, query-ready datasets
- Apply data quality checks and transformations at each layer
- Provide a clean dimensional/star-schema model for analytics consumption
- Demonstrate best practices in data engineering and modeling

---

## 🧱 Architecture

```
Source Systems
      │
      ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   BRONZE    │ ──▶ │   SILVER    │ ──▶ │    GOLD     │
│ Raw / Landed│     │ Cleaned &   │     │ Business /  │
│    Data     │     │  Conformed  │     │  Analytics  │
└─────────────┘     └─────────────┘     └─────────────┘
                                                │
                                                ▼
                                         BI / Reporting
```

| Layer | Purpose | Description |
|-------|---------|--------------|
| **Bronze** | Raw ingestion | Stores raw, unprocessed data exactly as received from source systems (append-only, schema-on-read). |
| **Silver** | Cleaned & conformed | Deduplicated, validated, standardized data with business rules applied. |
| **Gold** | Business-level / analytics-ready | Aggregated, dimensional (star schema) tables optimized for BI, dashboards, and reporting. |


## 🤝 About me
- I am  Vivaswan Prakash learning the Data engineering concepts for better understanding and building projects.

