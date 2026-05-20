-- <------------------  DATA SHARING ------------------------->
select * from OMS_DEV.BRONZE.ORDERS ;

--create shared object
CREATE SHARE oms_share;

--grant permissions to DATABASE schema tables (OMS_DEV.BRONZE.ORDERS)
GRANT USAGE ON DATABASE OMS_DEV TO SHARE oms_share;
GRANT USAGE ON SCHEMA OMS_DEV.BRONZE TO SHARE oms_share;
GRANT SELECT ON TABLE OMS_DEV.BRONZE.ORDERS TO SHARE oms_share;
GRANT SELECT ON TABLE OMS_DEV.BRONZE.ORDERS_v1 TO SHARE oms_share;

show shares ;

--provide access to consumer
ALTER SHARE oms_share ADD ACCOUNTS = EMEPHCP.CHERRY_READER_ACCT;



delete from  OMS_DEV.BRONZE.ORDERS where quantity < 10 ;

-- <------------------  CREATE READER ACCOUNT ------------------------->

-- Step 1: Create the reader account
CREATE MANAGED ACCOUNT CHERRY_READER_ACCT
    ADMIN_NAME = 'CHERRY_READER_ADMIN',
    ADMIN_PASSWORD = 'CHERRY_READER_ADMIN',
    TYPE = READER;

-- Step 2: View reader accounts to get the account locator and URL
SHOW MANAGED ACCOUNTS;

---------------------------from consumer account need to perform below ---------------

show shares ;


describe share AFZHTDG.HF66422.OMS_SHARE;


create database  vitech_dev   from  share AFZHTDG.HF66422.OMS_SHARE ;


select * from vitech_dev.bronze.orders ;



--------------------> DATA MASKING <-----------------------------------
-- Prepare table --
create or replace table customers(
  id number,
  full_name varchar,
  email varchar,
  phone varchar,
  spent number,
  create_date DATE DEFAULT CURRENT_DATE);

-- insert values in table --
insert into customers (id, full_name, email,phone,spent)
values
  (1,'Lewiss MacDwyer','lmacdwyer0@un.org','262-665-9168',140),
  (2,'Ty Pettingall','tpettingall1@mayoclinic.com','734-987-7120',254),
  (3,'Marlee Spadazzi','mspadazzi2@txnews.com','867-946-3659',120),
  (4,'Heywood Tearney','htearney3@patch.com','563-853-8192',1230),
  (5,'Odilia Seti','oseti4@globo.com','730-451-8637',143),
  (6,'Meggie Washtell','mwashtell5@rediff.com','568-896-6138',600);

select * from customers;
-- set up roles
CREATE OR REPLACE ROLE ANALYST_MASKED;
CREATE OR REPLACE ROLE ANALYST_FULL;

GRANT USAGE ON DATABASE OMS_DEV TO ROLE ANALYST_MASKED;
GRANT USAGE ON DATABASE OMS_DEV TO ROLE ANALYST_FULL;

-- grant select on table to roles
GRANT SELECT ON TABLE OMS_DEV.BRONZE.CUSTOMERS TO ROLE ANALYST_MASKED;
GRANT SELECT ON TABLE OMS_DEV.BRONZE.CUSTOMERS TO ROLE ANALYST_FULL;

GRANT USAGE ON SCHEMA OMS_DEV.BRONZE TO ROLE ANALYST_MASKED;
GRANT USAGE ON SCHEMA OMS_DEV.BRONZE TO ROLE ANALYST_FULL;

-- grant warehouse access to roles
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_MASKED;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_FULL;


-- assign roles to a user
GRANT ROLE ANALYST_MASKED TO USER CHARISHMAREDDY;
GRANT ROLE ANALYST_FULL TO USER CHARISHMAREDDY;

select current_user() ;

-- Set up masking policy

create or replace masking policy phone
    as (val varchar) returns varchar ->
            case        
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else '##-###-##'
            end;
 

-- Apply policy on a specific column
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone
SET MASKING POLICY PHONE;


ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN email
SET MASKING POLICY PHONE;

-- Validating policies

USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;




-- replace policy

use role accountadmin;

ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name UNSET MASKING POLICY;

create or replace masking policy names as (val varchar) returns varchar ->
            case
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else CONCAT(LEFT(val,2),'*******')
            end;

-- apply name masking policy
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name
SET MASKING POLICY names;

-- create phone masking policy (show last 4 digits only)
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone UNSET MASKING POLICY;

create or replace masking policy phone_mask as (val varchar) returns varchar ->
            case
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else CONCAT('**********', RIGHT(val, 4))
            end;

ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone
SET MASKING POLICY phone_mask;


-- Validating policies
USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;



select * from customers;


select   id ,full_name ,email from customers;


create table cust_ency  as
(
 select   id ,
    full_name ,
    ENCRYPT(email, 'MySecretPassphrase') AS encrypted_email from customers
) ;


select   id ,full_name ,TO_VARCHAR(DECRYPT(encrypted_email, 'MySecretPassphrase'), 'UTF-8') AS decrypted_email from cust_ency;
