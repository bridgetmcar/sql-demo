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

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    sale_date TEXT NOT NULL,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    units INTEGER NOT NULL,
    revenue NUMERIC NOT NULL,
    discount NUMERIC NOT NULL
);

INSERT INTO customers VALUES
(1,'Southern Retail Group','Retail','NSW','Key Accounts'),
(2,'Metro Food Distributors','Wholesale','NSW','Wholesale'),
(3,'Eastside Hospitality','Hospitality','VIC','Hospitality'),
(4,'Greenline Wholesale','Wholesale','QLD','Wholesale'),
(5,'Apex Convenience','Retail','QLD','Independent Retail'),
(6,'Harbour Market Stores','Retail','NSW','Independent Retail'),
(7,'Pacific Dining Co','Hospitality','WA','Hospitality'),
(8,'Northern Grocers','Retail','VIC','Key Accounts'),
(9,'Corner Pantry Group','Retail','SA','Independent Retail'),
(10,'FreshPath Distributors','Wholesale','WA','Wholesale'),
(11,'Sunrise Cafes','Hospitality','QLD','Hospitality'),
(12,'Central Buying Office','Retail','VIC','Key Accounts'),
(13,'Urban Corner Stores','Retail','NSW','Independent Retail'),
(14,'Budget Bites Cafe','Hospitality','VIC','Hospitality'),
(15,'QuickStop Convenience','Retail','QLD','Independent Retail'),
(16,'Regional Wholesale Hub','Wholesale','WA','Wholesale');

INSERT INTO products VALUES
(1,'Sparkling Water 12 Pack','Beverages','BluePeak',18.5),
(2,'Cold Brew Coffee','Beverages','NorthCup',24),
(3,'Greek Yogurt Tub','Dairy','FarmLane',6.8),
(4,'Shredded Cheese 1kg','Dairy','FarmLane',12.9),
(5,'Frozen Berry Mix','Frozen','EverFresh',11.4);

WITH RECURSIVE dates(d) AS (
  SELECT date('2025-01-01')
  UNION ALL
  SELECT date(d,'+1 day') FROM dates WHERE d < '2025-12-31'
)
INSERT INTO calendar
SELECT d,
strftime('%Y',d),
strftime('%m',d),
strftime('%m',d),
'Q'||((cast(strftime('%m',d) as int)-1)/3+1),
strftime('%Y',d),
strftime('%m',d)
FROM dates;

WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n<1000
)
INSERT INTO sales
SELECT
n,
date('2025-01-01','+'||(n%365)||' days'),
((n-1)%12)+1,
((n-1)%5)+1,
5 + (n%10),
ROUND((5 + (n%10)) * (10 + (n%5)*2),2),
0
FROM seq;

CREATE VIEW sales_data_flat AS
SELECT s.sale_id, s.sale_date, c.customer_name, p.product_name, s.revenue
FROM sales s
JOIN customers c ON s.customer_id=c.customer_id
JOIN products p ON s.product_id=p.product_id;
