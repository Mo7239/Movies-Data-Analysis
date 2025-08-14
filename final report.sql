WITH rental_summary AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        ci.city,
        co.country,
        COUNT(r.rental_id) AS total_rentals,
        SUM(p.amount) AS total_revenue,
        AVG(DATEDIFF(r.return_date, r.rental_date)) AS avg_rental_days,
        COUNT(DISTINCT f.film_id) AS unique_films,
        MAX(r.rental_date) AS last_rental_date
    FROM customer c
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    GROUP BY c.customer_id, c.first_name, c.last_name, ci.city, co.country
),
category_pref AS (
    SELECT 
        c.customer_id,
        cat.name AS top_category
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    GROUP BY c.customer_id, cat.name
    HAVING COUNT(*) = (
        SELECT MAX(cat_count) 
        FROM (
            SELECT COUNT(*) AS cat_count
            FROM rental r2
            JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
            JOIN film f2 ON i2.film_id = f2.film_id
            JOIN film_category fc2 ON f2.film_id = fc2.film_id
            WHERE r2.customer_id = c.customer_id
            GROUP BY fc2.category_id
        ) AS sub
    )
)
SELECT 
    rs.customer_id,
    rs.first_name,
    rs.last_name,
    rs.city,
    rs.country,
    rs.total_rentals,
    rs.total_revenue,
    rs.avg_rental_days,
    rs.unique_films,
    rs.last_rental_date,
    cp.top_category
FROM rental_summary rs
LEFT JOIN category_pref cp ON rs.customer_id = cp.customer_id
ORDER BY rs.total_revenue DESC;
