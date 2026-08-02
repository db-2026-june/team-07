-- ================================================================
-- FUNCTIONS & STORED PROCEDURES (TOPIC 12)
-- ================================================================
-- Project: "Sytyi Pan" Restaurant Management System
-- Schema: restaurantschema
-- ================================================================

SET search_path TO restaurantschema;

-- ================================================================
-- 1) FUNCTIONS
-- ================================================================

-- 1.1 Purpose: Checking available ingredients for a specific dish in a specific restaurant.
-- Parameters: 
--   - restaurant_id (INT): ID of the branch.
--   - menu_item_id (INT): ID of the dish from the menu.
-- Expected behavior: Returns 'Dish is available for order' if all ingredients count > 0, 
-- otherwise returns 'Not enough ingredients to order this dish'.
CREATE OR REPLACE FUNCTION restaurantschema.check_menu_item_availability(
    restaurant_id INT,
    menu_item_id INT
)
RETURNS TEXT AS $$
DECLARE
    count_out_of_stock INT;
BEGIN 
    -- Counting ingredients that are out of stock for this specific dish and restaurant
    SELECT COUNT(*) 
    INTO count_out_of_stock
    FROM restaurantschema."MenuItemIngredientsJunctionTable" mi
    JOIN restaurantschema."BasicInventories" bi ON mi.ingredientid = bi.ingredientid
    JOIN restaurantschema."RestaurantInventoryJunctionTable" ri ON bi.basicinventoryid = ri.basicinventoryid
    WHERE mi.menuitemid = menu_item_id
      AND ri.restaurantid = restaurant_id
      AND bi.count <= 0; 
    
    IF count_out_of_stock > 0 THEN
        RETURN 'Not enough ingredients to order this dish';
    END IF;

    RETURN 'Dish is available for order';
END;
$$ LANGUAGE plpgsql;


-- 1.2 Purpose: Checking if a table can fit the number of people and is not reserved within a 2-hour window.
-- Parameters:
--   - p_table_id (INT): ID of the table.
--   - p_people_count (INT): Number of guests.
--   - p_check_time (TIMESTAMP): Date and time to check.
-- Expected behavior: Returns TRUE if the table is large enough and free, FALSE otherwise.
CREATE OR REPLACE FUNCTION restaurantschema.is_table_suitable(
    p_table_id INT, 
    p_people_count INT, 
    p_check_time TIMESTAMP
)
RETURNS BOOLEAN AS $$
DECLARE
    v_capacity_ok BOOLEAN;
    v_is_free BOOLEAN;
BEGIN
    -- Checking if the table capacity is sufficient
    SELECT (sizeoftable >= p_people_count) INTO v_capacity_ok
    FROM restaurantschema."RestaurantTables"
    WHERE tableid = p_table_id;

    IF v_capacity_ok IS NOT TRUE THEN
        RETURN FALSE;
    END IF;

    -- Checking if there is no reservation within +/- 2 hours of the requested time
    SELECT NOT EXISTS (
        SELECT 1 FROM restaurantschema."Reservations"
        WHERE tableid = p_table_id 
          AND reservationdatetime BETWEEN p_check_time - INTERVAL '2 hours' AND p_check_time + INTERVAL '2 hours'
    ) INTO v_is_free;

    RETURN v_is_free;
END;
$$ LANGUAGE plpgsql;


-- 1.3 Purpose: Calculate the average rating for a specific restaurant based on customer feedback.
-- Parameters: 
--   - p_restaurant_id (INT): ID of the restaurant.
-- Expected behavior: Returns the average rating as a decimal value (e.g., 4.50).
CREATE OR REPLACE FUNCTION restaurantschema.get_avg_restaurant_rating(p_restaurant_id INT)
RETURNS DECIMAL(3,2) AS $$
BEGIN
    RETURN (SELECT AVG(rating)::DECIMAL(3,2) 
            FROM restaurantschema."CustomerFeedbacks" 
            WHERE restaurantid = p_restaurant_id);
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- 2) STORED PROCEDURES — SELECT / INSERT
-- ================================================================

