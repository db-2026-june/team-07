-- =========================================================
-- Restaurant Database — DML Script
-- Schema: restaurantschema
-- Chain: "Sytyi Pan" — a 10-location casual dining chain
--        operating across major Ukrainian cities.
-- Sections:
--   1. INSERTS   — fill in every table with >= 10 realistic rows
--   2. UPDATES   — demonstrate meaningful update operations
--   3. DELETES   — demonstrate deletions and constraint behaviour
-- =========================================================


-- =========================================================
-- SECTION 1: INSERTS
-- =========================================================

-- ---------------------------------------------------------
-- 1.1 Locations (10 rows) — physical addresses.
-- LocationId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Locations" (address) VALUES
	('12 Khreshchatyk St, Kyiv'),
	('45 Svobody Ave, Lviv'),
	('8 Derybasivska St, Odesa'),
	('101 Sumska St, Kharkiv'),
	('27 Yavornytskoho Ave, Dnipro'),
	('16 Soborna St, Vinnytsia'),
	('3 Sobornosti Sq, Poltava'),
	('54 Myru Ave, Chernihiv'),
	('19 Nezalezhnosti St, Ivano-Frankivsk'),
	('7 Koriatovycha St, Uzhhorod');

-- ---------------------------------------------------------
-- 1.2 Restaurants (10 rows) — one per location (1:1).
-- RestaurantId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Restaurants" (name, rating, locationid) VALUES
	('Sytyi Pan - Kyiv Center', 5, 1),
	('Sytyi Pan - Lviv', 4, 2),
	('Sytyi Pan - Odesa Port', 4, 3),
	('Sytyi Pan - Kharkiv', 3, 4),
	('Sytyi Pan - Dnipro', 4, 5),
	('Sytyi Pan - Vinnytsia', 5, 6),
	('Sytyi Pan - Poltava', 3, 7),
	('Sytyi Pan - Chernihiv', 4, 8),
	('Sytyi Pan - Ivano-Frankivsk', 5, 9),
	('Sytyi Pan - Uzhhorod', 4, 10);

-- ---------------------------------------------------------
-- 1.3 StaffRoles (10 rows) — lookup table.
-- StaffRoleId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."StaffRoles"(rolename, description) VALUES
	('Head Chef', 'Oversees the kitchen and menu execution'),
	('Sous Chef', 'Second-in-command in the kitchen'),
	('Line Cook', 'Prepares dishes at an assigned station'),
	('Waiter', 'Takes orders and serves guests'),
	('Bartender', 'Prepares and serves beverages'),
	('Host', 'Greets guests and manages seating'),
	('Restaurant Manager', 'Manages daily restaurant operations'),
	('Dishwasher', 'Cleans kitchenware and dining equipment'),
	('Barista', 'Prepares coffee and espresso-based drinks'),
	('Delivery Driver', 'Delivers orders to customers');

-- ---------------------------------------------------------
-- 1.4 Staff (15 rows) — employees, each with one role.
-- StaffId 1..15
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Staff" (staffroleid, name, address, phone) VALUES
	(1, 'Oleksandr Kovalenko', '5 Lesi Ukrainky St, Kyiv', '+380671234501'),
	(2, 'Iryna Bondarenko', '11 Franka St, Lviv', '+380671234502'),
	(3, 'Mykola Tkachenko', '9 Deribasivska St, Odesa', '+380671234503'),
	(3, 'Kateryna Shevchenko', '22 Sumska St, Kharkiv', '+380671234504'),
	(4, 'Andriy Melnyk', '14 Soborna St, Vinnytsia', '+380671234505'),
	(4, 'Olena Petrenko', '6 Myru Ave, Chernihiv', '+380671234506'),
	(5, 'Dmytro Savchenko', '18 Koriatovycha St, Uzhhorod', '+380671234507'),
	(6, 'Yuliya Kravchenko', '3 Nezalezhnosti St, Ivano-Frankivsk', '+380671234508'),
	(7, 'Serhiy Boyko', '31 Yavornytskoho Ave, Dnipro', '+380671234509'),
	(7, 'Nataliya Rudenko', '2 Sobornosti Sq, Poltava', '+380671234510'),
	(8, 'Vitaliy Marchenko', '10 Khreshchatyk St, Kyiv', '+380671234511'),
	(9, 'Anna Kolesnyk', '25 Svobody Ave, Lviv', '+380671234512'),
	(10, 'Ihor Polishchuk', '17 Derybasivska St, Odesa', '+380671234513'),
	(1, 'Tetyana Zaitseva', '8 Sumska St, Kharkiv', '+380671234514'),
	(4, 'Roman Lysenko', '13 Soborna St, Vinnytsia', '+380671234515');

