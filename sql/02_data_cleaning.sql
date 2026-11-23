-- 1. Check total rows and missing (NULL or blank) critical fields
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN sales IS NULL OR sales <= 0 THEN 1 ELSE 0 END) AS non_positive_sales,
    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END) AS non_positive_qty
FROM raw_superstore;

-- 2. Check for exact duplicate line items (same Order ID + Product ID + Sales + Quantity)
SELECT 
    order_id, 
    product_id, 
    sales, 
    quantity, 
    COUNT(*) AS duplicate_count
FROM raw_superstore
GROUP BY order_id, product_id, sales, quantity
HAVING COUNT(*) > 1;

-- 3. Check for impossible shipping dates (ship_date earlier than order_date)
SELECT COUNT(*) AS invalid_ship_dates
FROM raw_superstore
WHERE ship_date < order_date;

-- 4. Create a clean, enriched analytical view for downstream BI & reporting
DROP VIEW IF EXISTS vw_clean_sales;

CREATE VIEW vw_clean_sales AS
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    CAST(julianday(ship_date) - julianday(order_date) AS INTEGER) AS shipping_days,
    SUBSTR(order_date, 1, 4) AS order_year,
    SUBSTR(order_date, 1, 7) AS order_year_month,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    ROUND(sales, 2) AS sales,
    quantity,
    ROUND(discount, 2) AS discount,
    ROUND(profit, 2) AS profit,
    CASE 
        WHEN sales > 0 THEN ROUND((profit / sales) * 100.0, 2)
        ELSE 0 
    END AS profit_margin_pct
FROM raw_superstore;