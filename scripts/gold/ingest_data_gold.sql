/*

	===============================================================================
	===============================================================================

	Script Purpose:
		Creates views for the Gold layer. 
		Each view performs transformations and combines data from the Silver layer.

	===============================================================================
	===============================================================================

*/

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	cci.cst_id AS customer_id,
	cci.cst_key AS customer_number,
	cci.cst_firstname AS first_name,
	cci.cst_lastname AS last_name,
	ela.cntry AS country,
	cci.cst_marital_status AS marital_status,
	CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr -- CRM is Master for gender info
		ELSE COALESCE(eca.gen, 'n/a')
	END AS gender,
	eca.bdate AS birthdate,
	cci.cst_create_date AS create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela
ON cci.cst_key = ela.cid;

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
	cpi.prd_id AS product_id,
	cpi.prd_key AS product_number,
	cpi.prd_nm AS product_name,
	cpi.prd_cat_id AS category_id,
	epc.cat AS category,
	epc.subcat AS subcategory,
	epc.maintenance AS maintenance,
	cpi.prd_cost AS cost,
	cpi.prd_line AS product_line,
	cpi.prd_start_dt AS start_date
FROM silver.crm_prd_info cpi
LEFT JOIN silver.erp_px_cat_g1v2 epc
ON cpi.prd_cat_id = epc.id
WHERE cpi.prd_end_dt IS NULL;

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
	csd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customer_key,
	csd.sls_order_dt AS order_date,
	csd.sls_ship_dt AS shipping_date,
	csd.sls_due_dt AS due_date,
	csd.sls_sales AS sales_amount,
	csd.sls_quantity AS quantity,
	csd.sls_price AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_products dp
ON csd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers dc
ON csd.sls_cust_id = dc.customer_id;
