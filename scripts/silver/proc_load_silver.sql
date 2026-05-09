/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver) - MySQL Version
===============================================================================
*/

DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
    -- Variable Declarations
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE batch_start_time DATETIME(6);
    DECLARE batch_end_time DATETIME(6);

    -- Error Handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SELECT '==========================================' AS `Status`;
        SELECT 'ERROR OCCURED DURING LOADING SILVER LAYER' AS `Error`;
        SELECT CONCAT('Error Message: ', @text) AS `Message`;
        SELECT CONCAT('Error Number: ', @errno) AS `Number`;
        SELECT '==========================================' AS `Status`;
    END;

    SET batch_start_time = NOW(6);
    SELECT '================================================' AS `Info`;
    SELECT 'Loading Silver Layer' AS `Info`;
    SELECT '================================================' AS `Info`;

    -- ------------------------------------------------
    -- Loading CRM Tables
    -- ------------------------------------------------
    
    -- Table: silver.crm_cust_info
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.crm_cust_info' AS `Process`;
    TRUNCATE TABLE silver.crm_cust_info;
    
    SELECT '>> Inserting Data Into: silver.crm_cust_info' AS `Process`;
    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: silver.crm_prd_info
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.crm_prd_info' AS `Process`;
    TRUNCATE TABLE silver.crm_prd_info;
    
    SELECT '>> Inserting Data Into: silver.crm_prd_info' AS `Process`;
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
        SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)),
        prd_nm,
        IFNULL(prd_cost, 0),
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        CAST(prd_start_dt AS DATE),
        CAST(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS DATE)
    FROM bronze.crm_prd_info;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: silver.crm_sales_details
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.crm_sales_details' AS `Process`;
    TRUNCATE TABLE silver.crm_sales_details;
    
    SELECT '>> Inserting Data Into: silver.crm_sales_details' AS `Process`;
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR CHAR_LENGTH(CAST(sls_order_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END,
        CASE 
            WHEN sls_ship_dt = 0 OR CHAR_LENGTH(CAST(sls_ship_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END,
        CASE 
            WHEN sls_due_dt = 0 OR CHAR_LENGTH(CAST(sls_due_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price 
        END
    FROM bronze.crm_sales_details;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- ------------------------------------------------
    -- Loading ERP Tables
    -- ------------------------------------------------
    
    -- Table: silver.erp_cust_az12
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.erp_cust_az12' AS `Process`;
    TRUNCATE TABLE silver.erp_cust_az12;
    
    SELECT '>> Inserting Data Into: silver.erp_cust_az12' AS `Process`;
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4) ELSE cid END,
        CASE WHEN bdate > CURRENT_DATE() THEN NULL ELSE bdate END,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: silver.erp_loc_a101
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.erp_loc_a101' AS `Process`;
    TRUNCATE TABLE silver.erp_loc_a101;
    
    SELECT '>> Inserting Data Into: silver.erp_loc_a101' AS `Process`;
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', ''),
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a101;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: silver.erp_px_cat_g1v2
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: silver.erp_px_cat_g1v2' AS `Process`;
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    
    SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2' AS `Process`;
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
    FROM bronze.erp_px_cat_g1v2;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    SET batch_end_time = NOW(6);
    SELECT '==========================================' AS `Info`;
    SELECT 'Loading Silver Layer is Completed' AS `Info`;
    SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' seconds') AS `Summary`;
    SELECT '==========================================' AS `Info`;

END$$

DELIMITER ;