create database assignment;
use assignment;
-- Create the products table
CREATE TABLE products(
    product_id INT primary key,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price NUMERIC,
    stock_quantity INT
);

-- Insert sample data
INSERT INTO products VALUES 
(1, 'Laptop', 'Electronics', 65000.00, 15);

INSERT INTO products VALUES 
(2, 'Smartphone', 'Electronics', 25000.00, 30);

INSERT INTO products VALUES 
(3, 'Office Chair', 'Furniture', 5500.50, 20);

INSERT INTO products VALUES 
(6, 'Gamaing Chair', 'Furniture', 5500, 20);

INSERT INTO products VALUES 
(4, 'Running Shoes', 'Sports', 3200.75, 40);

INSERT INTO products VALUES 
(5, 'Coffee Maker', 'Home Appliances', 4500.00, 12);

select * from products;

-- Query 1: Electronics products over $100, sorted by price descending
SELECT * FROM products WHERE category = 'Electronics' AND price > 100 ORDER BY price DESC;

-- Query 2: Top 3 highest-priced products
SELECT * FROM products ORDER BY price DESC LIMIT 3;
