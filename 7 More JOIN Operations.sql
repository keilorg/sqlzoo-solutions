/*
More JOIN operations

This tutorial introduces the notion of a join.
The database consists of three tables - movie, actor, casting.
*/



/*
#1) 1962 movies

Q. List the films where the yr is 1962 [Show id, title]
*/
SELECT id, title
FROM movie
WHERE yr = 1962;


/*
#2) When was Citizen Kane released?

Q. Give year of 'Citizen Kane'.
*/
SELECT yr
FROM movie
WHERE title = 'Citizen Kane';


/*
#3) Star Trek movies

Q. List all of the Star Trek movies, include the id, title and yr (all of these movies include the words Star Trek in the title).
   Order results by year.
*/
SELECT id, title, yr
FROM movie
WHERE title LIKE 'Star Trek%'
ORDER BY yr;


/*
#4) id for actor Glenn Close

Q. What id number does the actor 'Glenn Close' have?
*/
SELECT id
FROM actor
WHERE name = 'Glenn Close';


/*
#5) id for Casablanca

Q. What is the id of the film 'Casablanca'?
*/
SELECT id
FROM movie
WHERE title = 'Casablanca';


/*
#6) Cast list for Casablanca

Q. Obtain the cast list for 'Casablanca'.
   Use movieid=11768, (or whatever value you got from the previous question)
*/
SELECT *
FROM nobel
WHERE winner IN ('Theodore Roosevelt', 'Woodrow Wilson', 'Jimmy Carter', 'Barack Obama');


/*
#7) Alien cast list

Q. Obtain the cast list for the film 'Alien'
*/
SELECT actor.name
FROM movie JOIN casting ON movie.id = casting.movieid
JOIN actor ON casting.actorid = actor.id
WHERE movie.title = 'Alien';


/*
#8) Harrison Ford movies

Q. List the films in which 'Harrison Ford' has appeared.
*/
SELECT movie.title
FROM movie JOIN casting ON movie.id = casting.movieid
JOIN actor ON casting.actorid = actor.id
WHERE actor.name = 'Harrison Ford';


/*
#9) Harrison Ford as a supporting actor

Q. List the films where 'Harrison Ford' has appeared - but not in the starring role.
   [Note: the ord field of casting gives the position of the actor. If ord=1 then this actor is in the starring role]
*/
SELECT movie.title
FROM movie JOIN casting ON movie.id = casting.movieid
JOIN actor ON casting.actorid = actor.id
WHERE (actor.name = 'Harrison Ford') AND (casting.ord != 1);


/*
#10) Lead actors in 1962 movies

Q. List the films together with the leading star for all 1962 films.
*/
SELECT movie.title, actor.name
FROM movie JOIN casting ON movie.id = casting.movieid
JOIN actor ON casting.actorid = actor.id
WHERE (movie.yr = 1962) AND (casting.ord = 1);


/*
#11) Busy years for Rock Hudson

Q. Which were the busiest years for 'Rock Hudson'?
   Show the year and the number of movies he made each year for any year in which he made more than 2 movies.
*/
SELECT yr, COUNT(title) movie_count
FROM movie JOIN casting ON movie.id = movieid
JOIN actor ON actorid = actor.id
WHERE name = 'Rock Hudson'
GROUP BY yr
HAVING COUNT(title) > 2;


/*
#12) Lead actor in Julie Andrews movies

Q. List the film title and the leading actor for all of the films 'Julie Andrews' played in.
*/
SELECT title, name
FROM movie JOIN casting ON movie.id = casting.movieid
JOIN actor ON casting.actorid = actor.id
WHERE (ord = 1) AND (movieid IN (
  SELECT movieid
  FROM casting y
  JOIN actor ON casting.actorid = actor.id
  WHERE name = 'Julie Andrews'));


/*
#13) Actors with 15 leading roles

Q. Obtain a list, in alphabetical order, of actors who've had at least 15 starring roles.
*/
SELECT actor.name
FROM casting JOIN actor ON casting.actorid = actor.id
WHERE casting.ord = 1
GROUP BY actor.name
HAVING COUNT(actor.name) >= 15
ORDER BY actor.name;


/*
#14)

Q. List the films released in the year 1978 ordered by the number of actors in the cast, then by title.
*/
SELECT movie.title, COUNT(movie.title) actor_count
FROM movie JOIN casting ON movie.id = casting.movieid
WHERE movie.yr = 1978
GROUP BY movie.title
ORDER BY COUNT(movie.title) DESC, movie.title;


/*
#15)

Q. List all the people who have worked with 'Art Garfunkel'.
*/
SELECT actor.name
FROM casting JOIN actor ON casting.actorid = actor.id
WHERE (actor.name != 'Art Garfunkel') AND (casting.movieid IN (
  SELECT casting.movieid
  FROM casting JOIN actor ON casting.actorid = actor.id
  WHERE actor.name = 'Art Garfunkel'));
