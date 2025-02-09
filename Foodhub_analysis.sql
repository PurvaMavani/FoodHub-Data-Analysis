create database Foodhub;

use Foodhub;
CREATE TABLE foodhub_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_name VARCHAR(255),
    cuisine_type VARCHAR(100),
    cost_of_the_order DECIMAL(10,2),
    day_of_the_week VARCHAR(20),
    rating VARCHAR(20),
    food_preparation_time INT,
    delivery_time INT
);

SELECT * FROM foodhub_orders LIMIT 50;
SELECT COUNT(*) FROM foodhub_orders;

-- -------------------------------------------A. Customer & Order Analysis--------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 1.Total Orders & Revenue:
-- How many total orders were placed? & What is the total revenue generated?
select count(order_id) as total_orders,sum(cost_of_the_order) as total_revenue_generated
from foodhub_orders;


-- 2. Customer Order Frequency:
-- How many unique customers placed orders? & What is the average order value per customer?
select count(distinct customer_id) as unique_customers, avg(cost_of_the_order) as avg_order_value
from foodhub_orders
order by avg_order_value desc;


-- 3. High-Value Customers: Which customers have spent the most money on food orders?
select distinct customer_id as customer_id, sum(cost_of_the_order) as total_order_value
from foodhub_orders
group by customer_id
order by total_order_value desc
limit 1;


-- 4. How many customers placed only one order vs. returning customers?
SELECT 
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS returning_customers
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM foodhub_orders
    GROUP BY customer_id
) AS customer_counts;


-- 5. Customer Loyalty: Top 10 Customers by Orders
select distinct customer_id, 
           count(order_id) as count_of_orders
from foodhub_orders
group by customer_id
order by count_of_orders desc
limit 10;


-- ------------------------------------------- B. Restaurant & Cuisine Insights--------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------

-- 6. Top 5 Restaurants by Order Volume
select restaurant_name,
       count(order_id) as no_of_orders
from foodhub_orders
group by restaurant_name
order by no_of_orders desc 
limit 5;


-- 7. Most Popular Cuisine Types
select cuisine_type as most_popular_cuisine,
    count(order_id) as count_of_orders
from foodhub_orders
group by most_popular_cuisine
order by count_of_orders desc
limit 1;

-- 8. Which restaurants generate the highest revenue?

SELECT restaurant_name, 
       SUM(cost_of_the_order) AS total_revenue, 
       COUNT(order_id) AS total_orders
FROM foodhub_orders
GROUP BY restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 9. Which cuisine types have the highest average order value?
select cuisine_type, sum(cost_of_the_order) as total_order_value
from foodhub_orders
group by cuisine_type
order by total_order_value desc
limit 1;




-- ------------------------------------------- C. Time-Based Analysis-----------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------

-- 10. Orders Distribution by Day of the Week
select count(order_id) as order_count, day_of_the_week
from foodhub_orders
group by day_of_the_week
order by order_count desc;


-- 11. Average Delivery Time Based on Day
select day_of_the_week, avg(delivery_time) as avg_delivery_time
from foodhub_orders
group by day_of_the_week
order by avg_delivery_time desc;

-- 12. Which days of the week have the highest average order value?- Peak Order Times

SELECT day_of_the_week, 
       COUNT(order_id) AS total_orders,
       AVG(cost_of_the_order) AS avg_order_value
FROM foodhub_orders
GROUP BY day_of_the_week
ORDER BY total_orders DESC;



-- 13. How do food orders fluctuate by month? - Seasonal Demand Trends
-- as there is no date column available however if it was available then we ca do it by:
/*ELECT
    EXTRACT(MONTH FROM order_date) AS order_month,
    AVG(order_count) AS average_orders,
    SUM(order_value) AS total_revenue
FROM
    foodhub_orders
GROUP BY
    order_month
ORDER BY
    order_month;*/

-- 14. What proportion of orders are delivered fast, average, or slow?
select 
    case when delivery_time <=15 then 'Fast Delivery'
     when delivery_time between 16 and 30 then 'Average Delivery'
     else 'slow' 
     end as delivery_speed, 
COUNT(order_id) AS order_count
FROM foodhub_orders
GROUP BY delivery_speed;

-- ------------------------------------------- D.Operational Efficiency-----------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- 15. Is there a correlation between food preparation time and delivery time?- Food Preparation vs. Delivery Time Efficiency
SELECT food_preparation_time, 
       AVG(delivery_time) AS avg_delivery_time,
       COUNT(order_id) AS order_count
FROM foodhub_orders
GROUP BY food_preparation_time
ORDER BY food_preparation_time;

-- 16. Which restaurants take the longest time for delivery?- Slowest Restaurants in Terms of Delivery

SELECT restaurant_name, 
       AVG(delivery_time) AS avg_delivery_time, 
       COUNT(order_id) AS total_orders
FROM foodhub_orders
GROUP BY restaurant_name
HAVING COUNT(order_id) > 10  -- Filter for meaningful data
ORDER BY avg_delivery_time DESC
LIMIT 10;

-- ------------------------------------------- G. Ratings & Customer Satisfaction--------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- 17. Rating Distribution
SELECT rating, COUNT(order_id) AS total_ratings
FROM foodhub_orders
GROUP BY rating
ORDER BY total_ratings DESC;


-- 18.How does delivery speed impact customer ratings?
SELECT 
    CASE 
        WHEN delivery_time <= 15 THEN 'Fast Delivery'
        WHEN delivery_time BETWEEN 16 AND 30 THEN 'Average Delivery'
        ELSE 'Slow Delivery' 
    END AS delivery_speed,
    AVG(NULLIF(rating, 'Not given') + 0) AS avg_rating,  -- Convert ratings to numeric, ignoring 'Not given'
    COUNT(order_id) AS order_count
FROM foodhub_orders
WHERE rating <> 'Not given'  -- Exclude non-numeric ratings
GROUP BY delivery_speed;

-- ------------------------------------------- F. Predictive Insights: Factors Affecting Delivery Time --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------

-- 19. What factors contribute most to slow delivery times?
SELECT cuisine_type, 
       AVG(delivery_time) AS avg_delivery_time,
       AVG(food_preparation_time) AS avg_prep_time,
       COUNT(order_id) AS total_orders
FROM foodhub_orders
GROUP BY cuisine_type
ORDER BY avg_delivery_time DESC;


