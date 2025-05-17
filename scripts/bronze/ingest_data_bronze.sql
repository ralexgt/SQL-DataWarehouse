/*
	
	===========================================================================
	===========================================================================

	Procedure to:
		Ingest the data from the sources.

	Usage: EXEC bronze.load_bronze; 
 	
 	WARNING: ----------------------------------------------------------------
	Running this script deletes all previous data in the Bronze Layer tables
	and updates it with the raw data from the sources.

	===========================================================================
	===========================================================================

*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	DECLARE @layer_start_time DATETIME, @layer_end_time DATETIME;
	SET @layer_start_time = GETDATE();
	BEGIN TRY
		PRINT ' ==================== ';
		PRINT ' Loading Bronze Layer ';
		PRINT ' ==================== ';
	
		PRINT ' -------------------- ';
		PRINT ' Loading CRM Source ';
		PRINT ' -------------------- ';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting data in table: crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM '/var/opt/mssql/data/datasets/source_crm/cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		-- SELECT TOP(10) * FROM bronze.crm_cust_info cci;
		-- SELECT COUNT(*) FROM bronze.crm_cust_info cci;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting data in table: crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM '/var/opt/mssql/data/datasets/source_crm/prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		-- SELECT TOP(10) * FROM bronze.crm_prd_info cpi;
		-- SELECT COUNT(*) FROM bronze.crm_prd_info cpi;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting data in table: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM '/var/opt/mssql/data/datasets/source_crm/sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		-- SELECT TOP(10) * FROM bronze.crm_sales_details csd;
		-- SELECT COUNT(*) FROM bronze.crm_sales_details csd;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
		
		PRINT ' -------------------- ';
		PRINT 'Loading ERP Source';
		PRINT ' -------------------- ';
		SET @start_time = GETDATE();
		PRINT 'Truncating table: erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT 'Inserting data in table: erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM '/var/opt/mssql/data/datasets/source_erp/cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		--SELECT TOP(10) * FROM bronze.erp_cust_az12 eca;
		-- SELECT COUNT(*) FROM bronze.erp_cust_az12 eca;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
		
		SET @start_time = GETDATE();
		PRINT 'Truncating table: erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT 'Inserting data in table: erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM '/var/opt/mssql/data/datasets/source_erp/loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		-- SELECT TOP(10) * FROM bronze.erp_loc_a101 ela;
		-- SELECT COUNT(*) FROM bronze.erp_loc_a101 ela;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
		
		SET @start_time = GETDATE();
		PRINT 'Inserting data in table: erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT 'Inserting data in table: erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM '/var/opt/mssql/data/datasets/source_erp/px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		-- SELECT TOP(10) * FROM bronze.erp_px_cat_g1v2 epcgv;
		-- SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2 epcgv;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '------------------'
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT '=========================================='
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Message: ' + CAST(ERROR_MESSAGE() AS VARCHAR);
		PRINT 'Error Message: ' + CAST(ERROR_STATE() AS VARCHAR);
	END CATCH
	SET @layer_end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @layer_start_time, @layer_end_time) AS NVARCHAR) + ' second';
END;	
