CREATE DATABASE IF NOT EXISTS ecommerce_analysis;
USE ecommerce_analysis;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    order_id            VARCHAR(10)     PRIMARY KEY,
    customer_id         VARCHAR(10)     NOT NULL,
    product_id          VARCHAR(10)     NOT NULL,
    category            VARCHAR(20)     NOT NULL,
    price               DECIMAL(10,2)   NOT NULL,
    discount            DECIMAL(4,2)    NOT NULL,
    quantity            INT             NOT NULL,
    payment_method      VARCHAR(20)     NOT NULL,
    order_date          DATE            NOT NULL,
    delivery_time_days  INT             NOT NULL,
    region              VARCHAR(20)     NOT NULL,
    returned            ENUM('Yes','No') NOT NULL,
    total_amount        DECIMAL(10,2)   NOT NULL,
    shipping_cost       DECIMAL(10,2)   NOT NULL,
    profit_margin       DECIMAL(10,2)   NOT NULL,
    customer_age        INT             NOT NULL,
    customer_gender     ENUM('Female','Male','Other') NOT NULL,
    INDEX idx_category (category),
    INDEX idx_region (region),
    INDEX idx_order_date (order_date),
    INDEX idx_customer (customer_id)
);

LOAD DATA LOCAL INFILE 'ecommerce_sales_for_mysql.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, product_id, category, price, discount, quantity,
 payment_method, @order_date, delivery_time_days, region, returned,
 total_amount, shipping_cost, profit_margin, customer_age, customer_gender)
SET order_date = STR_TO_DATE(@order_date, '%Y-%m-%d');


DROP TABLE IF EXISTS region_managers;
CREATE TABLE region_managers (
    region        VARCHAR(20) PRIMARY KEY,
    manager_name  VARCHAR(50) NOT NULL,
    manager_email VARCHAR(50) NOT NULL
);
INSERT INTO region_managers VALUES
('Central','Priya Nair','priya.nair@corp.com'),
('East','Daniel Osei','daniel.osei@corp.com'),
('North','Wei Zhang','wei.zhang@corp.com'),
('South','Ana Torres','ana.torres@corp.com'),
('West','Liam Carter','liam.carter@corp.com');

DROP TABLE IF EXISTS category_targets;
CREATE TABLE category_targets (
    category           VARCHAR(20) PRIMARY KEY,
    target_margin_pct  DECIMAL(4,2) NOT NULL
);
INSERT INTO category_targets VALUES
('Beauty',0.30),('Electronics',0.15),('Fashion',0.25),
('Grocery',0.10),('Home',0.25),('Sports',0.25),('Toys',0.25);


-- =====================================================================
-- 1. BASIC QUERIES
-- =====================================================================

-- 1.1 Preview the table
SELECT * FROM sales LIMIT 10;

-- 1.2 Column subset
SELECT order_id, category, total_amount, order_date FROM sales LIMIT 10;

-- 1.3 Distinct values in a column
SELECT DISTINCT category FROM sales;
-- Result: 7 rows — Beauty, Electronics, Fashion, Grocery, Home, Sports, Toys

-- 1.4 Row count
SELECT COUNT(*) AS total_orders FROM sales;
-- Result: 34,500


-- =====================================================================
-- 2. FILTERING & SORTING
-- =====================================================================

-- 2.1 Simple WHERE
SELECT order_id, category, total_amount
FROM sales
WHERE category = 'Electronics'
ORDER BY total_amount DESC
LIMIT 10;

-- 2.2 Multiple conditions (AND / OR)
SELECT order_id, category, region, total_amount, returned
FROM sales
WHERE category IN ('Electronics','Fashion')
  AND region = 'North'
  AND returned = 'Yes'
ORDER BY total_amount DESC;

-- 2.3 Range filter + pattern match
SELECT order_id, customer_id, total_amount, order_date
FROM sales
WHERE total_amount BETWEEN 500 AND 2000
  AND order_id LIKE 'O101%'
ORDER BY order_date;

-- 2.4 Sort by multiple keys
SELECT category, region, total_amount
FROM sales
ORDER BY category ASC, total_amount DESC
LIMIT 15;


