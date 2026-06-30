CREATE DATABASE SQL_CASE_STUDY;

USE SQL_CASE_STUDY;

SELECT * FROM googleplaystore;

# Q1 Find the top 5 categories having the highest average app rating.
 -- Consider only categories with at least 50 apps.
 
 SELECT
    Category,
    ROUND(AVG(Rating),2) AS avg_rating
FROM googleplaystore
GROUP BY Category
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC
LIMIT 5;

# Q2 Find the highest-rated app from each category.

WITH cte AS (
    SELECT
        App,
        Category,
        Rating,
        DENSE_RANK() OVER(
            PARTITION BY Category
            ORDER BY Rating DESC
        ) AS rnk
    FROM googleplaystore
)
SELECT
    App,
    Category,
    Rating
FROM cte
WHERE rnk = 1;

# Q3 Compare Free and Paid apps.
-- Return:

-- Number of apps
-- Average rating
-- Average reviews
-- Maximum installs

SELECT 
	type,
	COUNT(*) as Num_of_app,
	ROUND(AVG(Rating)) AS avg_rate,
	ROUND(AVG(Reviews)) AS avg_review,
	MAX(Installs) AS highest_Install
FROM googleplaystore
GROUP BY Type;

# Q4 Find categories where Paid apps represent more than 20% of all apps.

SELECT
    Category,
    COUNT(*) AS total_apps,
    SUM(CASE WHEN Type = 'Paid' THEN 1 ELSE 0 END) AS paid_apps,
    ROUND(
        SUM(CASE WHEN Type='Paid' THEN 1 ELSE 0 END)*100.0
        / COUNT(*),2
    ) AS paid_percentage
FROM googleplaystore
GROUP BY Category
HAVING paid_percentage > 20;

# Q5 Return the categories having
-- more than 100 apps
-- average rating greater than 4.2
-- Sort by average reviews.

SELECT
    Category,
    COUNT(*) AS total_apps,
    ROUND(AVG(Rating),2) AS avg_rating,
    ROUND(AVG(Reviews),2) AS avg_reviews
FROM googleplaystore
GROUP BY Category
HAVING COUNT(*) > 100
AND AVG(Rating) > 4.2
ORDER BY avg_reviews DESC;

# Q6 Find the top 3 apps (based on Reviews) within every category.

WITH CTE as (
SELECT 
	App,
	Reviews,
    Category,
    ROW_NUMBER() OVER(PARTITION BY Category ORDER BY Reviews DESC) AS rnk
FROM googleplaystore
)
SELECT * 
FROM CTE 
WHERE rnk < 4;

# Q7 Within each category, display apps ordered by Reviews along with
--  the cumulative number of reviews.

SELECT
    Category,
    App,
    Reviews,
    SUM(Reviews) OVER(
        PARTITION BY Category
        ORDER BY Reviews
    ) AS cumulative_reviews
FROM googleplaystore;

# Q8 For every app, compare its reviews with the previous app in the same category.

SELECT App,
Category,
Reviews,
LAG(Reviews) OVER(PARTITION BY Category ORDER BY Reviews DESC) AS previous_review
FROM googleplaystore;

# Q9 Create rating buckets.
-- Example
-- Below 3
-- 3–4
-- Above 4
-- Count apps in each bucket.

SELECT Rating,
SUM(CASE
		WHEN Rating < 3 THEN 1
	END)
FROM googleplaystore;

# Q10 Find the most expensive paid app from every category.

WITH cte AS (

SELECT
    App,
    Category,
    Price,
    DENSE_RANK() OVER(
        PARTITION BY Category
        ORDER BY Price DESC
    ) AS rnk
FROM googleplaystore
WHERE Type='Paid'

)
SELECT
    App,
    Category,
    Price
FROM cte
WHERE rnk=1;


# Q11 Find categories whose average reviews are higher than the overall average reviews of all apps.

SELECT
    Category,
    ROUND(AVG(Reviews),2) AS avg_reviews
FROM googleplaystore
GROUP BY Category
HAVING AVG(Reviews) >
(
SELECT AVG(Reviews)
FROM googleplaystore
);

# Q12 Rank every app based on installs within its category.
-- Return
-- App
-- Category
-- Installs
-- Rank

