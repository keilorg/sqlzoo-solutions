/*
Southwind
*/



/*
#1) Southwind Easy Questions

Q. List all the products ordered by customer c006.
   Include the description of the product, the date that the order was received and the number ordered.
*/
SELECT dscr, DATE_FORMAT(recv, '%Y-%m-%d') date_received, qnty
FROM tpurcd JOIN tprod ON tpurcd.prod = tprod.code
WHERE cust = 'c006';


/*
#2) Southwind Easy Questions

Q. For each product show the total number ordered.
   Include just the product code and the number ordered
*/
SELECT code, COALESCE(SUM(qnty), 0) total_qnty
FROM tprod LEFT JOIN tpurcd ON tprod.code = tpurcd.prod
GROUP BY code;


/*
#3) Southwind Easy Questions

Q. Give the firm and the address of each company that placed an order on 12th February 2002.
*/
SELECT DISTINCT firm, addr
FROM tpurcd JOIN tcust ON tpurcd.cust = tcust.code
WHERE DATE_FORMAT(recv, '%Y-%m-%d') = '2002-02-12';


/*
#4) Southwind Easy Questions

Q. Give all details of the order made by customer 'Assiduous Assoc.' on 12th February 2002.
   Include the product code, the description the price and the number ordered.
*/
SELECT prod, dscr, pric, qnty
FROM tpurcd JOIN tcust ON tpurcd.cust = tcust.code
JOIN tprod ON tpurcd.prod = tprod.code
WHERE (DATE_FORMAT(recv, '%Y-%m-%d') = '2002-02-12') AND
      (firm = 'Assiduous Assoc.');


/*
#5) Southwind Easy Questions

Q. Find the total number of 'Wilmington' ordered by 'Contiguous Corp.'.
*/
SELECT firm, dscr, SUM(qnty) total_qnty
FROM tpurcd JOIN tcust ON tpurcd.cust = tcust.code
JOIN tprod ON tpurcd.prod = tprod.code
WHERE (dscr = 'Wilmington') AND (firm = 'Contiguous Corp.')
GROUP BY firm, dscr;


/*
#1) Southwind Medium Questions

Q. Give the name of the firm or firms who have placed no orders.
*/
SELECT DISTINCT firm
FROM tcust LEFT JOIN tpurcd ON tcust.code = tpurcd.cust
WHERE recv IS NULL;


/*
#2) Southwind Medium Questions

Q. Create a list of products.
   For each product show the description and the total number ordered and the date of the most recent order.
*/
WITH temp1 AS (
  SELECT code, dscr, SUM(qnty) total_qnty
  FROM tprod JOIN tpurcd ON tprod.code = tpurcd.prod
  GROUP BY code, dscr
)
SELECT code, dscr, total_qnty, MAX(recv) most_recent
FROM temp1 JOIN tpurcd ON temp1.code = tpurcd.prod
GROUP BY code, dscr, total_qnty;


/*
#3) Southwind Medium Questions

Q. Show the customer code, the received date and the total value of all purchase orders with a total value of at least £475.
*/
SELECT cust, recv, SUM(pric*qnty) price
FROM tpurcd JOIN tprod ON tpurcd.prod = tprod.code
GROUP BY cust, recv
HAVING price >= 475;


/*
#4) Southwind Medium Questions

Q. List all shipments for the first week of February (2002-02-01 to 2002-02-07 inclusive).
   For each shipment show: the customer, the date of the shipment and the address.
   The address is the customer address as in tcust unless specified in tship
*/
SELECT firm, shpd, COALESCE(tship.addr, tcust.addr) address
FROM tship JOIN tcust ON tship.cust = tcust.code
WHERE DATE_FORMAT(shpd, '%Y-%m-%d') BETWEEN '2002-02-01' AND '2002-02-07';


/*
#5) Southwind Medium Questions

Q. Show the total sales by month.
*/
SELECT DATE_FORMAT(recv, '%M') month_, SUM(pric*qnty) total_sales
FROM tpurcd JOIN tprod ON tpurcd.prod = tprod.code
GROUP BY month_;


