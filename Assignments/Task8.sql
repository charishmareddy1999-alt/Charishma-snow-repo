-----------   TASK1   -----------------------------------

  CREATE OR REPLACE STAGE OUR_FIRST_DB.PUBLIC.PARQUET_STAGE
    URL = 's3://snowflakeparquetdemo' 
    FILE_FORMAT = (TYPE = 'PARQUET');

    LIST @OUR_FIRST_DB.PUBLIC.PARQUET_STAGE;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.PARQUET_DATA (
    PAR_DATA VARIANT
);

-- Load parquet into VARIANT table
COPY INTO OUR_FIRST_DB.PUBLIC.PARQUET_DATA
FROM @OUR_FIRST_DB.PUBLIC.PARQUET_STAGE;

-- Create structured table from VARIANT data
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.PARQUET_DATA AS
SELECT
    PAR_DATA:id::VARCHAR AS id,
    PAR_DATA:item_id::VARCHAR AS item_id,
    PAR_DATA:dept_id::VARCHAR AS dept_id,
    PAR_DATA:cat_id::VARCHAR AS cat_id,
    PAR_DATA:store_id::VARCHAR AS store_id,
    PAR_DATA:state_id::VARCHAR AS state_id,
    PAR_DATA:d::INT AS d,
    PAR_DATA:value::INT AS value,
    PAR_DATA:date::BIGINT AS date_raw
FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA;

SELECT * FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA;


SELECT COUNT(*) AS total_rows FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA;

-- Transformation 1: Total sales by department
SELECT dept_id, SUM(value) AS total_sales
FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA
GROUP BY dept_id
ORDER BY total_sales DESC;

-- Transformation 2: Total sales by state
SELECT state_id, SUM(value) AS total_sales, COUNT(*) AS num_transactions
FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA
GROUP BY state_id
ORDER BY total_sales DESC;

-- Transformation 3: Total sales by category and store
SELECT store_id, cat_id, SUM(value) AS total_sales
FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA
GROUP BY store_id, cat_id
ORDER BY store_id, total_sales DESC;

-- Transformation 4: Average sales per item
SELECT item_id, AVG(value) AS avg_sales, COUNT(*) AS days_sold
FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA
GROUP BY item_id
ORDER BY avg_sales DESC
LIMIT 20;




------------   TASK2   -----------------------------------------------

