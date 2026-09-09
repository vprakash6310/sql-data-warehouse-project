
/*
=============================================================
Store Procedure: Load Silver Layer (Bronze>> Silver)
=============================================================
Script Purpose:
	In the below script we are taking the data from Bronze layer
	and performing data normalization,data cleaning and data transformaiton.

	The scripts performs below tasks:
	-Truncate the bronze tables before loading data
	-Using 'Insert' command to load data from Bronze
	 to the silver layer tables.

	 To execute below SP:
	 
	 EXEC silver.load_silver
=================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time= GETDATE();
		PRINT'======================';
		PRINT'Loading Silver Layer';
		PRINT'======================';

		Print'------------------------'
		PRINT'Loading CRM Tables';
		Print'------------------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT'>> INSERTING Data into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)
		select 
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		CASE WHEN cst_marital_status='M' THEN 'MARRIED'
			WHEN cst_marital_status='S' THEN 'SINGLE'
			ELSE 'N/A'
		END cst_marital_status,  -- Normalize marital status vales into readable format
		CASE WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'FEMALE'
			WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'MALE'
			ELSE 'N/A'
			END cst_gndr, --Normalize gender value into readable format
		cst_create_date
		from (
			select *,
			ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) latest
			from bronze.crm_cust_info
			where cst_id is not null
		)t where latest=1;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>> INSERTING Data into: silver.crm_prd_info';

		INSERT INTO silver.crm_prd_info( 
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id, --Extract category ID
		SUBSTRING(prd_key,7,len(prd_key)) as prd_key,  --Extract Product Key
		prd_nm,
		coalesce(prd_cost,0) as prd_cost,
		CASE WHEN  UPPER(TRIM(prd_line))='M' THEN 'Mountain'
			WHEN  UPPER(TRIM(prd_line))='R' THEN 'Road'
			WHEN  UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
			WHEN  UPPER(TRIM(prd_line))='T' THEN 'Touring'
			ELSE 'N/A'
		END prd_line,  -- Map produt line to destcriptive value
		CAST(prd_start_dt as DATE) as prd_start_dt,
		CAST(
			LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 
			as date
			) as prd_end_dt  --calculate end date as one day before the next start date
		from bronze.crm_prd_info;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT'>> INSERTING Data into: silver.crm_sales_details';

		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_order_dt as varchar)as date)
		END as sls_order_dt,

		CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt as varchar)as date)
		END as sls_ship_dt,
		CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_due_dt as varchar)as date)
		END as sls_due_dt,
		CASE WHEN sls_sales is null or sls_sales<=0 or sls_sales!=sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END sls_sales,  -- Recalculating the sakes if original sales value is missing or incorrect
		sls_quantity,
		CASE WHEN sls_price is null or sls_price<=0
				THEN sls_sales/NULLIF(sls_quantity,0)
			ELSE sls_price -- evaluating the price in case of original is invalid
		END sls_price
		from bronze.crm_sales_details;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'


		Print'------------------------'
		PRINT'Loading ERP Tables';
		Print'------------------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>> INSERTING Data into: silver.erp_cust_az12';

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		select
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))
			ELSE cid
		END cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END bdate,
		CASE WHEN trim(upper(gen)) IN('F','FEMALE') THEN 'Female'
			WHEN trim(upper(gen)) IN('M','MALE')THEN 'Male'
			ELSE 'N/A'
		END as gen --Normalize gender values and handle unknown cases
		from 
		bronze.erp_cust_az12;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'>> INSERTING Data into: silver.erp_loc_a101';


		INSERT INTO silver.erp_loc_a101(cid,cntry)
		select 
		REPLACE(cid,'-','') cid,
		CASE WHEN trim(cntry) = 'DE' THEN 'Germany'
			WHEN trim(cntry) IN ('US','USA') THEN 'United States'
			WHEN trim(cntry) ='' OR cntry is null THEN 'N/A'
			else trim(cntry)
		END cntry --normalize and handle the missing or blank data in cntry column
		from bronze.erp_loc_a101;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		PRINT'>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT'>> INSERTING Data into: silver.erp_px_cat_g1v2';

		INSERT INTO silver.erp_px_cat_g1v2
		(id,cat,subcat,maintenance)
		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;

		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		SET @batch_end_time= GETDATE();
		PRINT'========================================';
		print'Loading Broze Layer is completed';
		print'Total Load Duration: '+cast(datediff(second, @batch_start_time,@batch_end_time) as NVARCHAR) + 'seconds';
		PRINT'========================================';

	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END