-- ---------------------------------------------------------
-- 1.5 StaffRestaurantJunctionTable (15 rows, M:N)
-- Most staff work at one restaurant; a few work at two.
-- ---------------------------------------------------------
INSERT INTO restaurantschema."StaffRestaurantJunctionTable" (staffid, restaurantid) VALUES
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 6),
	(6, 8),
	(7, 10),
	(8, 9),
	(9, 5),
	(10, 7),
	(11, 1),
	(12, 2),
	(13, 3),
	(1, 6),   -- Head Chef Oleksandr also consults at the Vinnytsia branch
	(9, 1);   -- Host Serhiy also covers shifts at Kyiv Center

-- ---------------------------------------------------------
-- 1.6 ShiftSchedules_JunctionTable (12 rows)
-- Own surrogate key; direct FKs to staff and restaurant.
-- ---------------------------------------------------------
INSERT INTO restaurantschema."ShiftSchedules_JunctionTable" (staffid, restaurantid, startdatetime, enddatetime) VALUES
	(1, 1, '2026-07-21 08:00', '2026-07-21 16:00'),
	(2, 2, '2026-07-21 09:00', '2026-07-21 17:00'),
	(3, 3, '2026-07-21 10:00', '2026-07-21 18:00'),
	(4, 4, '2026-07-21 10:00', '2026-07-21 18:00'),
	(5, 6, '2026-07-21 11:00', '2026-07-21 19:00'),
	(6, 8, '2026-07-21 12:00', '2026-07-21 20:00'),
	(7, 10, '2026-07-21 16:00', '2026-08-22 00:00'),
	(8, 9, '2026-07-21 09:00', '2026-07-21 15:00'),
	(9, 5, '2026-07-21 12:00', '2026-07-21 20:00'),
	(10, 7, '2026-07-22 08:00', '2026-07-22 16:00'),
	(11, 1, '2026-07-22 09:00', '2026-07-22 17:00'),
	(1, 6, '2026-07-23 08:00', '2026-07-23 14:00');

-- ---------------------------------------------------------
-- 1.7 MenuItemCategory (10 rows) — lookup table.
-- CategoryId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."MenuItemCategory" (categoryname) VALUES
	('Appetizers'),
	('Soups'),
	('Salads'),
	('Main Courses'),
	('Pizza'),
	('Pasta'),
	('Desserts'),
	('Beverages'),
	('Alcoholic Drinks'),
	('Breakfast');

-- ---------------------------------------------------------
-- 1.8 MenuItems (14 rows)
-- MenuItemId 1..14
-- ---------------------------------------------------------
INSERT INTO restaurantschema."MenuItems" (name, description, weight, price, categoryid) VALUES
	('Chicken Kyiv', 'Breaded chicken breast filled with garlic butter', 280.00, 245.00, 4),
	('Borscht', 'Traditional beet and cabbage soup with sour cream', 350.00, 95.00, 2),
	('Caesar Salad', 'Romaine lettuce, grilled chicken, parmesan, croutons', 220.00, 165.00, 3),
	('Margherita Pizza', 'Tomato sauce, mozzarella, fresh basil', 450.00, 210.00, 5),
	('Pepperoni Pizza', 'Tomato sauce, mozzarella, pepperoni', 480.00, 235.00, 5),
	('Carbonara Pasta', 'Spaghetti with egg, pancetta, parmesan', 320.00, 185.00, 6),
	('Bruschetta', 'Toasted bread with tomato, garlic and basil', 150.00, 89.00, 1),
	('Tiramisu', 'Classic Italian coffee-flavoured dessert', 180.00, 110.00, 7),
	('Cheesecake', 'Baked cheesecake with berry topping', 170.00, 105.00, 7),
	('Espresso', 'Single shot of espresso coffee', 30.00, 45.00, 8),
	('Fresh Orange Juice', 'Freshly squeezed orange juice', 250.00, 65.00, 8),
	('House Red Wine', 'Glass of house red wine, 150ml', 150.00, 120.00, 9),
	('Draft Beer', 'Local lager, 500ml', 500.00, 75.00, 9),
	('Scrambled Eggs & Toast', 'Scrambled eggs with buttered toast', 220.00, 85.00, 10);

