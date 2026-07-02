USE sql_case_study;

SELECT * FROM ipl_ball_by_ball_2008_2022;

RENAME TABLE ipl_ball_by_ball_2008_2022 TO ball_by_ball;

# Q1 Find the top 10 batsmen with the highest total runs scored.

SELECT 
	batter,
    SUM(total_run) as total_runs
FROM ball_by_ball
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;
	
# Q2 Among batsmen who have faced at least 500 balls, find the top 10 highest strike rates.
-- Strike Rate = (Runs / Balls Faced) × 100

SELECT 
	batter,
    ((total_run / ballnumber) * 100) AS Strike_rate
FROM ball_by_ball
GROUP BY batter
HAVING SUM(ballnumber) > 500
ORDER BY Strike_rate DESC
LIMIT 10;

# Q3 Find the top 10 bowlers with the best economy rate who have bowled at least 100 overs.
-- Economy = Runs Conceded / Overs Bowled

SELECT 
	bowler,
    (total_run / overs) AS economy
FROM ball_by_ball
GROUP BY bowler
HAVING SUM(overs) >= 100
ORDER BY economy DESC
LIMIT 10;

# Q4 Calculate the percentage of runs scored through boundaries (4s and 6s) for every batsman.

SELECT 
	batter
    
FROM ball_by_ball;

# Q5 Find the batsmen who scored the most runs in overs 16–20.

SELECT 
	batter,
    SUM(total_run) as total_runs
FROM ball_by_ball
WHERE overs BETWEEN 16 AND 20
GROUP BY batter
ORDER BY total_runs DESC;

# Q6 Find the bowlers with the highest dot-ball percentage (minimum 500 balls bowled).

SELECT 
	bowler,
    COUNT(*) AS dot_balls
FROM ball_by_ball
WHERE batsman_run = 0
GROUP BY bowler
HAVING COUNT(ballnumber) > 500;

# Q7 Find batsmen who have scored at least 30 runs in the most innings.

SELECT
    batter,
    COUNT(*) AS innings_with_30_plus
FROM (
    SELECT
        ID,
        innings,
        batter,
        SUM(total_run) AS runs_scored
    FROM ball_by_ball
    GROUP BY ID, innings, batter
) AS t
WHERE runs_scored >= 30
GROUP BY batter
ORDER BY innings_with_30_plus DESC;


# Q8 Find the batsman with the highest strike rate in death overs (minimum 300 balls).

WITH batter_runs AS (
    SELECT
        m.season,
        b.batter,
        SUM(b.total_run) AS total_runs
    FROM ball_by_ball b
    JOIN matches m
        ON b.ID = m.ID
    GROUP BY m.season, b.batter
)

SELECT
    season,
    batter,
    total_runs
FROM (
    SELECT
        season,
        batter,
        total_runs,
        RANK() OVER (
            PARTITION BY season
            ORDER BY total_runs DESC
        ) AS rnk
    FROM batter_runs
) AS ranked
WHERE rnk = 1;

# 10 Find the bowler with the most wickets 

SELECT 
	bowler,
    SUM(isWicketDelivery) AS total_wicket
FROM ball_by_ball
GROUP BY bowler
ORDER BY total_wicket DESC;

# Q11 For every batsman, identify the bowler who has dismissed them the most times.

WITH dismissals AS (
    SELECT
        player_out AS batter,
        bowler,
        COUNT(*) AS total_dismissals
    FROM ball_by_ball
    WHERE isWicketDelivery = 1
    GROUP BY player_out, bowler
)

SELECT
    batter,
    bowler,
    total_dismissals
FROM (
    SELECT *,
           RANK() OVER (
               PARTITION BY batter
               ORDER BY total_dismissals DESC
           ) AS rnk
    FROM dismissals
) t
WHERE rnk = 1
ORDER BY total_dismissals DESC;

# Q12 Calculate which batsmen have the highest average runs scored in overs 16–20 (minimum 20 innings).

WITH batter_innings AS (
    SELECT
        ID,
        innings,
        batter,
        SUM(total_run) AS runs_in_death_overs
    FROM ball_by_ball
    WHERE overs BETWEEN 16 AND 20
    GROUP BY ID, innings, batter
)

SELECT
    batter,
    COUNT(*) AS innings_played,
    ROUND(AVG(runs_in_death_overs), 2) AS avg_runs
FROM batter_innings
GROUP BY batter
HAVING COUNT(*) >= 20
ORDER BY avg_runs DESC;

# Q14 For every match and innings, calculate the running total after every ball.

SELECT
    ID,
    innings,
    overs,
    ballnumber,
    total_run,
    SUM(total_run) OVER (
        PARTITION BY ID, innings
        ORDER BY overs, ballnumber
    ) AS running_total
FROM ball_by_ball;

# Q15 Create your own MVP Score using a weighted formula, for example:
-- MVP Score =
-- (Runs × 1)
-- + (Wickets × 25)
-- + (Catches × 8)
-- + (Run Outs × 10)
-- + (Stumpings × 12)
-- − (Dot Balls Faced × 0.2)
-- Rank the Top 20 players based on this custom MVP score.
WITH batting AS (
    SELECT
        batter AS player,
        SUM(batsman_run) AS runs,
        SUM(CASE WHEN total_run = 0 THEN 1 ELSE 0 END) AS dot_balls
    FROM ball_by_ball
    GROUP BY batter
),

bowling AS (
    SELECT
        bowler AS player,
        COUNT(
            CASE
                WHEN isWicketDelivery = 1
                AND kind NOT IN ('run out','retired hurt')
                THEN 1
            END
        ) AS wickets
    FROM ball_by_ball
    GROUP BY bowler
)

SELECT
    COALESCE(bt.player, bw.player) AS player,
    COALESCE(bt.runs,0) AS runs,
    COALESCE(bw.wickets,0) AS wickets,
    COALESCE(bt.dot_balls,0) AS dot_balls,

    (
        COALESCE(bt.runs,0)
        + COALESCE(bw.wickets,0) * 25
        - COALESCE(bt.dot_balls,0) * 0.2
    ) AS MVP_SCORE

FROM batting bt

LEFT JOIN bowling bw
ON bt.player = bw.player

UNION

SELECT
    bw.player,
    COALESCE(bt.runs,0),
    COALESCE(bw.wickets,0),
    COALESCE(bt.dot_balls,0),

    (
        COALESCE(bt.runs,0)
        + COALESCE(bw.wickets,0) * 25
        - COALESCE(bt.dot_balls,0) * 0.2
    ) AS MVP_SCORE

FROM bowling bw

LEFT JOIN batting bt
ON bt.player = bw.player

WHERE bt.player IS NULL

ORDER BY MVP_SCORE DESC;