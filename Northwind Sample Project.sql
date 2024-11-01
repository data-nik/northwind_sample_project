-- 1)	Write a query to find out how many customers are in each city?  
--      Alter this query to return to top 3 cities based on number of customers.

SELECT 
	COUNT(*),
	city 
FROM customers
GROUP BY city
ORDER BY COUNT(*) DESC
LIMIT 3;



-- 2)	Create a query that returns a list of all customers who placed at least 1 order in May 2014 but no orders in June 2014.

SELECT 
	customerid
FROM orders
WHERE orderdate BETWEEN '2014-05-01' AND '2014-05-31'
	AND customerid NOT IN (SELECT 
								customerid 
      						FROM orders
      						WHERE orderdate BETWEEN '2014-06-01' AND '2014-06-30');


-- Another approach --
	
SELECT 
    customerid
FROM orders o1
WHERE orderdate BETWEEN '2014-05-01' AND '2014-05-31'
    AND NOT EXISTS (SELECT 
						1 
      				FROM orders o2
        			WHERE o2.customerid = o1.customerid 
            			AND o2.orderdate BETWEEN '2014-06-01' AND '2014-06-30');


	
-- 3)	Write a query that shows which product category has the most products with an above average unit price.

SELECT 
	categories.categoryname
FROM products
INNER JOIN categories USING(categoryid)
WHERE unitprice >= (SELECT AVG(unitprice) FROM products)
ORDER BY unitprice DESC;



-- 4)	Write a query that contains 2 columns: categoryname,  percent_discontinued.  
--      This query will show the percent (rounded to 2 decimal places) of discontinued products in each category.  
--      Every category should be in the output. If a category has no discontinued products then percent_discontinued should read 0. 

SELECT 
    categoryname,
    COALESCE(ROUND((SUM(CASE WHEN discontinued = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(productid), 2), 0) AS percent_discontinued
FROM categories 
LEFT JOIN products USING(categoryid)
GROUP BY categoryname;


-- 5)	Write two queries: One to find which customer has ordered the greatest quantity of products and the other to find which customer has ordered the greatest total value of products.  
--      Remember the total value would be quantity multiplied by unit price. (You may ignore the discount column)

-- Customer with the Greatest Quantity of Products Ordered --
SELECT
    customers.customerid,
    SUM(order_details.quantity) AS total_quantity
FROM customers
INNER JOIN orders ON customers.customerid = orders.customerid
INNER JOIN order_details ON orders.orderid = order_details.orderid
GROUP BY customers.customerid
ORDER BY total_quantity DESC
LIMIT 1;


-- Customer with the Greatest Total Value of Products Ordered --
SELECT
    customers.customerid,
    ROUND(SUM(order_details.quantity * order_details.unitprice),2) AS total_value
FROM customers
INNER JOIN orders ON customers.customerid = orders.customerid
INNER JOIN order_details ON orders.orderid = order_details.orderid
GROUP BY customers.customerid
ORDER BY total_value DESC
LIMIT 1;



-- 6)	Write a query that returns a list of customer cities which have not had products shipped by all the companies on the shippers table.  
--      Be sure this is not hard coded.  This query should work even if companies are added or removed from the shippers table in the future.

SELECT 
	city
FROM customers 
INNER JOIN orders  ON customers.customerid = orders.customerid
INNER JOIN shippers  ON orders.shipperid = shippers.shipperid
GROUP BY city
HAVING COUNT(DISTINCT shippers.shipperid) < (SELECT COUNT(*) FROM shippers);


