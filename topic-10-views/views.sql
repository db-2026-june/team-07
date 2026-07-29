-- ================================================================
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE VIEW scripts for required view types:
--    - Horizontal view (select specific columns)
--    - Vertical view (filter specific rows)
--    - Mixed view (columns + row filters)
--    - Join-based view (multiple tables)
--    - Subquery-based view
--    - UNION-based view
--    - View based on another view
--    - Updatable view with WITH CHECK OPTION
--
-- 2) Comments before each view explaining:
--    - Purpose of the view
--    - How it supports your project design
--
-- 3) Optional demo SELECT statements to show view output.
--
-- RECOMMENDED ORDER:
-- 1) Simple views (horizontal / vertical / mixed)
-- 2) Join and subquery views
-- 3) UNION and layered views
-- 4) CHECK OPTION view
--
-- IMPORTANT:
-- - Script must execute in PostgreSQL without errors.
-- - Keep naming consistent and readable.
-- - Submit all views in this single SQL file.
-- =========================================================
-- SQL VIEWS — Schema: restaurantschema
-- =========================================================

-- =========================================================
-- 1. SIMPLE VIEWS (Horizontal, Vertical, Mixed)
-- =========================================================

-- Horizontal view: Provides a quick list of restaurants with their public ratings.
CREATE OR REPLACE VIEW restaurantschema."view_RestaurantQuickList" AS
SELECT "Name", "Rating"
FROM restaurantschema."Restaurants";

-- Vertical view: Filters only top-performing restaurants with a rating of 4.5 or higher.
CREATE OR REPLACE VIEW restaurantschema."view_TopRatedRestaurants" AS
SELECT *
FROM restaurantschema."Restaurants"
WHERE "Rating" >= 4.5;

-- Mixed view: Selected columns from feedbacks where the rating is low, highlighting areas for improvement.
CREATE OR REPLACE VIEW restaurantschema."view_ActionRequiredFeedback" AS
SELECT "CustomerId", "Rating", "Comment"
FROM restaurantschema."CustomerFeedbacks"
WHERE "Rating" < 4.5;


-- =========================================================
-- 2. JOINED AND SUBQUERY VIEWS
-- =========================================================

-- Joined view: Combines order data with customer names and service types for a readable report.
CREATE OR REPLACE VIEW restaurantschema."view_OrderDetailsExtended" AS
SELECT
    o."OrderId",
    c."Name" AS customer_name,
    ot."NameOfType" AS order_type,
    o."Status"
FROM restaurantschema."Orders" AS o
JOIN restaurantschema."Customers" AS c ON o."CustomerId" = c."CustomerId"
JOIN restaurantschema."OrderTypes" AS ot ON o."OrderTypeId" = ot."OrderTypeId";

-- Subquery view: Identifies menu items that are priced above the current average of the entire menu.
CREATE OR REPLACE VIEW restaurantschema."view_AboveAveragePriceItems" AS
SELECT 
    "MenuItemId",
    "Name",
    "Price"
FROM restaurantschema."MenuItems"
WHERE "Price" > (
    SELECT AVG("Price") 
    FROM restaurantschema."MenuItems"
);


-- =========================================================
-- 3. UNION AND LAYERED VIEWS
-- =========================================================

-- UNION view: Merges shift start and end times into a single chronological timeline for staff management.
CREATE OR REPLACE VIEW restaurantschema."view_StaffScheduleTimeline" AS
SELECT 
    s."StaffId",
    s."Name" AS StaffName,
    sr."RoleName" AS StaffRole,
    ss."StartDateTime" AS EventTime,
    'Shift Start' AS EventType,
    'Scheduled start at restaurant ID: ' || ss."RestaurantId" AS Description
FROM restaurantschema."ShiftSchedules_JunctionTable" ss
JOIN restaurantschema."Staff" s ON ss."StaffId" = s."StaffId"
LEFT JOIN restaurantschema."StaffRoles" sr ON s."StaffRoleId" = sr."StaffRoleId"

UNION ALL

SELECT 
    s."StaffId",
    s."Name" AS StaffName,
    sr."RoleName" AS StaffRole,
    ss."EndDateTime" AS EventTime,
    'Shift End' AS EventType,
    'Scheduled end at restaurant ID: ' || ss."RestaurantId" AS Description
FROM restaurantschema."ShiftSchedules_JunctionTable" ss
JOIN restaurantschema."Staff" s ON ss."StaffId" = s."StaffId"
LEFT JOIN restaurantschema."StaffRoles" sr ON s."StaffRoleId" = sr."StaffRoleId"
ORDER BY EventTime;

-- Layered view: Based on "view_OrderDetailsExtended", it calculates the total count of orders per status.
CREATE OR REPLACE VIEW restaurantschema."view_OrderStatusSummary" AS 
SELECT 
    "Status", 
    COUNT(*) AS total_orders
FROM restaurantschema."view_OrderDetailsExtended"
GROUP BY "Status";


-- =========================================================
-- 4. CONTROL VIEWS (WITH CHECK OPTION)
-- =========================================================

-- Updatable view: Manages prices for premium items. CHECK OPTION ensures prices cannot be lowered below 150.
CREATE OR REPLACE VIEW restaurantschema."view_UpdatePremiumPrices" AS
SELECT "MenuItemId", "Name", "Price"
FROM restaurantschema."MenuItems"
WHERE "Price" >= 150.00
WITH CHECK OPTION;


-- =========================================================
-- 5. DEMO SELECTS (OPTIONAL)
-- =========================================================

-- SELECT * FROM restaurantschema."view_RestaurantQuickList";
-- SELECT * FROM restaurantschema."view_TopRatedRestaurants";
-- SELECT * FROM restaurantschema."view_OrderDetailsExtended";
-- SELECT * FROM restaurantschema."view_OrderStatusSummary";
-- SELECT * FROM restaurantschema."view_UpdatePremiumPrices";


