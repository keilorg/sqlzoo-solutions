/*
SELECT within SELECT Tutorial

This tutorial looks at how we can use SELECT statements within SELECT statements to perform more complex queries.
*/



/*
#1) Bigger than Russia

world(name, continent, area, population, gdp)

Q. List each country name where the population is larger than that of 'Russia'.
*/
SELECT name
FROM world
WHERE population > (
  SELECT population FROM world
  WHERE name='Russia');


/*
#2) Richer than UK

Q. Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.
*/
SELECT name
FROM world
WHERE (continent = 'Europe') AND (gdp/population > (
  SELECT gdp/population
  FROM world
  WHERE name = 'United Kingdom'));


/*
#3) Neighbours of Argentina and Australia

Q. List the name and continent of countries in the continents containing either Argentina or Australia.
   Order by name of the country.
*/
SELECT name, continent
FROM world
WHERE continent IN (
  SELECT continent
  FROM world
  WHERE name IN ('Argentina', 'Australia'))
ORDER BY name;


/*
#4) Between Canada and Poland

Q. Which country has a population that is more than Canada but less than Poland?
   Show the name and the population.
*/
SELECT name, population
FROM world
WHERE (population > (SELECT population FROM world WHERE name = 'Canada'))
  AND (population < (SELECT population FROM world WHERE name = 'Poland'));


/*
#5) Percentages of Germany

Germany (population 80 million) has the largest population of the countries in Europe.
Austria (population 8.5 million) has 11% of the population of Germany.

Q. Show the name and the population of each country in Europe.
   Show the population as a percentage of the population of Germany.
*/
SELECT name, CONCAT(ROUND(population / (
  SELECT population
  FROM world
  WHERE name='Germany')*100, 0),'%') percentage
FROM world
WHERE continent = 'Europe';


/*
#6) Bigger than every country in Europe

Q. Which countries have a GDP greater than every country in Europe? [Give the name only.]
   (Some countries may have NULL gdp values)
*/
SELECT name
FROM world
WHERE gdp > (
  SELECT MAX(gdp)
  FROM world
  WHERE continent = 'Europe');


/*
#7) Largest in each continent

Q. Find the largest country (by area) in each continent, show the continent, the name and the area.
*/
SELECT continent, name, area
FROM world y
WHERE area = (
  SELECT MAX(area)
  FROM world x
  WHERE y.continent = x.continent);


/*
#8) First country of each continent (alphabetically)

Q. List each continent and the name of the country that comes first alphabetically.
*/
SELECT continent, name
FROM world x
WHERE name = (
  SELECT MIN(name)
  FROM world y
  WHERE x.continent = y.continent);


/*
#9) Difficult Questions That Utilize Techniques Not Covered In Prior Sections

Q. Find the continents where all countries have a population <= 25000000.
   Then find the names of the countries associated with these continents.
   Show name, continent and population.
*/
SELECT name, continent, population
FROM world
WHERE continent IN (
  SELECT continent
  FROM world
  GROUP BY continent
  HAVING MAX(population) <= 25000000);


/*
#10) Difficult Questions That Utilize Techniques Not Covered In Prior Sections

Some countries have populations more than three times that of any of their neighbours (in the same continent).

Q. Give these countries and continents.
*/
SELECT name, continent
FROM world y
WHERE (population = (
         SELECT MAX(population)
         FROM world x
         WHERE y.continent = x.continent))
  AND (population > (
         SELECT 3*MAX(population)
         FROM world z
         WHERE (y.continent = z.continent) AND (y.population != z.population)));
