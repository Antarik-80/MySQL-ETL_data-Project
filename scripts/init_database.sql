/*
=============================================================
Create Databases (Schemas) - MySQL Version
=============================================================
Script Purpose:
    This script sets up the environment by creating three 
    databases: 'bronze', 'silver', and 'gold'.
    
    In MySQL, 'SCHEMA' and 'DATABASE' are interchangeable. 
    To maintain the architecture, we drop and recreate these 
    three distinct areas.

WARNING:
    Running this script will drop the 'bronze', 'silver', 
    and 'gold' databases if they exist. All data will be 
    permanently deleted.
*/

-- ----------------------------------------------------------
-- 1. Setup Bronze Layer
-- ----------------------------------------------------------
DROP DATABASE IF EXISTS bronze;
CREATE DATABASE bronze;

-- ----------------------------------------------------------
-- 2. Setup Silver Layer
-- ----------------------------------------------------------
DROP DATABASE IF EXISTS silver;
CREATE DATABASE silver;

-- ----------------------------------------------------------
-- 3. Setup Gold Layer
-- ----------------------------------------------------------
DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold;

-- ----------------------------------------------------------
-- Final Check: Display created databases
-- ----------------------------------------------------------
SHOW DATABASES;