-- =====================================================================
-- 3. AGGREGATIONS
-- =====================================================================

-- 3.1 Core aggregate functions
SELECT
    COUNT(*)                    AS total_orders,
    SUM(total_amount)           AS total_revenue,
    ROUND(AVG(total_amount),2)  AS avg_order_value,
    MIN(total_amount)           AS smallest_order,
    MAX(total_amount)           AS largest_order,
    SUM(quantity)               AS total_units
FROM sales;
-- Result: 34,500 orders | revenue 5,865,293.05 | AOV 170.01 | min 0.82 | max 12,931.80 | units 51,430

-- 3.2 Aggregate with a filter
SELECT ROUND(AVG(profit_margin),2) AS avg_profit_electronics
FROM sales
WHERE category = 'Electronics';

-- 3.3 Count distinct
SELECT COUNT(DISTINCT customer_id) AS distinct_customer_ids,
       COUNT(DISTINCT product_id)  AS distinct_product_ids
FROM sales;
-- Result: 7,903 customer_ids, 24,912 product_ids
-- (row-level labels, not stable entity keys — see Phase 1 Known_Issues)


-- =====================================================================
-- 4. GROUP BY / HAVING
-- =====================================================================

-- 4.1 Revenue and margin by category
SELECT
    category,
    COUNT(*)                          AS orders,
    ROUND(SUM(total_amount),2)        AS revenue,
    ROUND(SUM(profit_margin),2)       AS profit,
    ROUND(SUM(profit_margin)/SUM(total_amount)*100,2) AS margin_pct
FROM sales
GROUP BY category
ORDER BY revenue DESC;
-- Result: Electronics leads at 3,319,206.50 revenue (10.4% margin);
--         Grocery is the only category with negative margin (-11.2%)

-- 4.2 GROUP BY with HAVING — categories that are losing money on average
SELECT category, ROUND(AVG(profit_margin),2) AS avg_profit_per_order
FROM sales
GROUP BY category
HAVING AVG(profit_margin) < 0;
-- Result: Grocery only, avg_profit_per_order = -2.26

-- 4.3 GROUP BY two dimensions
SELECT region, payment_method, COUNT(*) AS orders, ROUND(SUM(total_amount),2) AS revenue
FROM sales
GROUP BY region, payment_method
HAVING COUNT(*) > 500
ORDER BY region, revenue DESC;


-- =====================================================================
-- 5. CASE WHEN
-- =====================================================================

-- 5.1 Order value tiering
SELECT
    order_id, total_amount,
    CASE
        WHEN total_amount >= 500 THEN 'High'
        WHEN total_amount >= 100 THEN 'Medium'
        ELSE 'Low'
    END AS value_tier
FROM sales
LIMIT 10;

-- 5.2 Aggregate by a CASE-derived bucket (age bands, replicating Phase 1/2 logic in SQL)
SELECT
    CASE
        WHEN customer_age < 25 THEN '18-24'
        WHEN customer_age < 35 THEN '25-34'
        WHEN customer_age < 45 THEN '35-44'
        WHEN customer_age < 55 THEN '45-54'
        WHEN customer_age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS orders,
    ROUND(AVG(total_amount),2) AS avg_order_value
FROM sales
GROUP BY age_group
ORDER BY age_group;
-- Result matches Phase 2 Customer_Analysis: 18-24 AOV 179.19, 65+ AOV 174.94 (highest two bands)

-- 5.3 Conditional aggregation (pivot-style counts in one pass)
SELECT
    category,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
    SUM(CASE WHEN returned = 'No'  THEN 1 ELSE 0 END) AS kept_orders,
    ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS return_rate_pct
FROM sales
GROUP BY category
ORDER BY return_rate_pct DESC;
-- Result: Fashion highest at 8.28%, Grocery lowest at 1.31%


-- =====================================================================
-- 6. JOINS
-- =====================================================================

