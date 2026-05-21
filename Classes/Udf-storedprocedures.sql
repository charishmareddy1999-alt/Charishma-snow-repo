create database udf_database;
create schema udf_schema;

CREATE OR REPLACE FUNCTION get_date(business_date timestamp)
RETURNS DATE
LANGUAGE SQL
AS
$$
TO_DATE(SUBSTR(TO_CHAR(business_date),1,10))
$$;

SELECT get_date('2024-01-01 12:53:22.000');

CREATE OR REPLACE TABLE SALES(
sale_datetime TIMESTAMP,
sale_amount NUMBER(19,4)
);
INSERT INTO SALES VALUES
('2023-01-01 12:53:22.000','2876.93'),
('2023-01-02 01:14:55.000','3509.75'),
('2023-01-03 01:05:12.000','2971.66'),
('2023-01-04 12:47:49.000','3328.32');

SELECT
get_date(sale_datetime) AS sale_date,
sale_amount
FROM SALES;

CREATE OR REPLACE TABLE sales_by_country(
year NUMBER(4),
country VARCHAR(50),
sale_amount NUMBER
);
INSERT INTO SALES_BY_COUNTRY VALUES
('2022','US','90000'),
('2022','UK','75000'),
('2022','FR','55000'),
('2023','US','100000'),
('2023','UK','80000'),
('2023','FR','70000');

CREATE OR REPLACE TABLE currency(
country VARCHAR(50),
currency VARCHAR(3)
);
INSERT INTO CURRENCY VALUES
('US','USD'),
('UK','GBP'),
('FR','EUR');


CREATE OR REPLACE FUNCTION get_sales(country_name VARCHAR)
RETURNS TABLE (year NUMBER, sale_amount NUMBER, country VARCHAR)
AS
$$
SELECT year, sale_amount, country
FROM sales_by_country
WHERE country = country_name
$$
;


SELECT * FROM TABLE(get_sales('US'));

CREATE or replace TABLE udf_database.udf_schema.EMPLOYEE (
    emp_id NUMBER AUTOINCREMENT START 100 INCREMENT 1,
    emp_name VARCHAR,
    emp_dept VARCHAR,
    emp_status VARCHAR,
    emp_salary NUMBER
);

INSERT INTO udf_database.udf_schema.EMPLOYEE (emp_name, emp_dept, emp_status, emp_salary)
VALUES
    ('John Smith', 'Engineering', 'Active', 85000),
    ('Jane Doe', 'Marketing', 'Active', 72000);


CREATE OR REPLACE PROCEDURE udf_database.udf_schema.INSERT_EMPLOYEE(
    p_emp_name VARCHAR,
    p_emp_dept VARCHAR,
    p_emp_status VARCHAR,
    p_emp_salary NUMBER
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO OMS_DEV.BRONZE.EMPLOYEE (emp_name, emp_dept, emp_status, emp_salary)
    VALUES (:p_emp_name, :p_emp_dept, :p_emp_status, :p_emp_salary);
    RETURN 'Employee inserted successfully';
END;
$$;

CALL udf_database.udf_schema.INSERT_EMPLOYEE('John Smith', 'Engineering', 'Active', 85000);
CALL udf_database.udf_schema.INSERT_EMPLOYEE('Jane Doe', 'Marketing', 'Active', 72000);

SELECT * FROM udf_database.udf_schema.EMPLOYEE;


delete from employee;

///using stored proc 
CALL udf_database.udf_schema.INSERT_EMPLOYEE('Vamsi ', 'IT', 'Active', 85000);


---employee is going to resign from org 

CREATE OR REPLACE PROCEDURE udf_database.udf_schema.DEACTIVATE_EMPLOYEE(
    p_emp_id NUMBER
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE OMS_DEV.BRONZE.EMPLOYEE
    SET emp_status = 'Inactive'
    WHERE emp_id = :p_emp_id;
    RETURN 'Employee status updated to Inactive';
END;
$$;

CALL udf_database.udf_schema.DEACTIVATE_EMPLOYEE(200);

SELECT * FROM udf_database.udf_schema.EMPLOYEE;

CREATE OR REPLACE PROCEDURE udf_database.udf_schema.DELETE_INACTIVE_EMPLOYEES()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    DELETE FROM udf_database.udf_schema.EMPLOYEE
    WHERE emp_status = 'Inactive';
    RETURN 'Inactive employees deleted successfully';
END;
$$;

CALL udf_database.udf_schema.DELETE_INACTIVE_EMPLOYEES();

SELECT * FROM udf_database.udf_schema.EMPLOYEE;



CREATE OR REPLACE TASK udf_database.udf_schema.TASK_DELETE_INACTIVE_EMPLOYEES
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = 'USING CRON 0 19 * * * America/New_York'
AS
CALL udf_database.udf_schema.DELETE_INACTIVE_EMPLOYEES();

ALTER TASK udf_database.udf_schema.TASK_DELETE_INACTIVE_EMPLOYEES RESUME;

select * from udf_database.udf_schema.TASK_DELETE_INACTIVE_EMPLOYEES;
---procedure to load data from AWS to snowflake 
--input --s3 url , table name    

-- CREATE OR REPLACE PROCEDURE udf_database.udf_schema.LOAD_FROM_S3(
--     p_s3_url VARCHAR,
--     p_table_name VARCHAR
-- )
-- RETURNS VARCHAR
-- LANGUAGE SQL
-- AS
-- $$
-- BEGIN
--     CREATE OR REPLACE STAGE udf_database.udf_schema.TEMP_S3_STAGE
--         URL = p_s3_url
--         STORAGE_INTEGRATION = AWS_S3_INTEGRATION
--         FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

--     EXECUTE IMMEDIATE 'COPY INTO udf_database.udf_schema.' || :p_table_name ||
--         ' FROM @udf_database.udf_schemaE.TEMP_S3_STAGE';

--     RETURN 'Data loaded successfully into ' || p_table_name;
-- END;
-- $$;

-- CALL OMS_DEV.BRONZE.LOAD_FROM_S3('s3://your-bucket/path/', 'EMPLOYEE');


-- select * from orders;

