# Zepto_Live_SQL_Project
SQL-based Zepto retail data analysis and insights generation.

****Zepto Retail Data Analysis Using SQL**:**
A SQL-based retail analytics project exploring product pricing, discounts, inventory, stock availability, and category-level insights using a Zepto product dataset.
Project Overview
This project uses MySQL to inspect, clean, transform, and analyse a Zepto product dataset. The objective is to turn raw product-level data into useful insights that could support retail decisions around pricing, discounting, stock availability, product value, and inventory.

**The work is organised into three main stages:**
1. Data exploration – understand the table, columns, categories, stock status, and repeated product names.
2. Data cleaning – identify missing or invalid values, remove zero-MRP records, and standardise prices that appear to be stored in paise rather than rupees.
3. Data analysis – answer eight business questions using filtering, aggregation, sorting, calculations, and conditional logic.
Important: The SQL script is the source of truth for the operations documented here. The dataset file itself was not included with the SQL upload, so exact row counts and final query outputs are not stated.

**Objectives**
- Inspect the structure and quality of the product dataset.
- Identify missing values and possible data-quality issues.
- Understand product categories and stock availability.
- Remove records with an MRP of zero.
- Convert price values from paise to rupees where the dataset indicates that conversion is required.
- Analyse discount levels, product prices, estimated inventory value, and inventory weight.
- Practise core SQL concepts used in entry-level data analysis.
**Tools and Technologies**
- MySQL – database creation, data cleaning, transformation, and analysis.
- MySQL Workbench – SQL editor, table inspection, query execution, and CSV import workflow.
- SQL – SELECT, DISTINCT, WHERE, ORDER BY, LIMIT, GROUP BY, aggregate functions, CASE, UPDATE, and DELETE.
Database and Table Structure
The script creates a database named zepto and a table named zepto_sql.
CREATE DATABASE Zepto;
USE zepto;

*************************************************
      CREATE TABLE zepto_sql (

      sku_id SERIAL PRIMARY KEY,
    
      category VARCHAR(150),
      
      name VARCHAR(250) NOT NULL,
    
      mrp NUMERIC(8,2),
    
      DiscountPercent NUMERIC(5,2),
    
      AvailableQuantity INTEGER,
    
      DiscountingSellingPrice NUMERIC(8,2),
    
      WeightInGms INTEGER,
    
      OutOfStock BOOLEAN,
    
      quantity INTEGER    );
********************************************************
Column description
Column	Data type	Description

sku_id	SERIAL PRIMARY KEY	Unique identifier for each SKU/record.

category	VARCHAR(150)	Product category.

name	VARCHAR(250)	Product name; cannot be NULL.

mrp	NUMERIC(8,2)	Maximum retail price, stored to two decimal places.

DiscountPercent	NUMERIC(5,2)	Discount percentage.

AvailableQuantity	INTEGER	Available inventory quantity.

DiscountingSellingPrice	NUMERIC(8,2)	Selling price after discount.

WeightInGms	INTEGER	Product weight in grams.

OutOfStock	BOOLEAN initially	Indicates whether a product is out of stock.

quantity	INTEGER	Quantity field present in the source dataset.


The script subsequently changes OutOfStock to VARCHAR(5):
ALTER TABLE zepto_sql
MODIFY COLUMN OutOfStock VARCHAR(5);
This change was made during the import workflow to accommodate the text values in the CSV (such as TRUE and FALSE). The analysis later compares the field with TRUE/`1`. Confirm the actual stored values in your imported table before relying on either representation.

**Project Workflow**

1. Database setup and import
- Created the zepto database.
- Selected it using USE zepto.
- Created the zepto_sql table with columns corresponding to the source data.
- Used MySQL Workbench's Table Data Import Wizard to load the CSV data.
- Reviewed the source-to-destination column mapping before importing.
  
2. Data exploration
The script begins by viewing the table:

  SELECT * FROM zepto_sql;
