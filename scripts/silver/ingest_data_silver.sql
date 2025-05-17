/*
	
	===========================================================================
	===========================================================================

	Procedure to:
		Ingest the data from the Bronze Layer and transform it
		in order to fit business logic.

	Usage: EXEC silver.load_silver; 
 	
 	WARNING: ----------------------------------------------------------------
	Running this script deletes all previous data in the Silver Layer tables
	and updates it with the transformed data from the Bronze Layer.

	===========================================================================
	===========================================================================

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	TRUNCATE TABLE silver.crm_cust_info
	INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) 
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname),
		TRIM(cst_lastname),
			CASE UPPER(TRIM(cst_marital_status))
		WHEN 'S' THEN 'Single'
		WHEN 'M' THEN 'Married'
		ELSE 'n/a'
		END cst_marital_status,
		CASE UPPER(TRIM(cst_gndr))
		WHEN 'F' THEN 'Female'
		WHEN 'M' THEN 'Male'
		ELSE 'n/a'
		END cst_gndr,
		cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cci.cst_id ORDER BY cci.cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info cci
		WHERE cci.cst_id IS NOT NULL
	)t WHERE flag_last = 1;
	
	TRUNCATE TABLE silver.crm_prd_info
	INSERT INTO silver.crm_prd_info (prd_id, prd_cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		TRIM(prd_nm) AS prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other sales'
		WHEN 'M' THEN 'Mountain'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
		END prd_line,
		prd_start_dt,
		DATEADD(day, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt
	FROM bronze.crm_prd_info;
	
	TRUNCATE TABLE silver.crm_sales_details
	INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
	SELECT 
		TRIM(sls_ord_num),
		TRIM(sls_prd_key),
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price
	FROM bronze.crm_sales_details csd;
	
	TRUNCATE TABLE silver.erp_cust_az12
	INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
	SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		CASE
			WHEN UPPER(TRIM(gen)) LIKE ('F%') THEN 'Female'
			WHEN UPPER(TRIM(gen)) LIKE ('M%') THEN 'Male'
			ELSE 'n/a'
		END AS gen
	FROM bronze.erp_cust_az12 eca;
	
	TRUNCATE TABLE silver.erp_loc_a101
	INSERT INTO silver.erp_loc_a101 (cid, cntry)
	SELECT
		REPLACE(ela.cid, '-', '') AS cid,
		CASE WHEN ela.cntry LIKE '%US%' OR ela.cntry LIKE '%USA%' THEN 'United States'
			WHEN ela.cntry LIKE '%DE%' THEN 'Germany'
			WHEN cntry LIKE '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(ela.cntry)
		END AS cntry
	FROM bronze.erp_loc_a101 ela;
	
	TRUNCATE TABLE silver.erp_px_cat_g1v2
	INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
	SELECT 
		id,
		TRIM(cat),
		TRIM(subcat),
		TRIM(maintenance)
	FROM bronze.erp_px_cat_g1v2 epcgv;
END
