use assignment;

create table platform_sales(
		year_number int,
        quarter_no int,
        platform varchar(10),
        revenue decimal(10,2),
        user_counts int
);

INSERT INTO platform_sales VALUES
(2022, 1, 'Netflix', 90000, 5000),
(2022, 2, 'Netflix', 110000, 5500),
(2022, 3, 'Netflix', 105000, 5400),
(2022, 4, 'Netflix', 98000, 5100),

(2022, 1, 'Prime', 70000, 3000),
(2022, 2, 'Prime', 75000, 3200),
(2022, 3, 'Prime', 72000, 3100),
(2022, 4, 'Prime', 68000, 2900),

(2022, 1, 'HotStar', 50000, 2000),
(2022, 2, 'HotStar', 62000, 2400),
(2022, 3, 'HotStar', 60000, 2300),
(2022, 4, 'HotStar', 58000, 2200);

select * from platform_sales;

# Q1
WITH growth_data AS (
    SELECT
        *,
        LAG(revenue) OVER (
            PARTITION BY platform
            ORDER BY year_number, quarter_no
        ) AS previous_revenue
    FROM platform_sales
)
SELECT
    year_number,
    quarter_no,
    platform,
    revenue,
    user_counts,
    ROUND((revenue - previous_revenue) / previous_revenue * 100, 2) AS growth_pct
FROM growth_data
WHERE previous_revenue IS NOT NULL;

# Q2

