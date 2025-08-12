ALTER DATABASE CURRENT SET QUERY_STORE = ON;
ALTER DATABASE CURRENT SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON );

SELECT desired_state, actual_state FROM sys.database_query_store_options;
SELECT name, desired_state_desc, actual_state_desc FROM sys.database_automatic_tuning_options;
