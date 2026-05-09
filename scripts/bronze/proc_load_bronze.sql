/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA INFILE` command to load data from csv Files to bronze tables.

Usage Example:
    CALL bronze.load_bronze();
===============================================================================
*/

DELIMITER $$

CREATE PROCEDURE bronze.load_bronze()
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
        SELECT 'ERROR OCCURED DURING LOADING BRONZE LAYER' AS `Error`;
        SELECT CONCAT('Error Message: ', @text) AS `Message`;
        SELECT CONCAT('Error Number: ', @errno) AS `Number`;
        SELECT '==========================================' AS `Status`;
    END;

    SET batch_start_time = NOW(6);
    SELECT '================================================' AS `Info`;
    SELECT 'Loading Bronze Layer' AS `Info`;
    SELECT '================================================' AS `Info`;

    -- ------------------------------------------------
    -- Loading CRM Tables
    -- ------------------------------------------------
    SELECT '------------------------------------------------' AS `Info`;
    SELECT 'Loading CRM Tables' AS `Info`;
    SELECT '------------------------------------------------' AS `Info`;

    -- Table: bronze.crm_cust_info
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.crm_cust_info' AS `Process`;
    TRUNCATE TABLE bronze.crm_cust_info;
    
    SELECT '>> Inserting Data Into: bronze.crm_cust_info' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_crm/cust_info.csv'
    INTO TABLE bronze.crm_cust_info
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: bronze.crm_prd_info
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.crm_prd_info' AS `Process`;
    TRUNCATE TABLE bronze.crm_prd_info;

    SELECT '>> Inserting Data Into: bronze.crm_prd_info' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_crm/prd_info.csv'
    INTO TABLE bronze.crm_prd_info
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: bronze.crm_sales_details
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.crm_sales_details' AS `Process`;
    TRUNCATE TABLE bronze.crm_sales_details;

    SELECT '>> Inserting Data Into: bronze.crm_sales_details' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_crm/sales_details.csv'
    INTO TABLE bronze.crm_sales_details
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- ------------------------------------------------
    -- Loading ERP Tables
    -- ------------------------------------------------
    SELECT '------------------------------------------------' AS `Info`;
    SELECT 'Loading ERP Tables' AS `Info`;
    SELECT '------------------------------------------------' AS `Info`;
    
    -- Table: bronze.erp_loc_a101
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.erp_loc_a101' AS `Process`;
    TRUNCATE TABLE bronze.erp_loc_a101;

    SELECT '>> Inserting Data Into: bronze.erp_loc_a101' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_erp/loc_a101.csv'
    INTO TABLE bronze.erp_loc_a101
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: bronze.erp_cust_az12
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.erp_cust_az12' AS `Process`;
    TRUNCATE TABLE bronze.erp_cust_az12;

    SELECT '>> Inserting Data Into: bronze.erp_cust_az12' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_erp/cust_az12.csv'
    INTO TABLE bronze.erp_cust_az12
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    -- Table: bronze.erp_px_cat_g1v2
    SET start_time = NOW(6);
    SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2' AS `Process`;
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: bronze.erp_px_cat_g1v2' AS `Process`;
    LOAD DATA INFILE 'C:/sql/dwh_project/datasets/source_erp/px_cat_g1v2.csv'
    INTO TABLE bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
    SET end_time = NOW(6);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS `Duration`;

    SET batch_end_time = NOW(6);
    SELECT '==========================================' AS `Info`;
    SELECT 'Loading Bronze Layer is Completed' AS `Info`;
    SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' seconds') AS `Summary`;
    SELECT '==========================================' AS `Info`;

END$$

DELIMITER ;