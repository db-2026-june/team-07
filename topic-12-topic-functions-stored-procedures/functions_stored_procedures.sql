-- ================================================================
-- FUNCTIONS & STORED PROCEDURES TEMPLATE (TOPIC 12)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
--
-- FUNCTIONS (at least 3):
--   - Each function should encapsulate reusable logic or a
--     calculation relevant to your project domain.
--   - Use CREATE OR REPLACE FUNCTION ... RETURNS ...
--
-- STORED PROCEDURES — SELECT / INSERT (at least 2):
--   - Procedures that retrieve data or insert new records.
--   - Use CREATE OR REPLACE PROCEDURE ...
--
-- STORED PROCEDURES — UPDATE (at least 2):
--   - Procedures that modify existing records.
--
-- FOR EACH FUNCTION / PROCEDURE, ADD COMMENTS EXPLAINING:
--   - Purpose: what it does
--   - Parameters: name, type, meaning
--   - Expected behavior / return value
--
-- TEST CALLS:
--   - Include at least one example call per function/procedure
--     (SELECT my_function(...) or CALL my_procedure(...))
--
-- OPTIONAL:
--   - EXCEPTION blocks for error handling
--   - Transaction management with BEGIN / COMMIT / ROLLBACK
--
-- RECOMMENDED ORDER:
-- 1) Functions
-- 2) SELECT / INSERT procedures
-- 3) UPDATE procedures
-- 4) Test calls
--
-- IMPORTANT:
-- - All routines must execute in PostgreSQL without errors.
-- - Logic must be relevant to your project domain.
-- - Submit everything in this single SQL file.
-- ================================================================

SET search_path TO restaurantschema;
=========================================================
-- 1. FUNCTIONS:
--======================================================
========================================================
-- 1.1Checking available ingredients for dish 
========================================================
CREATE OR REPLACE FUNCTION restaurantschema.check_menu_item_availability(
    restaurant_id INT,
    menu_item_id INT
)
RETURNS TEXT AS $$
DECLARE
    count_out_of_stock INT;
BEGIN 
    -- Counting ingredients that out of stock
    SELECT COUNT(*) 
    INTO count_out_of_stock
    FROM restaurantschema."MenuItemIngredientsJunctionTable" mi
    JOIN restaurantschema."BasicInventories" bi 
        ON mi.ingredientid = bi.ingredientid
    JOIN restaurantschema."RestaurantInventoryJunctionTable" ri 
        ON bi.basicinventoryid = ri.basicinventoryid
    WHERE mi.menuitemid = menu_item_id
      AND ri.restaurantid = restaurant_id
      AND bi.count <= 0; 
    
    -- Getting error msg if some ingredients missing
    IF count_out_of_stock > 0 THEN
        RETURN 'Not enough ingredients to order this dish';
    END IF;

    -- Everything is enought and ready to order
    RETURN 'Dish is available for order';
END;
$$ LANGUAGE plpgsql;
-- Checking if menu item 1 available in restaurant 1;
SELECT restaurantschema.check_menu_item_availability(1, 1);

========================================================
--1.2 Checking available tables(how many can sit there) in restaurant 
========================================================
-- checking available tables on strict date 
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
    -- Checking if table can fit there 
    SELECT (sizeoftable >= p_people_count) INTO v_capacity_ok
    FROM restaurantschema."RestaurantTables"
    WHERE tableid = p_table_id;

    -- Getting FALSE if table is too small 
    IF v_capacity_ok IS NOT TRUE THEN
        RETURN FALSE;
    END IF;

    -- Checking if there no reservation (+/- 2 hours)
    SELECT NOT EXISTS (
        SELECT 1 FROM restaurantschema."Reservations"
        WHERE tableid = p_table_id 
          AND reservationdatetime BETWEEN p_check_time - INTERVAL '2 hours' AND p_check_time + INTERVAL '2 hours'
    ) INTO v_is_free;

    RETURN v_is_free;
END;
$$ LANGUAGE plpgsql;
-- Checking table №1 for 4 people on strict date
SELECT restaurantschema.is_table_suitable(1, 4, '2026-07-22 19:00:00');
=========================================================
-- 1.3 Purpose: Calculate the average rating for a restaurant.
=========================================================
-- Expected to return the average rating as a decimal.
CREATE OR REPLACE FUNCTION restaurantschema.get_avg_restaurant_rating(p_restaurant_id INT)
RETURNS DECIMAL(3,2) AS $$
BEGIN
    RETURN (SELECT AVG(rating)::DECIMAL(3,2) 
            FROM restaurantschema."CustomerFeedbacks" 
            WHERE restaurantid = p_restaurant_id);
