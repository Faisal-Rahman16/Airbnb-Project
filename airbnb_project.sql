--Top 20 Airbnb Listing Earners in Austin 2024

With cte as (
	SELECT id, name, listing_url, 30 - availability_30 as booked_ot_30,
		   TRY_CAST(REPLACE(price, '$', '') AS DECIMAL(10, 2)) AS price_decimal,
		   TRY_CAST(TRY_CAST(REPLACE(price, '$', '') AS DECIMAL(10, 2)) AS INT) AS price_clean
	FROM df_listings)

	Select Top 20
	id, name,listing_url, booked_ot_30 * price_clean as project_revenue

	from cte 
	where booked_ot_30 * price_clean is not NULL 
	order by booked_ot_30 * price_clean desc
	;

 -- The list host who needs to maintain cleaniness in their Airbnb 
 
 SELECT 
    HOST_ID, 
    HOST_NAME, 
    host_url, 
    COUNT(*) AS num_dirty_reviews
FROM 
    df_listings 
INNER JOIN 
    df_reviews
ON 
    df_listings.id = df_reviews.listing_id 
WHERE 
    comments LIKE '%dirty%' 
GROUP BY 
    HOST_ID, HOST_NAME, host_url
	
order by  num_dirty_reviews desc	;

--Highly Rated Hosts with Active Listings

SELECT host_id, host_name, host_url, AVG(review_scores_rating) AS avg_rating, COUNT(id) AS total_listings
FROM df_listings
WHERE has_availability = 't' AND review_scores_rating IS NOT NULL
GROUP BY host_id, host_name, host_url
HAVING AVG(review_scores_rating) > 4.5
ORDER BY avg_rating DESC;


--Availability vs. Occupancy Rates

WITH availability_analysis AS (
    SELECT 
        id,
        number_of_reviews,
        CASE 
            WHEN availability_30 >= 25 AND availability_60 >= 50 AND availability_90 >= 75 THEN 'Very High Availability'
            WHEN availability_30 >= 15 AND availability_60 >= 30 AND availability_90 >= 45 THEN 'High Availability'
            WHEN availability_30 >= 5 AND availability_60 >= 10 AND availability_90 >= 15 THEN 'Medium Availability'
            ELSE 'Low Availability'
        END AS availability_status
    FROM df_listings
)

SELECT 
    availability_status,
    AVG(number_of_reviews) AS avg_reviews
FROM 
    availability_analysis
GROUP BY 
    availability_status;

--Analysis of Room Types & avg_minimum_nights by Revenue

WITH revenue AS (
    SELECT id, room_type, price, minimum_nights, 
           TRY_CAST(REPLACE(price, '$', '') AS DECIMAL(10, 2)) * minimum_nights AS estimated_revenue
    FROM df_listings
					)
SELECT room_type,AVG(minimum_nights) as avg_minimum_nights, AVG(estimated_revenue) AS avg_revenue
FROM revenue
GROUP BY room_type
ORDER BY avg_revenue DESC;



