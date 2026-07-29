-- ================================================================
-- DATABASE ADMINISTRATION TEMPLATE (TOPIC 11)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE ROLE statements for at least 2 distinct roles.
--    Example roles: read-only analyst, read-write editor.
--
-- 2) GRANT statements assigning appropriate permissions to each role:
--    - Read-only role: GRANT SELECT ON ALL TABLES IN SCHEMA ...
--    - Read-write role: GRANT SELECT, INSERT, UPDATE, DELETE ...
--
-- 3) CREATE USER statements for at least 2 users.
--    Each user must be assigned to one of the defined roles.
--
-- 4) Comments before each section explaining the rationale:
--    - Why this role exists
--    - What access it should and should not have
--
-- RECOMMENDED ORDER:
-- 1) Roles + their GRANTs
-- 2) Users + GRANT ROLE TO USER
-- 3) Optional: REVOKE statements for fine-grained restrictions
-- 4) Optional cleanup block (commented out by default):
--    -- DROP USER ...; DROP ROLE ...;
--
-- IMPORTANT:
-- - Use explicit GRANT / REVOKE statements — do not rely on defaults.
-- - Roles must have meaningfully different permission levels.
-- - Script must execute in PostgreSQL without errors.
-- ================================================================

-- Add your script below this line

-- ================================================================
-- Restaurant Database - Task 5: DATABASE ADMINISTRATION
-- Schema: restaurantschema
-- ================================================================

-- ================================================================
-- HOW THIS SUPPORTS SECURITY AND DATA INTEGRITY
-- ================================================================
-- - Applies the Principle of Least Privilege.
-- - Separates users and roles for easier access management.
-- - Restricts write operations to protect data integrity.
-- - Prevents deletion of customer feedback records.
-- - Uses explicit GRANT and REVOKE statements for secure access control.


-- ================================================================
-- SECTION 1: BASELINE HARDENING
-- ================================================================
-- Revoke all default privileges from PUBLIC to enforce the Principle of Least Privilege. 
-- Access to restaurantschema is granted explicitly in the following sections.
REVOKE ALL ON SCHEMA restaurantschema FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA restaurantschema FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA restaurantschema FROM PUBLIC;

-- ================================================================
-- SECTION 2: ROLES + GRANTS
-- ================================================================

-- ----------------------------------------------------------------
-- 2.1 READONLY ROLE
-- ----------------------------------------------------------------
-- Provides read-only access for reporting and analytics users.
CREATE ROLE readonly_role NOLOGIN;

-- Allows access to objects within the schema.
GRANT USAGE ON SCHEMA restaurantschema TO readonly_role;

-- Read-only access to all existing tables and views.
GRANT SELECT ON ALL TABLES IN SCHEMA restaurantschema TO readonly_role;

-- Apply the same privileges to future tables.
ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema
    GRANT SELECT ON TABLES TO readonly_role;

-- ----------------------------------------------------------------
-- 2.2 READWRITE ROLE
-- ----------------------------------------------------------------
-- Provides read and write access for application users.
CREATE ROLE readwrite_role NOLOGIN;

GRANT USAGE ON SCHEMA restaurantschema TO readwrite_role;

-- Full CRUD access to all existing tables.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA restaurantschema TO readwrite_role;

-- Allow use of identity sequences for INSERT operations.
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA restaurantschema TO readwrite_role;

-- Apply the same privileges to future tables and sequences.
ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema
    GRANT USAGE, SELECT ON SEQUENCES TO readwrite_role;

-- ================================================================
-- SECTION 3: USERS
-- ================================================================
-- Create login accounts and assign permissions through roles. Passwords are for local testing only.
CREATE USER readonly_user WITH LOGIN PASSWORD 'ReadOnly_Pass123!';
CREATE USER readwrite_user WITH LOGIN PASSWORD 'ReadWrite_Pass123!';

-- ================================================================
-- SECTION 4: ROLE ASSIGNMENT
-- ================================================================
-- Grant each user the appropriate role and its associated privileges.
GRANT readonly_role TO readonly_user;
GRANT readwrite_role TO readwrite_user;

