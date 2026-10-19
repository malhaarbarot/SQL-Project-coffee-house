# Monday Coffee SQL Project

This project analyzes Monday Coffee sales data and recommends cities for new coffee-shop locations.

The project is written for **MySQL 8.0 or newer** and can be run in MySQL Workbench.

## Project files

| File            | Purpose                                            |
| --------------- | -------------------------------------------------- |
| `Schemas.sql`   | Creates the `coffee_house` database and its tables |
| `Solutions.sql` | Runs the data checks and ten analysis reports      |
| `city.csv`      | City population and rent data                      |
| `customers.csv` | Customer data                                      |
| `products.csv`  | Product data                                       |
| `sales.csv`     | Sales transactions                                 |

## Run in MySQL Workbench

### 1. Create the tables

1. Open MySQL Workbench and connect to your MySQL server.
2. Open `Schemas.sql`.
3. Execute the entire script.

The script creates and selects a database named `coffee_house`. It also removes and recreates the four project tables, so do not run it if you need to preserve existing data.

### 2. Import the CSV files

Use MySQL Workbench's **Table Data Import Wizard**. Import the files into these tables:

| CSV file        | Table       |
| --------------- | ----------- |
| `city.csv`      | `city`      |
| `products.csv`  | `products`  |
| `customers.csv` | `customers` |
| `sales.csv`     | `sales`     |

Import `city.csv` and `products.csv` first. Then import `customers.csv`, followed by `sales.csv`, because foreign keys reference those tables.

When importing:

- Select **CSV** as the file type.
- Enable **column names in the first row** / header.
- Use a comma as the separator.
- Confirm that the columns map to the matching table columns.

### 3. Check the imported data

Run:

```sql
USE coffee_house;

SELECT COUNT(*) AS city_count FROM city;
SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS sale_count FROM sales;
```

Each count should be greater than zero.

### 4. Run the analysis

Open `Solutions.sql` and execute the entire script. It contains:

1. Estimated coffee consumers by city
2. Q4 2023 revenue
3. Product sales counts
4. Average sales per customer by city
5. Population and coffee-consumer estimates
6. Top three products by city
7. Unique customers by city
8. Average sales compared with rent
9. Monthly sales growth
10. Top three cities by total sales

## Run from the MySQL command line

From the project directory, run:

```bash
mysql -u root -p < Schemas.sql
```

After importing the CSV files through MySQL Workbench, run:

```bash
mysql -u root -p coffee_house < Solutions.sql
```

Replace `root` with your MySQL username if necessary.

## Notes

- MySQL 8.0+ is required for the common table expressions and window functions used by the reports.
- The SQL uses MySQL functions such as `YEAR()`, `MONTH()`, and `QUARTER()`.
- The monetary columns use `DECIMAL` rather than floating-point types.
