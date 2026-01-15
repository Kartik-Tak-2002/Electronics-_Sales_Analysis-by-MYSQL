# create database

CREATE DATABASE sales_analysis;
USE sales_analysis;
---------------------------------------------------------------------------------------------------------------------------------
# check data load table.

select * from dim_customer;
select * from dim_market;
select * from dim_product; 
select * from fact_sales_monthly1;
---------------------------------------------------------------------------------------------------------------------------------
# Count table columns 
SELECT COUNT(*) FROM fact_sales_monthly1;
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_market;

# Simple trial check table data

SELECT * FROM fact_sales_monthly1 LIMIT 5;
----------------------------------------------------------------------------------------------------------------------------------

# Identify duplicate records

SELECT date, product_code, customer_code, COUNT(*)
FROM fact_sales_monthly1
GROUP BY date, product_code, customer_code
HAVING COUNT(*) > 1;
----------------------------------------------------------------------------------------------------------------------------------
# Find missing values

SELECT
SUM(date IS NULL) AS missing_date,
SUM(product_code IS NULL) AS missing_product,
SUM(customer_code IS NULL) AS missing_customer,
SUM(Qty IS NULL) AS missing_qty,
SUM(net_sales_amount IS NULL) AS missing_sales
FROM fact_sales_monthly1;
----------------------------------------------------------------------------------------------------------------------------------
# Identify negative quantities.

SELECT sum(Qty)
FROM fact_sales_monthly1
WHERE Qty < 0;
----------------------------------------------------------------------------------------------------------------------------------
# Filter only valid quantities.

SELECT sum(Qty)
FROM fact_sales_monthly1
WHERE Qty > 0;

----------------------------------------------------------------------------------------------------------------------------------
-- 1. Total Sales

SELECT SUM(net_sales_amount) AS Total_Sales
FROM fact_sales_monthly1;

-- ====================================================================
-- 2.  Sales by Year
SELECT YEAR(date) AS year,
SUM(net_sales_amount) AS sales
FROM fact_sales_monthly1
WHERE Qty > 0
GROUP BY YEAR(date)
ORDER BY year;
-- ====================================================================
-- 3. Sales by Market
SELECT dc.market,
AVG(f.net_sales_amount) AS sales
FROM fact_sales_monthly1 f
JOIN dim_customer dc
ON f.customer_code = dc.customer_code
WHERE f.Qty > 0
GROUP BY dc.market
ORDER BY sales DESC;
-- ===================================================================
-- 4. Sales by Region 
SELECT dm.region,
SUM(f.net_sales_amount) AS sales
FROM fact_sales_monthly1 f
JOIN dim_customer dc ON f.customer_code = dc.customer_code
JOIN dim_market dm ON dc.market = dm.market
WHERE f.Qty > 0
GROUP BY dm.region;
-- ====================================================================
-- 5. Top 5 customer

SELECT dc.customer,
SUM(f.net_sales_amount) AS revenue
FROM fact_sales_monthly1 f
JOIN dim_customer dc
ON f.customer_code = dc.customer_code
WHERE f.Qty > 0
GROUP BY dc.customer
ORDER BY revenue DESC
LIMIT 5;
-- ====================================================================
-- 6. Product performance
SELECT dp.product,
SUM(f.net_sales_amount) AS revenue
FROM fact_sales_monthly1 f
JOIN dim_product dp
ON f.product_code = dp.product_code
WHERE f.Qty > 0
GROUP BY dp.product
ORDER BY revenue DESC;
-- ====================================================================
-- 7. Customer Segments
SELECT dc.customer,
SUM(f.net_sales_amount) AS total_sales,
CASE
    WHEN SUM(f.net_sales_amount) > 100000 THEN 'High Value'
    WHEN SUM(f.net_sales_amount) BETWEEN 50000 AND 100000 THEN 'Medium Value'
    ELSE 'Low Value'
END AS customer_type
FROM fact_sales_monthly1 f
JOIN dim_customer dc
ON f.customer_code = dc.customer_code
WHERE f.Qty > 0
GROUP BY dc.customer;
-- ==================================================================== 

