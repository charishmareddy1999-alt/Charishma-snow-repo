--s3://bucketsnowflakes3
---s3://bucketsnowflakes3/Loan_payments_data.csv

CREATE TABLE   vitech_dev1.LOANS.LOAN_PAYMENT  (
   Loan_ID  STRING,
   loan_status  STRING,
   Principal  STRING,
   terms  STRING,
   effective_date  STRING,
   due_date  STRING,
   paid_off_time  STRING,
   past_due_days  STRING,
   age  STRING,
   education  STRING,
   Gender  STRING);


   CREATE DATABASE vitech_dev1;

  CREATE SCHEMA vitech_dev1.LOANS;



COPY INTO vitech_dev1.LOANS.LOAN_PAYMENT
FROM 's3://bucketsnowflakes3/Loan_payments_data.csv'
FILE_FORMAT = (TYPE=CSV , SKIP_HEADER = 1)


SELECT * FROM vitech_dev1.LOANS.LOAN_PAYMENT


SELECT
   LOAN_ID ,
   LOAN_STATUS,
   PRINCIPAL * TERMS AS TOTATL
FROM vitech_dev1.LOANS.LOAN_PAYMENT ;


SELECT DISTINCT * FROM vitech_dev1.LOANS.LOAN_PAYMENT;


SELECT GENDER, COUNT(*) AS GENDER_COUNT
FROM vitech_dev1.LOANS.LOAN_PAYMENT
GROUP BY GENDER;

--elt
--------------------------------------------------------------------
--etl

CREATE STAGE   LOANS_STAGE_V1
URL = 's3://bucketsnowflakes3';


CREATE STAGE   LOANS_STAGE
URL = 's3://bucketsnowflakes3/Loan_payments_data.csv'  ;


LIST @LOANS_STAGE ;
 
COPY INTO vitech_dev1.LOANS.LOAN_PAYMENT_V1
FROM @LOANS_STAGE
FILE_FORMAT = (TYPE=CSV , SKIP_HEADER = 1)


CREATE TABLE   vitech_dev1.LOANS.LOAN_PAYMENT_V1  (
   Loan_ID  STRING,
   loan_status  STRING,
   Principal  STRING,
   terms  STRING,
   effective_date  STRING,
   due_date  STRING,
   paid_off_time  STRING,
   past_due_days  STRING,
   age  STRING,
   education  STRING,
   Gender  STRING);



   SELECT * FROM vitech_dev1.LOANS.LOAN_PAYMENT_V1 ;



-------------------------------

   COPY INTO vitech_dev1.LOANS.LOAN_PAYMENT_V1
FROM @LOANS_STAGE
FILE_FORMAT = (TYPE=CSV , SKIP_HEADER = 1)


CREATE OR REPLACE TABLE   vitech_dev1.LOANS.LOAN_PAYMENT_V2 (
   Loan_ID  STRING,
   loan_status  STRING,
   Principal  STRING,
   TERMS sTRING
   )


  SELECT * FROM vitech_dev1.LOANS.LOAN_PAYMENT_V2 ;

COPY INTO vitech_dev1.LOANS.LOAN_PAYMENT_V2
FROM (
  SELECT $1,$2,$3,$4
  --($3*$4)
  FROM @LOANS_STAGE
)
FILE_FORMAT = (TYPE=CSV , SKIP_HEADER = 1) ;


  -----

  CREATE OR REPLACE TABLE   vitech_dev1.LOANS.LOAN_PAYMENT_V3 (
   Loan_ID  STRING,
   loan_status  STRING,
   Principal  STRING,
   TERMS sTRING,
   TOTAL_AMT STRING
   )
   
  COPY INTO vitech_dev1.LOANS.LOAN_PAYMENT_V3
FROM (
  SELECT $1,$2,$3,$4,
  COALESCE($8,'na')
  FROM @LOANS_STAGE
)
FILE_FORMAT = (TYPE=CSV , SKIP_HEADER = 1) ;


SELECT * FROM Vitech_dev1.LOANS.LOAN_PAYMENT_V3 ;


---------------------------------------------