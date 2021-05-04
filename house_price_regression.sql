-- SQL questions - regression

CREATE DATABASE house_price_regression;
USE house_price_regression;

CREATE TABLE `house_price_data` (
  `id` bigint DEFAULT NULL,
  `data` text, 
  `bedrooms` int DEFAULT NULL,
  `bathrooms` double DEFAULT NULL,
  `sqft_living` int DEFAULT NULL,
  `sqft_lot` int DEFAULT NULL,
  `floors` double DEFAULT NULL,
  `waterfront` int DEFAULT NULL,
  `view` int DEFAULT NULL,
  `condition` int DEFAULT NULL,
  `grade` int DEFAULT NULL,
  `sqft_above` int DEFAULT NULL,
  `sqft_basement` int DEFAULT NULL,
  `yr_built` int DEFAULT NULL,
  `yr_renovated` int DEFAULT NULL,
  `zip_code` int DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lon` double DEFAULT NULL,
  `sqft_living15` int DEFAULT NULL,
  `sqft_lot15` int DEFAULT NULL,
  `price` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/train_boston.csv'
INTO TABLE house_price_regression.house_price_data
FIELDS TERMINATED BY ',';

-- Select all the data from table house_price_data to check if the data was imported correctly
select * from house_price_data;

-- Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.
alter table house_price_data
drop column data;
select * from house_price_data
limit 10;

-- Use sql query to find how many rows of data you have.
select count(*) as 'number_of_rows'
from house_price_data;

-- Now we will try to find the unique values in some of the categorical columns:
-- What are the unique values in the column bedrooms?
select distinct bedrooms from house_price_data;

-- What are the unique values in the column bathrooms?
select distinct bathrooms from house_price_data;

-- What are the unique values in the column floors?
select distinct floors from house_price_data;

-- What are the unique values in the column condition?
select distinct `condition` from house_price_data;

-- What are the unique values in the column grade?
select distinct grade from house_price_data;

-- Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.
select id, price from house_price_data
order by price desc
limit 10;

-- What is the average price of all the properties in your data?
select avg(price) from house_price_data;

-- What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
select bedrooms, round(avg(price)) as 'average_surface' from house_price_data
group by bedrooms
order by bedrooms;

-- What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second column.
select bedrooms, round(avg(sqft_living)) as 'average_surface_sqft' from house_price_data
group by bedrooms
order by bedrooms;

-- What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the second column.
select waterfront, round(avg(price)) as 'average_price' from house_price_data
group by waterfront;

-- Is there any correlation between the columns condition and grade? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
select `condition`, grade from house_price_data
group by `condition`, grade
order by `condition`;

-- You might also have to check the number of houses in each category (i.e. number of houses for a given condition) to assess if that category is well represented in the dataset to include it in your analysis. For eg. If the category is under-represented as compared to other categories, ignore that category in this analysis
select `condition`, count(distinct id) as 'number_of_properties_per_condition' from house_price_data
group by `condition`; -- conditions 1 and 2 are underrepresented

-- One of the customers is only interested in the following houses:
-- Number of bedrooms either 3 or 4
-- Bathrooms more than 3
-- One Floor
-- No waterfront
-- Condition should be 3 at least
-- Grade should be 5 at least
-- Price less than 300000

select bedrooms, `condition`, grade, count(distinct id) as 'options_count'
from house_price_data
where bedrooms in (3, 4) 
and bathrooms > 3 
and waterfront = 0 
and `condition` >= 3
and grade > 5 and price < 300000
group by bedrooms, grade; 

-- Or a more detailed query:
select id, bedrooms, bathrooms, `condition`, grade, price
from house_price_data
where bedrooms in (3, 4) 
and bathrooms > 3 
and waterfront = 0 
and `condition` >= 3
and grade > 5 and price < 300000
group by id, bedrooms, grade
order by price asc;

-- Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a subquery for this problem.
select * from house_price_data
where price > 2*(
select avg(price) 
from house_price_data);

-- Since this is something that the senior management is regularly interested in, create a view called Houses_with_higher_than_double_average_price of the same query.
create or replace view Houses_with_higher_than_double_average_price as  
select * from house_price_data
where price > 2*(
select avg(price) 
from house_price_data);
select * from Houses_with_higher_than_double_average_price;

-- Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms? In this case you can simply use a group by to check the prices for those particular houses.
select bedrooms, round(avg(price)) as 'average_price' from house_price_data
where bedrooms in (3, 4)  
group by bedrooms;

-- What are the different locations where properties are available in your database? (distinct zip codes)
select distinct zip_code from house_price_data;

-- Show the list of all the properties that were renovated.
select * from house_price_data
where yr_renovated != 0;

-- Provide the details of the property that is the 11th most expensive property in your database.
select *, dense_rank() over (order by price desc) as 'price_rank' 
from house_price_data
-- where 'price_rank' = 11
;
