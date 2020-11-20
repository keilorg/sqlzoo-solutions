/*
Dressmaker
*/



/*
#1) Dressmaker Easy Questions

Q. List the post code, order number, order date and garment descriptions for all items associated with Ms Brown.
*/
SELECT c_post_code, order_no, order_date, description
FROM jmcust j JOIN dress_order do ON j.c_no = do.cust_no
JOIN order_line ol ON do.order_no = ol.order_ref
JOIN garment g ON ol.ol_style = g.style_no
WHERE c_name = 'Ms Brown';


/*
#2) Dressmaker Easy Questions

Q. List the customer name, postal information, order date and order number of all orders that have been completed.
*/
SELECT c_name, c_post_code, order_date, order_no
FROM jmcust j JOIN dress_order do ON j.c_no = do.cust_no
WHERE completed = 'Y';


/*
#3) Dressmaker Easy Questions

Q. Which garments have been made or are being made from 'red abstract' or 'blue abstract' coloured materials.
*/
SELECT DISTINCT description
FROM material m JOIN order_line ol ON m.material_no = ol.ol_material
JOIN garment g ON ol.ol_style = g.style_no
WHERE (colour = 'Red Abstract') OR (colour = 'Blue Abstract');


/*
#4) Dressmaker Easy Questions

Q. How many garments has each dressmaker constructed?
   You should give the number of garments and the name and postal information of each dressmaker.
*/
SELECT COUNT(*) garment_count, d_name, d_post_code
FROM dressmaker d JOIN construction c ON d.d_no = c.maker
JOIN order_line ol ON (c.order_ref = ol.order_ref AND c.line_ref = ol.line_no)
JOIN garment g ON ol.ol_style = g.style_no
GROUP BY d_post_code, d_name;


/*
#5) Dressmaker Easy Questions

Q. list the different instruments played by the musicians and avg number of musicians who play the instrument.
*/
SELECT DISTINCT d_name
FROM dressmaker d JOIN construction c ON d.d_no = c.maker
JOIN order_line ol ON (c.order_ref = ol.order_ref AND c.line_ref = ol.line_no)
JOIN material m ON ol.ol_material = m.material_no
JOIN dress_order do ON ol.order_ref = do.order_no
WHERE (fabric = 'Silk') AND (completed = 'Y');


/*
#1) Dressmaker Medium Questions

Q. Assuming that any garment could be made in any of the available materials,
   list the garments (description, fabric, colour and pattern) which are expensive to make,
   that is, those for which the labour costs are 80% or more of the total cost.
*/
WITH temp1 AS (
  SELECT DISTINCT description, labour_cost, quantity
  FROM garment g JOIN quantities q ON g.style_no = q.style_q
), temp2 AS (
  SELECT DISTINCT fabric, colour, pattern, cost
  FROM material
)
SELECT description, fabric, colour, pattern
FROM temp1 CROSS JOIN temp2
WHERE labour_cost / (labour_cost + cost*quantity) >= .8
ORDER BY description, fabric, colour, pattern;


/*
#2) Dressmaker Medium Questions

Q. List the descriptions and the number of orders of the less popular garments,
     that is those for which less than the average number of orders per garment have been placed.
   Also print out the average number of orders per garment.
   When calculating the average, ignore any garments for which no orders have been made.
*/
WITH temp1 AS (
  SELECT description, COUNT(DISTINCT(order_ref)) order_cnt
  FROM garment g JOIN order_line ol ON g.style_no = ol.ol_style
  GROUP BY description
)
SELECT *
FROM temp1
WHERE order_cnt < (SELECT AVG(order_cnt) FROM temp1);


