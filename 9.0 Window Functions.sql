/*
Window functions

General Elections were held in the UK in 2015 and 2017.
Every citizen votes in a constituency.
The candidate who gains the most votes becomes MP for that constituency.

All these results are recorded in a table ge
*/



/*
#1) Warming up

Q. Show the lastName, party and votes for the constituency 'S14000024' in 2017.
*/
SELECT lastName, party, votes
FROM ge
WHERE (constituency = 'S14000024') AND (yr = 2017)
ORDER BY votes DESC;


/*
#2) Who won?

You can use the RANK function to see the order of the candidates.
If you RANK using (ORDER BY votes DESC) then the candidate with the most votes has rank 1.

Q. Show the party and RANK for constituency S14000024 in 2017.
   List the output by party.
*/
SELECT party, votes,
  RANK() OVER (ORDER BY votes DESC) rnk
FROM ge
WHERE (constituency = 'S14000024') AND (yr = 2017)
ORDER BY party;


/*
#3) PARTITION BY

The 2015 election is a different PARTITION to the 2017 election.
We only care about the order of votes for each year.

Q. Use PARTITION to show the ranking of each party in S14000021 in each year.
   Include yr, party, votes and ranking (the party with the most votes is 1).
*/
SELECT yr, party, votes,
  RANK() OVER (PARTITION BY yr ORDER BY votes DESC) AS rnk
FROM ge
WHERE constituency = 'S14000021'
ORDER BY party, yr;


/*
#4) Edinburgh Constituency

Edinburgh constituencies are numbered S14000021 to S14000026.

Q. Use PARTITION BY constituency to show the ranking of each party in Edinburgh in 2017.
   Order your results so the winners are shown first, then ordered by constituency.
*/
SELECT constituency, party, votes,
  RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) rnk
FROM ge
WHERE (yr = 2017) AND (constituency BETWEEN 'S14000021' AND 'S14000026')
ORDER BY rnk, constituency;


/*
#5) Winners Only

You can use SELECT within SELECT to pick out only the winners in Edinburgh.

Q. Show the parties that won for each Edinburgh constituency in 2017.
*/
SELECT constituency, party
FROM (
  SELECT constituency, party, votes,
    RANK() OVER (PARTITION BY constituency order by votes desc) rnk
  FROM ge
  WHERE (constituency BETWEEN 'S14000021' AND 'S14000026') AND (yr = 2017)
  ORDER BY constituency, votes DESC
) temp1
WHERE rnk = 1;


/*
#6) Scottish seats

You can use COUNT and GROUP BY to see how each party did in Scotland.
Scottish constituencies start with 'S'.

Q. Show how many seats for each party in Scotland in 2017.
*/
SELECT party, SUM(rnk) seats
FROM (
  SELECT party,
    RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) rnk
  FROM ge
  WHERE (yr = 2017) AND (constituency LIKE 'S%')
) temp1
WHERE rnk = 1
GROUP BY party;
