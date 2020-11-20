/*
SELECT names

This tutorial uses the LIKE operator to check names.
We will be using the SELECT command on the table world.
*/


/*
#1)

Q. Find the country that start with Y
*/
SELECT name
FROM world
WHERE name LIKE 'Y%';


/*
#2)

Q. Find the countries that end with y
*/
SELECT name
FROM world
WHERE name LIKE '%y';


/*
#3)

Luxembourg has an x - so does one other country.
List them both.

Q. Find the countries that contain the letter x
*/
SELECT name
FROM world
WHERE name like '%x%';


/*
#4)

Iceland, Switzerland end with land - but are there others?

Q. Find the countries that end with land
*/
SELECT name
FROM world
WHERE name LIKE '%land';


/*
#5)

Columbia starts with a C and ends with ia - there are two more like this.

Q. Find the countries that start with C and end with ia
*/
SELECT name
FROM world
WHERE name LIKE 'C%ia';


/*
#6)

Greece has a double e - who has a double o?

Q. Find the country that has oo in the name
*/
SELECT name
FROM world
WHERE name LIKE '%oo%';


/*
#7)

Bahamas has three a - who else?

Q. Find the countries that have three or more a in the name
*/
SELECT name
FROM world
WHERE name LIKE '%a%a%a%';


/*
#8)

Q. Find the countries that have "t" as the second character.
*/
SELECT name
FROM world
WHERE name LIKE '_t%'
ORDER BY name;


/*
#9)

Q. Find the countries that have two "o" characters separated by two others.
*/
SELECT name
FROM world
WHERE name LIKE '%o__o%';


/*
#10)

Q. Find the countries that have exactly four characters.
*/
SELECT name
FROM world
WHERE LENGTH(name) = 4;


/*
#11)

Q. The capital of Luxembourg is Luxembourg.
   Show all the countries where the capital is the same as the name of the country.
*/
SELECT name
FROM world
WHERE name = capital;


/*
#12)

The capital of Mexico is Mexico City.
Show all the countries where the capital has the country together with the word "City".

Q. Find the country where the capital is the country plus "City".
*/
SELECT name
FROM world
WHERE capital = CONCAT(name, ' City');


/*
#13)

Q. Find the capital and the name where the capital includes the name of the country.
*/
SELECT capital, name
FROM world
WHERE capital LIKE CONCAT('%',name,'%');


/*
#14)

Q. Find the capital and the name where the capital is an extension of name of the country.
   You should include Mexico City as it is longer than Mexico.
   You should not include Luxembourg as the capital is the same as the country.
*/
SELECT capital, name
FROM world
WHERE (capital LIKE CONCAT(name,'%')) AND (capital != name);


/*
#15)

For Monaco-Ville the name is Monaco and the extension is -Ville.

Q. Show the name and the extension where the capital is an extension of name of the country.
*/
SELECT name, REPLACE(capital, name, '') extension
FROM world
WHERE (capital LIKE CONCAT(name,'%')) AND capital != name;