It then checks for missing values across the important columns:

 ****************************************************   
    SELECT * FROM zepto_sql

    WHERE name IS NULL

     OR category IS NULL
   
     OR mrp IS NULL
   
     OR DiscountPercent IS NULL
   
     OR AvailableQuantity IS NULL
   
     OR DiscountingSellingPrice IS NULL
   
     OR WeightInGms IS NULL
   
     OR OutOfStock IS NULL
   
     OR quantity IS NULL;
   
**********************************************  
Other exploration queries:

- List distinct product categories.
- Count products by stock status.
- Find product names associated with multiple SKUs.
These checks help understand the dataset before making changes.

3. Data cleaning and transformation
Identify zero-price records
*******************************************************
    SELECT *
   
    FROM zepto_sql

    WHERE mrp = 0

      OR DiscountingSellingPrice = 0;
   
    Remove records with zero MRP

    DELETE FROM zepto_sql

    WHERE mrp = 0;
*******************************************************
The script then checks whether any zero-MRP rows remain:
*******************************************************
    SELECT *

    FROM zepto_sql

    WHERE mrp = 0;
**********************************************************
The script records that this check returned no remaining zero-MRP rows.

Cleaning decision: The deletion condition removes rows where mrp = 0. It does not delete rows solely because DiscountingSellingPrice = 0.
Convert price values from paise to rupees

The script notes that some prices appeared to be stored in paise rather than rupees. It therefore divides both price columns by 100:
UPDATE zepto_sql
**********************************************************************
    SET mrp = mrp / 100.0,

    DiscountingSellingPrice = DiscountingSellingPrice / 100.0;
 *********************************************************************   
This is a dataset-specific transformation based on the observed price scale. It should only be applied when the source values are confirmed to be in paise. Re-running this update on already-converted values would divide the prices again.
Business Questions and SQL Analysis
The project contains eight analysis questions.

Q1. What are the top 10 best-value products based on discount percentage?
******************************************************************************
    SELECT DISTINCT name, mrp, DiscountPercent

    FROM zepto_sql

    ORDER BY DiscountPercent DESC

    LIMIT 10;
******************************************************************************
Purpose: Ranks products by discount percentage, from highest to lowest, and returns up to ten distinct product/price/discount combinations.

Q2. Which products have a high MRP but are out of stock?
***********************************************************
    SELECT DISTINCT name, mrp

    FROM zepto_sql

    WHERE OutOfStock IS TRUE

    AND mrp > 300
  
    ORDER BY mrp DESC;
**********************************************************
Purpose: Identifies products with an MRP above 300 that are marked out of stock, then sorts them by MRP in descending order.

Troubleshooting note: During development, this query returned zero rows in zepto_sql. The script includes diagnostic queries to inspect stock-status values, count records by stock status, count products with MRP above 300, and test the combined condition. A zero-row result means no rows in the queried table satisfy both filters; it does not by itself prove that the SQL syntax is wrong. The final result depends on the imported data and the actual stored representation of OutOfStock.

Q3. What is the estimated value of available inventory for each category?
**************************************************************************
    SELECT

        category,
    
        SUM(DiscountingSellingPrice * AvailableQuantity) AS Total_Revenue
    
    FROM zepto_sql

    GROUP BY category

    ORDER BY Total_Revenue;
*************************************************************************
Purpose: Calculates a category-level total using discounted selling price multiplied by available quantity.

Interpretation note: Because this calculation uses current available inventory, it is more precisely an estimated value of available inventory at discounted selling price, not confirmed sales revenue. Actual revenue would require transaction or sales data.

Q4. Which products have an MRP greater than 500 and a discount below 10%?
**************************************************************************
    SELECT DISTINCT name, mrp, DiscountPercent

    FROM zepto_sql

    WHERE mrp > 500

      AND DiscountPercent < 10
  
    ORDER BY mrp DESC, DiscountPercent DESC;
****************************************************************************
Purpose: Finds higher-priced products with relatively low discount percentages.

Q5. Which five categories have the highest average discount percentage?
********************************************************************
      SELECT

          category,
    
          ROUND(AVG(DiscountPercent), 2) AS avg_discount
    
      FROM zepto_sql

      GROUP BY category

      ORDER BY avg_discount DESC

      LIMIT 5;
