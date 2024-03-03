USE project;

CREATE TABLE BigMart_Sales(
Item_Id VARCHAR(6) NOT NULL,
Item_Weight DOUBLE,	
Item_Fat_Content VARCHAR(10),
Item_Visibility DECIMAL(11,10),
Item_Type VARCHAR(30),
Item_MRP DECIMAL(8,5),
Outlet_Id VARCHAR(7) NOT NULL,
Outlet_Establishment_Year INT,
Outlet_Size VARCHAR(10),
Outlet_Location_Type VARCHAR(10),	
Outlet_Type	VARCHAR(30),
Item_Outlet_Sales DECIMAL(10,5)
);

 # Data Cleaning #
 -- replace missing value with mode --
UPDATE bigmart_sales
SET outlet_size = (
    SELECT t.outlet_size
    FROM (
        SELECT outlet_size
        FROM bigmart_sales
        WHERE outlet_size != '0'
        GROUP BY outlet_size
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS t
)
WHERE outlet_size = '0';

SELECT 
    outlet_size, COUNT(outlet_size) as count
FROM
    bigmart_sales
GROUP BY Outlet_Size
ORDER BY count;

-- Replace Item_Fat_Content:
UPDATE bigmart_sales
SET Item_Fat_Content = REPLACE(REPLACE(Item_Fat_Content,
     'LF', 'Low Fat'),
     'reg', 'Regular');
     


# QUESTIONS
-- KPI Metric
# 1) Overall total sales
SELECT 
    ROUND(SUM(item_outlet_sales),2) as Total_Sales
FROM
    bigmart_sales;
-- Overall Sales is 18,591,125.41 --

# 2) Average Sales per Item:
SELECT 
    ROUND(AVG(Item_Outlet_Sales), 2) AS Average_Sales
FROM
    bigmart_sales;
-- Average Sales is 2,181.29 --

# 3) Total Number of Items Sold
SELECT 
    COUNT(DISTINCT item_id) AS Number_of_item_sold
FROM
    bigmart_sales;
-- Numbers of unique items sold is 1,559 --


# 4) Total Transaction 
SELECT 
    COUNT(item_id) AS Total_transaction
FROM
    bigmart_sales;
-- Total transaction is 8,523 --


# 5) What is the distribution of sales across different items and outlets?
SELECT 
    outlet_type,
    item_type,
    ROUND(SUM(item_outlet_sales), 2) AS Total_Sales
FROM
    bigmart_sales
GROUP BY 1 , 2
ORDER BY Total_sales DESC;
-- Supermarket Type 1 and Fruits and Vegetables has the highest sales --


# 6a) Which items contribute the most to overall sales?
SELECT item_type,
    ROUND(SUM(item_outlet_sales),0) as Total_Sales
FROM
    bigmart_sales
GROUP BY item_type
ORDER BY Total_sales DESC
LIMIT 5;
-- Top selling items are "Fruits & Vegetables" followed by "Snacks Foods" --

# 6b) Least performing items
SELECT item_type,
    ROUND(SUM(item_outlet_sales),0) as Total_Sales
FROM
    bigmart_sales
GROUP BY item_type
ORDER BY Total_sales ASC
LIMIT 5;
-- Least performing item is "Seafood" with a sale of 148,868 --

# 7) Overall Sales Trend by year 
SELECT 
    outlet_establishment_year AS EstablishedYear,
    ROUND(SUM(item_outlet_sales), 0) AS Total_sales
FROM
    bigmart_sales
GROUP BY EstablishedYear
ORDER BY Total_sales DESC;
-- Year 1985 had the best sales of 3,633,620 --

# 8) What outlet type had the highest sales
SELECT 
    Outlet_Location_Type,
    ROUND(SUM(item_outlet_sales), 0) AS Total_sales
FROM
    bigmart_sales
GROUP BY Outlet_Location_Type
ORDER BY Total_sales DESC;
-- Tier 3 location made the most sales --

# 9) What is the top-selling item for each sales year?
WITH top_selling_item AS
(   
    SELECT
        Outlet_Establishment_Year AS Sales_Year,
        Item_Type,
        SUM(Item_Outlet_Sales) AS Total_sales,
        ROW_NUMBER() OVER (PARTITION BY Outlet_Establishment_Year ORDER BY SUM(Item_Outlet_Sales) DESC) AS Row_num
    FROM
        bigmart_sales
    GROUP BY
        Outlet_Establishment_Year, Item_Type
)
SELECT
    Sales_Year,
    Item_Type,
    Total_sales
FROM
    top_selling_item
WHERE
    Row_num = 1;

# 10) Average Sales by Outlet size
SELECT 
    Outlet_Size,
    ROUND(AVG(Item_Outlet_Sales), 2) AS Average_Sales
FROM
    bigmart_sales
GROUP BY Outlet_Size
ORDER BY Average_Sales DESC; 
-- Outlet size "High" had an average_sales of 2,299, followed by Medium size with 2,283.73 lastly Small with 1,912.15 --

# 11) What is the distribution and percentage of items in the fat content category?
SELECT 
    Item_Fat_Content,
    COUNT(*) AS Item_Count,
    (CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM bigmart_sales) * 100, 2),'%')) AS Percentage
FROM 
     bigmart_sales
GROUP BY Item_Fat_Content;
-- Low fat products accounts for 64.73% while regular items (35.27%) in this category --




  