/*
#1) Southwind Hard Questions

There are three kinds of exception:
  - RETURN: a customer returns a product
  - INCOMPLETE: a customer is sent an incomplete shipment
  - OUTSTANDING: an order has not been shipped

Q. Produce an exceptions list.
   The exceptions list should show the customer/supplier id and name, the date, the exception code,
    the product involved and any other details that are available - such as the explanation.
*/
(SELECT CASE
    WHEN tship.cust IS NULL THEN 'OUTSTANDING'
    WHEN (tship.cust IS NOT NULL) AND (tshipd.cust IS NULL) THEN 'INCOMPLETE'
    ELSE '' END exception,
  tpurcd.cust, firm, tpurcd.recv, tpurcd.prod, tprod.dscr, tpurcd.qnty, '' expl
FROM tship RIGHT JOIN tpurcd ON (tship.cust = tpurcd.cust) AND
                                (tship.recv = tpurcd.recv)
LEFT JOIN tshipd ON (tshipd.cust = tpurcd.cust) AND
                    (tshipd.recv = tpurcd.recv) AND
                    (tshipd.prod = tpurcd.prod)
JOIN tcust ON tpurcd.cust = tcust.code
JOIN tprod ON tpurcd.prod = tprod.code
WHERE tshipd.cust IS NULL
) UNION ALL (
SELECT 'RETURN' exception, cust, firm, recv, prod, dscr, qnty, expl
FROM tretn JOIN tcust ON tretn.cust = tcust.code
JOIN tprod ON tretn.prod = tprod.code);


/*
#2) Southwind Hard Questions

Q. For each item, calculate the total number currently in stock based on the most recent stock check and deliveries/shipments since that date.
   You should assume that customer returned items are put back in stock.
*/
WITH temp1 AS (
  SELECT *
  FROM tstck
), temp2 AS (
  SELECT *, RANK() OVER (PARTITION BY prod ORDER BY chck DESC) rnk
  FROM temp1
), temp3 AS (
  SELECT chck, prod, qnty
  FROM temp2
  WHERE rnk = 1
  ORDER BY prod
), temp4 AS (
  SELECT temp3.prod, SUM(tretn.qnty) rtns
  FROM temp3 LEFT JOIN tretn ON (temp3.prod = tretn.prod) AND (temp3.chck < tretn.recv)
  GROUP BY temp3.prod
  ORDER BY temp3.prod
), temp5 AS (
  SELECT chck, temp3.prod, qnty + COALESCE(rtns, 0) qnty_post_rtns
  FROM temp3 JOIN temp4 ON temp3.prod = temp4.prod
), temp6 AS (
  SELECT temp5.prod, SUM(tshipd.qnty) shpmnts
  FROM temp5 LEFT JOIN tshipd ON (temp5.prod = tshipd.prod) AND (temp5.chck < tshipd.shpd)
  GROUP BY temp5.prod
  ORDER BY temp5.prod
), temp7 AS (
  SELECT chck, temp5.prod, qnty_post_rtns - COALESCE(shpmnts, 0) qnty_post_rtns_shp_
  FROM temp5 JOIN temp6 ON temp5.prod = temp6.prod
), temp8 AS (
  SELECT temp7.prod, SUM(tdlvrd.qnty) dlvrs
  FROM temp7 LEFT JOIN tdlvrd ON (temp7.prod = tdlvrd.prod) AND (temp7.chck < tdlvrd.recv)
  GROUP BY temp7.prod
  ORDER BY temp7.prod
)
SELECT temp7.prod, qnty_post_rtns_shp_ + COALESCE(dlvrs, 0) current_stock
FROM temp7 JOIN temp8 ON temp7.prod = temp8.prod;


/*
#3) Southwind Hard Questions

Q. Identify the best selling product line for each month.
   The best selling product is the one with the greatest value of orders.
*/
WITH temp1 AS (
  SELECT DATE_FORMAT(recv, '%M') month_, tpurcd.prod, SUM(pric*qnty) order_value
  FROM tpurcd JOIN tprod ON tpurcd.prod = tprod.code
  GROUP BY month_, tpurcd.prod
), temp2 AS (
  SELECT *
  FROM temp1
), temp3 AS (
  SELECT *, RANK() OVER (PARTITION BY month_ ORDER BY order_value DESC) rnk
  FROM temp2
)
SELECT month_, temp3.prod best_selling, dscr, order_value
FROM temp3 JOIN tprod ON temp3.prod = tprod.code
WHERE rnk = 1;


/*
#4) Southwind Hard Questions

Q. Produce a bar chart showing the total capital value of the stock week by week for the 8 weeks from 11th January to 1st March 2007.
   The bar chart may have horizontal bars made of characters
*/
SET SQL_BIG_SELECTS=1;

