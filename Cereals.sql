USE project;



CREATE TABLE cereals(
name VARCHAR(50) NOT NULL,
mfr VARCHAR(30),	
type VARCHAR(10),
calories INT,
protein INT,
fat INT,
sodium INT,
fiber DECIMAL(4,2),
carbo DECIMAL(4,2),
sugars INT,	
potass INT,
vitamins INT,
shelf INT,
weight  DECIMAL(4,2),
cups  DECIMAL(4,2),
rating  DECIMAL(9,7)
);

describe cereals;

SELECT COUNT(cereals_name) FROM cereals;

-- DATA CLEANING --
# Rename some columns #
ALTER TABLE cereals
CHANGE COLUMN name cereals_name VARCHAR(50),
CHANGE COLUMN  mfr manufacturer VARCHAR(30),
CHANGE COLUMN potass potassium DECIMAL(8,2),
CHANGE COLUMN carbo carbohydrates DECIMAL(4,2);


UPDATE cereals
SET manufacturer  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(manufacturer,
     'A', 'American Home Food Products'),
     'G', 'General Mills'),
     'K','Kelloggs'),
     'N', ' Nabisco'),
	 'P', 'Post'),
     'Q', 'Quaker Oats'),
	 'R', 'Ralston Purina');
     
     
UPDATE cereals
SET type  = REPLACE(REPLACE(type,
     'C', 'Cold'),
     'H', 'Hot'); 
     
-- Convert sodium from milligrams to grams and change datatype to decimal
ALTER TABLE cereals
MODIFY COLUMN sodium DECIMAL(8, 2);

UPDATE cereals
SET sodium = sodium / 1000;

-- Convert potassium from milligrams to grams
UPDATE cereals
SET potassium = potassium / 1000;     

     
-- Checking missing values --
SELECT * FROM cereals WHERE cereals_name IS NULL;    
-- No missing values --

-- To check for duplicates 
SELECT cereals_name, COUNT(*) AS duplicate_count
FROM cereals
GROUP BY cereals_name
HAVING COUNT(*) > 1;
-- No duplicates --

-- Quetions --
# 1) Retrieve the total number of cereals in the dataset
SELECT COUNT(DISTINCT cereals_name) AS Total_Number_of_cereals FROM cereals;
-- Answer: There are 77 cereals in the dataset --

# 2) Find the distinct manufacturers ('mfr') present in the dataset
SELECT COUNT(DISTINCT manufacturer) AS count FROM cereals;
-- Answer: 7 manufacturers --

# 3) Calculate the total number of cereals for each manufacturer.
SELECT manufacturer,
      COUNT(cereals_name) AS count
FROM cereals
GROUP BY manufacturer
ORDER BY count DESC;
-- Answer: Kelloggs has 23 cereals followed by General Mills with 22 --

# 4) Average ratings
SELECT ROUND(AVG(rating),2) AS average_rating FROM cereals;
-- Answer: 42.67 --

# 5) top 3 cereals by highest ratings?
SELECT cereals_name,
       ROUND(AVG(rating),2) AS highest_rating
FROM cereals
GROUP BY cereals_name
ORDER BY highest_rating DESC
LIMIT 3;
-- Answer: All Bran has the highest rating at 93.70 --

# 6) Cereal with  calories lesser than the average calories
SELECT 
    cereals_name, calories
FROM
    cereals
WHERE
    calories < (SELECT 
            ROUND(AVG(calories),2) AS average_calories
            FROM cereals)
ORDER BY calories DESC;


# 7)  Cereals with high vs low sugar content
SELECT cereals_name,
       MIN(sugars) AS low_sugar
FROM cereals
GROUP BY cereals_name
ORDER BY low_sugar ASC
LIMIT 5;
-- Answer: Quaker Oatmeal has the lowest sugar content at -1 --


SELECT cereals_name,
       MAX(sugars) AS high_sugar
FROM cereals
GROUP BY cereals_name
ORDER BY high_sugar DESC
LIMIT 5;
-- Answer: Golden Crisp and Smacks have the highest sugar at 15 --

# 8)) Top 5 most nutritious cereal
WITH NutritionalValues AS (
    SELECT
        MAX(protein) AS max_protein,
        MAX(fiber) AS max_fiber,
        MIN(sugars) AS min_sugar
    FROM
        cereals
)

SELECT
    cereals_name, manufacturer,
    protein,
    fiber,
    sugars,
    vitamins,
    ROUND((nv.max_protein * protein + nv.max_fiber * fiber + nv.min_sugar * sugars + vitamins),0) AS nutritional_score
FROM
    cereals
CROSS JOIN
    NutritionalValues nv
ORDER BY
    nutritional_score DESC
LIMIT 5;
-- Answer: All Bran with extra fiber from Kelloggs is the most nutritious with a nutritional score of 245

# 9) Least nutritious cereal
WITH LeastNutritious AS (
    SELECT
        cereals_name,
        sugars,
        sodium,
        vitamins,
        protein,
        RANK() OVER (
            ORDER BY sugars DESC, sodium DESC, vitamins ASC, protein ASC
        ) AS nutrient_rank
    FROM cereals
)
SELECT cereals_name, sugars, sodium, vitamins, protein, nutrient_rank
FROM LeastNutritious 
ORDER BY nutrient_rank
LIMIT 5;
-- Answer: Smacks is ranked as the least nutritious


#  10) Find cereals with calories greater than 100g, carbohydrate of higher than the average and display shelf of 2 
SELECT cereals_name,
       calories,
       carbohydrates,
       shelf
FROM cereals
WHERE calories > 100
      AND carbohydrates > (SELECT AVG(carbohydrates) FROM cereals)
      AND shelf = 2;
      

# 11) Manufacturers with Cereals Having Average Protein Greater Than 2:
SELECT manufacturer, AVG(protein) AS avg_protein
FROM cereals
GROUP BY manufacturer
HAVING AVG(protein) > 2;


# 12) Cereals with Fiber More Than 4 and high sugar content:
SELECT cereals_name, fiber, sugars
FROM cereals c1
WHERE fiber > 4
  AND EXISTS (
    SELECT 1
    FROM cereals c2
    WHERE c2.sugars > 10
      AND c2.cereals_name = c1.cereals_name
  );
-- Answer: Fruitful Bran, Post Nat. Raisin Bran and Raisin Bran


# 13) Calculate the percentage of cereals on each shelf, grouped by manufacturer type
SELECT  manufacturer, 
       shelf,
       COUNT(*) AS total_cereals,
	   ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (PARTITION BY shelf), 2) AS percentage_on_shelf
FROM cereals
GROUP BY manufacturer, shelf
ORDER BY manufacturer, shelf;


# 14) Distribution of type
SELECT type,
       COUNT(type) AS count
FROM cereals
GROUP BY type;
-- Answer: Majority of cereals are of type Cold.