-- ================================================================
-- SECTION 5: FINE-GRAINED REVOKE - PROTECT HISTORICAL/AUDIT DATA
-- ================================================================
-- Prevent the application role from deleting customer feedback while still allowing it to view and modify existing records.
REVOKE DELETE ON restaurantschema."CustomerFeedbacks" FROM readwrite_role;

-- ================================================================
-- SECTION 6: A THIRD, MORE RESTRICTED ROLE
-- ================================================================
-- Provides limited access for hostess staff based on the Principle of Least Privilege.
CREATE ROLE hostess_role NOLOGIN;

GRANT USAGE ON SCHEMA restaurantschema TO hostess_role;

-- Manage reservations and table availability.
GRANT SELECT, INSERT, UPDATE, DELETE ON restaurantschema."Reservations" TO hostess_role;
GRANT SELECT, UPDATE ON restaurantschema."RestaurantTables" TO hostess_role;

-- Read-only access to customer information.
GRANT SELECT ON restaurantschema."Customers" TO hostess_role;

-- Restrict access to sensitive tables and customer modifications.
REVOKE ALL ON restaurantschema."Suppliers" FROM hostess_role;
REVOKE ALL ON restaurantschema."Staff" FROM hostess_role;
REVOKE INSERT, UPDATE, DELETE ON restaurantschema."Customers" FROM hostess_role;

-- Allow use of the reservation identity sequence.
GRANT USAGE, SELECT ON restaurantschema."Reservations_reservationid_seq" TO hostess_role;

CREATE USER hostess_user WITH LOGIN PASSWORD 'Hostess_Pass123!';
GRANT hostess_role TO hostess_user;

-- ================================================================
-- SECTION 7: VERIFICATION QUERIES
-- ================================================================
-- These SELECTs let you double-check the resulting privilege structure without needing to log in as each user individually.

-- 7.1 Which roles exist, and can they log in directly?
SELECT rolname, rolcanlogin, rolsuper
FROM pg_roles
WHERE rolname IN ('readonly_role', 'readwrite_role', 'hostess_role',
                  'readonly_user', 'readwrite_user', 'hostess_user')
ORDER BY rolname;

-- 7.2 Which users are members of which roles?
SELECT
	m.rolname  AS member_user,
	r.rolname  AS granted_role
FROM pg_auth_members am
JOIN pg_roles m ON am.member = m.oid
JOIN pg_roles r ON am.roleid = r.oid
WHERE m.rolname IN ('readonly_user', 'readwrite_user', 'hostess_user')
ORDER BY member_user;

-- 7.3 Table-level privileges actually granted to each role (confirms readonly = SELECT only, readwrite = full CRUD, hostess = limited to specific tables).
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('readonly_role', 'readwrite_role', 'hostess_role')
ORDER BY grantee, table_name, privilege_type;

-- ================================================================
-- SECTION 8: CLEANUP AFTER TESTING
-- ================================================================

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA restaurantschema FROM readonly_role;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA restaurantschema FROM readwrite_role;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA restaurantschema FROM hostess_role;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA restaurantschema FROM readwrite_role;
REVOKE USAGE ON SCHEMA restaurantschema FROM readonly_role, readwrite_role, hostess_role;

REVOKE readonly_role FROM readonly_user;
REVOKE readwrite_role FROM readwrite_user;
REVOKE hostess_role FROM hostess_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema REVOKE SELECT ON TABLES FROM readonly_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM readwrite_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA restaurantschema REVOKE USAGE, SELECT ON SEQUENCES FROM readwrite_role;
REVOKE USAGE, SELECT ON restaurantschema."Reservations_reservationid_seq" FROM hostess_role;

DROP USER IF EXISTS readonly_user;
DROP USER IF EXISTS readwrite_user;
DROP USER IF EXISTS hostess_user;

DROP ROLE IF EXISTS readonly_role;
DROP ROLE IF EXISTS readwrite_role;
DROP ROLE IF EXISTS hostess_role;
