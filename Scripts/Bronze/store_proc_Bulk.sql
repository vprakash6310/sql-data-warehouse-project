
/*
=============================================================
Store Procedure: Load Bronze Layer (SOurce>>Bronze)
=============================================================
Script Purpose:
	In the below script we are taking the data from Source 
	which is csv file and from there loading into 'bronze' schema.

	The scripts performs below tasks:
	-Truncate the bronze tables before loading data
	-Using 'Bulk Insert' command to load data from the CSV files
	 to the Bronze tables.

	 To execute below SP:
	 
	 EXEC bronze.load_bronze
=================================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time= GETDATE();
		PRINT'======================';
		PRINT'Loading Bronze Layer';
		PRINT'======================';

		Print'------------------------'
		PRINT'Loading CRM Tables';
		Print'------------------------'

		set @start_time = GETDATE();
		print'Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		print'Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		print'Truncating Table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;
		print'Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @start_time = GETDATE();
		print'Truncating Table: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;
		print'Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		Print'------------------------'
		PRINT'Loading ERP Tables';
		Print'------------------------'

		set @end_time = GETDATE();
		print'Truncating Table: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12;
		print'Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @end_time = GETDATE();
		print'Truncating Table: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;
		print'Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>>Load Duration' + CAST(datediff(second, @start_time,@end_time) as NVARCHAR) + 'seconds';
		print'>>--------------'

		set @end_time = GETDATE();
		print'Truncating Table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		print'Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Vivaswan\data-warehouse\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
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