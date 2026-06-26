use evaluation;

SELECT * FROM car_price_prediction_;

# Q1 Display the top 10 most expensive cars along with their Brand, Model, Year, and Price.

SELECT Brand,Model,Year,Price 
FROM car_price_prediction_
ORDER BY Price DESC
LIMIT 10;

# Q2 Find the average price, average mileage, and total number of cars for every Brand.

SELECT Brand,
ROUND(AVG(Price)) AS AVG_PRICE,
ROUND(AVG(Mileage)) AS AVG_MILEAGE,
COUNT(`Car Id`) AS NUMBER_OF_CARS
FROM car_price_prediction_
GROUP BY Brand
ORDER BY AVG_PRICE DESC;

# Q3 Find Brands whose
-- average price is greater than 60,000
-- and have more than 100 cars.

SELECT Brand,
ROUND(AVG(Price)) AS avg_price,
COUNT(`Car ID`) AS Numbers_Cars
FROM car_price_prediction_
GROUP BY Brand
HAVING AVG(Price) > (SELECT AVG(Price) FROM car_price_prediction_) 
AND COUNT(`Car ID`) > 100;

# Q4 Create a new column called Price_Category
-- Premium → Price > 70,000
-- Mid Range → 40,000–70,000
-- Budget → Below 40,000
-- Also display Brand, Model, Price.

SELECT Brand,
Model,
Price,
CASE 
	WHEN Price > 70000 THEN 'Premium'
    WHEN Price > 40000 THEN 'Mid Range'
    ELSE 'Budget'
END AS Price_category
FROM car_price_prediction_
LIMIT 10;

# Q5 Find all cars whose price is greater than the average price of all cars.

SELECT * 
FROM car_price_prediction_
WHERE Price > (
		SELECT AVG(Price) FROM car_price_prediction_
)
LIMIT 10;

# Q6 For every Brand, find the most expensive car.
-- Display:
-- Brand
-- Model
-- Price

WITH Rank_Car AS (
	SELECT Brand,
	Model,
	Price,
	RANK() OVER(PARTITION BY Brand ORDER BY Price DESC) AS rnk
	FROM car_price_prediction_
)
SELECT Brand,
Model,
Price
FROM Rank_Car
WHERE rnk = 1;

# Q7 Rank every car within its Brand based on Price.
-- Display
-- Brand
-- Model
-- Price

SELECT Brand,
Model,
Price,
RANK() OVER(PARTITION BY Brand ORDER BY Price Desc) AS Rank_of_Car
FROM car_price_prediction_;

# Q8 Find the Top 3 most expensive cars from every Brand.

WITH rnk AS(
SELECT Brand,
Model,
Price,
ROW_NUMBER() OVER(PARTITION BY Brand ORDER BY Price Desc) AS Rank_of_Car
FROM car_price_prediction_
)
SELECT * 
FROM rnk
WHERE Rank_of_Car < 4;

# Q9 For every Brand calculate
-- Total Cars
-- Highest Price
-- Lowest Price
-- Average Price
-- Average Mileage

SELECT Brand,
COUNT(`Car ID`) AS TOTAL_Car,
ROUND(MAX(Price)) AS Expensive_Car_Price,
ROUND(MIN(Price)) AS Cheapest_Car_Price,
ROUND(AVG(Price)) AS Avg_Car_Price,
ROUND(AVG(Mileage)) AS Avg_Car_Mileage
FROM car_price_prediction_
GROUP BY Brand;

# Q10 Show each car along with
-- previous car's price
-- next car's price

SELECT `Car ID`,
Brand,
Price,
LAG(Price) OVER(ORDER BY `Car ID`) as previous_Price,
LEAD(Price) OVER(ORDER BY `Car ID`) as Next_Price
FROM car_price_prediction_;

# Q11 Calculate the difference between a car's price and the average price of its Brand.
-- Display
-- Brand
-- Model
-- Price
-- Brand Average
-- Difference
-- Tests: Window Aggregation

