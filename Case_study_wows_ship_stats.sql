USE evaluation;

SELECT * FROM wows_ship_stats;

# Q1. Find the top 10 ships with the highest average Damage.

SELECT 
	Ship,
    AVG(Damage) AS avg_damage
FROM wows_ship_stats
GROUP BY Ship
ORDER BY avg_damage DESC
LIMIT 10;

# Q2 Find the average Win Rate for each Nation and display the results from highest to lowest.

SELECT 
	Nation,
    AVG(`Win rate`) AS avg_win_rate
FROM wows_ship_stats
GROUP BY Nation
ORDER BY avg_win_rate DESC;

# Q3 Display all Nations whose average Base XP is greater than the overall average Base XP.

SELECT 
	Nation,
    `Base Xp`,
    AVG(`Base XP`) AS avg_base_xp
FROM wows_ship_stats
GROUP BY Nation
HAVING `Base Xp` > (SELECT AVG(`Base Xp`) FROM wows_ship_stats);

# Q4 Find the average Survival Rate for each Ship Class.

SELECT 
	Class,
    AVG(`Survival rate`) AS avg_survived
FROM wows_ship_stats
GROUP BY Class;

# Q5 Which Tier has the highest average Damage?

SELECT 
	Tier,
    AVG(Damage) AS avg_damage
FROM wows_ship_stats
GROUP BY Tier
ORDER BY avg_damage DESC;

# Q6 Find the Nation that has the highest number of ships with Win Rate greater than 55%.

SELECT 
	Nation,
    COUNT(Ship) AS number_ship,
    `Win rate`
FROM wows_ship_stats
WHERE `Win rate` > 0.55
GROUP BY Nation
ORDER BY `Win rate` DESC;

# Q7 Display the top-performing ship in terms of Base XP from each Nation.

SELECT 
	Nation,
    Ship,
    `Base Xp`,
    DENSE_RANK() OVER(PARTITION BY Nation ORDER BY `Base Xp` DESC) AS rnk
FROM wows_ship_stats;

# Q8 Find all ships whose Damage is greater than the average Damage of their Nation.

SELECT 
	Nation,
	Ship,
    Damage
FROM wows_ship_stats w1
WHERE Damage > (
	SELECT 
		AVG(Damage)
	FROM wows_ship_stats
    WHERE Nation = w1.Nation
)
ORDER BY Damage DESC;

# Q9 Find the average Damage, Frags, and Survival Rate for every Class.

SELECT 
	Class,
	AVG(Damage) AS avg_damage,
    AVG(Frags) AS avg_frags,
    AVG(`Survival rate`) AS avg_survived_rate
FROM wows_ship_stats
GROUP BY Class;

# Q10. Which Ship Class has the highest average Potential Damage?

SELECT 
	Class,
    AVG(Potential) AS avg_potential
FROM wows_ship_stats
GROUP BY Class
ORDER BY avg_potential DESC;

# Q11 Rank all ships by Damage.

SELECT 
	Ship,
    RANK() OVER(ORDER BY Damage DESC) AS Rnk
FROM wows_ship_stats;

# Q12. Display the Top 3 ships with the highest Win Rate in every Nation.

SELECT 
	Nation,
	Ship,
    `Win rate`,
    ROW_NUMBER() OVER(PARTITION BY Nation ORDER BY `Win rate` DESC) as rnk
FROM wows_ship_stats;

# Q13. Compare every ship's Damage with the average Damage of its Class.

SELECT 
	Ship,
    Class,
    Damage,
    AVG(Damage) OVER(PARTITION BY Class ORDER BY Damage DESC) AS avg_damage
FROM wows_ship_stats;

# Q14. Find ships whose Win Rate is higher than the average Win Rate of their Class.

SELECT
    Ship,
    Class,
    `Win rate`
FROM
(
    SELECT *,
           AVG(`Win rate`) OVER(PARTITION BY Class) AS avg_win_rate
    FROM wows_ship_stats
) t
WHERE `Win rate` > avg_win_rate
ORDER BY `Win rate` DESC;

# Q15 Rank Nations according to their average Base XP.

WITH CTE AS (
	SELECT 
		Nation,
        AVG(`Base XP`) AS avg_base_xp
	FROM wows_ship_stats
    GROUP BY Nation
)
SELECT 
	w.Nation,
    w.`Base XP`,
    ROW_NUMBER() OVER(PARTITION BY c.Nation ORDER BY c.avg_base_xp DESC) AS rnk
FROM wows_ship_stats w
JOIN CTE c
ON w.Nation = c.Nation;

# Q16. Find the highest Damage ship in every Tier.

SELECT 
	Ship,
	Tier,
    Damage,
    DENSE_RANK() OVER(PARTITION BY Tier ORDER BY Damage DESC) AS rnk
FROM wows_ship_stats;
    
# Q17 Find ships whose Battles are greater than the average Battles of their Nation.
WITH CTE AS 
(
	SELECT 
		Nation,
        Ship,
        Battles,
		AVG(Battles) AS avg_battles
	FROM wows_ship_stats
)
SELECT
	Nation,
	Ship,
    Battles
FROM CTE
WHERE Battles > avg_battles;

# Q17 Find ships whose Battles are greater than the average Battles of their Nation.

WITH CTE AS
(
    SELECT
        Nation,
        Ship,
        Battles,
        AVG(Battles) OVER(PARTITION BY Nation) AS avg_battles
    FROM wows_ship_stats
)
SELECT
    Nation,
    Ship,
    Battles
FROM CTE
WHERE Battles > avg_battles;

# Q18. Display the cumulative (running) total of Battles ordered by Tier.

SELECT 
	Ship,
    Tier,
    Battles,
    SUM(Battles) OVER(PARTITION BY Tier ORDER BY Battles) AS running_battle
FROM wows_ship_stats;

# Q19 Calculate the percentage contribution of each Nation to the total number of ships.

SELECT
    Nation,
    COUNT(*) AS Ship_Count,
    ROUND((COUNT(*) * 100.0) /
    (
        SELECT COUNT(*)
        FROM wows_ship_stats
    ), 2) AS Percentage
FROM wows_ship_stats
GROUP BY Nation
ORDER BY Percentage DESC;

# Q20 Categorize ships into:
-- Elite (Win Rate ≥ 60%)
-- Excellent (55–59.99%)
-- Good (50–54.99%)
-- Average (<50%)

-- Display the number of ships in each category.

WITH Ship_Category AS
(
    SELECT
        `Win rate` * 100 AS Win_Rate,
        CASE
            WHEN `Win rate` * 100 >= 60 THEN 'Elite'
            WHEN `Win rate` * 100 BETWEEN 55 AND 59.99 THEN 'Excellent'
            WHEN `Win rate` * 100 BETWEEN 50 AND 54.99 THEN 'Good'
            ELSE 'Average'
        END AS Category
    FROM wows_ship_stats
)
SELECT
    Category,
    COUNT(*) AS Ship_Count
FROM Ship_Category
GROUP BY Category;
    
    