SELECT App,
	Category,
    Installs,
    RANK() OVER(PARTITION BY Category ORDER BY Installs DESC) AS rnk
FROM googleplaystore;

# Q13 For every category compute
-- Highest Rating - Lowest Rating
-- Sort by the largest gap.
SELECT
    Category,
    MAX(Rating)-MIN(Rating) AS Rating_Gap
FROM googleplaystore
GROUP BY Category
ORDER BY Rating_Gap DESC;

# Q14 Find apps whose Reviews are more than twice the average reviews of their own category.
WITH avg_review AS (

SELECT
    Category,
    AVG(Reviews) AS avg_reviews
FROM googleplaystore
GROUP BY Category

)

SELECT
    g.App,
    g.Category,
    g.Reviews,
    a.avg_reviews
FROM googleplaystore g

JOIN avg_review a
ON g.Category=a.Category

WHERE g.Reviews > 2*a.avg_reviews;

# Q15 Create a popularity score:
-- Popularity Score =
-- Rating × LOG10(Reviews + 1)

-- Return the top 20 apps according to this score.

SELECT 
	App,
    Category,
	ROUND((Rating * log10(Reviews + 1)),2) AS `Popularity Score`
FROM googleplaystore
ORDER BY `Popularity Score` DESC
LIMIT 20 ;

# Q16 Create one SQL query that returns, for every category:
-- Total Apps
-- Free Apps
-- Paid Apps
-- Average Rating
-- Average Reviews
-- Maximum Installs
-- Highest Rated App
-- Most Reviewed App
-- Average Price of Paid Apps
WITH total_apps AS (
    SELECT
        Category,
        COUNT(*) AS total_apps
    FROM googleplaystore
    GROUP BY Category
),

free_apps AS (
    SELECT
        Category,
        COUNT(*) AS free_apps
    FROM googleplaystore
    WHERE Type = 'Free'
    GROUP BY Category
),

paid_apps AS (
    SELECT
        Category,
        COUNT(*) AS paid_apps
    FROM googleplaystore
    WHERE Type = 'Paid'
    GROUP BY Category
),

avg_rating AS (
    SELECT
        Category,
        ROUND(AVG(Rating),2) AS avg_rating
    FROM googleplaystore
    GROUP BY Category
),

avg_reviews AS (
    SELECT
        Category,
        ROUND(AVG(Reviews),2) AS avg_reviews
    FROM googleplaystore
    GROUP BY Category
),

max_installs AS (
    SELECT
        Category,
        MAX(Installs) AS max_installs
    FROM googleplaystore
    GROUP BY Category
),

highest_rated_app AS (
    SELECT
        Category,
        App,
        Rating,
        ROW_NUMBER() OVER(
            PARTITION BY Category
            ORDER BY Rating DESC
        ) AS rn
    FROM googleplaystore
),

most_reviewed_app AS (
    SELECT
        Category,
        App,
        Reviews,
        ROW_NUMBER() OVER(
            PARTITION BY Category
            ORDER BY Reviews DESC
        ) AS rn
    FROM googleplaystore
),

avg_paid_price AS (
    SELECT
        Category,
        ROUND(AVG(Price),2) AS avg_paid_price
    FROM googleplaystore
    WHERE Type='Paid'
    GROUP BY Category
)

SELECT
    t.Category,
    t.total_apps,
    f.free_apps,
    p.paid_apps,
    ar.avg_rating,
    avr.avg_reviews,
    mi.max_installs,
    hr.App AS highest_rated_app,
    hr.Rating,
    mr.App AS most_reviewed_app,
    mr.Reviews,
    ap.avg_paid_price

FROM total_apps t

LEFT JOIN free_apps f
ON t.Category=f.Category

LEFT JOIN paid_apps p
ON t.Category=p.Category

LEFT JOIN avg_rating ar
ON t.Category=ar.Category

LEFT JOIN avg_reviews avr
ON t.Category=avr.Category

LEFT JOIN max_installs mi
ON t.Category=mi.Category

LEFT JOIN highest_rated_app hr
ON t.Category=hr.Category
AND hr.rn=1

LEFT JOIN most_reviewed_app mr
ON t.Category=mr.Category
AND mr.rn=1

LEFT JOIN avg_paid_price ap
ON t.Category=ap.Category

ORDER BY t.Category;