END;
$$ LANGUAGE plpgsql;
-Output avg rating of curruetn restaurant
SELECT restaurantschema.get_avg_restaurant_rating(1) AS "Average rating of restaurant №1";
=========================================================
-- 2. PROCEDURES: SELECT & INSERT 
-- ======================================================
--2.1registration of new client
--Makes a record of client and returning messenge
=========================================================
CREATE OR REPLACE PROCEDURE restaurantschema.register_customer(p_name TEXT, p_phone TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO restaurantschema."Customers" (name, phone) 
    VALUES (p_name, p_phone);
    
    RAISE NOTICE 'Client % successfully recorded.', p_name;
END;
$$;
--Invoke a procedure
CALL restaurantschema.register_customer('Alex', '+380501112233');
--Cheking result
SELECT * FROM restaurantschema."Customers" 
WHERE name = 'Alex';

========================================================
--2.2 Getting orders list of client 
--Output in console information about order
========================================================
CREATE OR REPLACE PROCEDURE restaurantschema.show_customer_orders(p_customer_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r_order RECORD;
    v_found BOOLEAN := false;
BEGIN
    -- Цикл по замовленнях
    FOR r_order IN (
        SELECT orderid, status 
        FROM restaurantschema."Orders" 
        WHERE customerid = p_customer_id
    ) 
    LOOP 
        v_found := true;
        RAISE NOTICE 'Замовлення №%: статус %', r_order.orderid, r_order.status;
    END LOOP;

    IF NOT v_found THEN
        RAISE NOTICE 'У клієнта з ID % замовлень не знайдено.', p_customer_id;
    END IF;
END;
$$;
--Checking if information created
CALL restaurantschema.show_customer_orders(13);

======================================================
-- 3. PROCEDURES: UPDATE 
======================================================
-- 3.1 Updating worker position 
======================================================
--Changing role of workers and looking if ID exits
CREATE OR REPLACE PROCEDURE restaurantschema.promote_staff(
    p_staff_id INT, 
    p_new_role_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- If worker exists
    IF NOT EXISTS (SELECT 1 FROM restaurantschema."Staff" WHERE staffid = p_staff_id) THEN
        RAISE EXCEPTION 'Працівника з ID % не знайдено.', p_staff_id;
    END IF;

    --  If this role exists
    IF NOT EXISTS (SELECT 1 FROM restaurantschema."StaffRoles" WHERE staffroleid = p_new_role_id) THEN
        RAISE EXCEPTION 'Ролі з ID % не існує.', p_new_role_id;
    END IF;

    -- Updating 
    UPDATE restaurantschema."Staff"
    SET staffroleid = p_new_role_id
    WHERE staffid = p_staff_id;

    RAISE NOTICE 'Worker with ID % successfully updatet on new role(Role: %).', p_staff_id, p_new_role_id;
END;
$$;

--Cheking current role 
SELECT staffid, name, staffroleid FROM restaurantschema."Staff" WHERE staffid = 1;

--Invoke procedure 
CALL restaurantschema.promote_staff(1, 2);

--Checking update
SELECT staffid, name, staffroleid FROM restaurantschema."Staff" WHERE staffid = 1;

--Checking all roles in restaurants 
SELECT staffroleid || ' - ' || rolename AS "List off all roles"
FROM restaurantschema."StaffRoles"
ORDER BY staffroleid;
========================================================
-- 3.2 Update price for menu item 
========================================================
CREATE OR REPLACE PROCEDURE restaurantschema.sp_update_menu_item_price(
    p_menu_item_id INT,
    p_new_price NUMERIC(10,2)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_item_exists BOOLEAN;
BEGIN
    -- Checking if new price is valid
    IF p_new_price <= 0 THEN
        RAISE EXCEPTION 'Invalid price: % (Price must be greater than zero)', p_new_price;
    END IF;

    -- Checking if dish exists 
    SELECT EXISTS (
        SELECT 1 
        FROM restaurantschema."MenuItems"
        WHERE menuitemid = p_menu_item_id
    ) INTO v_item_exists;

    -- Error if menu item does not exist
    IF NOT v_item_exists THEN
        RAISE EXCEPTION 'Menu item with ID % not found', p_menu_item_id;
    END IF;

    -- Updating price for dish
    UPDATE restaurantschema."MenuItems"
    SET price = p_new_price
    WHERE menuitemid = p_menu_item_id;

EXCEPTION
    WHEN OTHERS THEN
        -- Catching errors and throwing descriptive message with error code
        RAISE EXCEPTION 'Failed to update price for menu item %: [SQLSTATE %] %', 
            p_menu_item_id, SQLSTATE, SQLERRM;
END;
$$;

-- Procedure to update dish 3 price to 199.99
CALL restaurantschema.sp_update_menu_item_price(3, 199.99); 

