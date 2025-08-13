/* 
   =============================
          data exploration
   =============================
 Its purpose is to understand
 the data initially so that we 
 can gain a general view of it
 and the direction in which the 
 data is heading, thus facilitating
 the analysis process later. */

 /*
	================================
	     Basic Questions (EDA)
    ================================
*/ 
    
-- get overview about film table
SELECT * FROM film;

-- How many films in film table
SELECT count(DISTINCT film_id) AS total_films FROM film ;

-- How many customers in our data
SELECT count(DISTINCT customer_id) AS total_customers
 FROM customer ;
 
 -- How many actors in our data
 SELECT count(DISTINCT actor_id) AS total_actors
 FROM actor ;
 
-- What is the top 5 languages 
SELECT l.name  , COUNT(f.film_id) as total_films
FROM film f
INNER JOIN language l ON l.language_id = f.language_id
GROUP BY l.name
ORDER BY  COUNT(f.film_id) DESC ;-- all films have english language!!

-- How many active vs non-active customers
SELECT 	
	CASE
		WHEN active = 1 THEN "active"
        ELSE "non-active"
    END customer_status, 
count(customer_id) AS customer_count
FROM  customer
GROUP BY customer_status;
 
-- What is the longest and the shortest two films
SELECT max(length) AS longest_film ,
 min(length) AS shortest_film
 FROM film;
 
 -- What is the average duration of the show
 SELECT AVG(length) AS avg_show FROM film;
 
 -- What is the effect of each film rating
 SELECT rating , count(film_id) as films_count
 FROM film
 GROUP BY rating
 ORDER BY count(film_id) DESC;
 
 -- TOP 5 Cities
 SELECT ci.city , COUNT(cust.customer_id) AS customer_count
 FROM  customer cust
 INNER JOIN address addr ON cust.address_id = addr.address_id
 INNER JOIN city ci ON addr.city_id = ci.city_id
 GROUP BY ci.city 
 ORDER BY COUNT(cust.customer_id) DESC
 LIMIT 5;

-- Top 5 countries
 SELECT coun.country , COUNT(cust.customer_id) AS customer_count
 FROM  customer cust
 INNER JOIN address addr ON cust.address_id = addr.address_id
 INNER JOIN city ci ON addr.city_id = ci.city_id
 INNER JOIN country coun ON coun.country_id = ci.country_id
 GROUP BY coun.country
 ORDER BY COUNT(cust.customer_id) DESC
 LIMIT 5;
 
 
