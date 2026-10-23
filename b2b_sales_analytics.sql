-- 1. DATABASE SCHEMA SETUP & CONFIGURATION

-- CREATE DATABASE
CREATE DATABASE IF NOT EXISTS b2b_sales_analytics;

-- USE DATABASE
USE b2b_sales_analytics;

-- CREATE SALES TABLE
DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
id INT PRIMARY KEY,
invoice_date DATE,
party_name VARCHAR(60), 
sales_man VARCHAR(60),
item_name VARCHAR(60),
quantity INT NOT NULL CHECK (quantity>0),
rate DECIMAL(12,2) NOT NULL CHECK (rate>=0),
amount DECIMAL(12,2) NOT NULL,
gst DECIMAL(12,2) NOT NULL,
total DECIMAL(12,2) NOT NULL
);

-- DATA INGESTION
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.CSV'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM sales;

-- 2. DATA CLEANING, STRUCTURAL INTEGRITY & WRANGLING SCRIPTS
-- Business Audit: Verify tax compliance architecture (Amount * 18% = GST)
SELECT 
    id, 
    Quantity, 
    Rate, 
    Amount,
    (Quantity * Rate) AS Computed_Amount,
    GST,
    (Amount * 0.18) AS Expected_GST,
    ABS(GST - (Amount * 0.18)) AS Tax_Variance
FROM sales
WHERE ABS(GST - (Amount * 0.18)) > 1.00;

-- 3. EXPLORATORY DATA ANALYSIS (EDA) MODULES

-- KPI Dashboard Query: Executive Performance Overview Matrix
SELECT 
    COUNT(id) AS Total_Invoices_Issued,
    SUM(Quantity) AS Aggregate_Units_Distributed,
    SUM(Amount) AS Gross_Revenue_PreTax,
    SUM(GST) AS Total_Tax_Collected,
    SUM(Total) AS Net_Company_Turnover,
    AVG(Total) AS Average_Order_Value_AOV
FROM sales;

-- Product Portfolio Distribution Analysis
SELECT 
    Item_Name,
    COUNT(*) AS Order_Frequency,
    SUM(Quantity) AS Total_Volume_Sold,
    AVG(Rate) AS Average_Market_Rate,
    SUM(Total) AS Total_Product_Contribution,
    ROUND((SUM(Total) / SUM(SUM(Total)) OVER()) * 100, 2) AS Revenue_Share_Percentage
FROM sales
GROUP BY Item_Name
ORDER BY Total_Product_Contribution DESC;

-- Customer Value Cohort Segments
SELECT 
    Party_Name,
    COUNT(id) AS Purchase_Count,
    SUM(Quantity) AS Gross_Quantity_Purchased,
    SUM(Total) AS Customer_Lifetime_Value_CLV
FROM sales
GROUP BY Party_Name
ORDER BY Customer_Lifetime_Value_CLV DESC;

SELECT * FROM sales;

-- Display records where Qty > 500.
SELECT Id, Invoice_Date, Party_Name, Sales_Man, Item_Name, Quantity, Total
FROM sales
WHERE Quantity > 500
ORDER BY Quantity ASC;

-- Show bills where Total > 200000.
SELECT Id, Invoice_Date, Party_Name, Item_Name, Amount, GST, Total
FROM sales
WHERE Total > 200000.00
ORDER BY Total DESC;

-- Find records for Sales Man = 'Ajay'.
SELECT Id, Invoice_Date, Party_Name, Sales_Man, Item_Name, Total
FROM sales
WHERE Sales_Man = 'Ajay';

-- Display records ordered by Total descending.
SELECT Id, Invoice_Date, Party_Name, Sales_Man, Item_Name, Quantity, Rate, Total
FROM sales
ORDER BY Total DESC;

-- Show top 10 highest Total bills.
SELECT ID, Invoice_Date, Party_Name, Sales_Man, Item_Name, Total
FROM sales
ORDER BY Total DESC
LIMIT 10;

-- Group by Party Name and count bills.
SELECT Party_Name, COUNT(Id) AS Invoice_Count
FROM sales
GROUP BY Party_Name
ORDER BY Invoice_Count DESC;

-- Show Party Names having more than 30 bills.
SELECT Party_Name, COUNT(Id) AS Invoice_Count
FROM sales
GROUP BY Party_Name
HAVING COUNT(Id) > 30
ORDER BY Invoice_Count DESC;

-- Find customers who purchased more than 4 different items.
SELECT Party_Name, COUNT(DISTINCT Item_Name) AS Unique_Items_Count
FROM sales
GROUP BY Party_Name
HAVING COUNT(DISTINCT Item_Name) > 4
ORDER BY Unique_Items_Count DESC;

