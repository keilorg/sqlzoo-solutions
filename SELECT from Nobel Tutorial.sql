/*
nobel Nobel Laureates
We continue practicing simple SQL queries on a single table.
This tutorial is concerned with a table of Nobel prize winners: nobel(yr, subject, winner)
Using the SELECT statement.
*/



/*
#1) Winners from 1950

Q. Change the query shown so that it displays Nobel prizes for 1950.
*/
SELECT yr, subject, winner
FROM nobel
WHERE yr = 1950;


/*
#2) 1962 Literature

Q. Show who won the 1962 prize for Literature.
*/
SELECT winner
FROM nobel
WHERE yr = 1962 AND subject = 'Literature';


/*
#3) Albert Einstein

Q. Show the year and subject that won 'Albert Einstein' his prize.
*/
SELECT yr, subject
FROM nobel
WHERE winner = 'Albert Einstein';


/*
#4) Recent Peace Prizes

Q. Give the name of the 'Peace' winners since the year 2000, including 2000.
*/
SELECT winner
FROM nobel
WHERE subject = 'Peace' AND yr >= 2000;


/*
#5) Literature in the 1980's

Q. Show all details (yr, subject, winner) of the Literature prize winners for 1980 to 1989 inclusive.
*/
SELECT *
FROM nobel
WHERE (subject = 'Literature') AND (yr BETWEEN 1980 AND 1989);


/*
#6) Only Presidents

Q. Show all details of the presidential winners:
   - Theodore Roosevelt
   - Woodrow Wilson
   - Jimmy Carter
   - Barack Obama
*/
SELECT *
FROM nobel
WHERE winner IN ('Theodore Roosevelt', 'Woodrow Wilson', 'Jimmy Carter', 'Barack Obama');


/*
#7) John

Q. Show the winners with first name John
*/
SELECT winner
FROM nobel
WHERE LEFT(winner, 4) = 'John';


/*
#8) Chemistry and Physics from different years

Q. Show the year, subject, and name of Physics winners for 1980 together with the Chemistry winners for 1984.
*/
SELECT yr, subject, winner
FROM nobel
WHERE (subject = 'Physics' AND yr = 1980) OR
      (subject = 'Chemistry' AND yr = 1984);


/*
#9) Exclude Chemists and Medics

Q. Show the year, subject, and name of winners for 1980 excluding Chemistry and Medicine
*/
SELECT yr, subject, winner
FROM nobel
WHERE (yr = 1980) AND (subject NOT IN ('Chemistry', 'Medicine'));


/*
#10) Early Medicine, Late Literature

Q. Show year, subject, and name of people who won a 'Medicine' prize in an early year (before 1910, not including 1910),
   together with winners of a 'Literature' prize in a later year (after 2004, including 2004).
*/
SELECT yr, subject, winner
FROM nobel
WHERE (subject = 'Medicine' AND yr < 1910) OR (subject = 'Literature' AND yr >= 2004);


/*
#11) Umlaut

Q. Find all details of the prize won by PETER GRÜNBERG.
*/
SELECT *
FROM nobel
WHERE winner = 'PETER GRÜNBERG';


/*
#12) Apostrophe

Q. Find all details of the prize won by EUGENE O'NEILL.
*/
SELECT *
FROM nobel
WHERE winner = 'EUGENE O''NEILL';


/*
#13) Knights of the realm

Knights in order

Q. List the winners, year and subject where the winner starts with Sir.
   Show the the most recent first, then by name order.
*/
SELECT winner, yr, subject
FROM nobel
WHERE LEFT(winner, 3) = 'Sir'
ORDER BY yr DESC, winner


/*
#14) Chemistry and Physics last

The expression subject IN ('Chemistry','Physics') can be used as a value - it will be 0 or 1.

Q. Show the 1984 winners and subject ordered by subject and winner name; but list Chemistry and Physics last.
*/
SELECT winner, subject
FROM nobel
WHERE yr = 1984
ORDER BY (subject IN ('Chemistry', 'Physics')), subject, winner;
