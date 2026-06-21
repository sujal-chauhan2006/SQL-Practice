USE evaluation;

SELECT count(*) FROM movies;

# Q1 Movies with Above Average Score

SELECT *
FROM movies 
WHERE score > (
SELECT AVG(score) FROM movies
);

# Q2  Highest Rated Movie

SELECT * 
FROM movies
WHERE score=(
	SELECT MAX(score) FROM movies
);

# Q3 Movies with More Votes Than Average

SELECT * 
FROM movies
WHERE votes > (
	SELECT AVG(votes) FROM movies
);

# Q4 Highest Grossing Movie in the Dataset

SELECT * 
FROM movies
WHERE gross = 
(
(
SELECT MAX(gross) FROM movies
);

# Q5 Directors with Above Average Movie Scores

SELECT director 
FROM movies 
WHERE score > (
SELECT AVG(score) FROM movies
);

# Q6 Movies Released in the Same Year as the Highest Grossing Movie

SELECT name
FROM movies m2 
WHERE year IN (
			  SELECT year FROM movies
			  WHERE gross =(
							SELECT MAX(gross) FROM movies
							)
             );

# Q7 Movies with Budget Higher Than Their Genre Average

SELECT *
FROM movies m1
WHERE budget > (
    SELECT AVG(budget)
    FROM movies m2
    WHERE m2.genre = m1.genre
);

# Q8 Top Rated Movie in Each Genre

SELECT *
FROM movies m1
WHERE score = (
    SELECT MAX(score)
    FROM movies m2
    WHERE m2.genre = m1.genre
);

# Q9 Directors Who Have Directed More Movies Than the Average Director

SELECT director
FROM movies
GROUP BY director
HAVING COUNT(*) > (
    SELECT AVG(movie_count)
    FROM (
        SELECT COUNT(*) AS movie_count
        FROM movies
        GROUP BY director
    ) AS director_counts
);

# Q10 Movies Whose Gross is Higher Than All Movies Directed by 'Steven Spielberg'

SELECT name,gross
FROM movies
WHERE gross >= (
SELECT MAX(gross) FROM movies
WHERE director = 'Steven Spielberg'
);
