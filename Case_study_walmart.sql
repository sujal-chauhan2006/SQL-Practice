USE evaluation;

SELECT * FROM `walmart retail data`;

ALTER TABLE `walmart retail data`
RENAME TO retail_sales;

SELECT * FROM retail_sales;


# Q1 Display all orders where Sales > 1000.

SELECT *
FROM retail_sales
WHERE Sales > 1000;

# Q2 Display Customer Name, Sales and Profit where
-- Discount > 0.2
-- Order Priority = 'High'
-- Sort by Sales descending.

SELECT 
	`Customer Name` AS Name,
    Sales,
    Profit
FROM retail_sales
WHERE Discount > 0.2 AND
`Order Priority` = 'High'
ORDER BY Sales DESC;

# Q3 Display all customers whose names start with 'A'.

SELECT * 
FROM retail_sales
WHERE `Customer Name` LIKE 'A%';

# Q4 Find all Furniture orders placed in California.

SELECT *
FROM retail_sales
WHERE `Product Category` = 'Furniture' AND
State = 'California';

# Q5 Display top 15 most expensive products according to Unit Price.

SELECT *
FROM retail_sales
ORDER BY `Unit Price` DESC
LIMIT 15;

# Q6 Find total Sales for each Product Category.

SELECT
	`Product Category`,
	ROUND(SUM(Sales),2) AS total_sales
FROM retail_sales
GROUP BY `Product Category`
ORDER BY total_sales DESC;

# Q7 Find average Profit for each Region.
-- Round to 2 decimal places.

SELECT 
	Region,
    ROUND(AVG(Profit),2) AS avg_profit
FROM retail_sales
GROUP BY Region 
ORDER BY avg_profit DESC;

# Q8 Find total number of orders placed in each State.

SELECT
	State,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY State
ORDER BY total_orders DESC;

# Q9 Find Product Categories whose average Sales is greater than 500.

SELECT 
	`Product Category`,
    ROUND(AVG(Sales)) AS avg_sales
FROM retail_sales
GROUP BY `Product Category`
HAVING AVG(Sales) > 500
ORDER BY avg_sales DESC;

# Q10 Find the customer who has placed the maximum number of orders.

SELECT 
	`Customer Name`,
    COUNT(`Order ID`) AS number_order
FROM retail_sales
GROUP BY `Customer Name`
ORDER BY number_order DESC;

# Q11 For every Customer Segment calculate
-- Total Sales
-- Total Profit
-- Average Discount

SELECT 
	`Customer Segment`,
    ROUND(SUM(Sales),2) AS total_sales,
    ROUND(SUM(Profit),2) AS total_profit,
    ROUND(AVG(Discount),2) AS avg_discount
FROM retail_sales
GROUP BY `Customer Segment`;

# Q12 Create a CASE statement.
-- If Profit
-- Profit > 500
-- High Profit
-- 0–500
-- Medium Profit
-- Below 0
-- Loss
-- Return a new column named Profit_Status.

SELECT 
	Profit,
    CASE 
		WHEN Profit > 500 THEN 'High Profit'
        WHEN Profit BETWEEN 0 AND 500 THEN 'Medium Profit'
        ELSE 'Loss'
	END AS Profit_status
FROM retail_sales;

# Q13 Find the second highest Sales value.
-- (No LIMIT 1 OFFSET 1)
-- Use Subquery.

SELECT sales
FROM retail_sales
WHERE sales < (SELECT MAX(Sales) FROM retail_sales)
ORDER BY sales DESC
LIMIT 1;

# Q14 Find all orders whose Sales is greater than the average Sales.

SELECT *
FROM retail_sales
WHERE Sales > (SELECT AVG(Sales) FROM retail_sales);

# Q15 Find the Product Sub-Category having highest total Profit.

SELECT
    `Product Sub-Category`,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_sales
GROUP BY `Product Sub-Category`
ORDER BY Total_Profit DESC
LIMIT 1;

# Q16 Rank all products according to Sales.

SELECT 
	`Product Name`,
	RANK() OVER(ORDER BY Sales DESC) AS Rnk
FROM retail_sales;

# Q17 For every Product Category,
-- find Top 3 highest selling products.

WITH CTE AS (
SELECT 
	`Product Category`,
    `Product Name`,
    ROUND(SUM(Sales),2) AS total_sales,
    ROW_NUMBER() OVER(PARTITION BY `Product Category` ORDER BY SUM(Sales) DESC) As rnk
FROM retail_sales
GROUP BY `Product Category`,`product Name`
)
SELECT *
FROM CTE
WHERE rnk <= 3;

# Q18 For every Region
-- find customer having highest Profit.
-- Use
-- DENSE_RANK()

WITH CTE AS (
SELECT 
	Region,
	`Customer Name`,
    SUM(Profit) AS highest_profit,
    DENSE_RANK() OVER(PARTITION BY Region ORDER BY SUM(Profit) DESC) AS rnk
FROM retail_sales
GROUP BY Region,`Customer Name`
)
SELECT *
FROM CTE 
WHERE rnk = 1;

# Q17 Using LAG(),calculate previous order Sales for each Customer.
-- Output
-- Customer Name
-- Order Date
-- Sales
-- Previous Sales
-- Difference

SELECT 
	`Customer Name`,
    `Order Date`,
    Sales,
    LAG(Sales) OVER(ORDER BY Sales DESC) AS Previous_sales,
    ROUND((Sales - LAG(Sales) OVER(ORDER BY Sales DESC))) AS Difference
FROM retail_sales;


# Q20 For every State,display the customer who generated the highest Sales.
-- Expected Output

-- State
-- Customer Name
-- Sales
-- Rank

WITH CTE AS (
SELECT 
	State,
    `Customer Name`,
	SUM(Sales) AS total_sales,
    ROW_NUMBER() OVER(PARTITION BY State ORDER BY SUM(Sales) DESC) AS rnk
FROM retail_sales
GROUP BY `Customer Name`
)
SELECT *
FROM CTE
WHERE rnk = 1;

# Q21 Write one SQL query that returns
-- Region
-- Product Category
-- Total Sales
-- Total Profit
-- Average Discount

-- Only include those categories where

-- Average Profit > 100

SELECT 
	Region,
    `Product Category`,
    ROUND(SUM(Sales)) AS total_sales,
    ROUND(SUM(Profit)) AS total_profit,
    ROUND(AVG(Discount),2) AS avg_discount
FROM retail_sales
GROUP BY Region,`Product Category`
HAVING AVG(Profit) > 100
ORDER BY total_sales DESC;

# Q22 Find Top 2 customers from every Region according to Total Sales.
-- Expected Output
-- Region
-- Customer Name
-- Total Sales
-- Rank

WITH CTE AS (
	SELECT 
		Region,
        `Customer Name`,
        SUM(Sales) AS total_sales,
        ROW_NUMBER() OVER(PARTITION BY Region ORDER BY SUM(Sales) DESC) AS rnk
	FROM retail_sales
    GROUP BY Region,`Customer Name`
)
SELECT *
FROM CTE
WHERE rnk <= 2;


# Q23 For each Region, compute:
-- Region
-- Total Sales
-- Total Profit
-- Number of Customers
-- Name of the customer with the highest Total Sales
-- Conditions
-- Include only Regions where the average Profit exceeds 200.
-- Add a column named Average_Discount.
-- Order the final result by Total Sales in descending order.

WITH CTE AS (
	SELECT 
		Region,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit
)