-- ---------------------------------------------------------
-- 1.9 RestaurantMenuItemsJunctionTable (20 rows, M:N)
-- Flagship items sold at multiple locations.
-- ---------------------------------------------------------
INSERT INTO restaurantschema."RestaurantMenuItemsJunctionTable" (restaurantid, menuitemid) VALUES
	(1, 1), (1, 2), (1, 4), (1, 10), (1, 12),
	(2, 1), (2, 3), (2, 6), (2, 13),
	(3, 2), (3, 5), (3, 11),
	(4, 4), (4, 5), (4, 6),
	(5, 1), (5, 7),
	(6, 8), (6, 9), (6, 14);

-- ---------------------------------------------------------
-- 1.10 Ingredients (12 rows) — stable catalog data.
-- IngredientId 1..12
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Ingredients" (name, weight, quantity) VALUES
	('Chicken Breast', 0.20, 500),
	('Beef Tenderloin', 0.25, 200),
	('Salmon Fillet', 0.18, 150),
	('Tomatoes', 0.12, 800),
	('Mozzarella Cheese', 0.10, 400),
	('Wheat Flour', 1.00, 600),
	('Olive Oil', 0.50, 120),
	('Garlic', 0.01, 300),
	('Onion', 0.15, 350),
	('Fresh Basil', 0.02, 100),
	('Potatoes', 0.20, 700),
	('Eggs', 0.06, 900);

-- ---------------------------------------------------------
-- 1.11 MenuItemIngredientsJunctionTable (16 rows, M:N recipe composition)
-- ---------------------------------------------------------
INSERT INTO restaurantschema."MenuItemIngredientsJunctionTable" (menuitemid, ingredientid) VALUES
	(1, 1), (1, 6), (1, 8),
	(2, 4), (2, 9), (2, 11),
	(3, 1), (3, 4),
	(4, 4), (4, 5), (4, 10),
	(5, 4), (5, 5),
	(6, 6), (6, 12), (6, 8);

-- ---------------------------------------------------------
-- 1.12 BasicInventories (12 rows) — operational stock batches.
-- Some ingredients have multiple batches (1:N).
-- BasicInventoryId 1..12
-- ---------------------------------------------------------
INSERT INTO restaurantschema."BasicInventories" (ingredientid, name, count) VALUES
	(1, 'Chicken Breast - Batch A', 150),
	(1, 'Chicken Breast - Batch B', 90),
	(2, 'Beef Tenderloin - Batch A', 60),
	(3, 'Salmon Fillet - Batch A', 45),
	(4, 'Tomatoes - Batch A', 300),
	(4, 'Tomatoes - Batch B', 120),
	(5, 'Mozzarella - Batch A', 200),
	(6, 'Wheat Flour - Batch A', 250),
	(7, 'Olive Oil - Batch A', 40),
	(8, 'Garlic - Batch A', 100),
	(9, 'Onion - Batch A', 180),
	(12, 'Eggs - Batch A', 400);

-- ---------------------------------------------------------
-- 1.13 RestaurantInventoryJunctionTable (12 rows, M:N)
-- Which inventory batches are tracked at which restaurants.
-- ---------------------------------------------------------
INSERT INTO restaurantschema."RestaurantInventoryJunctionTable" (restaurantid, basicinventoryid) VALUES
	(1, 1), (1, 4), (1, 7),
	(2, 2), (2, 5),
	(3, 3), (3, 6),
	(4, 8), (4, 10),
	(5, 9),
	(6, 11),
	(7, 12);

