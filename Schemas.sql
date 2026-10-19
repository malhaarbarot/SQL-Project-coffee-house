
CREATE DATABASE IF NOT EXISTS coffee_house;
USE coffee_house;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE city
(
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    population BIGINT NOT NULL,
    estimated_rent DECIMAL(12, 2) NOT NULL,
    city_rank INT
);

CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    CONSTRAINT fk_customers_city
        FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
    rating INT,
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_customers_city_id ON customers(city_id);
CREATE INDEX idx_sales_product_id ON sales(product_id);
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_sale_date ON sales(sale_date);


USE coffee_house;

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers LIMIT 10;
SELECT * FROM sales LIMIT 10;



