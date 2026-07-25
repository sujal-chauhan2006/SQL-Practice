USE sql_case_study;

SELECT * FROM ahmendabad_house_price;

# Q1. Find the top 10 most expensive properties.

SELECT *
FROM ahmendabad_house_price
ORDER BY price_in_cr DESC
LIMIT 10;

# Q2. Find the average property price for each BHK type.

SELECT 
	name,
    location,
    bhk_type,
	ROUND(AVG(price_in_cr),2) as avg_price_in_cr
FROM ahmendabad_house_price
GROUP BY bhk_type;

# Q3. Count the number of properties available in each location.

SELECT 
	location,
	COUNT(DISTINCT name) AS no_of_pro
FROM ahmendabad_house_price
GROUP BY location
ORDER BY no_of_pro DESC;

# Q4. Show locations that have more than 20 properties.

SELECT 
	location,
	COUNT(DISTINCT name) AS no_of_pro
FROM ahmendabad_house_price
GROUP BY location
HAVING no_of_pro >= 20
ORDER BY no_of_pro DESC;

# Q5. Find the average rate per square foot for every property type.

SELECT
	property_type,
    ROUND(AVG(rate_per_sqft),2) AS avg_rate_per_sqft
FROM ahmendabad_house_price
GROUP BY property_type
ORDER BY avg_rate_per_sqft DESC;

# Q6. Find all properties whose area is greater than the average area.

SELECT
	name,
    AVG(area_in_sqft) AS avg_area
FROM ahmendabad_house_price
GROUP BY name
HAVING avg_area > (
	SELECT AVG(area_in_sqft) FROM ahmendabad_house_price
)
ORDER BY avg_area DESC;

# Q7. Find duplicate property names.

SELECT
	name,
	COUNT(*) AS total_property
FROM ahmendabad_house_price
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY total_property DESC; 

# Q8. Count how many rows have NULL values in each column.

SELECT
	SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS names_null,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS locations_null,
    SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description_null,
    SUM(CASE WHEN rate_per_sqft IS NULL THEN 1 ELSE 0 END) AS rate_per_sqft_null,
    SUM(CASE WHEN area_in_sqft IS NULL THEN 1 ELSE 0 END) AS area_in_sqft_null,
    SUM(CASE WHEN area_type IS NULL THEN 1 ELSE 0 END) AS area_type_null,
    SUM(CASE WHEN property_title IS NULL THEN 1 ELSE 0 END) AS property_title_null,
    SUM(CASE WHEN property_type IS NULL THEN 1 ELSE 0 END) AS property_type_null,
    SUM(CASE WHEN bhk_type IS NULL THEN 1 ELSE 0 END) AS bhk_type_null,
    SUM(CASE WHEN price_in_cr IS NULL THEN 1 ELSE 0 END) AS price_in_cr_null
FROM ahmendabad_house_price;

# Q9. Find the highest priced property in every location.

SELECT
	name,
    location,
    MAX(price_in_cr) AS highest_priced_property
FROM ahmendabad_house_price 
GROUP BY location
ORDER BY highest_priced_property DESC;

# Q10. Find locations where the average property price is greater than 2 Cr.

SELECT 
	location,
    AVG(price_in_cr) AS avg_price
FROM ahmendabad_house_price 
GROUP BY location
HAVING AVG(price_in_cr) > 2
ORDER BY avg_price DESC;

# Q11. Find the second most expensive property in every location.

WITH CTE AS (
SELECT
	location,
    name,
    price_in_cr,
    DENSE_RANK() OVER(PARTITION BY location ORDER BY price_in_cr DESC) as rnk
FROM ahmendabad_house_price
)
SELECT *
FROM CTE
WHERE rnk = 2;

# Q12. Find the top 3 expensive properties in each location.

WITH CTE AS (
SELECT
	location,
    name,
    price_in_cr,
    DENSE_RANK() OVER(PARTITION BY location ORDER BY price_in_cr DESC) as rnk
FROM ahmendabad_house_price
)
SELECT *
FROM CTE
WHERE rnk <= 3;

# Q13. Rank all properties according to their price.

SELECT 
	name,
    RANK() OVER (ORDER BY price_in_cr DESC) AS Rnk
FROM ahmendabad_house_price;

# Q14. Display the previous property's price.

SELECT 
	name,
	price_in_cr,
    LAG(price_in_cr) OVER(ORDER BY price_in_cr DESC) AS previous_price
FROM ahmendabad_house_price;

# Q15. Display the next property's price.

SELECT 
	name,
	price_in_cr,
    LEAD(price_in_cr) OVER(ORDER BY price_in_cr ) AS next_price
FROM ahmendabad_house_price;

# Q16. Find properties whose price is above the average price of their location.

SELECT
	name,
    location,
    AVG(price_in_cr) OVER(PARTITION BY location ORDER BY price_in_cr DESC) AS avg_price
FROM ahmendabad_house_price;

# Q17. Find the difference between a property's price and its location's average price.

