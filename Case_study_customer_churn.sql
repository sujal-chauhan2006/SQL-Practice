USE sql_case_study;

SELECT * FROM customer_churn_dataset;

# Q1 Find the subscription types with the highest average total spend.

SELECT `Subscription Type`,
AVG(`Total Spend`) AS avg_total_spend
FROM customer_churn_dataset
GROUP BY `Subscription Type`
ORDER BY avg_total_spend DESC;

# Q2 Calculate the churn percentage for each contract length.
-- Contract Length
-- Total Customers
-- Churned Customers
-- Churn Rate (%)

SELECT 
	`Contract Length`,
	COUNT(*) AS total_customer,
    SUM(Churn) AS Churned_Customers,
    ROUND(AVG(Churn) * 100) AS churn_rate
FROM customer_churn_dataset
GROUP BY `Contract Length`
ORDER BY churn_rate DESC;

# Q3 Find the top 5 highest-spending customers within each subscription type.

WITH RankedCustomers AS (
    SELECT
        `CustomerID`,
        `Subscription Type`,
        `Total Spend`,
        ROW_NUMBER() OVER(
            PARTITION BY `Subscription Type`
            ORDER BY `Total Spend` DESC
        ) AS rn
    FROM customer_churn_dataset
)

SELECT
    `CustomerID`,
    `Subscription Type`,
    `Total Spend`,
    rn
FROM RankedCustomers
WHERE rn <= 5
ORDER BY `Subscription Type`, rn;

# Q4 Find customers whose total spend is greater than the average spend of their subscription type.

WITH CTE AS (
    SELECT
        `Subscription Type`,
        AVG(`Total Spend`) AS avg_total_spend
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
)

SELECT
    c.*
FROM customer_churn_dataset c
JOIN CTE c1
ON c.`Subscription Type` = c1.`Subscription Type`
WHERE c.`Total Spend` > c1.avg_total_spend;


# Q5 Show the cumulative total spend within each subscription type.

SELECT 
	CustomerID,
    `Total Spend`,
    SUM(`Total Spend`) OVER(PARTITION BY `Subscription Type` ORDER BY `Total Spend` DESC) as cumulative_total_spend
FROM customer_churn_dataset;

# Q6 Compare each customer's total spend with the previous customer (ordered by CustomerID).

SELECT 
	CustomerID,
    `Total Spend`,
    LAG(`Total Spend`) OVER(ORDER BY CustomerID) AS previous_customer
FROM customer_churn_dataset;

# Q7 Find the highest spending customer for every contract length.

SELECT 
	CustomerID,
    `Total Spend`,
    `Contract Length`,
    RANK() OVER(PARTITION BY `Contract Length` ORDER BY `Total Spend` DESC) AS rnk
FROM customer_churn_dataset;

# Q8 Create customer risk groups using support calls.
-- 0–2 → Low Risk
-- 3–5 → Medium Risk
-- More than 5 → High Risk

-- Count customers in each group.

SELECT
    CASE
        WHEN `Support Calls` <= 2 THEN 'Low Risk'
        WHEN `Support Calls` <= 5 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS Risk_Group,
    COUNT(*) AS Customer_Count
FROM customer_churn_dataset
GROUP BY Risk_Group
ORDER BY Customer_Count DESC;

# Q9 Find customers whose payment delay is greater than the overall average payment delay.

SELECT 
	CustomerID
FROM customer_churn_dataset
WHERE `Payment Delay` > (
	SELECT AVG(`Payment Delay`) FROM customer_churn_dataset
);

# Q10 Create age buckets.
-- Below 25
-- 25–40
-- 41–60
-- Above 60

-- Return
-- Customer Count
-- Churn Rate
-- Average Spend

SELECT 
	COUNT(*) AS Customer_Count,
    ROUND(AVG(Churn) * 100) AS Churn_rate,
    ROUND(AVG(`Total Spend`)) AS avg_spend,
    CASE
		WHEN Age < 25 THEN 'Teen'
        WHEN Age <= 40 THEN 'Adult'
        WHEN Age <= 60 THEN 'Senior_Adult'
        ELSE 'Senior_Citizen'
	END AS Age_bucket
FROM customer_churn_dataset
GROUP BY Age_bucket
ORDER BY avg_spend DESC;

# Q11 Calculate revenue lost because of churn for each subscription type.

SELECT 
	`Subscription Type`,
    COUNT(*) AS Churned_customer,
    SUM(`Total Spend`) AS revnue_lost
FROM customer_churn_dataset
WHERE Churn = 1
GROUP BY `Subscription Type`
ORDER BY revnue_lost DESC;