WITH temp0 AS (
  SELECT *
  FROM (
    SELECT *
    FROM (
      SELECT ADDDATE('2002-01-11', t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) week_
      FROM (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
           (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
           (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
           (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
           (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) v
    WHERE week_ BETWEEN '2002-01-11' AND '2002-02-28') t
  WHERE (FLOOR(DATEDIFF(week_, '2002-01-11')/7) - DATEDIFF(week_, '2002-01-11')/7) = 0
), temp1 AS (
  SELECT chck + INTERVAL 1 DAY start, SUM(qnty * pric) start_capital
  FROM tstck JOIN tprod ON tstck.prod = tprod.code
  WHERE DATE_FORMAT(chck, '%Y-%m-%d') = '2002-01-10'
  GROUP BY chck
), temp2 AS (
  SELECT *, qnty * pric capital_sold
  FROM tpurcd JOIN tprod ON tpurcd.prod = tprod.code
), temp_sales AS (
  SELECT DATE_FORMAT(MAKEDATE(2002, 11) + INTERVAL FLOOR(DATEDIFF(recv, MAKEDATE(2002, 11))/7) WEEK, '%Y-%m-%d') in_week, SUM(capital_sold) sales_in_week
  FROM temp2
  GROUP BY in_week
), temp3 AS (
  SELECT *, qnty * pric capital_rtnd
  FROM tretn JOIN tprod ON tretn.prod = tprod.code
), temp_rtns AS (
  SELECT DATE_FORMAT(MAKEDATE(2002, 11) + INTERVAL FLOOR(DATEDIFF(recv, MAKEDATE(2002, 11))/7) WEEK, '%Y-%m-%d') in_week, SUM(capital_rtnd) rtns_in_week
  FROM temp3
  GROUP BY in_week
), temp4 AS (
  SELECT *, qnty * pric capital_supl
  FROM tdlvrd JOIN tprod ON tdlvrd.prod = tprod.code
), temp_supl AS (
  SELECT DATE_FORMAT(MAKEDATE(2002, 11) + INTERVAL FLOOR(DATEDIFF(recv, MAKEDATE(2002, 11))/7) WEEK, '%Y-%m-%d') in_week, SUM(capital_supl) supl_in_week
  FROM temp4
  GROUP BY in_week
), temp5 AS (
  SELECT week_, (SELECT start_capital FROM temp1) start_capital, COALESCE(sales_in_week, 0) sales_in_week, COALESCE(rtns_in_week, 0) rtns_in_week, COALESCE(supl_in_week, 0) supl_in_week
  FROM temp0 LEFT JOIN temp_sales ON temp0.week_ = temp_sales.in_week
  LEFT JOIN temp_rtns ON temp0.week_ = temp_rtns.in_week
  LEFT JOIN temp_supl ON temp0.week_ = temp_supl.in_week
), temp6 AS (
  SELECT week_, start_capital, rtns_in_week + supl_in_week - sales_in_week change_in_week
  FROM temp5
), temp7 AS (
  SELECT x.week_, x.start_capital, x.change_in_week, SUM(y.change_in_week) balance
  FROM temp6 x JOIN temp6 y ON x.week_ >= y.week_
  GROUP BY x.week_, x.start_capital, x.change_in_week
), temp8 AS (
  SELECT week_, start_capital + balance capital
  FROM temp7
)
SELECT *, RIGHT('IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII', ROUND((capital/100), 0)) bar_graph
FROM temp8;


/*
#5) Southwind Hard Questions

Q. Obtain a list of discrepancies in the stock levels
*/
WITH temp1 AS (
  SELECT *
  FROM tstck
), temp2 AS (
  SELECT prod, chck, qnty, LAG(chck, 1) OVER (PARTITION BY prod ORDER BY chck) last_chck, LAG(qnty, 1) OVER (PARTITION BY prod ORDER BY chck) last_qnty
  FROM temp1
), temp3 AS (
  SELECT *
  FROM temp2
  WHERE last_chck IS NOT NULL
), temp4 AS (
  SELECT temp3.*, recv sale_recv, COALESCE(tpurcd.qnty, 0) sale_qnty
  FROM temp3 LEFT JOIN tpurcd ON (temp3.prod = tpurcd.prod) AND (recv > last_chck AND recv <= chck)
), temp5 AS (
  SELECT temp4.*, tretn.recv rtn_recv, COALESCE(tretn.qnty, 0) rtn_qnty
  FROM temp4 LEFT JOIN tretn ON (temp4.prod = tretn.prod) AND (tretn.recv > last_chck AND tretn.recv <= chck)
), temp6 AS (
  SELECT temp5.*, tdlvrd.recv dlvr_recv, COALESCE(tdlvrd.qnty, 0) dlvr_qnty
  FROM temp5 LEFT JOIN tdlvrd ON (temp5.prod = tdlvrd.prod) AND (tdlvrd.recv > last_chck AND tdlvrd.recv <= chck)
), temp7 AS (
  SELECT prod, chck, qnty qnty_reported, last_chck, last_qnty, last_qnty - SUM(sale_qnty) - SUM(rtn_qnty) - SUM(dlvr_qnty) qnty_actual
  FROM temp6
  GROUP BY prod, chck, qnty, last_chck, last_qnty
)
SELECT prod, chck, qnty_reported, qnty_actual, qnty_reported - qnty_actual descrepancy
FROM temp7;