****************************************************************************
Purpose: Calculates the average discount for each category, rounds it to two decimal places, and returns the five highest averages.

Q6. What is the price per gram for products weighing more than 100 grams?
****************************************************************************************
      SELECT

          name,
    
          WeightInGms,
    
          DiscountingSellingPrice,
    
     ROUND(DiscountingSellingPrice / WeightInGms, 2) AS Price_per_Grams
    
     FROM zepto_sql

     WHERE WeightInGms > 100

     ORDER BY Price_per_Grams;
*******************************************************************************************
Purpose: Calculates discounted selling price per gram and sorts products from the lowest unit price upward. The filter excludes products weighing 100 grams or less, avoiding division by zero for zero-weight records.

Q7. How can products be grouped into Low, Medium, and Bulk weight categories?
**********************************************************************************
       SELECT DISTINCT

            name,
    
            WeightInGms,
    
            CASE
               WHEN WeightInGms < 1000 THEN 'Low'
        
               WHEN WeightInGms < 5000 THEN 'Medium'
        
               ELSE 'Bulk'
        
           END AS weight_category
    
       FROM zepto_sql;
***************************************************************************************
Purpose: Uses a CASE expression to classify products by weight:

- Low: less than 1,000 grams.
- Medium: 1,000 to less than 5,000 grams.
- Bulk: 5,000 grams or more.
  
Q8. What is the total inventory weight for each category?
*************************************************************************************
       SELECT

           category,
    
           SUM(WeightInGms * AvailableQuantity) AS total_Inv_Weight
    
       FROM zepto_sql

       GROUP BY category

       ORDER BY total_Inv_Weight ASC;
**************************************************************************************
Purpose: Multiplies product weight by available quantity and sums the result for each category. The result represents estimated available inventory weight in grams.

SQL Errors and Challenges Encountered

The following section documents the SQL and data-import issues encountered during the project, along with the corrective actions taken or the diagnostic steps used.

1. Error 1046 – No database selected

What happened: Table creation or deletion statements were executed before a default database had been selected.

Why it happened: MySQL did not know which database should contain the table.

How it was addressed:
USE zepto;

Selecting the database before running table operations provides the required context.

2. Error 1110 – Column DiscountPercent specified twice
   
What happened: The CSV import wizard attempted to map more than one source column to the same destination column.

Why it happened: The source-to-destination mapping was misaligned. In the import preview, later source fields were mapped to the wrong destination fields, resulting in a duplicate destination-column assignment.

How it was addressed: The column mapping needed to be checked so that each source column mapped to its corresponding destination column exactly once. The import preview should be reviewed carefully before proceeding.

3. Missing quantity destination mapping during import

What happened: The quantity source field did not have an appropriate destination column available in the import mapping list.

Why it happened: The destination table must contain a matching column before the wizard can map the source field to it.

How it was addressed: The table definition includes a quantity INTEGER column. The destination table structure and import mapping should be checked to ensure this field exists and is mapped correctly.

4. Error 1366 – Incorrect integer value FALSE for OutOfStock
   
What happened: The import failed when MySQL attempted to place the text value FALSE into an integer-compatible destination field.

Why it happened: The CSV represented stock status as text (TRUE/`FALSE`), while the destination column was being treated as an integer during import.

How it was addressed in the project: The SQL script changes the column to VARCHAR(5):

ALTER TABLE zepto_sql

MODIFY COLUMN OutOfStock VARCHAR(5);

This accommodates the text representation used by the CSV. The values should then be checked after import to confirm how they were stored.

5. Error 1175 – Safe Update Mode blocked DELETE
   
What happened: This statement was blocked:

DELETE FROM zepto_sql

WHERE mrp = 0;

Why it happened: MySQL Workbench Safe Update Mode was enabled, and the WHERE condition did not use a key column. The table's primary key is sku_id, not mrp.

