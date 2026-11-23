-- 1. Executive Headline KPIs (Overall Business Performance)
SELECT
    COUNT(*) AS total_line_items,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100.0, 2) AS overall_profit_margin_pct,
    ROUND(AVG(shipping_days), 1) AS avg_shipping_days
FROM vw_clean_sales;

-- 2. Yearly Revenue, Profit & YoY Growth
WITH yearly_stats AS (
    SELECT
        order_year,
        COUNT(DISTINCT order_id) AS orders,
        ROUND(SUM(sales), 2) AS sales,
        ROUND(SUM(profit), 2) AS profit,
        ROUND((SUM(profit) / SUM(sales)) * 100.0, 2) AS margin_pct
    FROM vw_clean_sales
    GROUP BY order_year
)
SELECT
    order_year,
    orders,
    sales,
    profit,
    margin_pct,
    ROUND(
        ((sales - LAG(sales) OVER (ORDER BY order_year)) / LAG(sales) OVER (ORDER BY order_year)) * 100.0,
        2
    ) AS yoy_sales_growth_pct
FROM yearly_stats
ORDER BY order_year;

-- 3. Regional Performance
SELECT
    region,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100.0, 2) AS profit_margin_pct
FROM vw_clean_sales
GROUP BY region
ORDER BY total_sales DESC;

-- 4. Category & Sub-Category Profitability (Spotting Margin Leaks)
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100.0, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100.0, 1) AS avg_discount_pct
FROM vw_clean_sales
GROUP BY category, sub_category
ORDER BY total_profit ASC;

-- 5. Top 5 Most Profitable Products vs. Bottom 5 Loss-Making Products
SELECT * FROM (
    SELECT 'Top 5 Profitable' AS rank_group, product_name, category, ROUND(SUM(sales), 2) AS sales, ROUND(SUM(profit), 2) AS profit
    FROM vw_clean_sales
    GROUP BY product_name, category
    ORDER BY profit DESC
    LIMIT 5
)
UNION ALL
SELECT * FROM (
    SELECT 'Bottom 5 Loss-Making' AS rank_group, product_name, category, ROUND(SUM(sales), 2) AS sales, ROUND(SUM(profit), 2) AS profit
    FROM vw_clean_sales
    GROUP BY product_name, category
    ORDER BY profit ASC
    LIMIT 5
);