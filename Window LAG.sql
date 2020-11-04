/*
Window LAG

COVID-19 Data

Notes on the data: This data was assembled based on work done by Rodrigo Pombo based on John Hopkins University, based on World Health Organisation.
The data was assembled 21st April 2020 - there are no plans to keep this data set up to date.
*/



/*
#1) Introducing the covid table

The example uses a WHERE clause to show the cases in 'Italy' in March.

Q. Modify the query to show data from Spain.
*/
SELECT name, DAY(whn),
 confirmed, deaths, recovered
 FROM covid
WHERE name = 'Spain'
AND MONTH(whn) = 3
ORDER BY whn;


/*
#2) Introducing the LAG function

The LAG function is used to show data from the preceding row or the table.
When lining up rows the data is partitioned by country name and ordered by the data whn.
That means that only data from Italy is considered.

Q. Modify the query to show confirmed for the day before.
*/
SELECT name, DAY(whn), confirmed,
  LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3
ORDER BY whn;


/*
#3) Number of new cases

The number of confirmed case is cumulative - but we can use LAG to recover the number of new cases reported for each day.

Q. Show the number of new cases for each day, for Italy, for March.
*/
SELECT name, DAY(whn),
  (confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)) AS day_count
FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3
ORDER BY whn;


/*
#4) Weekly changes

The data gathered are necessarily estimates and are inaccurate.
However by taking a longer time span we can mitigate some of the effects.
You can filter the data to view only Monday's figures WHERE WEEKDAY(whn) = 0.

Q. Show the number of new cases in Italy for each week - show Monday only.
*/
SELECT name, DATE_FORMAT(whn,'%Y-%m-%d'),
  confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS week_count
FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0
ORDER BY whn;


/*
#5) LAG using a JOIN

You can JOIN a table using DATE arithmetic.
This will give different results if data is missing.

Q. Show the number of new cases in Italy for each week - show Monday only.
*/
SELECT tw.name, DATE_FORMAT(tw.whn,'%Y-%m-%d'),
  (tw.confirmed - lw.confirmed) week_count
FROM covid tw LEFT JOIN covid lw ON
  (DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn AND tw.name=lw.name)
WHERE tw.name = 'Italy' AND WEEKDAY(tw.whn)=0
ORDER BY tw.whn


/*
#6) RANK()

The query shown shows the number of confirmed cases together with the world ranking for cases.
United States has the highest number, Spain is number 2...
Notice that while Spain has the second highest confirmed cases, Italy has the second highest number of deaths due to the virus.

Q. Include the ranking for the number of deaths in the table.
*/
SELECT name, confirmed,
  RANK() OVER (ORDER BY confirmed DESC) rc,
deaths,
  RANK() OVER (ORDER BY deaths DESC) rd
FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC;
