USE DATABASE OMS_DEV;
USE SCHEMA BRONZE;

---------------------------------------------------
-- Create table
---------------------------------------------------

CREATE OR REPLACE TABLE CUSTOMERS(
    ID NUMBER,
    FULL_NAME VARCHAR,
    EMAIL VARCHAR,
    PHONE VARCHAR,
    SPENT NUMBER,
    CREATE_DATE DATE DEFAULT CURRENT_DATE
);

---------------------------------------------------
-- Insert records
---------------------------------------------------

INSERT INTO CUSTOMERS (ID, FULL_NAME, EMAIL, PHONE, SPENT)
VALUES
    (1,'Lewiss MacDwyer','lmacdwyer0@un.org','262-665-9168',140),
    (2,'Ty Pettingall','tpettingall1@mayoclinic.com','734-987-7120',254),
    (3,'Marlee Spadazzi','mspadazzi2@txnews.com','867-946-3659',120),
    (4,'Heywood Tearney','htearney3@patch.com','563-853-8192',1230),
    (5,'Odilia Seti','oseti4@globo.com','730-451-8637',143),
    (6,'Meggie Washtell','mwashtell5@rediff.com','568-896-6138',600);

SELECT * FROM CUSTOMERS;

---------------------------------------------------
-- Create roles
---------------------------------------------------

CREATE OR REPLACE ROLE ANALYST_MASKED;
CREATE OR REPLACE ROLE ANALYST_FULL;

---------------------------------------------------
-- Grant access
---------------------------------------------------

GRANT USAGE ON DATABASE OMS_DEV TO ROLE ANALYST_MASKED;
GRANT USAGE ON DATABASE OMS_DEV TO ROLE ANALYST_FULL;

GRANT USAGE ON SCHEMA OMS_DEV.BRONZE TO ROLE ANALYST_MASKED;
GRANT USAGE ON SCHEMA OMS_DEV.BRONZE TO ROLE ANALYST_FULL;

GRANT SELECT ON TABLE OMS_DEV.BRONZE.CUSTOMERS TO ROLE ANALYST_MASKED;
GRANT SELECT ON TABLE OMS_DEV.BRONZE.CUSTOMERS TO ROLE ANALYST_FULL;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_MASKED;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_FULL;

---------------------------------------------------
-- Assign roles to user
---------------------------------------------------

GRANT ROLE ANALYST_MASKED TO USER CHARISHMAREDDY;
GRANT ROLE ANALYST_FULL TO USER CHARISHMAREDDY;

---------------------------------------------------
-- Create masking policy
---------------------------------------------------

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE MASKING POLICY OMS_DEV.BRONZE.PHONE_MASK AS
(val VARCHAR) RETURNS VARCHAR ->
CASE
    WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN')
        THEN val
    ELSE CONCAT('********', RIGHT(val,4))
END;

---------------------------------------------------
-- Apply masking policy
---------------------------------------------------

ALTER TABLE OMS_DEV.BRONZE.CUSTOMERS
MODIFY COLUMN PHONE
SET MASKING POLICY OMS_DEV.BRONZE.PHONE_MASK;

---------------------------------------------------
-- Validate masking
---------------------------------------------------

USE ROLE ANALYST_FULL;

SELECT PHONE FROM OMS_DEV.BRONZE.CUSTOMERS;



---------------------------------------------------

USE ROLE ANALYST_MASKED;

SELECT ID, FULL_NAME,PHONE FROM OMS_DEV.BRONZE.CUSTOMERS;

