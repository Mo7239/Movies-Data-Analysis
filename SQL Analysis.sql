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
