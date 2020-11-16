/*
White Christmas

The HadCET data is "the longest available instrumental record of temperature in the world", currently available from the UK Met Office.
It provides the daily mean temperature for the centre of England since 1772.
*/



/*
#1) Days, Months and Years

The units are 10th of a degree Celcius.
The columns are yr and dy for year and day of month.
The next twelve columns are for January through to December.

Q. Show the average daily temperature for August 10th 1964
*/
SELECT m8 / 10 Aug_10th_1964
FROM hadcet
WHERE (yr = 1964) AND (dy = 10)


/*
#2) preteen Dickens

Charles Dickens is said to be responsible for the tradition of expecting snow at Christmas Daily Telegraph.
Show the temperature on Christmas day (25th December) for each year of his childhood.
He was born in February 1812 - so he was 1 (more or less) in December 1812.

Q. Show the twelve temperatures.
*/
SELECT yr-1811 age, m12 / 10 temp
FROM hadcet
WHERE (dy = 25) AND (yr BETWEEN 1812 AND 1823);


/*
#3) Minimum Temperature Before Christmas

We declare a White Christmas if there was a day with an average temperature below zero between 21st and 25th of December.

Q. For each age 1-12 show which years were a White Christmas.
   Show 'White Christmas' or 'No snow' for each age.
*/
WITH temp1 AS (
  SELECT yr-1811 age, dy, m12 / 10 temp, IF(m12 < 0, 1, 0) snow
  FROM hadcet
  WHERE (dy IN (21, 22, 23, 24, 25)) AND (yr BETWEEN 1812 AND 1823)
), temp2 AS (
  SELECT age, SUM(snow) white_xmas
  FROM temp1
  GROUP BY age
)
SELECT age, IF(white_xmas > 0, 'White Christmas', 'No Snow') Xmas_Snow
FROM temp2


/*
#4) White Christmas Count

A person's White Christmas Count (wcc) is the number of White Christmases they were exposed to as a child
(between 3 and 12 inclusive assuming they were born at the beginning of the year and were about 1 year old on their first Christmas).

Charles Dickens's wcc was 8.

Q. List all the years and the wcc for children born in each year of the data set.
   Only show years where the wcc was at least 7.

   (Note: Smiley-face answer on SQLzoo is incorrect. It requires "m12 <= 0" in the first SELECT
    statement in the answer below. The answer below is technically correct.)
*/
WITH temp1 AS (
  SELECT yr, dy, m12 / 10 temp, IF(m12 < 0, 1, 0) snow
  FROM hadcet
  WHERE dy BETWEEN 21 AND 25
), temp2 AS (
  SELECT yr, SUM(snow) white_xmas_a
  FROM temp1
  GROUP BY yr
), temp3 AS (
  SELECT yr, IF(white_xmas_a > 0, 1, 0) white_xmas
  FROM temp2
), temp4 AS (
  SELECT yr, (SELECT SUM(white_xmas) FROM temp3 WHERE temp3.yr BETWEEN t.yr+2 AND t.yr+11) wcc
  FROM temp3 t
)
SELECT *
FROM temp4
WHERE wcc > 6;
