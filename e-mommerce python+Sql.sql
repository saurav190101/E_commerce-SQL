-- 🛒 E-commerce Sales Analysis Project (PostgreSQL + Python(sqlalchemy))



--1. Monthly Revenue Trend

SELECT
	MONTH,
	SUM("Total Purchase Amount")
FROM
	"e-commerce" GROUP BY month
	
--2. Most Purchased Products (Window Function + RANK)

SELECT
	"Product Category",
	SUM("Quantity") AS TOTAL_QANTITY,
	DENSE_RANK() OVER (
		ORDER BY
			SUM("Quantity") DESC
	)
FROM
	"e-commerce"
GROUP BY
	"Product Category"


--3. Return Rate by Product Category

SELECT
	"Product Category",
	COUNT(*) AS TOTAL_ORDERS,
	SUM(
		CASE
			WHEN "Returns" = 1 THEN "Returns"
			ELSE 0
		END
	) AS TOTAL_RETURN,
	ROUND(
		(
			SUM(
				CASE
					WHEN "Returns" = 1 THEN "Returns"
					ELSE 0
				END
			)::NUMERIC / COUNT(*)
		) * 100,
		2
	) AS RETUNT_RATE_PERCENTGE_
FROM
	"e-commerce"
GROUP BY
	"Product Category"
ORDER BY
	RETUNT_RATE_PERCENTGE_ DESC



--Q4: Find the Top 5 Most Returning Customers Based on Return Rate
with customers_orders as(
select "Customer ID",count(*) total_orders ,sum(case
							when "Returns"=1 then 1 else 0 end)as total_reutrns
						 from "e-commerce" 
						 group by "Customer ID" ),
Return_rate as(						 
select "Customer ID",total_orders,total_reutrns,round((total_reutrns::numeric/total_orders)*100,2) as return_Rate_percentage  
from customers_orders where total_reutrns>1 )

select * from return_rate  
order by total_reutrns desc
limit 5


--4. Average Order Value per Customer
 
SELECT
	"Customer ID",
	COUNT(*) TOTAL_ORDERS,
	ROUND(
		SUM("Total Purchase Amount")::NUMERIC / COUNT(*),
		2
	) AS AVG_ORDER_VALUES
FROM
	"e-commerce" 
	GROUP BY
	"Customer ID"


 --Q5. Return Rate by Product Category
WITH
	PRODUCT_ORDERS AS (
		SELECT
			"Product Category",
			COUNT(*) TOTAL_ORDERS,
			SUM(
				CASE
					WHEN "Returns" = 1 THEN "Returns"
					ELSE 0
				END
			) AS TOTAL_RETURNS
		FROM
			"e-commerce"
		GROUP BY
			"Product Category"
	)
SELECT
	"Product Category",
	ROUND((TOTAL_RETURNS::NUMERIC / TOTAL_ORDERS) * 100, 2) AS PRODUCT_RETURN_RATE
FROM
	PRODUCT_ORDERS
ORDER BY
	PRODUCT_RETURN_RATE DESC



--Q6. Top-Selling Product Categories

select "Product Category" ,count(*),
sum("Total Purchase Amount")as total_revenue
from  "e-commerce"
group by  "Product Category"
order by total_revenue desc;


--Q6. Contribution of Each Payment Method

SELECT
	"Payment Method",
	COUNT(*) AS TOTAL_ORDERS,
	ROUND(
		(
			COUNT(*)::NUMERIC / (
				SELECT
					COUNT(*)
				FROM
					"e-commerce"
			)
		) * 100,
		2
	) AS PECENTAGE_SHARE
FROM
	"e-commerce"
GROUP BY
	1
order by PECENTAGE_SHARE desc;


--Q7. Quarterly Revenue Trend


SELECT
	EXTRACT(
		YEAR
		FROM
			"Purchase Date"
	) AS YEARS,
	EXTRACT(
		MONTH
		FROM
			"Purchase Date"
	) AS MONTHS,
	EXTRACT(
		QUARTER
		FROM
			"Purchase Date"
	) AS QUARTER,
	SUM("Total Purchase Amount") AS TOTAL_SPENT
FROM
	"e-commerce"
GROUP BY
	YEARS,MONTHS,
	QUARTER
order by TOTAL_SPENT desc;

--Q8. Identify VIP Customers (top 10% by total purchase)
WITH
	CUSTOMER_SPENDIND AS (
		SELECT
			"Customer ID",
			SUM("Total Purchase Amount") AS TOTAL_SPENT
		FROM
			"e-commerce"
		GROUP BY
			1
	),
	RANKED AS (
		SELECT
			*,
			NTILE(10) OVER (
				ORDER BY
					TOTAL_SPENT DESC
			) AS DECILE
		FROM
			CUSTOMER_SPENDIND
	)
SELECT
	*
FROM
	RANKED
WHERE
	DECILE = 1
ORDER BY
	TOTAL_SPENT DESC
LIMIT
	10;


-- Q9. Days with High Return Rate (>= 30%)
WITH
	WEEK_DAY_RETURNS AS (
		SELECT
			DATE ("Purchase Date") AS PURCHASE_DAY,
			COUNT(*) AS TOTAL_ORDERS,
			SUM(
				CASE
					WHEN "Returns" = 1 THEN 1
					ELSE 0
				END
			) TOTAL_RETURNS
		FROM
			"e-commerce"
		GROUP BY
			PURCHASE_DAY
	)
SELECT
	PURCHASE_DAY,
	TOTAL_ORDERS,
	TOTAL_RETURNS,
	ROUND((TOTAL_RETURNS::NUMERIC / TOTAL_ORDERS) * 100, 2) AS DATE_RETURN_PECENTAGE
FROM
	WEEK_DAY_RETURNS
WHERE
	(TOTAL_RETURNS::NUMERIC / TOTAL_ORDERS) * 100 >= 30
ORDER BY
	TOTAL_RETURNS DESC


--Q10. First and Last Purchase per Customer (Window Functions)

SELECT
	"Customer ID",
	COUNT(*) TOTAL_ORDERS,
	MIN(DATE ("Purchase Date")) AS FIRST_PURCHASE,
	MAX(DATE ("Purchase Date")) AS LAST_PURCHASE
FROM
	"e-commerce"
GROUP BY
	"Customer ID"
ORDER BY
	TOTAL_ORDERS DESC


															--THANK YOU--


