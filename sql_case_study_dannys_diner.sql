Create database diners;
Use diners;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
 
  
INSERT INTO sales (
  customer_id, order_date, product_id
)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
 
 
 
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);
 
 
 
INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
 
 
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
 
 
INSERT INTO members (customer_id, join_date)
VALUES  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) 
from sales s 
inner join menu m 
on s.product_id = m.product_id
group by s.customer_id;

# 2 How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as visit_days
from sales
group by customer_id;

#3 What was the first item from the menu purchased by each customer?

with rnk as (
select s.customer_id, s.order_date, s.product_id,
m.product_name,
row_number() over (partition by s.customer_id order by s.order_date) as rnum
from sales s inner join menu m 
on s.product_id = m.product_id
)
select customer_id, product_name from rnk where rnum = 1;


# 4  What is the most purchased item on the menu and how many times was it
-- purchased by all customers?
SELECT
    m.product_name,
    COUNT(*) AS times_purchased
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?
WITH customer_item_counts AS (
  SELECT s.customer_id,
         s.product_id,
         COUNT(*) AS order_count,
         RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS r_ank
  FROM sales s
  GROUP BY s.customer_id, s.product_id
)
SELECT c.customer_id,
       m.product_name,
       c.order_count
FROM customer_item_counts c
JOIN menu m ON c.product_id = m.product_id
WHERE c.r_ank = 1;


-- 6. Which item was purchased first by the customer after they became a member?
with new as (
SELECT a.customer_id, c.product_name, a.order_date,
RANK() OVER (PARTITION BY a.customer_id ORDER BY a.order_date) AS rnkng
FROM sales as a JOIN members as b  ON a.customer_id = b.customer_id
JOIN menu c  ON a.product_id = c.product_id
WHERE a.order_date >= b.join_date
) 
select * from new where rnkng = 1;

-- 7. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,
       COUNT(*) AS total_items,
       SUM(mn.price) AS total_amount
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
JOIN menu mn ON s.product_id = mn.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
order by customer_id;



-- 8. If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
-- how many points would each customer have? (case when)


SELECT customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
GROUP BY customer_id
ORDER BY customer_id;