-- ---------------------------------------------------------
-- 1.14 Suppliers (10 rows)
-- SupplierId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Suppliers" (name, address, phone) VALUES
	('Metro Cash & Carry', '1 Brovarskyi Ave, Kyiv', '+380442230101'),
	('Auchan Wholesale', '25 Petrivska St, Kyiv', '+380442230102'),
	('Lviv Fresh Farms', '4 Stryiska St, Lviv', '+380322230103'),
	('Odesa Seafood Co.', '19 Prymorska St, Odesa', '+380482230104'),
	('Kharkiv Meat Group', '8 Poltavskyi Shliakh, Kharkiv', '+380572230105'),
	('Dnipro Dairy Ltd.', '14 Naberezhna St, Dnipro', '+380562230106'),
	('Vinnytsia Bakers Union', '3 Khmelnytske Hwy, Vinnytsia', '+380432230107'),
	('Poltava Produce', '9 Zinkivska St, Poltava', '+380532230108'),
	('Carpathian Organic Goods', '2 Halytska St, Ivano-Frankivsk', '+380342230109'),
	('Uzhhorod Beverages', '6 Kyivska St, Uzhhorod', '+380312230110');

-- ---------------------------------------------------------
-- 1.15 BasicInventoriesSuppliersJunctionTable (12 rows, M:N)
-- ---------------------------------------------------------
INSERT INTO restaurantschema."BasicInventoriesSuppliersJunctionTable" (supplierid, basicinventoryid) VALUES
	(1, 1), (1, 7),
	(2, 4), (2, 5),
	(3, 9),
	(4, 3),
	(5, 2),
	(6, 12),
	(7, 8),
	(8, 6),
	(9, 10),
	(10, 11);

-- ---------------------------------------------------------
-- 1.16 RestaurantTables (14 rows) — seating tables per restaurant.
-- TableId 1..14
-- ---------------------------------------------------------
INSERT INTO restaurantschema."RestaurantTables" (restaurantid, sizeoftable) VALUES
	(1, 2), (1, 4), (1, 6),
	(2, 2), (2, 4),
	(3, 4), (3, 8),
	(4, 2), (4, 4),
	(5, 4),
	(6, 2), (6, 6),
	(7, 4),
	(8, 4);

-- ---------------------------------------------------------
-- 1.17 Customers (12 rows) — anonymized sample data.
-- CustomerId 1..12
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Customers" (name, phone) VALUES
	('Nadiya Hrynchuk', '+380501112201'),
	('Pavlo Sydorenko', '+380501112202'),
	('Larysa Vasylenko', '+380501112203'),
	('Bohdan Ivanchuk', '+380501112204'),
	('Oksana Fedorenko', '+380501112205'),
	('Taras Hnatiuk', '+380501112206'),
	('Halyna Moroz', '+380501112207'),
	('Viktor Semenov', '+380501112208'),
	('Sofiya Danylenko', '+380501112209'),
	('Ruslan Pavliuk', '+380501112210'),
	('Yevheniya Karpenko', '+380501112211'),
	('Maksym Onyshchuk', '+380501112212');

-- ---------------------------------------------------------
-- 1.18 Reservations (12 rows)
-- ReservationId 1..12
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Reservations" (tableid, customerid, reservationdatetime, numberofpeople) VALUES
	(1, 1, '2026-07-22 19:00', 2),
	(2, 2, '2026-07-22 20:00', 4),
	(3, 3, '2026-07-23 18:30', 5),
	(4, 4, '2026-07-23 19:30', 2),
	(5, 5, '2026-07-24 12:00', 3),
	(6, 6, '2026-07-24 13:00', 8),
	(7, 7, '2026-07-25 18:00', 2),
	(8, 8, '2026-07-25 19:00', 4),
	(9, 9, '2026-07-26 20:00', 3),
	(10, 10, '2026-07-26 21:00', 2),
	(11, 11, '2026-07-27 18:00', 2),
	(12, 12, '2026-07-27 19:00', 6);

