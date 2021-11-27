# Lab | SQL Rolling calculations

-- In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals.

### Instructions
USE sakila;
-- 1. Get number of monthly active customers.
SELECT * FROM sakila.customer;
SELECT * FROM sakila.rental;

# Get the information I need and save it into a view:
CREATE OR REPLACE VIEW sakila.customer_activity AS
SELECT customer_id, rental_date AS activity_date,
DATE_FORMAT(rental_date, '%m') AS activity_month,
DATE_FORMAT(rental_date, '%Y') AS activity_year
FROM sakila.rental;

CREATE OR REPLACE VIEW sakila.monthly_activity AS
SELECT activity_year, activity_month, COUNT(DISTINCT customer_id) as users 
FROM sakila.customer_activity
GROUP BY activity_year, activity_month
ORDER BY activity_year ASC, activity_month ASC;

-- 2. Active users in the previous month.
SELECT *, LAG(users) OVER () AS prev_month_users
FROM sakila.monthly_activity;

-- 3. Percentage change in the number of active customers.
WITH cte1 AS (
SELECT *, LAG(users) OVER () AS prev_month_users
FROM sakila.monthly_activity
)
SELECT *, ROUND(((users-prev_month_users)/prev_month_users*100),2) AS percent_change
FROM cte1;

-- 4. Retained customers every month.
CREATE OR REPLACE VIEW sakila.active_customers AS
SELECT DISTINCT customer_id, 
DATE_FORMAT(rental_date, '%m') AS activity_month,
DATE_FORMAT(rental_date, '%Y') AS activity_year
FROM sakila.rental;

-- step 2: self join to find recurrent customers (customers that rented a film this month and also last month)
CREATE OR REPLACE VIEW sakila.recurrent_customers AS
SELECT a1.customer_id, a1.activity_year, a1.activity_month FROM active_customers a1
JOIN active_customers a2
ON a1.activity_year = a2.activity_year
AND a1.activity_month = a2.activity_month+1
AND a1.customer_id = a2.customer_id
ORDER BY a1.customer_id, a1.activity_year, a1.activity_month;

SELECT * FROM recurrent_customers;

-- step 3: grouping by year and month, and counting recurring customers.
SELECT activity_year, activity_month, COUNT(customer_id) AS retained_customers FROM recurrent_customers
GROUP BY activity_year, activity_month;