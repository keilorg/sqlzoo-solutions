/*
AdventureWorks

This data is based on Microsoft's AdventureWorks database.
*/



/*
#1) AdventureWorks Easy Questions

Q. Show the first name and the email address of customer with CompanyName 'Bike World'
*/
SELECT firstname, emailaddress
FROM Customer
WHERE companyname = 'Bike World';


/*
#2) AdventureWorks Easy Questions

Q. Show the CompanyName for all customers with an address in City 'Dallas'.
*/
SELECT companyname
FROM Customer c JOIN CustomerAddress ca ON c.customerid = ca.customerid
JOIN Address a ON ca.addressid = a.addressid
WHERE city = 'Dallas';


/*
#3) AdventureWorks Easy Questions

Q. How many items with ListPrice more than $1000 have been sold?
*/
SELECT COUNT(salesorderid) Total
FROM SalesOrderDetail s JOIN Product p ON s.productid = p.productid
WHERE listprice > 1000;


/*
#4) AdventureWorks Easy Questions

Q. Give the CompanyName of those customers with orders over $100000.
   Include the subtotal plus tax plus freight.
*/
SELECT companyname
FROM Customer c JOIN SalesOrderHeader sh ON c.customerid = sh.customerid
WHERE subtotal + taxamt + freight > 100000;


/*
#5) AdventureWorks Easy Questions

Q. Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
*/
SELECT SUM(orderqty) Total
FROM Product p JOIN SalesOrderDetail sd ON p.productid = sd.productid
JOIN SalesOrderHeader sh ON sd.salesorderid = sh.salesorderid
JOIN Customer c ON sh.customerid = c.customerid
WHERE (Name = 'Racing Socks, L') AND (companyname = 'Riding Cycles');


/*
#6) AdventureWorks Medium Questions

A "Single Item Order" is a customer order where only one item is ordered.

Q. Show the SalesOrderID and the UnitPrice for every Single Item Order.
*/
WITH temp1 AS (
  SELECT salesorderid, SUM(orderqty) items
  FROM SalesOrderDetail
  GROUP BY salesorderid
  HAVING items = 1
)
SELECT salesorderid, unitprice
FROM SalesOrderDetail
WHERE salesorderid IN (SELECT salesorderid FROM temp1);



/*
#7) AdventureWorks Medium Questions

Where did the racing socks go?

Q. List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
*/
SELECT p.name, companyname
FROM Customer c JOIN SalesOrderHeader sh ON c.customerid = sh.customerid
JOIN SalesOrderDetail sd ON sh.salesorderid = sd.salesorderid
JOIN Product p ON sd.productid = p.productid
JOIN ProductModel pm ON p.productmodelid = pm.productmodelid
WHERE pm.name = 'Racing Socks';


/*
#8) AdventureWorks Medium Questions

Q. Show the product description for culture 'fr' for product with ProductID 736.
*/
SELECT description
FROM Product p JOIN ProductModel pm ON p.productmodelid = pm.productmodelid
JOIN ProductModelProductDescription pmpd ON pm.productmodelid = pmpd.productmodelid
JOIN ProductDescription pd ON pmpd.productdescriptionid = pd.productdescriptionid
WHERE (productid = 736) AND (culture = 'fr');


/*
#9) AdventureWorks Medium Questions

Q. Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest.
   For each order show the CompanyName and the SubTotal and the total weight of the order.
*/
SELECT companyname, subtotal, SUM(orderqty * weight) weight
FROM SalesOrderHeader sh JOIN SalesOrderDetail sd ON sh.salesorderid = sd.salesorderid
JOIN Product p ON sd.productid = p.productid
JOIN Customer c ON sh.customerid = c.customerid
GROUP BY sh.salesorderid, companyname, subtotal
ORDER BY subtotal DESC;


/*
#10) AdventureWorks Medium Questions

Q. How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
*/
SELECT SUM(orderqty) Total
FROM Address a JOIN SalesOrderHeader sh ON a.addressid = sh.billtoaddressid
JOIN SalesOrderDetail sd ON sh.salesorderid = sd.salesorderid
JOIN Product p ON sd.productid = p.productid
JOIN ProductCategory pc ON p.productcategoryid = pc.productcategoryid
WHERE (city = 'London') AND (pc.name = 'Cranksets');


/*
#11) AdventureWorks Hard Questions

Q. For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address.
   If there is no shipping address leave it blank.
   Use one row per customer.
*/
SELECT companyname,
  MAX(CASE WHEN addresstype = 'Main Office' THEN addressline1 ELSE '' END) main_office,
  MAX(CASE WHEN addresstype = 'Shipping' THEN addressline1 ELSE '' END) shipping
FROM CustomerAddress ca JOIN Address a ON ca.addressid = a.addressid
JOIN Customer c ON ca.customerid = c.customerid
WHERE city = 'Dallas'
GROUP BY companyname;


/*
#12) AdventureWorks Hard Questions

Q. For each order show the SalesOrderID and SubTotal calculated three ways:
   A) From the SalesOrderHeader
   B) Sum of OrderQty*UnitPrice
   C) Sum of OrderQty*ListPrice
*/
WITH tempA AS (
  SELECT salesorderid, subtotal A_total
  FROM SalesOrderHeader
), tempB AS (
  SELECT salesorderid, SUM(orderqty * unitprice) B_total
  FROM SalesOrderDetail
  GROUP BY salesorderid
), tempC AS (
  SELECT salesorderid, SUM(orderqty * listprice) C_total
  FROM SalesOrderDetail sd JOIN Product p ON sd.productid = p.productid
  GROUP BY salesorderid
)
SELECT tempA.salesorderid, A_total, B_total, C_total
FROM tempA JOIN tempB ON tempA.salesorderid = tempB.salesorderid
JOIN tempC ON tempB.salesorderid = tempC.salesorderid;