-- 6.1 INNER JOIN — revenue by region with the manager responsible
SELECT s.region, rm.manager_name, rm.manager_email, ROUND(SUM(s.total_amount),2) AS revenue
FROM sales s
JOIN region_managers rm ON s.region = rm.region
GROUP BY s.region, rm.manager_name, rm.manager_email
ORDER BY revenue DESC;
-- Result: South/Ana Torres tops at 1,298,096.07; Central/Priya Nair lowest at 940,503.38

-- 6.2 LEFT JOIN — every category against its margin target, flagging misses
SELECT
    ct.category,
    ct.target_margin_pct,
    ROUND(SUM(s.profit_margin)/SUM(s.total_amount), 4) AS actual_margin_pct,
    CASE WHEN SUM(s.profit_margin)/SUM(s.total_amount) < ct.target_margin_pct
         THEN 'Below Target' ELSE 'On Target' END AS status
FROM category_targets ct
LEFT JOIN sales s ON s.category = ct.category
GROUP BY ct.category, ct.target_margin_pct
ORDER BY actual_margin_pct;
-- Result: every one of the 7 categories is below its target margin;
--         Grocery misses worst (target 10%, actual -11.2%)

-- 6.3 Self-join — pair each order with the next order in the same
-- category, ordered by date (illustrates self-join mechanics via a
-- ranked CTE; ranking runs per category so the join stays 1:1)
WITH ranked AS (
    SELECT order_id, category, order_date, total_amount,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY order_date, order_id) AS rn
    FROM sales
)
SELECT a.category, a.order_id AS order_a, a.total_amount AS amount_a,
       b.order_id AS order_b, b.total_amount AS amount_b
FROM ranked a
JOIN ranked b ON a.category = b.category AND b.rn = a.rn + 1
LIMIT 10;


-- =====================================================================
-- 7. SUBQUERIES
-- =====================================================================

-- 7.1 Scalar subquery in WHERE
SELECT order_id, category, total_amount
FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales)
ORDER BY total_amount DESC
LIMIT 10;

-- 7.2 Correlated subquery — orders priced above their own category's average
SELECT s.order_id, s.category, s.total_amount
FROM sales s
WHERE s.total_amount > (
    SELECT AVG(s2.total_amount) FROM sales s2 WHERE s2.category = s.category
)
ORDER BY s.category, s.total_amount DESC
LIMIT 10;

-- 7.3 IN subquery — orders from regions whose average order value beats 170
SELECT category, region, total_amount
FROM sales
WHERE region IN (
    SELECT region FROM sales GROUP BY region HAVING AVG(total_amount) > 170
)
LIMIT 10;
-- Qualifying regions: East (170.36), South (171.19), West (174.31)

-- 7.4 EXISTS — categories that have at least one high-value return
SELECT DISTINCT category
FROM sales s
WHERE EXISTS (
    SELECT 1 FROM sales s2
    WHERE s2.category = s.category AND s2.returned = 'Yes' AND s2.total_amount > 1000
);
-- Result: Home, Electronics


-- =====================================================================
-- 8. CTEs (WITH)
-- =====================================================================

-- 8.1 Single CTE — monthly revenue, referenced twice
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month, SUM(total_amount) AS revenue
    FROM sales
    GROUP BY year_month
)
SELECT * FROM monthly ORDER BY year_month;
-- Result: 25 months, Sep 2023 (151,135.60) through Sep 2025 (91,848.17, partial month)

-- 8.2 Chained CTEs — best category per region
WITH region_category AS (
    SELECT region, category, SUM(total_amount) AS revenue
    FROM sales
    GROUP BY region, category
),
ranked AS (
    SELECT region, category, revenue,
           RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rnk
    FROM region_category
)
SELECT region, category, revenue
FROM ranked
WHERE rnk = 1
ORDER BY revenue DESC;
-- Result: Electronics is the top category in every one of the 5 regions

-- 8.3 CTE for a reusable KPI base, joined back to itself
WITH cat_kpi AS (
    SELECT category, SUM(total_amount) AS revenue, SUM(profit_margin) AS profit
    FROM sales GROUP BY category
)
SELECT category, revenue, profit, ROUND(profit/revenue*100,2) AS margin_pct
FROM cat_kpi
WHERE revenue > (SELECT AVG(revenue) FROM cat_kpi)
ORDER BY revenue DESC;