-- Display records where GST is greater than 18% and Quantity is greater than 400.
SELECT Id, Invoice_Date, Party_Name, Quantity, Amount, GST, 
       ROUND((GST / NULLIF(Amount, 0)) * 100, 2) AS Calculated_GST_Pct
FROM sales
WHERE (GST / NULLIF(Amount, 0)) > 0.18 
  AND Quantity >400;
  
-- Show all bills generated in the last 15 days of the month.
SELECT Id, Invoice_Date, Party_Name, Item_Name, Total
FROM sales
WHERE EXTRACT(DAY FROM Invoice_Date) >= 16
ORDER BY Invoice_Date ASC;
  
-- Display the total sales of each Salesman whose total sales exceed 45,000,000
SELECT Sales_Man, SUM(Total) AS Gross_Sales
FROM sales
GROUP BY Sales_Man
HAVING SUM(Total) > 45000000
ORDER BY Gross_Sales DESC;

-- Find categories (Items) having more than 100 transactions.
SELECT Item_Name AS Product_Category, COUNT(Id) AS Transaction_Volume
FROM sales
GROUP BY Item_Name
HAVING COUNT(Id) >100
ORDER BY Transaction_Volume DESC;

-- Display customers whose total purchase quantity is greater than 50,000.
SELECT Party_Name, SUM(Quantity) AS Total_Units_Purchased
FROM sales
GROUP BY Party_Name
HAVING SUM(Quantity) > 50000
ORDER BY Total_Units_Purchased DESC;

-- Find Salesman where the average bill amount is greater than 500,000.
SELECT Sales_Man, AVG(Total) AS Avg_Bill_Amount 
FROM sales
GROUP BY Sales_Man 
HAVING AVG(Total)>500000;

-- Display the top 5 highest bill amounts.
SELECT Id, Invoice_Date, Party_Name, Total AS Bill_Amount
FROM sales
ORDER BY Total DESC
LIMIT 5;

-- Display the 8 customers with the highest purchase amount.
SELECT Party_Name, SUM(Total) AS Cumulative_Purchase_Value
FROM sales
GROUP BY Party_Name
ORDER BY Cumulative_Purchase_Value DESC
LIMIT 8;

-- Show the lowest 5 GST amounts.
SELECT Id, Invoice_Date, Party_Name, Item_Name, GST
FROM sales
ORDER BY GST ASC
LIMIT 5;

-- Display DISTINCT Item Names whose Rate is greater than ₹500
SELECT DISTINCT Item_Name, Rate
FROM sales
WHERE Rate > 500.00
ORDER BY Rate ASC;

-- Find customers whose names start with 'R' and end with 'H'.
SELECT DISTINCT Sales_Man
FROM sales
WHERE UPPER(Sales_Man) LIKE 'R%H' 
   OR UPPER(Sales_Man) LIKE 'R%H.'; 

-- Find Item_Name where the second character is 'E'.
SELECT DISTINCT Item_Name 
FROM sales
WHERE Item_Name LIKE '_E%';

-- Find total Qty sold by each Item Name.
SELECT Item_Name, SUM(Quantity) AS Aggregate_Quantity_Sold
FROM sales
GROUP BY Item_Name
ORDER BY Aggregate_Quantity_Sold DESC;

-- Find average Rate by Sales Man.
SELECT Sales_Man, ROUND(AVG(Rate), 2) AS Average_Negotiated_Rate
FROM sales
GROUP BY Sales_Man
ORDER BY Average_Negotiated_Rate DESC;

-- Find highest Total for each Party Name.
SELECT Party_Name, MAX(Total) AS Maximum_Single_Invoice_Value
FROM sales
GROUP BY Party_Name
ORDER BY Maximum_Single_Invoice_Value DESC;

-- Find lowest Amount for each Item Name.
SELECT Item_Name, MIN(Amount) AS Minimum_Transaction_Amount
FROM sales
GROUP BY Item_Name
ORDER BY Minimum_Transaction_Amount ASC;

 -- Concatenate Party Name and Sales Man.
SELECT CONCAT(Party_Name, "-", Sales_Man) 
FROM sales;

--  Replace 'Enterprises' with 'Ent.' in Party Name.
SELECT DISTINCT Party_Name AS Original_Party_Name,
REPLACE(Party_Name, 'Enterprises', 'Ent.') AS Compressed_Party_Name
FROM sales
WHERE Party_Name LIKE '%Enterprises%';

-- Display first occurrence position of letter 'a' in Item Name.
SELECT DISTINCT Item_Name,
POSITION('a' IN LOWER(Item_Name)) AS First_Occurrence_Of_A
FROM sales
ORDER BY First_Occurrence_Of_A DESC;