SELECT
	name,
    ROUND(price_in_cr - AVG(price_in_cr) OVER(PARTITION BY location ORDER BY price_in_cr DESC),2) AS difference
FROM ahmendabad_house_price
ORDER BY difference DESC;

# Q18. Categorize properties into Budget, Mid, and Luxury.
-- Budget < 1 Cr
-- Mid = 1–2 Cr
-- Luxury > 2 Cr

SELECT
	name,
    CASE 
		WHEN price_in_cr > 2 THEN 'Luxury'
        WHEN price_in_cr > 1 THEN 'MID'
        ELSE 'Budget'
	END AS category
FROM ahmendabad_house_price;

# Q19. Find the running average of property prices.

SELECT
    name,
    price_in_cr,
    AVG(price_in_cr) OVER(ORDER BY price_in_cr) AS running_avg
FROM ahmendabad_house_price;

# Q20. Find the percentage contribution of each property's price to the total price.

SELECT 
	name,
    ROUND(
		(price_in_cr) * 100/ SUM(price_in_cr) OVER()
        ,2) AS per
FROM ahmendabad_house_price;

# Q21. Find the median property price.

WITH CTE AS (
    SELECT
        price_in_cr,
        ROW_NUMBER() OVER(ORDER BY price_in_cr) AS rn,
        COUNT(*) OVER() AS total_rows
    FROM ahmendabad_house_price
)

SELECT AVG(price_in_cr) AS median_price
FROM CTE
WHERE rn IN (
    (total_rows + 1) / 2,
    (total_rows + 2) / 2
);

# Q22. Find the 5 most expensive locations based on average property price.

SELECT
	location,
    AVG(price_in_cr) AS avg_price
FROM ahmendabad_house_price
GROUP BY location
ORDER BY avg_price DESC
LIMIT 5;

# Q23. Find the most expensive property for each BHK type.

SELECT 
	name,
	bhk_type,
    price_in_cr,
    ROW_NUMBER() OVER(PARTITION BY bhk_type ORDER BY price_in_cr DESC) AS rnk
FROM ahmendabad_house_price;

# Q24. Find the cheapest property in every location.

SELECT 
	location,
    MIN(price_in_cr) OVER(PARTITION BY location ORDER BY price_in_cr) chepest_property_price
    
FROM ahmendabad_house_price;

# Q25. Find locations where the average rate per sqft is higher than the overall average rate per sqft.

SELECT 
	location,
    AVG(rate_per_sqft) AS avg_rate
FROM ahmendabad_house_price
GROUP BY location
HAVING avg_rate > (
	SELECT AVG(rate_per_sqft) FROM ahmendabad_house_price
);

# Q26. Find the percentage of properties in each property type.

SELECT
	name,
    property_type,
	ROUND((COUNT(*)) * 100 / SUM(COUNT(*)) OVER(),2) AS percentage
FROM ahmendabad_house_price
GROUP BY property_type;

# Q27. Find outlier properties whose price is more than twice the average price of their location.

WITH CTE AS (
	SELECT
		name,
		location,
		ROUND(AVG(price_in_cr),2) as avg_price_per_locations
	FROM ahmendabad_house_price
    GROUP BY location
)
SELECT 
	a.name,
    a.location,
    a.price_in_cr,
    c.avg_price_per_locations
FROM ahmendabad_house_price a
INNER JOIN CTE c
ON a.location = c.location
WHERE a.price_in_cr > 2 * c.avg_price_per_locations;

# Q29. Find the most common property type in every location.

SELECT
	name ,
    location,
    COUNT(*) AS number_of_property
FROM ahmendabad_house_price
GROUP BY name
HAVING COUNT(*) > 20
ORDER BY number_of_property DESC;

# Q30. Find the location where the average property price increased 
-- the most compared to the previous location after sorting alphabetically.

WITH CTE AS (
SELECT
    location,
    ROUND(AVG(price_in_cr),2) as avg_price
FROM ahmendabad_house_price
GROUP BY location
)
SELECT 
    location,
    avg_price,
    ROUND(
			(avg_price) - 
			(LAG(avg_price) OVER(ORDER BY location DESC))
		,2) AS difference
FROM CTE
ORDER BY location ASC;

# Q31.

-- Find the Top 5 locations that have:
-- Highest average price
-- More than 10 properties

SELECT 
	location,
    COUNT(*) AS no_of_property,
    ROUND(AVG(price_in_cr),2) AS avg_price
FROM ahmendabad_house_price
GROUP BY location
HAVING COUNT(*) > 10
ORDER BY avg_price,no_of_property DESC
LIMIT 5;

# Q32. Find all luxury properties where the rate per sqft is below the city average.

SELECT 
	location,
    rate_per_sqft,
    price_in_cr
FROM ahmendabad_house_price 
WHERE price_in_cr > (
	SELECT AVG(price_in_cr) FROM ahmendabad_house_price
) AND rate_per_sqft <
(
	SELECT AVG(rate_per_sqft) FROM ahmendabad_house_price
)


