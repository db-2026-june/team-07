// ================================================================
// Restaurant Database - MongoDB Document Schema
// ================================================================
// Design principles:
// - Independent entities are stored as separate collections.
// - Closely related child data with a single parent is embedded.
// - Small static lookup tables (e.g. roles, categories, order types) are stored as fields instead of separate collections.
//
// Collections:
// 1. restaurants - restaurants, address, tables, menu
// 2. staff - staff, role, assigned restaurants, schedules
// 3. customers - customers with embedded reservations
// 4. orders - orders with embedded items
// 5. menu_items - menu items with recipe
// 6. ingredients - ingredients with stock batches
// 7. suppliers - suppliers
// 8. feedback - customer feedback
// ================================================================

// ================================================================
// 1. restaurants
// ================================================================
// Stores restaurant information as a top-level collection.
// Address (1:1) and tables (1:N) are embedded because they belong only to one restaurant. The menu is embedded as a denormalized array for efficient read operations.
db.restaurants.insertMany([
	{
		_id: 1,
		name: "Sytyi Pan - Kyiv Center",
		rating: 5,
		address: {
			street: "12 Khreshchatyk St",
			city: "Kyiv"
		},
		tables: [
			{ tableId: 1, sizeOfTable: 2 },
			{ tableId: 2, sizeOfTable: 4 },
			{ tableId: 3, sizeOfTable: 6 }
		],
		menu: [
			{ menuItemId: 1, name: "Chicken Kyiv", price: 245.00 },
			{ menuItemId: 2, name: "Borscht", price: 95.00 },
			{ menuItemId: 4, name: "Margherita Pizza", price: 220.50 },
			{ menuItemId: 10, name: "Espresso", price: 45.00 },
			{ menuItemId: 12, name: "House Red Wine", price: 120.00 }
		]
	},
	{
		_id: 2,
		name: "Sytyi Pan - Lviv",
		rating: 4,
		address: {
			street: "45 Svobody Ave",
			city: "Lviv"
		},
		tables: [
			{ tableId: 4, sizeOfTable: 2 },
			{ tableId: 5, sizeOfTable: 4 }
		],
		menu: [
			{ menuItemId: 1, name: "Chicken Kyiv", price: 245.00 },
			{ menuItemId: 3, name: "Caesar Salad", price: 165.00 },
			{ menuItemId: 6, name: "Carbonara Pasta", price: 185.00 },
			{ menuItemId: 13, name: "Draft Beer", price: 75.00 }
		]
	}
]);


// ================================================================
// 2. staff
// ================================================================
// Stores employee information as a top-level collection.
// Role is stored as a field instead of a separate lookup collection.
// Assigned restaurants (M:N) and work schedules (1:N) are embedded because they belong to a specific staff member.
db.staff.insertMany([
	{
		_id: 1,
		name: "Oleksandr Kovalenko",
		phone: "+380671234501",
		role: "Head Chef",
		assignedRestaurants: [
			{ restaurantId: 1, restaurantName: "Sytyi Pan - Kyiv Center" },
			{ restaurantId: 6, restaurantName: "Sytyi Pan - Vinnytsia" }
		],
		schedule: [
			{ shiftId: 1, restaurantId: 1, start: "2026-07-21T08:00:00", end: "2026-07-21T16:00:00" },
			{ shiftId: 12, restaurantId: 6, start: "2026-07-23T08:00:00", end: "2026-07-23T14:00:00" }
		]
	},
	{
		_id: 2,
		name: "Iryna Bondarenko",
		phone: "+380671234502",
		role: "Sous Chef",
		assignedRestaurants: [
			{ restaurantId: 2, restaurantName: "Sytyi Pan - Lviv" }
		],
		schedule: [
			{ shiftId: 2, restaurantId: 2, start: "2026-07-21T09:00:00", end: "2026-07-21T17:00:00" }
		]
	}
]);


// ================================================================
// 3. customers
// ================================================================
// Stores customer information as a top-level collection.
// Reservations (1:N) are embedded because they belong to a single customer and are typically retrieved together.
db.customers.insertMany([
	{
		_id: 1,
		name: "Nadiya Hrynchuk",
		phone: "+380501112201",
		reservations: [
			{
				reservationId: 1,
				restaurantId: 1,
				tableId: 1,
				reservationDateTime: "2026-07-22T19:00:00",
				numberOfPeople: 2
			}
		]
	},
	{
		_id: 2,
		name: "Pavlo Sydorenko",
		phone: "+380501112202",
		reservations: [
			{
				reservationId: 2,
				restaurantId: 1,
				tableId: 2,
				reservationDateTime: "2026-07-22T20:00:00",
				numberOfPeople: 4
			}
		]
	}
]);


