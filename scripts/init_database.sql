/*
	CREATE or DROP then CREATE the database to be used for the Data Warehouse.
	Set up 3 Schemas for the 3 layers in the Medallion Approach.
 	
	Running this script drops the database if it exists. Use it with caution
	and know that any data is lost if you do not set up a backup.
*/

USE master;

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse			 -- force any other connection to
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- be disconnected and rollback

	DROP TABLE DataWarehouse
END;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