/*
#13) AdventureWorks Hard Questions

Q. Show the best selling item by value.
*/
SELECT name, SUM(orderqty * unitprice) total_value
FROM SalesOrderDetail sd JOIN Product p ON sd.productid = p.productid
GROUP BY name
ORDER BY total_value DESC
LIMIT 1;


/*
#14) AdventureWorks Hard Questions

Q. Show how many orders are in the following ranges (in $):
   RANGE      Num Orders      Total Value
   0-99
   100-999
   1000-9999
   10000-
*/
WITH temp1 AS (
  SELECT salesorderid, SUM(orderqty * unitprice) order_total
  FROM SalesOrderDetail
  GROUP BY salesorderid
), temp2 AS (
  SELECT salesorderid, order_total, CASE
    WHEN order_total BETWEEN 0 AND 99 THEN '0-99'
    WHEN order_total BETWEEN 100 AND 999 THEN '100-999'
    WHEN order_total BETWEEN 1000 AND 9999 THEN '1000-9999'
    WHEN order_total >= 10000 THEN '10000-'
    ELSE 'Error'
    END AS rng
  FROM temp1
)
SELECT rng 'RANGE', COUNT(rng) 'Num Orders', SUM(order_total) Total
FROM temp2
GROUP BY rng;


/*
#15) AdventureWorks Hard Questions

Q. Identify the three most important cities.
   Show the break down of top level product category against city.
*/
WITH temp1 AS (
  SELECT city, SUM(unitprice * orderqty) AS total_sales
  FROM SalesOrderDetail sd JOIN SalesOrderHeader sh ON sd.salesorderid = sh.salesorderid
  JOIN Address a ON sh.shiptoaddressid = a.addressid
  GROUP BY city
  ORDER BY total_sales DESC
  LIMIT 3
)
SELECT city, pc.name, SUM(unitprice * orderqty) AS total_sales
FROM SalesOrderDetail sd JOIN SalesOrderHeader sh ON sd.salesorderid = sh.salesorderid
JOIN Address a ON sh.shiptoaddressid = a.addressid
JOIN Product p ON sd.productid = p.productid
JOIN ProductCategory pc ON p.productcategoryid = pc.productcategoryid
WHERE city IN (SELECT city FROM temp1)
GROUP BY city, pc.name
ORDER BY city, total_sales DESC;


/*
#1) AdventureWorks Resit Questions

Q.  List the SalesOrderNumber for the customers 'Good Toys' and 'Bike World'.
*/
SELECT companyname, salesorderid
FROM Customer c LEFT JOIN SalesOrderHeader sh ON c.customerid = sh.customerid
WHERE companyname LIKE '%Good Toys%' OR companyname LIKE '%Bike World%';


/*
#2) AdventureWorks Resit Questions

Q.  List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'.
*/
SELECT companyname, p.name, SUM(sd.orderqty) qty
FROM Customer c JOIN SalesOrderHeader sh ON c.customerid = sh.customerid
JOIN SalesOrderDetail sd ON sh.salesorderid = sd.salesorderid
JOIN Product p ON sd.productid = p.productid
WHERE companyname LIKE '%Futuristic Bikes%'
GROUP BY companyname, p.name;



/*
#3) AdventureWorks Resit Questions

Q.  List the name and addresses of companies containing the word 'Bike' (upper or lower case) and companies containing 'cycle' (upper or lower case).
    Ensure that the 'bike's are listed before the 'cycles's.
*/
WITH temp1 AS (
  (SELECT DISTINCT(companyname), customerid, IF(1, 'bike', '') tag
  FROM Customer
  WHERE companyname LIKE '%bike%'
  ) UNION ALL (
  SELECT DISTINCT(companyname), customerid, IF(1, 'cycle', '') tag
  FROM Customer
  WHERE companyname LIKE '%cycle%')
)
SELECT companyname, tag, ca.addressid, addressline1, addressline2, city, stateprovince, postalcode
FROM temp1 JOIN CustomerAddress ca ON temp1.customerid = ca.customerid
JOIN Address a ON ca.addressid = a.addressid
ORDER BY tag;



/*
#4) AdventureWorks Resit Questions

Q.  Show the total order value for each CountryRegion.
    List by value with the highest first.
*/
SELECT countyregion, SUM(subtotal) total
FROM Address a JOIN SalesOrderHeader sh ON a.addressid = sh.shiptoaddressid
GROUP BY countyregion;




/*
#5) AdventureWorks Resit Questions

Q.  Find the best customer in each region.
*/
WITH temp1 AS (
  SELECT countyregion, companyname, SUM(subtotal) total,
    Rank() OVER (PARTITION BY countyregion ORDER BY total DESC) rnk
  FROM Address a JOIN SalesOrderHeader sh ON a.addressid = sh.shiptoaddressid
  JOIN Customer c ON sh.customerid = c.customerid
  GROUP BY countyregion, companyname
)
SELECT countyregion, companyname, total
FROM temp1
WHERE rnk = 1
