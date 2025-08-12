CREATE ROLE app_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers TO app_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Orders TO app_rw;

CREATE ROLE report_ro;
GRANT SELECT ON dbo.Customers TO report_ro;
GRANT SELECT ON dbo.Orders TO report_ro;

CREATE ROLE dba_admin;
GRANT ALTER ANY USER TO dba_admin;
GRANT ALTER ANY ROLE TO dba_admin;
GRANT VIEW DEFINITION TO dba_admin;
