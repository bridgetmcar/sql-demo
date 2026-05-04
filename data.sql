PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS sales_data_flat;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS standard_cost;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL UNIQUE,
    channel TEXT NOT NULL,
    region TEXT NOT NULL,
    customer_segment TEXT NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL UNIQUE,
    product_category TEXT NOT NULL,
    brand TEXT NOT NULL,
    list_price NUMERIC NOT NULL
);

CREATE TABLE calendar (
    calendar_date TEXT PRIMARY KEY,
    calendar_year INTEGER NOT NULL,
    calendar_month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    quarter_label TEXT NOT NULL,
    financial_year INTEGER NOT NULL,
    financial_period INTEGER NOT NULL
);

CREATE TABLE standard_cost (
    product_id INTEGER NOT NULL,
    effective_from TEXT NOT NULL,
    standard_cost NUMERIC NOT NULL,
    PRIMARY KEY (product_id, effective_from),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    sale_date TEXT NOT NULL,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    units INTEGER NOT NULL,
    revenue NUMERIC NOT NULL,
    cost NUMERIC NOT NULL,
    discount NUMERIC NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (sale_date) REFERENCES calendar(calendar_date)
);

INSERT INTO customers (customer_id, customer_name, channel, region, customer_segment) VALUES
(1,  'Southern Retail Group',   'Retail',      'NSW', 'Key Accounts'),
(2,  'Metro Food Distributors', 'Wholesale',   'NSW', 'Wholesale'),
(3,  'Eastside Hospitality',    'Hospitality', 'VIC', 'Hospitality'),
(4,  'Greenline Wholesale',     'Wholesale',   'QLD', 'Wholesale'),
(5,  'Apex Convenience',        'Retail',      'QLD', 'Independent Retail'),
(6,  'Harbour Market Stores',   'Retail',      'NSW', 'Independent Retail'),
(7,  'Pacific Dining Co',       'Hospitality', 'WA',  'Hospitality'),
(8,  'Northern Grocers',        'Retail',      'VIC', 'Key Accounts'),
(9,  'Corner Pantry Group',     'Retail',      'SA',  'Independent Retail'),
(10, 'FreshPath Distributors',  'Wholesale',   'WA',  'Wholesale'),
(11, 'Sunrise Cafes',           'Hospitality', 'QLD', 'Hospitality'),
(12, 'Central Buying Office',   'Retail',      'VIC', 'Key Accounts'),
(13, 'Urban Corner Stores',     'Retail',      'NSW', 'Independent Retail'),
(14, 'Budget Bites Cafe',       'Hospitality', 'VIC', 'Hospitality'),
(15, 'QuickStop Convenience',   'Retail',      'QLD', 'Independent Retail'),
(16, 'Regional Wholesale Hub',  'Wholesale',   'WA',  'Wholesale');

INSERT INTO products (product_id, product_name, product_category, brand, list_price) VALUES
(1,  'Sparkling Water 12 Pack',   'Beverages', 'BluePeak', 18.50),
(2,  'Cold Brew Coffee',          'Beverages', 'NorthCup', 24.00),
(3,  'Greek Yogurt Tub',          'Dairy',     'FarmLane',  6.80),
(4,  'Shredded Cheese 1kg',       'Dairy',     'FarmLane', 12.90),
(5,  'Frozen Berry Mix',          'Frozen',    'EverFresh', 11.40),
(6,  'Ready Meal Pasta Bake',     'Frozen',    'KitchenCo',  9.75),
(7,  'Sea Salt Crackers',         'Snacks',    'SnackHouse', 4.60),
(8,  'Protein Snack Bars',        'Snacks',    'SnackHouse', 21.00),
(9,  'Tomato Pasta Sauce',        'Pantry',    'KitchenCo',  5.20),
(10, 'Olive Oil 500ml',           'Pantry',    'Meditera',  13.80);

INSERT INTO standard_cost (product_id, effective_from, standard_cost) VALUES
(1, '2025-01-01', 10.20),
(2, '2025-01-01', 13.60),
(3, '2025-01-01',  3.90),
(4, '2025-01-01',  7.80),
(5, '2025-01-01',  6.10),
(6, '2025-01-01',  5.40),
(7, '2025-01-01',  2.20),
(8, '2025-01-01', 12.50),
(9, '2025-01-01',  2.90),
(10,'2025-01-01',  8.10);