SELECT Brand,
Model,
Price,
ROUND(AVG(Price) OVER(PARTITION BY Brand)) AS Avg_price,
ROUND((Price - AVG(Price) OVER(PARTITION BY Brand ORDER BY Price DESC))) AS Diffrence
FROM car_price_prediction_;

# Q12 Divide all cars into 4 quartiles based on Price.
-- Display
-- Brand
-- Model
-- Price
-- Quartile

SELECT Brand,
Model,
Price,
NTILE(4) OVER(ORDER BY Price DESC) AS Quartile
FROM car_price_prediction_;

# Q13 Find Brands whose average price is above the overall average price, 
-- but whose average mileage is below the overall average mileage.
-- Tests:
-- Multiple Subqueries
-- Aggregation
-- Logical Thinking

WITH cte AS(
SELECT *,
ROUND(AVG(Price) OVER(PARTITION BY Brand)) AS avg_brand_price,
ROUND(AVG(Mileage) OVER(PARTITION BY Brand)) AS avg_brand_Mileage
FROM car_price_prediction_
)
SELECT * 
FROM cte 
WHERE avg_brand_price > (
	SELECT AVG(Price) FROM car_price_prediction_
) AND
avg_brand_Mileage < (
	SELECT AVG(Mileage) FROM car_price_prediction_
);

SELECT Brand,
AVG(Price) AS avg_price,
AVG(Mileage) AS avg_mileage
FROM car_price_prediction_
GROUP BY Brand
HAVING AVG(Price) > (SELECT AVG(Price) FROM car_price_prediction_) AND
AVG(Mileage) < (SELECT AVG(Mileage) FROM car_price_prediction_);

# Q14 Using a CTE, find the second most expensive car from every Brand.
-- Display
-- Brand
-- Model
-- Price
-- Tests:
-- CTE
-- ROW_NUMBER()

WITH most_expensive_car As(
	SELECT Brand,
    Model,
    Price,
    ROW_NUMBER() OVER(PARTITION BY Brand ORDER BY Price DESC) AS rnk
    FROM car_price_prediction_
)
SELECT * 
FROM most_expensive_car
WHERE rnk = 2;

# Q15 For every Brand, display

-- Total Cars
-- Average Price
-- Highest Price
-- Lowest Price
-- Average Mileage
-- Percentage of Automatic Cars
-- Most Expensive Model
-- Cheapest Model
-- Rank Brands based on Average Price
-- Sort by Rank.

WITH BrandStats AS (
    SELECT
        Brand,
        COUNT(`Car ID`) AS Total_Cars,
        ROUND(AVG(Price), 2) AS Average_Price,
        MAX(Price) AS Highest_Price,
        MIN(Price) AS Lowest_Price,
        ROUND(AVG(Mileage), 2) AS Average_Mileage,
        ROUND(
            SUM(CASE
                    WHEN Transmission = 'Automatic' THEN 1
                    ELSE 0
                END) * 100.0 / COUNT(*),
            2
        ) AS Automatic_Percentage
    FROM car_price_prediction_
    GROUP BY Brand
),

ExpensiveModel AS (
    SELECT
        Brand,
        Model AS Most_Expensive_Model,
        ROW_NUMBER() OVER(PARTITION BY Brand ORDER BY Price DESC) AS rn
    FROM car_price_prediction_
),

CheapestModel AS (
    SELECT
        Brand,
        Model AS Cheapest_Model,
        ROW_NUMBER() OVER(PARTITION BY Brand ORDER BY Price ASC) AS rn
    FROM car_price_prediction_
)

SELECT
    bs.Brand,
    bs.Total_Cars,
    bs.Average_Price,
    bs.Highest_Price,
    bs.Lowest_Price,
    bs.Average_Mileage,
    bs.Automatic_Percentage,
    em.Most_Expensive_Model,
    cm.Cheapest_Model,
    RANK() OVER(ORDER BY bs.Average_Price DESC) AS Brand_Rank
FROM BrandStats bs
JOIN ExpensiveModel em
    ON bs.Brand = em.Brand
    AND em.rn = 1
JOIN CheapestModel cm
    ON bs.Brand = cm.Brand
    AND cm.rn = 1
ORDER BY Brand_Rank;