// ================================================================
// 4. orders
// ================================================================
// Stores orders as a top-level collection. Order type is stored as a field instead of a lookup collection.
// Ordered items (M:N) are embedded to keep each order complete, including item details at the time of purchase.
db.orders.insertMany([
	{
		_id: 1,
		customerId: 1,
		customerName: "Nadiya Hrynchuk",
		restaurantId: 1,
		tableId: 1,
		orderType: "Dine-In",
		status: "completed",
		items: [
			{ menuItemId: 1, name: "Chicken Kyiv", price: 245.00 },
			{ menuItemId: 10, name: "Espresso", price: 45.00 }
		]
	},
	{
		_id: 4,
		customerId: 4,
		customerName: "Bohdan Ivanchuk",
		restaurantId: 1,
		tableId: null,            // no table: this is a Delivery order
		orderType: "Delivery",
		status: "pending",
		items: [
			{ menuItemId: 4, name: "Margherita Pizza", price: 220.50 },
			{ menuItemId: 11, name: "Fresh Orange Juice", price: 65.00 }
		]
	}
]);


// ================================================================
// 5. menu_items
// ================================================================
// Stores menu items as a top-level collection.
// Category is stored as a field instead of a lookup collection.
// Recipe (M:N) is embedded because ingredient lists are typically retrieved together with the menu item.
db.menu_items.insertMany([
	{
		_id: 1,
		name: "Chicken Kyiv",
		description: "Breaded chicken breast filled with garlic butter",
		category: "Main Courses",
		price: 245.00,
		recipe: [
			{ ingredientId: 1, ingredientName: "Chicken Breast" },
			{ ingredientId: 6, ingredientName: "Wheat Flour" },
			{ ingredientId: 8, ingredientName: "Garlic" }
		]
	},
	{
		_id: 4,
		name: "Margherita Pizza",
		description: "Tomato sauce, mozzarella, fresh basil",
		category: "Pizza",
		price: 220.50,
		recipe: [
			{ ingredientId: 4, ingredientName: "Tomatoes" },
			{ ingredientId: 5, ingredientName: "Mozzarella Cheese" },
			{ ingredientId: 10, ingredientName: "Fresh Basil" }
		]
	}
]);


// ================================================================
// 6. ingredients
// ================================================================
// Stores ingredients as a top-level collection.
// Stock batches (1:N) are embedded, with suppliers (M:N) and tracked restaurants (M:N) nested inside each batch to keep inventory information together.
db.ingredients.insertMany([
	{
		_id: 1,
		name: "Chicken Breast",
		weight: 0.20,
		stockBatches: [
			{
				batchId: 1,
				batchName: "Chicken Breast - Batch A",
				count: 340,
				suppliers: [
					{ supplierId: 1, supplierName: "Metro Cash & Carry Ukraine" }
				],
				trackedAtRestaurants: [
					{ restaurantId: 1, restaurantName: "Sytyi Pan - Kyiv Center" }
				]
			},
			{
				batchId: 2,
				batchName: "Chicken Breast - Batch B",
				count: 90,
				suppliers: [],
				trackedAtRestaurants: []
			}
		]
	},
	{
		_id: 4,
		name: "Tomatoes",
		weight: 0.12,
		stockBatches: [
			{
				batchId: 5,
				batchName: "Tomatoes - Batch A",
				count: 300,
				suppliers: [
					{ supplierId: 2, supplierName: "Auchan Wholesale" }
				],
				trackedAtRestaurants: [
					{ restaurantId: 1, restaurantName: "Sytyi Pan - Kyiv Center" }
				]
			}
		]
	}
]);


// ================================================================
// 7. suppliers
// ================================================================
// Stores suppliers as a top-level collection.
// Suppliers are referenced by ingredient batches because one supplier can provide multiple batches.
db.suppliers.insertMany([
	{
		_id: 1,
		name: "Metro Cash & Carry Ukraine",
		address: "10 Bilenko St, Kyiv",
		phone: "+380442230101"
	},
	{
		_id: 2,
		name: "Auchan Wholesale",
		address: "25 Petrivska St, Kyiv",
		phone: "+380442230102"
	}
]);


// ================================================================
// 8. feedback
// ================================================================
// Stores customer feedback as a top-level collection.
// References customers and restaurants, since feedback belongs to both entities and grows independently over time.
db.feedback.insertMany([
	{
		_id: 1,
		customerId: 1,
		customerName: "Nadiya Hrynchuk",
		restaurantId: 1,
		restaurantName: "Sytyi Pan - Kyiv Center",
		rating: 5,
		comment: "Amazing Chicken Kyiv, will definitely come back!"
	},
	{
		_id: 2,
		customerId: 2,
		customerName: "Pavlo Sydorenko",
		restaurantId: 1,
		restaurantName: "Sytyi Pan - Kyiv Center",
		rating: 4,
		comment: "Great atmosphere, service was a bit slow."
	}
]);


// ================================================================
// Sample verification queries
// ================================================================
db.restaurants.findOne({ _id: 1 });
db.staff.findOne({ _id: 1 });
db.orders.find({ restaurantId: 1 }).toArray();