/*
#3) Dressmaker Medium Questions

Q. Which is the most popular line, that is, the garment with the highest number of orders.
   Bearing in mind the fact that there may be several such garments, list the garment description(s) and number(s) of orders.
*/
WITH temp1 AS (
  SELECT description, COUNT(DISTINCT(order_ref)) order_cnt
  FROM garment g JOIN order_line ol ON g.style_no = ol.ol_style
  GROUP BY description
)
SELECT *
FROM temp1
WHERE order_cnt = (SELECT MAX(order_cnt) FROM temp1);


/*
#4) Dressmaker Medium Questions

Q. List the descriptions, and costs of the more expensive size 8, Cotton garments which might be ordered,
     that is those costing more than the average (labour costs + material costs) to make.
*/
WITH temp1 AS (
  SELECT *
  FROM garment g JOIN quantities q ON g.style_no = q.style_q
  WHERE size_q = 8
), temp2 AS (
  SELECT *
  FROM material
  WHERE fabric = 'Cotton'
), temp3 AS (
  SELECT DISTINCT description, colour, pattern, ROUND(labour_cost + cost*quantity, 2)
  total_cost
  FROM temp1 CROSS JOIN temp2
  ORDER BY description, colour, pattern
)
SELECT *
FROM temp3
WHERE total_cost > (SELECT AVG(total_cost) FROM temp3);


/*
#5) Dressmaker Medium Questions

Q. What is the most common size ordered for each garment type?
   List description, size and number of orders, assuming that there could be several equally popular sizes for each type.
*/
WITH temp1 AS (
  SELECT description, ol_size, COUNT(*) cnt
  FROM garment g JOIN order_line ol ON g.style_no = ol.ol_style
  GROUP BY description, ol_size
), temp2 AS (
  SELECT *, MAX(cnt) OVER (PARTITION BY description) max_cnt
  FROM temp1
  ORDER BY description, cnt DESC, ol_size
)
SELECT *
FROM temp2
WHERE max_cnt = cnt;


/*
#2) Dressmaker Hard Questions

Q. It is decided to review the materials stock. How much did each material contribute to turnover in 2002?
*/
SELECT material_no, fabric, colour, pattern, ROUND(SUM(quantity), 2) total_meters_sold
FROM order_line ol JOIN material m ON ol.ol_material = m.material_no
JOIN quantities q ON (ol.ol_style = q.style_q) AND (ol.ol_size = size_q)
JOIN dress_order do ON ol.order_ref = do.order_no
WHERE YEAR(order_date) = 2002
GROUP BY material_no, fabric, colour, pattern;


/*
#3) Dressmaker Hard Questions

Q.  An order for shorts has just been placed and the work is to be distributed amongst the workforce,
      and we wish to know how busy the shorts makers are.
    For each of the workers who have experience of making shorts show the number of hours work that she is currently committed to,
      assuming a meagre wage of £4.50 per hour.
*/
WITH temp1 AS (
  SELECT DISTINCT d_name
  FROM dressmaker d JOIN construction c ON d.d_no = c.maker
  JOIN order_line ol ON (c.order_ref = ol.order_ref AND c.line_ref = ol.line_no)
  JOIN garment g ON ol.ol_style = g.style_no
  WHERE description LIKE '%shorts%'
), temp2 AS (
  SELECT d_name, ROUND(SUM(labour_cost / 4.5), 1) hrs_committed
  FROM dressmaker d JOIN construction c ON d.d_no = c.maker
  JOIN order_line ol ON (c.order_ref = ol.order_ref AND c.line_ref = ol.line_no)
  JOIN dress_order do ON ol.order_ref = do.order_no
  JOIN garment g ON ol.ol_style = g.style_no
  WHERE (finish_date IS NULL)
  GROUP BY d_name
)
SELECT temp1.d_name, COALESCE(hrs_committed, 0) hr_commitment
FROM temp1 LEFT JOIN temp2 ON temp1.d_name = temp2.d_name;


