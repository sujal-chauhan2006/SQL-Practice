USE evaluation;

SELECT * FROM train;

# Q1 Find the total number of passengers in the dataset.

SELECT COUNT(PassengerId)
FROM train;

# Q2 Calculate the overall survival rate (in percentage).

SELECT ROUND(AVG(Survived) * 100,2) AS Percentage
FROM train;

# Q3 Find the total number of male and female passengers.

SELECT COUNT(PassengerId) AS count_of_passengers
,Sex
FROM train
GROUP BY Sex;

# Q4 Find the average age of passengers.

SELECT AVG(Age) AS avg_age
FROM train;

# Q5 Find the number of passengers in each passenger class.

SELECT Pclass,
COUNT(PassengerId) AS Nummber_passenger
FROM train
GROUP BY Pclass;

# Q6 Find the survival rate for each passenger class.

SELECT ROUND(AVG(Survived)* 100,2) AS Percentage
FROM train
GROUP BY Pclass;

# Q7 Find the average fare paid by survivors and non-survivors.

SELECT Survived,
AVG(Fare) AS avg_fare
FROM train
GROUP BY Survived;

# Q8 Find the Top 10 passengers who paid the highest fare.

SELECT PassengerId,
Name,
Fare 
FROM train
ORDER BY Fare DESC
LIMIT 10;

# Q9 Find the average age based on Passenger Class and Gender.
-- | Pclass | Sex | Average Age |

SELECT Sex,
Pclass,
AVG(Age) AS avg_age
FROM train
GROUP BY Pclass,Sex;

# Q10 Count passengers from each embarkation port.
-- Sort from highest to lowest.
-- Expected Output
--  Embarked  Total 

SELECT Embarked,
COUNT(*) AS Total
FROM train
GROUP BY Embarked
ORDER BY Total DESC;

# Q11 Find the Top 5 oldest passengers who survived.
-- PassengerId,Name,Age,Pclass

SELECT PassengerId,
Name,
Age,
Pclass
FROM train
WHERE Survived = 1
ORDER BY Age Desc
LIMIT 5;

# Q12 Find passengers whose fare is greater than the average fare.
-- PassengerId
-- Name
-- Fare

SELECT PassengerId,
Name,
Fare
FROM train
WHERE Fare > (SELECT AVG(Fare) FROM train)
ORDER BY Fare DESC
LIMIT 10;

# Q13 Create a new column
-- Family_Size = SibSp + Parch + 1
-- PassengerId
-- Name
-- Family_Size

SELECT PassengerId,
Name,
(SibSp + Parch + 1) AS Family_Size
FROM train
ORDER BY Family_Size DESC;

# Q 14 Rank all passengers according to Fare.
-- Display
-- PassengerId
-- Name
-- Fare
-- Fare Rank

SELECT PassengerId,
Name,
Fare,
DENSE_RANK() OVER(ORDER BY Fare DESC) AS Fare_Rank
FROM train
LIMIT 10;

# Q15 Find the survival rate for each combination of
-- Passenger Class
-- Gender
-- Sort by highest survival rate.

SELECT Pclass,
Sex,
AVG(Survived) * 100 AS Survival_rate
FROM train
GROUP BY Sex,Pclass
ORDER BY Survival_rate Desc;