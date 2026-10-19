USE coffee_house;

-- Optional data checks
SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Q1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT
    city_name,
    ROUND(population * 0.25 / 1000000, 2) AS coffee_consumers_in_millions,
    city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC;

-- Q2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT
    SUM(total) AS total_revenue
FROM sales
WHERE YEAR(sale_date) = 2023
  AND QUARTER(sale_date) = 4;

SELECT
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
    ON s.customer_id = c.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
WHERE YEAR(s.sale_date) = 2023
  AND QUARTER(s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q3. Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT
    p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;

-- Q4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
FROM sales AS s
JOIN customers AS c
    ON s.customer_id = c.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
WITH city_table AS
(
    SELECT
        city_id,
        city_name,
        population,
        ROUND(population * 0.25 / 1000000, 2) AS coffee_consumers
    FROM city
),
customers_table AS
(
    SELECT
        ci.city_id,
        COUNT(DISTINCT c.customer_id) AS unique_cx
    FROM sales AS s
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_id
)
SELECT
    ct.city_name,
    ct.population,
    ct.coffee_consumers AS coffee_consumer_in_millions,
    COALESCE(cust.unique_cx, 0) AS unique_cx
FROM city_table AS ct
LEFT JOIN customers_table AS cust
    ON ct.city_id = cust.city_id
ORDER BY ct.city_name;

-- Q6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
SELECT
    city_name,
    product_name,
    total_orders
FROM
(
    SELECT
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders,
        DENSE_RANK() OVER
        (
            PARTITION BY ci.city_id
            ORDER BY COUNT(s.sale_id) DESC
        ) AS product_rank
    FROM sales AS s
    JOIN products AS p
        ON s.product_id = p.product_id
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_id, ci.city_name, p.product_id, p.product_name
) AS ranked_products
WHERE product_rank <= 3
ORDER BY city_name, total_orders DESC, product_name;

-- Q7. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cx
FROM city AS ci
JOIN customers AS c
    ON c.city_id = ci.city_id
JOIN sales AS s
    ON s.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = s.product_id
GROUP BY ci.city_id, ci.city_name
ORDER BY unique_cx DESC;

-- Q8. Average Sale vs Rent
-- Find each city and their average sale per customer and average rent per customer.
WITH city_table AS
(
    SELECT
        ci.city_id,
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c
        ON s.customer_id = c.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_id, ci.city_name
)
SELECT
    c.city_name,
    c.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    ROUND(c.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city AS c
JOIN city_table AS ct
    ON c.city_id = ct.city_id
ORDER BY ct.avg_sale_pr_cx DESC;

-- Q9. Monthly Sales Growth
-- Calculate the percentage growth or decline in sales by city and month.
WITH monthly_sales AS
(
    SELECT
        ci.city_id,
        ci.city_name,
        MONTH(s.sale_date) AS month,
        YEAR(s.sale_date) AS sale_year,
        SUM(s.total) AS total_sale
    FROM sales AS s
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_id, ci.city_name, YEAR(s.sale_date), MONTH(s.sale_date)
),
growth_ratio AS
(
    SELECT
        city_name,
        month,
        sale_year,
        total_sale AS current_month_sale,
        LAG(total_sale) OVER
        (
            PARTITION BY city_id
            ORDER BY sale_year, month
        ) AS last_month_sale
    FROM monthly_sales
)
SELECT
    city_name,
    month,
    sale_year,
    current_month_sale,
    last_month_sale,
    ROUND(
        (current_month_sale - last_month_sale) / last_month_sale * 100,
        2
    ) AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL
ORDER BY city_name, sale_year, month;

-- Q10. Market Potential Analysis
-- Identify the top 3 cities based on total sales.
WITH city_table AS
(
    SELECT
        ci.city_id,
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c
        ON s.customer_id = c.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_id, ci.city_name
),
city_rent AS
(
    SELECT
        city_id,
        estimated_rent,
        ROUND(population * 0.25 / 1000000, 3) AS estimated_coffee_consumer_in_millions
    FROM city
)
SELECT
    ct.city_name,
    ct.total_revenue,
    cr.estimated_rent AS total_rent,
    ct.total_cx,
    cr.estimated_coffee_consumer_in_millions,
    ct.avg_sale_pr_cx,
    ROUND(cr.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city_table AS ct
JOIN city_rent AS cr
    ON cr.city_id = ct.city_id
ORDER BY ct.total_revenue DESC
LIMIT 3;