-- =====================================================================
-- 9. WINDOW FUNCTIONS
-- =====================================================================

-- 9.1 RANK / DENSE_RANK / ROW_NUMBER — top 3 orders per category by value
SELECT * FROM (
    SELECT category, order_id, total_amount,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_amount DESC) AS rn,
           RANK()       OVER (PARTITION BY category ORDER BY total_amount DESC) AS rnk
    FROM sales
) t
WHERE rn <= 3
ORDER BY category, rn;

-- 9.2 Running total and 3-month moving average of revenue
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month, SUM(total_amount) AS revenue
    FROM sales GROUP BY year_month
)
SELECT
    year_month, revenue,
    SUM(revenue) OVER (ORDER BY year_month) AS running_total,
    ROUND(AVG(revenue) OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3mo
FROM monthly
ORDER BY year_month;

-- 9.3 Month-over-month % change with LAG
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month, SUM(total_amount) AS revenue
    FROM sales GROUP BY year_month
)
SELECT
    year_month, revenue,
    LAG(revenue) OVER (ORDER BY year_month) AS prev_month_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month))
          / LAG(revenue) OVER (ORDER BY year_month), 2) AS pct_change
FROM monthly
ORDER BY year_month;
-- Result: Oct 2023 +73.69% vs Sep (partial launch month); largest swings are at the edges of the window

-- 9.4 Each order's share of its category's total revenue
SELECT category, order_id, total_amount,
       ROUND(100.0 * total_amount / SUM(total_amount) OVER (PARTITION BY category), 4) AS pct_of_category_revenue
FROM sales
ORDER BY category, pct_of_category_revenue DESC
LIMIT 10;

-- 9.5 NTILE — split orders into 4 value quartiles (labeling, not filtering)
SELECT order_id, total_amount,
       NTILE(4) OVER (ORDER BY total_amount DESC) AS value_quartile
FROM sales
LIMIT 10;


-- =====================================================================
-- 10. DATE ANALYSIS
-- =====================================================================

-- 10.1 Extract date parts
SELECT order_id, order_date,
       YEAR(order_date) AS yr, MONTH(order_date) AS mo,
       QUARTER(order_date) AS qtr, DAYNAME(order_date) AS weekday
FROM sales
LIMIT 10;

-- 10.2 Revenue by quarter
SELECT YEAR(order_date) AS yr, QUARTER(order_date) AS qtr,
       COUNT(*) AS orders, ROUND(SUM(total_amount),2) AS revenue
FROM sales
GROUP BY yr, qtr
ORDER BY yr, qtr;

-- 10.3 Revenue by day of week
SELECT DAYNAME(order_date) AS weekday, COUNT(*) AS orders, ROUND(SUM(total_amount),2) AS revenue
FROM sales
GROUP BY weekday, DAYOFWEEK(order_date)
ORDER BY DAYOFWEEK(order_date);
-- Result: flat across the week, 824,795-866,319 revenue per day — no weekday/weekend pattern

-- 10.4 Average delivery time by category, using TIMESTAMPDIFF logic
-- (delivery_time_days is already stored; TIMESTAMPDIFF shown for a
--  scenario where you only had an order_date and a delivery_date)
SELECT category, ROUND(AVG(delivery_time_days),2) AS avg_delivery_days
FROM sales
GROUP BY category
ORDER BY avg_delivery_days DESC;

-- 10.5 Year-to-date-style filter: orders in the most recent 90 days of data
SELECT category, COUNT(*) AS orders, ROUND(SUM(total_amount),2) AS revenue
FROM sales
WHERE order_date >= (SELECT DATE_SUB(MAX(order_date), INTERVAL 90 DAY) FROM sales)
GROUP BY category
ORDER BY revenue DESC;




-- Q10. If we could only fix one thing this quarter, what does the data say?
SELECT 'See Business_Insights sheet (Phase 2) for the full narrative — '
       'in SQL terms: Q2 (Grocery margin) has the largest quantified downside.' AS answer;
