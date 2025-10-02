<img width="1516" height="466" alt="image" src="https://github.com/user-attachments/assets/34374e99-c0a2-44c3-b31d-83777587b154" />




## 🐊 Data Flow

1. **RAW (seeds/)**  
   - CSVs are version-controlled and loaded via `dbt seed`.  
   - Example: `RAW.crocodile_species`.

2. **STAGING (models/staging/)**  
   - Standardizes column names and types.  
   - Handles light cleaning (dates, enums, QA flags).  
   - Still at row-level grain.

3. **GOLDEN (models/golden/)**  
   - **Dimensions**: `dim_species`, `dim_location`, `dim_date`, `dim_observer`, `dim_conservation_status`.  
   - **Fact**: `fact_croc_observation` with measures (`observed_length_m`, `observed_weight_kg`) and foreign keys to all dims.  
   - Enforced with **tests** and optional DB constraints (`post_hook`).

4. **Folders** 
    - seeds/ - static/public datasets (RAW layer).
	- scripts/ - helper ingestion scripts (fetch CSVs).
	- staging/ - row-level cleanup (types, enums, QA flags).
	- golden/ - star schema (dims and fact) for BI & semantic layers.
	- macros/ - overrides dbt’s default schema naming to keep exactly RAW, STAGING, GOLDEN.