# Q12 Find customers whose total spend is 
-- more than 2× the average spend of customers with the same contract length.

WITH cte AS (
    SELECT
        `Contract Length`,
        AVG(`Total Spend`) AS avg_total_spend
    FROM customer_churn_dataset
    GROUP BY `Contract Length`
)

SELECT
    c.CustomerID,
    c.`Contract Length`,
    c.`Total Spend`,
    t.avg_total_spend
FROM customer_churn_dataset c
JOIN cte t
ON c.`Contract Length` = t.`Contract Length`
WHERE c.`Total Spend` > t.avg_total_spend * 2;


# Q13 Rank customers by tenure within each subscription type.
-- CustomerID
-- Subscription Type
-- Tenure
-- Rank

SELECT 
	CustomerID,
    `Subscription Type`,
	Tenure,
    RANK() OVER(PARTITION BY `Subscription Type` ORDER BY Tenure DESC) AS rnk
FROM customer_churn_dataset;

# Q14 Create a dashboard showing, for each subscription type:
-- Total Customers
-- Churned Customers
-- Average Spend
-- Average Tenure
-- Maximum Spend
-- Minimum Spend
-- Average Payment Delay
-- Highest Spending Customer
-- Churn Rate
WITH total_cust AS (
    SELECT
        `Subscription Type`,
        COUNT(*) AS total_customers
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

churned_cust AS (
    SELECT
        `Subscription Type`,
        COUNT(*) AS churned_customers
    FROM customer_churn_dataset
    WHERE Churn = 1
    GROUP BY `Subscription Type`
),

avg_spend AS (
    SELECT
        `Subscription Type`,
        ROUND(AVG(`Total Spend`),2) AS avg_spend
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

avg_tenure AS (
    SELECT
        `Subscription Type`,
        ROUND(AVG(Tenure),2) AS avg_tenure
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

max_spend AS (
    SELECT
        `Subscription Type`,
        MAX(`Total Spend`) AS max_spend
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

min_spend AS (
    SELECT
        `Subscription Type`,
        MIN(`Total Spend`) AS min_spend
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

avg_payment_delay AS (
    SELECT
        `Subscription Type`,
        ROUND(AVG(`Payment Delay`),2) AS avg_payment_delay
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
),

highest_spending_customer AS (
    SELECT
        CustomerID,
        `Subscription Type`,
        `Total Spend`,
        ROW_NUMBER() OVER(
            PARTITION BY `Subscription Type`
            ORDER BY `Total Spend` DESC
        ) AS rn
    FROM customer_churn_dataset
),

churn_rate AS (
    SELECT
        `Subscription Type`,
        ROUND(AVG(Churn) * 100,2) AS churn_rate
    FROM customer_churn_dataset
    GROUP BY `Subscription Type`
)

SELECT
    t.`Subscription Type`,
    t.total_customers,
    c.churned_customers,
    a.avg_spend,
    at.avg_tenure,
    mx.max_spend,
    mn.min_spend,
    ap.avg_payment_delay,
    h.CustomerID AS highest_spending_customer,
    h.`Total Spend` AS highest_spend,
    cr.churn_rate

FROM total_cust t

LEFT JOIN churned_cust c
ON t.`Subscription Type` = c.`Subscription Type`

LEFT JOIN avg_spend a
ON t.`Subscription Type` = a.`Subscription Type`

LEFT JOIN avg_tenure at
ON t.`Subscription Type` = at.`Subscription Type`

LEFT JOIN max_spend mx
ON t.`Subscription Type` = mx.`Subscription Type`

LEFT JOIN min_spend mn
ON t.`Subscription Type` = mn.`Subscription Type`

LEFT JOIN avg_payment_delay ap
ON t.`Subscription Type` = ap.`Subscription Type`

LEFT JOIN highest_spending_customer h
ON t.`Subscription Type` = h.`Subscription Type`
AND h.rn = 1

LEFT JOIN churn_rate cr
ON t.`Subscription Type` = cr.`Subscription Type`

ORDER BY t.`Subscription Type`;

# Q15 Create a custom churn score.
-- Example:
-- Churn Score =
-- (Total Spend × 0.3)
-- +
-- (Support Calls × 5)
-- +
-- (Payment Delay × 2)
-- -
-- (Tenure × 1.5)
-- Return the Top 20 highest-risk customers.
SELECT *,
	((`Total Spend`* 0.3) + (`Support Calls` * 5) + (`Payment Delay` * 2) - (Tenure * 1.5)) AS Churn_Score
FROM customer_churn_dataset
ORDER BY Churn_Score DESC
LIMIT 20