create database Zepto;
use zepto;
drop table zepto_sql;
create table zepto_SQL (
sku_id serial primary key,
category varchar(150),
name varchar(250) not null,
mrp numeric(8,2),
DiscountPercent numeric(5,2),
AvailableQuantity integer,
DiscountingSellingPrice numeric(8,2),
WeightInGms integer,
OutOfStock boolean,
quantity integer
);
USE zepto;

ALTER TABLE zepto_sql
MODIFY COLUMN OutOfStock VARCHAR(5);

select * from zepto_sql;
select * from zepto_sql
where name is null
or
category is null
or
mrp is null
or
DiscountPercent is null
or
AvailableQuantity is null
or
DiscountingSellingPrice is null
or
WeightInGms is null
or
OutOfStock is null
or 
quantity is null;

select distinct category
from zepto_sql
order by category;

# product in stock vs out of stock
select OutOfStock, count(sku_id)
from zepto_sql
group by OutOfStock;

#product name present multiple times
select name, count(sku_id) as "Number of SKUs"
from zepto_sql
group by name
order by count(sku_id) desc;

# data cleaning 

# product with price= 0
select * from zepto_sql
where mrp=0
or
DiscountingSellingPrice=0;

delete from zepto_sql
where mrp=0;

set sql_safe_updates=0;
#finally fixed this annoying error 

#resetting our safe mode for sql 
set sql_safe_updates=1;


#lets see the weather our mrp=0 one is deleted successfully
select * from zepto_sql
where mrp=0;
# successfully removed 

# fixing the mrp pricing standard from paise to rupee because onion cannot be 2500 rs. so its sure to be in paise in dataset you can say this is called to be outliers 
# so now converting paise into rupee

update zepto_sql
set mrp=mrp/100.0,
DiscountingSellingPrice= DiscountingSellingPrice/100.0;

# lets check 
select (mrp) from zepto_sql;
select (DiscountingSellingPrice) from zepto_sql;

# outliers successfully removed

#its good successfully changed the price from paise to rupee

#lets solve some Analysis related question for further analysis
# Q1 lets find out top 10 best valued products based on discount percentage
select distinct name, mrp, DiscountPercent
from zepto_sql
order by DiscountPercent desc
limit 10;

#Q2 what are the product with high mrp but out of stock
select distinct name,mrp
from zepto_sql
where OutOfStock is TRUE and mrp >300 
order by mrp desc;

SELECT OutOfStock, COUNT(*)
FROM zepto_sql
GROUP BY OutOfStock;

SELECT *
FROM zepto_sql
WHERE OutOfStock = 1
LIMIT 10;

SELECT
    COUNT(*) AS Total_Products,
    SUM(OutOfStock = 1) AS Out_Of_Stock,
    SUM(mrp > 300) AS Price_Above_300,
    SUM(OutOfStock = 1 AND mrp > 300) AS Matching_Products
FROM zepto_sql;

SELECT DISTINCT name, mrp
FROM zepto_sql
WHERE OutOfStock = TRUE
AND mrp > 300
ORDER BY mrp DESC;

SELECT DISTINCT name, mrp
FROM zepto_sql
WHERE OutOfStock = TRUE;

SELECT OutOfStock, COUNT(*) AS Total
FROM zepto_sql
GROUP BY OutOfStock;

SELECT COUNT(*) AS Products_Above_300
FROM zepto_sql
WHERE mrp > 300;

#Q3 Calculate estimated revenue for each category
select category,
SUM(DiscountingSellingPrice*AvailableQuantity) as Total_Revenue
from zepto_sql
group by category
order by Total_Revenue;

#Q4 find all the product where mrp is greater then 500 and discount is less then 10%
select distinct name,mrp,DiscountPercent
from zepto_sql
where mrp > 500 and DiscountPercent < 10
order by mrp desc, DiscountPercent desc;

#Q5 identify the top 5 category that provide highest average discount percentage 
select category,
round(avg(DiscountPercent),2) as avg_discount
from zepto_sql
group by category
order by avg_discount desc
limit 5;

#Q6 Find the price per gram for products above 100 gms and short by best values
select name, WeightInGms,DiscountingSellingPrice,
round(DiscountingSellingPrice/WeightInGms,2) as Price_per_Grams
from zepto_sql
where WeightInGms > 100
order by Price_per_Grams;

# Q7 group the product into categories like low, medium, bulk 
select distinct name, WeightInGms,
CASE when WeightInGms < 1000 then "Low"
	 when WeightInGms < 5000 then "Medium"
     Else "Bulk" 
     END as weight_category
from zepto_sql;

#Q8 what is the total inventory weight per category 
select category,
sum(WeightInGms*AvailableQuantity) as total_Inv_Weight 
from zepto_sql
group by category
order by total_Inv_Weight asc;