-- ---------------------------------------------------------
-- 1.19 CustomerFeedbacks (12 rows)
-- FeedbackId 1..12
-- ---------------------------------------------------------
INSERT INTO restaurantschema."CustomerFeedbacks"(customerid, restaurantid, rating, comment) VALUES
	(1, 1, 5, 'Amazing Chicken Kyiv, will definitely come back!'),
	(2, 1, 4, 'Great atmosphere, service was a bit slow.'),
	(3, 2, 4, 'Loved the Caesar salad, fresh ingredients.'),
	(4, 2, 5, 'Best pizza in Lviv, highly recommend.'),
	(5, 3, 3, 'Food was good but wait time was long.'),
	(6, 3, 4, 'Cozy place near the port, nice view.'),
	(7, 4, 3, 'Average experience, nothing special.'),
	(8, 5, 5, 'Excellent staff and quick service.'),
	(9, 6, 5, 'Fantastic desserts, especially the tiramisu.'),
	(10, 6, 4, 'Great wine selection.'),
	(11, 9, 5, 'Wonderful breakfast menu.'),
	(12, 10, 4, 'Friendly staff, will visit again.');

-- ---------------------------------------------------------
-- 1.20 OrderTypes (10 rows) — lookup table for order channels.
-- OrderTypeId 1..10
-- ---------------------------------------------------------
INSERT INTO restaurantschema."OrderTypes" (nameoftype) VALUES
	('Dine-In'),
	('Takeaway'),
	('Delivery'),
	('Drive-Thru'),
	('Catering'),
	('Online Pickup'),
	('Phone Order'),
	('Third-Party Delivery'),
	('Group Order'),
	('Curbside Pickup');

-- ---------------------------------------------------------
-- 1.21 Orders (14 rows) — order headers.
-- OrderId 1..14. Delivery/Takeaway orders have Null tableid.
-- ---------------------------------------------------------
INSERT INTO restaurantschema."Orders" (tableid, ordertypeid, customerid, status) VALUES
	(1, 1, 1, 'completed'),
	(2, 1, 2, 'completed'),
	(3, 1, 3, 'completed'),
	(NULL, 3, 4, 'pending'),
	(NULL, 2, 5, 'completed'),
	(6, 1, 6, 'completed'),
	(7, 1, 7, 'in_progress'),
	(NULL, 3, 8, 'pending'),
	(9, 1, 9, 'completed'),
	(NULL, 2, 10, 'completed'),
	(11, 1, 11, 'in_progress'),
	(12, 1, 12, 'completed'),
	(NULL, 6, 1, 'completed'),
	(NULL, 3, 3, 'cancelled');

-- ---------------------------------------------------------
-- 1.22 MenuItems_Orders_JunctionTable (23 rows, M:N order items)
-- ---------------------------------------------------------
INSERT INTO restaurantschema."MenuItems_Orders_JunctionTable" (menuitemid, orderid) VALUES
	(1, 1), (10, 1),
	(2, 2), (12, 2),
	(4, 3), (13, 3),
	(4, 4), (11, 4),
	(3, 5),
	(8, 6), (10, 6),
	(6, 7),
	(5, 8), (13, 8),
	(9, 9), (14, 9),
	(7, 10),
	(1, 11), (2, 11),
	(4, 12), (5, 12),
	(8, 13),
	(2, 14);


-- =========================================================
-- SECTION 2: UPDATES
-- Demonstrates realistic, meaningful update operations.
-- =========================================================

-- 2.1 Recalculate a restaurant's rating as the rounded average of its
--     customer feedback ratings — a typical maintenance operation.
UPDATE restaurantschema."Restaurants" AS r
SET rating = sub.avg_rating
FROM (
	SELECT restaurantid, Round(Avg(rating)) AS avg_rating
	FROM restaurantschema."CustomerFeedbacks"
	GROUP BY restaurantid
) AS sub
WHERE r.restaurantid = sub.restaurantid
RETURNING *;

-- 2.2 Apply a seasonal price increase of 5% to all Pizza category items.
UPDATE restaurantschema."MenuItems"
SET price = Round(price * 1.05, 2)
WHERE categoryid = (SELECT categoryid FROM restaurantschema."MenuItemCategory" WHERE categoryname = 'Pizza')
RETURNING *;