WITH RECURSIVE dates(d) AS (
    SELECT date('2025-01-01')
    UNION ALL
    SELECT date(d, '+1 day')
    FROM dates
    WHERE d < date('2025-12-31')
)
INSERT INTO calendar (calendar_date, calendar_year, calendar_month, month_name, quarter_label, financial_year, financial_period)
SELECT
    d AS calendar_date,
    CAST(strftime('%Y', d) AS INTEGER) AS calendar_year,
    CAST(strftime('%m', d) AS INTEGER) AS calendar_month,
    CASE strftime('%m', d)
        WHEN '01' THEN 'January'
        WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'
        WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'
        WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'
        WHEN '08' THEN 'August'
        WHEN '09' THEN 'September'
        WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'
        ELSE 'December'
    END AS month_name,
    'Q' || (((CAST(strftime('%m', d) AS INTEGER) - 1) / 3) + 1) AS quarter_label,
    CASE
        WHEN CAST(strftime('%m', d) AS INTEGER) >= 7 THEN CAST(strftime('%Y', d) AS INTEGER) + 1
        ELSE CAST(strftime('%Y', d) AS INTEGER)
    END AS financial_year,
    CASE CAST(strftime('%m', d) AS INTEGER)
        WHEN 7 THEN 1
        WHEN 8 THEN 2
        WHEN 9 THEN 3
        WHEN 10 THEN 4
        WHEN 11 THEN 5
        WHEN 12 THEN 6
        WHEN 1 THEN 7
        WHEN 2 THEN 8
        WHEN 3 THEN 9
        WHEN 4 THEN 10
        WHEN 5 THEN 11
        ELSE 12
    END AS financial_period
FROM dates;

WITH RECURSIVE seq(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 1000
)
INSERT INTO sales (sale_id, sale_date, customer_id, product_id, units, revenue, cost, discount)
SELECT
    n AS sale_id,
    date('2025-01-01', '+' || ((n * 3) % 365) || ' days') AS sale_date,
    ((n - 1) % 12) + 1 AS customer_id,
    ((n * 7 - 1) % 10) + 1 AS product_id,
    2 + ((n * 5) % 10) AS units,
    ROUND(
        (
            (2 + ((n * 5) % 10)) *
            (SELECT list_price FROM products WHERE product_id = (((n * 7 - 1) % 10) + 1)) *
            (CASE 
                WHEN CAST(strftime('%m', date('2025-01-01', '+' || ((n * 3) % 365) || ' days')) AS INTEGER) IN (11,12) THEN 1.14
                WHEN CAST(strftime('%m', date('2025-01-01', '+' || ((n * 3) % 365) || ' days')) AS INTEGER) IN (6,7,8) THEN 0.94
                ELSE 1.00
             END) *
            (CASE (((n - 1) % 12) + 1)
                WHEN 1 THEN 1.12
                WHEN 2 THEN 1.08
                WHEN 3 THEN 1.05
                WHEN 4 THEN 1.03
                WHEN 5 THEN 0.97
                WHEN 6 THEN 0.95
                WHEN 7 THEN 1.01
                WHEN 8 THEN 1.09
                WHEN 9 THEN 0.93
                WHEN 10 THEN 1.00
                WHEN 11 THEN 0.96
                ELSE 1.10
             END) *
            (1 - (CASE 
                WHEN n % 9 = 0 THEN 0.10
                WHEN n % 4 = 0 THEN 0.05
                ELSE 0.00
            END))
        ),
        2
    ) AS revenue,
    ROUND(
        (2 + ((n * 5) % 10)) *
        (SELECT standard_cost FROM standard_cost WHERE product_id = (((n * 7 - 1) % 10) + 1)),
        2
    ) AS cost,
    CASE 
        WHEN n % 9 = 0 THEN 0.10
        WHEN n % 4 = 0 THEN 0.05
        ELSE 0.00
    END AS discount
FROM seq;

CREATE VIEW sales_data_flat AS
SELECT
    s.sale_id,
    s.sale_date,
    c.customer_name,
    c.region,
    c.customer_segment,
    p.product_name,
    p.product_category,
    s.units,
    s.revenue,
    s.cost,
    s.discount
FROM sales s
JOIN customers c
    ON s.customer_id = c.customer_id
JOIN products p
    ON s.product_id = p.product_id;

-- Optional checks
-- SELECT COUNT(*) AS sales_rows FROM sales;
-- SELECT COUNT(*) AS calendar_rows FROM calendar;
-- SELECT * FROM sales_data_flat LIMIT 10;