-- 2.1 Purpose: Registration of a new client in the database (INSERT).
-- Parameters:
--   - p_name (TEXT): Full name of the customer.
--   - p_phone (TEXT): Contact phone number.
-- Expected behavior: Inserts a new record into "Customers" table and raises a success notice.
CREATE OR REPLACE PROCEDURE restaurantschema.register_customer(p_name TEXT, p_phone TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO restaurantschema."Customers" (name, phone) 
    VALUES (p_name, p_phone);
    
    RAISE NOTICE 'Client % successfully recorded.', p_name;
END;
$$;


-- 2.2 Purpose: Retrieve and display the order history for a specific customer (SELECT).
-- Parameters:
--   - p_customer_id (INT): ID of the customer.
-- Expected behavior: Loops through the customer's orders and outputs their ID and status to the console.
CREATE OR REPLACE PROCEDURE restaurantschema.show_customer_orders(p_customer_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r_order RECORD;
    v_found BOOLEAN := false;
BEGIN
    FOR r_order IN (
        SELECT orderid, status 
        FROM restaurantschema."Orders" 
        WHERE customerid = p_customer_id
    ) 
    LOOP 
        v_found := true;
        RAISE NOTICE 'Order №%: status %', r_order.orderid, r_order.status;
    END LOOP;

    IF NOT v_found THEN
        RAISE NOTICE 'No orders found for customer with ID %.', p_customer_id;
    END IF;
END;
$$;


-- ================================================================
-- 3) STORED PROCEDURES — UPDATE
-- ================================================================

-- 3.1 Purpose: Update a staff member's role and validate if both employee and role IDs exist (UPDATE).
-- Parameters:
--   - p_staff_id (INT): ID of the staff member.
--   - p_new_role_id (INT): ID of the new role.
-- Expected behavior: Updates the role or throws an exception if IDs are not found.
CREATE OR REPLACE PROCEDURE restaurantschema.promote_staff(
    p_staff_id INT, 
    p_new_role_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if staff member exists
    IF NOT EXISTS (SELECT 1 FROM restaurantschema."Staff" WHERE staffid = p_staff_id) THEN
        RAISE EXCEPTION 'Staff member with ID % not found.', p_staff_id;
    END IF;

    -- Check if the new role exists
    IF NOT EXISTS (SELECT 1 FROM restaurantschema."StaffRoles" WHERE staffroleid = p_new_role_id) THEN
        RAISE EXCEPTION 'Role with ID % does not exist.', p_new_role_id;
    END IF;

    -- Performing update
    UPDATE restaurantschema."Staff"
    SET staffroleid = p_new_role_id
    WHERE staffid = p_staff_id;

    RAISE NOTICE 'Worker ID % successfully promoted to role ID %.', p_staff_id, p_new_role_id;
END;
$$;


-- 3.2 Purpose: Update the price for a specific menu item with validation and error handling (UPDATE).
-- Parameters:
--   - p_menu_item_id (INT): ID of the dish.
--   - p_new_price (NUMERIC): The new price to set.
-- Expected behavior: Updates the price if the item exists and the price is positive. 
-- Uses EXCEPTION block for descriptive error catching.
CREATE OR REPLACE PROCEDURE restaurantschema.sp_update_menu_item_price(
    p_menu_item_id INT,
    p_new_price NUMERIC(10,2)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_item_exists BOOLEAN;
BEGIN
    -- Validation: Price must be positive
    IF p_new_price <= 0 THEN
        RAISE EXCEPTION 'Invalid price: % (Price must be greater than zero)', p_new_price;
    END IF;

    -- Validation: Check if item exists
    SELECT EXISTS (
        SELECT 1 FROM restaurantschema."MenuItems"
        WHERE menuitemid = p_menu_item_id
    ) INTO v_item_exists;

    IF NOT v_item_exists THEN
        RAISE EXCEPTION 'Menu item with ID % not found', p_menu_item_id;
    END IF;

    -- Updating the price
    UPDATE restaurantschema."MenuItems"
    SET price = p_new_price
    WHERE menuitemid = p_menu_item_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to update price for menu item %: [SQLSTATE %] %', 
            p_menu_item_id, SQLSTATE, SQLERRM;
END;
$$;


-- ================================================================
-- 4) TEST CALLS
-- ================================================================

-- Test 1: Check Dish Availability (Function)
SELECT restaurantschema.check_menu_item_availability(1, 1);

-- Test 2: Check Table Suitability (Function)
SELECT restaurantschema.is_table_suitable(1, 4, '2026-07-22 19:00:00');

-- Test 3: Get Average Restaurant Rating (Function)
SELECT restaurantschema.get_avg_restaurant_rating(1) AS "Average rating of restaurant №1";

-- Test 4: Register New Customer (Procedure)
CALL restaurantschema.register_customer('Alex', '+380501112233');

-- Test 5: Show Customer Orders (Procedure - result in Notice log)
CALL restaurantschema.show_customer_orders(1);

-- Test 6: Promote Staff (Procedure)
CALL restaurantschema.promote_staff(1, 2);

-- Test 7: Update Menu Price (Procedure)
CALL restaurantschema.sp_update_menu_item_price(3, 199.99);

-- Verification Selects
SELECT * FROM restaurantschema."Customers" WHERE name = 'Alex';
SELECT staffid, staffroleid FROM restaurantschema."Staff" WHERE staffid = 1;
SELECT menuitemid, price FROM restaurantschema."MenuItems" WHERE menuitemid = 3;
