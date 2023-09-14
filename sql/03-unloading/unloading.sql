USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;
USE SCHEMA PUBLIC;

-- ****************************** 1.- Creating Mapping ******************************
CREATE OR REPLACE TRANSIENT TABLE SNOWPROCORE.PUBLIC.ACCOUNT_STATUS_CODE_MAPPING (
    ACCOUNT_STATUS_CODE VARCHAR(10),
    ACCOUNT_STATUS_DESCRIPTION VARCHAR(100)
);

INSERT INTO SNOWPROCORE.PUBLIC.ACCOUNT_STATUS_CODE_MAPPING (ACCOUNT_STATUS_CODE, ACCOUNT_STATUS_DESCRIPTION) VALUES ('1', 'SUPER ACCOUNT');

SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNT_STATUS_CODE_MAPPING;

--****************************** 2.- File Format ******************************
CREATE OR REPLACE FILE FORMAT SNOWPROCORE.PUBLIC.FILE_FORMAT_CSV_GENERIC
 COMPRESSION = 'AUTO'
 TYPE = 'CSV'
 FIELD_DELIMITER = ','
 FILE_EXTENSION = 'csv'
 EMPTY_FIELD_AS_NULL = TRUE
 FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

--****************************** 3.- Unloading to stage ******************************
COPY INTO @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS/TRANSFORMED_ACCOUNTS/
FROM (
    SELECT AR.ACCESSIBLE_BALANCE, AR.ACCOUNT_BALANCE, ASCM.ACCOUNT_STATUS_DESCRIPTION
    FROM SNOWPROCORE.PUBLIC.ACCOUNTS_RAW AS AR
    INNER JOIN SNOWPROCORE.PUBLIC.ACCOUNT_STATUS_CODE_MAPPING AS ASCM
        ON AR.ACCOUNT_STATUS_CODE = ASCM.ACCOUNT_STATUS_CODE
)
FILE_FORMAT = (FORMAT_NAME = SNOWPROCORE.PUBLIC.FILE_FORMAT_CSV_GENERIC)
;

--****************************** 3.- Downloading to local ******************************
GET @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS/TRANSFORMED_ACCOUNTS/data_0_0_0.csv.gz file:///Users/eplata/Developer/personal/snowflake-sample-code/sql/03-unloading/data_0_0_0.csv.gz;