-- 2.3 Progress an order's status as it moves through the kitchen workflow.
UPDATE restaurantschema."Orders"
SET status = 'completed'
WHERE orderid = 7
RETURNING *;

-- 2.4 Promote a staff member: change role from Line Cook to Sous Chef.
UPDATE restaurantschema."Staff"
SET staffroleid = (SELECT staffroleid FROM restaurantschema."StaffRoles" WHERE rolename = 'Sous Chef')
WHERE name = 'Kateryna Shevchenko'
RETURNING *;

-- 2.5 Correct a customer's phone number (typical data-fix scenario).
UPDATE restaurantschema."Customers"
SET phone = '+380501112299'
WHERE name = 'Maksym Onyshchuk'
RETURNING *;

-- 2.6 Restock an inventory batch after a new delivery arrives.
UPDATE restaurantschema."BasicInventories"
SET count = count + 100
WHERE name = 'Chicken Breast - Batch A'
RETURNING *;

-- 2.7 Customer reschedules their reservation to a later time and updates the party size (common self-service scenario).
UPDATE restaurantschema."Reservations"
SET reservationdatetime = '2026-07-24 15:00', numberofpeople = 5
WHERE tableid = 5 AND customerid = 5
RETURNING *;
 
-- 2.8 Renovation at the Kyiv Center branch: two small tables are physically merged into one bigger table, so its seating capacity is updated in place (no need to delete/recreate the row, 
-- since the table itself still exists — only its attribute changes).
UPDATE restaurantschema."RestaurantTables"
SET sizeoftable = 8
WHERE restaurantid = 1 AND sizeoftable = 6
RETURNING *;
 
-- 2.9 Recalculate each ingredient's master "Quantity" (catalog snapshot) as the sum of all its current operational stock batches in BasicInventories. 
UPDATE restaurantschema."Ingredients" AS i
SET quantity = sub.total_count
FROM (
	SELECT ingredientid, Sum(count) AS total_count
	FROM restaurantschema."BasicInventories"
	WHERE ingredientid IS NOT NULL
	GROUP BY ingredientid
) AS sub
WHERE i.ingredientid = sub.ingredientid
RETURNING *;
 
-- 2.10 Supplier rebrands and relocates to a new office address.
UPDATE restaurantschema."Suppliers"
SET name = 'Metro Cash & Carry Ukraine', address = '10 Bilenko St, Kyiv'
WHERE name = 'Metro Cash & Carry'
RETURNING *;
 
-- 2.11 Correct a location's address after municipal street renumbering (city authorities renumbered buildings on that street).
UPDATE restaurantschema."Locations"
SET address = '12A Khreshchatyk St, Kyiv'
WHERE address = '12 Khreshchatyk St, Kyiv'
RETURNING *;



-- =========================================================
-- SECTION 3: DELETES
-- Demonstrates deletions and the schema's ON DELETE behaviour (CASCADE / SET NULL / RESTRICT).
-- =========================================================
 
-- 3.1 CASCADE: deleting a staff member automatically removes their rows in StaffRestaurantJunctionTable and ShiftSchedules_JunctionTable (both defined with ON DELETE CASCADE).
--     Roman Lysenko (StaffId 15) has no shifts/assignments seeded above, so this is a clean, safe example row to remove.
DELETE FROM restaurantschema."Staff"
WHERE name = 'Roman Lysenko';
 
-- 3.2 SET NULL: deleting a Location sets the owning Restaurant's LocationId to Null (ON DELETE SET NULL) instead of deleting the restaurant itself. 
--     We add a throwaway 11th location/restaurant pair purely to demonstrate this safely, without touching real chain data.
INSERT INTO restaurantschema."Locations" (address) VALUES ('99 Test Place, Kyiv')
RETURNING *;

INSERT INTO restaurantschema."Restaurants" (name, rating, locationid)
	VALUES ('Sytyiy Pan - Test', 3, (SELECT locationid FROM restaurantschema."Locations" WHERE address = '99 Test Place, Kyiv'))
RETURNING *;
 
