use evaluation;
# Q1

SELECT Gender,
		avg(`Sleep duration`) as avg_sleep
FROM evaluation.sleep_efficiency
WHERE `Sleep duration` >= 7.5
GROUP BY Gender
Having Gender = 'Male';

# Q2  Show avg deep sleep time for both gender. Round result at 2 decimal places.

SELECT Gender,avg(`Deep sleep percentage`) as Deep_sleep 
FROM sleep_efficiency
GROUP BY Gender;

# Q3 Find out the lowest 10th to 30th light sleep percentage records 
-- where deep sleep percentage values are between 25 to 45. 
-- Display age, light sleep percentage and deep sleep percentage columns only.

SELECT age,`Light sleep percentage`,`Deep sleep percentage`
FROM sleep_efficiency
WHERE `Deep sleep percentage` BETWEEN 25 and 45
ORDER BY `Light sleep percentage` ASC
LIMIT 9,21;

# Q4 Group by on exercise frequency and smoking status and show average deep sleep time, 
-- average light sleep time and avg rem sleep time.
-- Note the differences in deep sleep time for smoking and non smoking status

SELECT `Exercise frequency`,
		`Smoking status`,
        AVG(`Deep sleep percentage`) as avg_deep_sleep,
		AVG(`Light sleep percentage`) as avg_light_sleep,
        AVG(`Rem sleep percentage`) as avg_rem
FROM sleep_efficiency
GROUP BY `Exercise frequency`,`Smoking status`;

# Q5 Group By on Awekning and show AVG Caffeine consumption, 
-- AVG Deep sleep time and AVG Alcohol consumption only for people who do exercise atleast 3 days a week. 
-- Show result in descending order awekenings

SELECT Awakenings,
	   ROUND(AVG(`Caffeine consumption`),2) as avg_caffeine_cons,
       ROUND(AVG(`Deep sleep percentage`),2) as avg_deep_sleep,
       ROUND(AVG(`Alcohol consumption`),2) as avg_alcohol_cons
FROM sleep_efficiency
WHERE `Exercise frequency` >= 3
GROUP BY Awakenings
ORDER BY Awakenings DESC;

# Q1 Find all age groups where the average sleep duration is greater than 7 hours.

SELECT Age,
	   ROUND(AVG(`Sleep duration`),2) as avg_sleep
FROM sleep_efficiency
Group BY Age
HAVING avg_sleep > 7;

# Q2 Find smoking status categories having more than 10 people.

SELECT `Smoking status`,
       COUNT(*) AS total_people
FROM sleep_efficiency
GROUP BY `Smoking status`
HAVING COUNT(*) > 10;

# Q3 Find exercise frequencies where the average sleep efficiency is greater than 85.

SELECT `Exercise frequency`,
		AVG(`Sleep efficiency`) as avg_sleep_efficiency
FROM sleep_efficiency
GROUP BY `Exercise frequency`
HAVING avg_sleep_efficiency > 85;

# Q4 Find awakening groups whose average caffeine consumption is greater than 2.

SELECT Awakenings,
	   ROUND(AVG(`Caffeine consumption`)) avg_caffeine
FROM sleep_efficiency
GROUP BY Awakenings
HAVING avg_caffeine > 2;

# Q5 Find genders where the average deep sleep percentage is greater than 25.

SELECT Gender,
	   AVG(`Deep sleep percentage`) as avg_deep_sleep
FROM sleep_efficiency
GROUP BY Gender
HAVING avg_deep_sleep > 25;

# Q6 Find smoking status groups having:
-- average alcohol consumption > 1
-- average sleep efficiency > 80
SELECT `Smoking status`,
	   AVG(`Alcohol consumption`) AS avg_alcohol_cons,
       AVG(`Sleep efficiency`) as avg_sleep_effieciency
FROM sleep_efficiency
GROUP BY `Smoking status`
HAVING avg_alcohol_cons > 1 
AND avg_sleep_effieciency > 80;