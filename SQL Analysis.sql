-- How many films in each category
SELECT cat.name , COUNT(fc.film_id) AS film_counts
FROM category cat
INNER JOIN film_category fc ON cat.category_id = fc.category_id
GROUP BY cat.name 
ORDER BY COUNT(fc.film_id) DESC;

-- Top 5 actors according to the number of films
SELECT ac.first_name , ac.last_name , COUNT(fa.film_id) AS film_counts
from film_actor fa
INNER JOIN actor ac ON fa.actor_id = ac.actor_id
GROUP BY  ac.actor_id
ORDER BY film_counts DESC
LIMIT 5;

-- What is the revenue per each store
SELECT store_id ,  SUM(amount) as Total_revenue
FROM store s 
INNER JOIN  payment p ON s.manager_staff_id = p.staff_id
GROUP BY store_id 
ORDER BY Total_revenue DESC;

-- Top 5 films have revenue
SELECT title , SUM(pay.amount) as Total_revenue
FROM payment pay
INNER JOIN rental ren ON ren.rental_id = pay.rental_id
INNER JOIN inventory inv ON inv.inventory_id = ren.inventory_id
INNER JOIN film f ON f.film_id = inv.film_id
GROUP  BY  title 
ORDER BY Total_revenue DESC
LIMIT 5;

-- Average rental per movie
SELECT title , AVG(pay.amount) as avg_revenue
FROM payment pay
INNER JOIN rental ren ON ren.rental_id = pay.rental_id
INNER JOIN inventory inv ON inv.inventory_id = ren.inventory_id
INNER JOIN film f ON f.film_id = inv.film_id
GROUP  BY  title 
ORDER BY avg_revenue DESC;

-- How many rentals per customer
SELECT cust.first_name , cust.last_name ,COUNT(rental_id) AS total_rentals
FROM customer cust
INNER JOIN rental ren ON ren.customer_id = cust.customer_id
GROUP BY cust.customer_id
ORDER BY total_rentals DESC;

-- What is the most profitable rating
SELECT f.rating, SUM(p.amount) AS total_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.rating
ORDER BY total_revenue DESC;

-- Customers who spent more than 100$
SELECT cust.first_name , cust.last_name , SUM(pay.amount) AS total_revenue
FROM customer cust
INNER JOIN payment pay ON cust.customer_id = pay.customer_id
GROUP BY cust.customer_id
HAVING total_revenue > 100
ORDER BY total_revenue DESC;

-- What is the average rental period for each rating?
SELECT rating , AVG(rental_duration) 
FROM film 
GROUP BY rating
ORDER BY AVG(rental_duration) DESC;

-- Percentage of active customers
SELECT 
    CASE WHEN active = 1 THEN 'Active' ELSE 'Non Active' END AS status,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customer
GROUP BY active;

-- Sort customers by total spending
SELECT cust.first_name , cust.last_name ,
 SUM(pay.amount) AS total_revenue,
 RANK() OVER(ORDER BY SUM(pay.amount) DESC) AS spending_rank
FROM customer cust
INNER JOIN payment pay ON cust.customer_id = pay.customer_id
GROUP BY cust.customer_id;

-- Highest-grossing film in each category
WITH category_revenue AS ( 
	SELECT cat.name , f.title , SUM(p.amount) AS total_revenue,
	RANK() OVER(PARTITION BY cat.name ORDER BY SUM(p.amount) DESC) AS rnk
	FROM payment p 
	INNER JOIN rental ren ON ren.rental_id = p.rental_id
	INNER JOIN inventory inv ON inv.inventory_id = ren.inventory_id
	INNER JOIN film f ON f.film_id = inv.film_id
	INNER JOIN film_category fc ON fc.film_id = f.film_id
	INNER JOIN category cat ON cat.category_id = fc.category_id
	GROUP BY cat.name , f.title)

SELECT name , title , total_revenue FROM category_revenue
WHERE rnk = 1;

-- Monthly revenue for the last year
WITH max_date AS(
	SELECT MAX(payment_date) AS max_date FROM payment ) -- to get the last year in the data
    
SELECT DATE_FORMAT(payment_date,"%Y-%M") AS month,
SUM(amount) AS monthly_revenue 
FROM payment
INNER JOIN  max_date mad ON payment_date>=DATE_SUB( mad.max_date, INTERVAL 12 MONTH)
GROUP BY month;

-- Top 3 clients per country
WITH ranked_customers  AS ( 
	SELECT country , cust.first_name , cust.last_name ,
	SUM(p.amount) AS total_spent,
	RANK() OVER(PARTITION BY country ORDER BY SUM(p.amount) DESC) AS rnk
	FROM payment p
	INNER JOIN customer cust ON cust.customer_id = p.customer_id
	INNER JOIN address addr ON addr.address_id = cust.address_id
	INNER JOIN city c ON c.city_id = addr.city_id
	INNER JOIN country coun ON coun.country_id = c.country_id
	GROUP BY country , cust.customer_id)
    
SELECT * FROM ranked_customers
WHERE rnk <= 3; 

-- Most 5 profitable actors
SELECT a.first_name, a.last_name, SUM(p.amount) AS revenue
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY a.actor_id
ORDER BY revenue DESC
LIMIT 5;

-- Average rental term by country
SELECT co.country, AVG(DATEDIFF(r.return_date, r.rental_date)) AS avg_rental_days
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY avg_rental_days DESC;

-- Customers who rented more than average

WITH rental_counts AS (
	SELECT customer_id , COUNT(*) AS rental_count
	FROM rental
	GROUP BY customer_id ) , 
avg_rental AS (
	SELECT AVG(rental_count) AS avg_count  FROM rental_counts) 

SELECT customer_id ,rental_count  FROM rental_counts , avg_rental
WHERE rental_count > avg_count;