DELETE FROM restaurantschema."Locations" WHERE address = '99 Test Place, Kyiv';

-- Verify: the test restaurant still exists but its locationid is now Null.
SELECT name, locationid FROM restaurantschema."Restaurants" WHERE name = 'Sytyiy Pan - Test';
 
-- Clean up the throwaway restaurant created for the demo above.
DELETE FROM restaurantschema."Restaurants" WHERE name = 'Sytyiy Pan - Test';

-- 3.3 SET NULL: deleting a StaffRole sets StaffRoleId to Null for every staff member who had that role (ON DELETE SET NULL on - fk_staff_role), instead of deleting the staff members themselves.
DELETE FROM restaurantschema."StaffRoles" WHERE rolename = 'Delivery Driver';

-- Verify: 
SELECT staffid, name, staffroleid FROM restaurantschema."Staff"
WHERE name = 'Ihor Polishchuk';  -- staffroleid is now Null

-- 3.4 SET NULL: deleting a MenuItemCategory sets CategoryId to Null on any menu items in that category (ON DELETE SET NULL on fk_menuitem_category), instead of deleting the dishes themselves.
DELETE FROM restaurantschema."MenuItemCategory" WHERE categoryname = 'Breakfast';

-- Verify: 
SELECT menuitemid, name, categoryid FROM restaurantschema."MenuItems"
WHERE name = 'Scrambled Eggs & Toast';  -- categoryid is now Null
 
-- 3.5 RESTRICT: an Ingredient that is still used in a recipe (MenuItemIngredientsJunctionTable) cannot be deleted directly. This statement is EXPECTED to fail with an error (foreign key violation)
DELETE FROM restaurantschema."Ingredients" WHERE name = 'Chicken Breast';
 
-- 3.6 RESTRICT: a Customer with an existing Reservation or Order cannot be deleted directly, protecting historical/business data. This statement is also EXPECTED to fail with a foreign key violation error.
DELETE FROM restaurantschema."Customers" WHERE name = 'Nadiya Hrynchuk';
 
-- 3.7 Correct multi-step deletion: to remove a cancelled order, its line items in MenuItems_Orders_JunctionTable must be deleted first (that FK is ON DELETE RESTRICT, by design — order history should
--     normally never be hard-deleted; this shows how an admin cleanup script would do it if ever required).
DELETE FROM restaurantschema."MenuItems_Orders_JunctionTable"
WHERE orderid = (
    SELECT orderid
    FROM restaurantschema."Orders"
    WHERE status = 'cancelled'
      AND customerid = 3
);

-- Verify: no line items remain for the cancelled order.
SELECT *
FROM restaurantschema."MenuItems_Orders_JunctionTable"
WHERE orderid = (
    SELECT orderid
    FROM restaurantschema."Orders"
    WHERE status = 'cancelled'
      AND customerid = 3
);

DELETE FROM restaurantschema."Orders"
WHERE status = 'cancelled'
  AND customerid = 3;

-- Verify: the cancelled order has been removed.
SELECT *
FROM restaurantschema."Orders"
WHERE status = 'cancelled'
  AND customerid = 3;
 
-- 3.8 Simple junction-table deletion: remove a staff member's extra assignment to a second restaurant (relationship no longer needed). Remove the relationship between staff member 9 and restaurant 1.
--     This deletes only the association in the junction table. The staff member and the restaurant remain in the database.
DELETE FROM restaurantschema."StaffRestaurantJunctionTable"
WHERE staffid = 9 AND restaurantid = 1;

INSERT INTO restaurantschema."StaffRestaurantJunctionTable"(staffid, restaurantid)
VALUES (9, 3);

-- Verify: the old relationship no longer exists.
SELECT *
FROM restaurantschema."StaffRestaurantJunctionTable"
WHERE staffid = 9
  AND restaurantid = 1;

-- Verify: the new relationship exists.
SELECT *
FROM restaurantschema."StaffRestaurantJunctionTable"
WHERE staffid = 9
  AND restaurantid = 3;
 