How it was addressed: Safe Update Mode was temporarily disabled, the intended deletion was performed, and Safe Update Mode was enabled again:
SET SQL_SAFE_UPDATES = 0;

DELETE FROM zepto_sql
WHERE mrp = 0;

SET SQL_SAFE_UPDATES = 1;

The project then checked for remaining zero-MRP rows:

SELECT *

FROM zepto_sql

WHERE mrp = 0;

Good practice: Inspect the target rows with a SELECT statement before running a destructive DELETE or UPDATE.

Key SQL Concepts Practised
SQL concept	How it was used
CREATE DATABASE / USE	Create and select the project database.
CREATE TABLE	Define the table and its columns.
ALTER TABLE	Change the stock-status column data type.
SELECT	Retrieve records and inspect data.
DISTINCT	Return unique product combinations or categories.
WHERE	Filter records using conditions.
IS NULL	Identify missing values.
AND / OR	Combine filtering conditions.
COUNT()	Count records and SKUs.
SUM()	Calculate inventory value and inventory weight.
AVG()	Calculate average discount by category.
ROUND()	Round calculated values to two decimal places.
GROUP BY	Aggregate data by category or stock status.
ORDER BY	Sort query results.
LIMIT	Restrict the number of returned rows.
CASE	Classify products into weight categories.
UPDATE	Standardise price values.
DELETE	Remove records with zero MRP.


Important Assumptions and Limitations
- The paise-to-rupee conversion is based on the price-scale issue documented in the SQL comments. Validate the source units before applying it to another dataset.
- The OutOfStock column is altered from BOOLEAN to VARCHAR(5) in the script. Its actual imported values should be inspected before using Boolean comparisons.
- Q3 calculates an estimated value of available inventory using discounted selling price and available quantity. It is not actual realised revenue.
- Q6 calculates unit price per gram. Its results depend on valid, positive product weights and consistent price units.
- The SQL file includes diagnostic queries from the troubleshooting process as well as the final analytical queries.
- The uploaded SQL script does not include the original CSV dataset or screenshots of final outputs. Therefore, this README does not claim specific final counts or business findings that cannot be verified from the SQL file alone.
How to Run the Project
1. Open MySQL Workbench and connect to your MySQL server.
2. Open zepto SQL Project.sql.
3. Execute the database creation and selection statements.
4. Create the zepto_sql table using the supplied schema.
5. Import the source CSV using the Table Data Import Wizard. Check that every source column maps to the correct destination column.
6. Confirm that the import completed and inspect the imported data.
7. Run the data exploration queries.
8. Run the cleaning and transformation queries carefully. In particular, verify the price units before running the paise-to-rupee update.
9. Run the eight analytical queries and review the result grids.
Important: The script contains data-changing statements (DELETE and UPDATE). If you are rerunning the project, restore a fresh copy of the source data or make a backup first. Do not blindly rerun the price conversion, because it can divide already-converted prices by 100 again.
Repository Contents
A suggested repository structure:
Zepto_Live_SQL_Project/
│
├── zepto SQL Project.sql
├── README.md
└── dataset/
    └── zepto.csv
Add the CSV to the repository only if you are permitted to share the dataset. If it is not included, update the repository description or this section to explain how the dataset can be obtained.
Skills Demonstrated
- Relational database setup and table design
- CSV-to-MySQL data import and column mapping
- Data quality checks and data cleaning
- Data type handling
- Price standardisation
- Filtering, sorting, and aggregation
- Conditional classification using CASE
- Troubleshooting MySQL errors
- Translating retail questions into SQL queries
- Interpreting query results and documenting analytical assumptions
Conclusion
This project demonstrates an end-to-end SQL workflow on a retail product dataset: setting up a database, importing and inspecting data, cleaning selected data-quality issues, transforming price values, and answering business-oriented questions about discounts, pricing, stock availability, and inventory.

Beyond writing queries, the project also involved diagnosing SQL execution and import errors, understanding why grouped queries require aggregate-aware sorting, and validating unexpected zero-row results rather than assuming that every successful query must return records.