/*
#4) Dressmaker Hard Questions

Q.  "Big spender of the year" is the customer who spends the most on high value items.
    Identify the "Big spender of the year 2002" if the "high value" threshold is set at £30.
    Also who would it be if the threshold was £20 or £50?
*/
WITH tempa AS (
  SELECT c_name, order_ref, line_no, ROUND((labour_cost + quantity * cost), 2) dress_cost
  FROM order_line ol JOIN garment g ON ol.ol_style = g.style_no
  JOIN quantities q ON (ol.ol_style = q.style_q AND ol.ol_size = size_q)
  JOIN material m ON ol.ol_material = m.material_no
  JOIN dress_order do ON ol.order_ref = do.order_no
  JOIN jmcust j ON do.cust_no = j.c_no
  WHERE YEAR(order_date) = 2002
), temp30a AS (
  SELECT c_name big_spender, SUM(dress_cost) total_spent
  FROM tempa
  WHERE dress_cost >= 30
  GROUP BY c_name
  ORDER BY total_spent DESC
), temp30 AS (
  SELECT *, '£30' Threshold
  FROM temp30a
  WHERE total_spent = (SELECT MAX(total_spent) FROM temp30a)
), temp20a AS (
  SELECT c_name big_spender, SUM(dress_cost) total_spent
  FROM tempa
  WHERE dress_cost >= 20
  GROUP BY c_name
  ORDER BY total_spent DESC
), temp20 AS (
  SELECT *, '£20' Threshold
  FROM temp20a
  WHERE total_spent = (SELECT MAX(total_spent) FROM temp20a)
), temp50a AS (
  SELECT c_name big_spender, SUM(dress_cost) total_spent
  FROM tempa
  WHERE dress_cost >= 50
  GROUP BY c_name
  ORDER BY total_spent DESC
), temp50 AS (
  SELECT *, '£50' Threshold
  FROM temp50a
  WHERE total_spent = (SELECT MAX(total_spent) FROM temp50a)
)
(SELECT * FROM temp30) UNION ALL
(SELECT * FROM temp20) UNION ALL
(SELECT * FROM temp50);


/*
#5) Dressmaker Hard Questions

Q.  Who is the fastest at making trousers?
*/
WITH temp1 AS (
  SELECT d_name, ol.order_ref, line_no, start_date, finish_date, DATEDIFF(finish_date, start_date) days_to_cmplte
  FROM order_line ol JOIN garment g ON ol.ol_style = g.style_no
  JOIN construction c ON (ol.order_ref = c.order_ref AND ol.line_no = c.line_ref)
  JOIN dressmaker d ON c.maker = d.d_no
  WHERE (description LIKE '%trousers%') AND (finish_date IS NOT NULL)
)
SELECT d_name, days_to_cmplte
FROM temp1
WHERE days_to_cmplte = (SELECT MIN(days_to_cmplte) FROM temp1);


/*
#6) Dressmaker Hard Questions

Q.  "Employee of the month" is the seamstress who completes the greatest value of clothes.
    Show the "employees of the month" for months in 2002.
*/
WITH temp1 AS (
  SELECT d_name, DATE_FORMAT(finish_date, '%b') month_, SUM(ROUND((labour_cost + quantity * cost), 2)) month_value
  FROM order_line ol JOIN garment g ON ol.ol_style = g.style_no
  JOIN quantities q ON (ol.ol_style = q.style_q AND ol.ol_size = size_q)
  JOIN material m ON ol.ol_material = m.material_no
  JOIN dress_order do ON ol.order_ref = do.order_no
  JOIN construction c ON (ol.order_ref = c.order_ref AND ol.line_no = c.line_ref)
  JOIN dressmaker d ON c.maker = d.d_no
  WHERE (YEAR(order_date) = 2002) AND (finish_date IS NOT NULL)
  GROUP BY d_name, month_
), temp2 AS (
  SELECT *, MAX(month_value) OVER (PARTITION BY month_) month_max_val
  FROM temp1
)
SELECT d_name EmpOfTheMnth, month_, month_value
FROM temp2
WHERE month_value = month_max_val;