-- 3.9 Bulk cleanup: Delete reservation records scheduled before 1 July 2026. Demonstrates a bulk DELETE operation using a date condition.
DELETE FROM restaurantschema."Reservations"
WHERE reservationdatetime < TIMESTAMP '2026-07-01 00:00';
 
-- 3.10 CASCADE: discontinuing a limited-time seasonal menu item. We first add the seasonal item (with a recipe and restaurant availability), then remove it once the season ends. 
--     Because it was never ordered, MenuItems_Orders_JunctionTable (ON DELETE RESTRICT) does not block it, while its recipe rows in MenuItemIngredientsJunctionTable and its availability rows in
--     RestaurantMenuItemsJunctionTable (both ON DELETE CASCADE) are removed automatically together with the menu item.
INSERT INTO restaurantschema."MenuItems" (name, description, weight, price, categoryid)
	VALUES ('Summer Berry Lemonade', 'Limited-time seasonal cold drink', 300.00, 70.00, 8)
RETURNING *;
 
INSERT INTO restaurantschema."MenuItemIngredientsJunctionTable" (menuitemid, ingredientid)
	VALUES ((SELECT menuitemid FROM restaurantschema."MenuItems" WHERE name = 'Summer Berry Lemonade'), 4)
RETURNING *;
 
INSERT INTO restaurantschema."RestaurantMenuItemsJunctionTable" (restaurantid, menuitemid)
	VALUES (1, (SELECT menuitemid FROM restaurantschema."MenuItems" WHERE name = 'Summer Berry Lemonade'))
RETURNING *;
 
DELETE FROM restaurantschema."MenuItems" WHERE name = 'Summer Berry Lemonade';

-- Verify: the recipe/availability rows above are gone too (cascaded).
SELECT * FROM restaurantschema."MenuItemIngredientsJunctionTable"
WHERE menuitemid = (SELECT menuitemid FROM restaurantschema."MenuItems" WHERE name = 'Summer Berry Lemonade');
 
-- 3.11 CASCADE: a depleted inventory batch is removed from the system. The batch quantity is first set to zero to indicate it has been fully consumed, then the inventory record is deleted. 
--     Related rows in RestaurantInventoryJunctionTable and BasicInventoriesSuppliersJunctionTable are removed automatically through ON DELETE CASCADE.
SELECT * FROM restaurantschema."BasicInventories" WHERE name = 'Onion - Batch A';

UPDATE restaurantschema."BasicInventories" SET count = 0 WHERE name = 'Onion - Batch A';

DELETE FROM restaurantschema."BasicInventories" WHERE name = 'Onion - Batch A';

-- Verify: rows above are gone too after deleting (cascaded).
SELECT *
FROM restaurantschema."RestaurantInventoryJunctionTable"
WHERE basicinventoryid = 11;

SELECT *
FROM restaurantschema."BasicInventoriesSuppliersJunctionTable"
WHERE basicinventoryid = 11;
 
-- 3.12 CASCADE: remove an inactive supplier. Deleting the supplier automatically removes its related rows from BasicInventoriesSuppliersJunctionTable through ON DELETE CASCADE.

-- Create a temporary inventory batch.
INSERT INTO restaurantschema."BasicInventories"
(ingredientid, name, count)
VALUES
( 10,'Onion - Batch B', 50)
RETURNING *;

-- Link the supplier with the inventory batch.
INSERT INTO restaurantschema."BasicInventoriesSuppliersJunctionTable"
(basicinventoryid, supplierid)
VALUES (
    (SELECT basicinventoryid
     FROM restaurantschema."BasicInventories"
     WHERE name = 'Onion - Batch B'),
    (SELECT supplierid
     FROM restaurantschema."Suppliers"
     WHERE name = 'Uzhhorod Beverages')
)
RETURNING *;

-- Delete the supplier.
DELETE FROM restaurantschema."Suppliers"
WHERE name = 'Uzhhorod Beverages';

-- Verify that the junction-table row was removed automatically.
SELECT *
FROM restaurantschema."BasicInventoriesSuppliersJunctionTable"
WHERE supplierid = (
    SELECT supplierid
    FROM restaurantschema."Suppliers"
    WHERE name = 'Uzhhorod Beverages'
);