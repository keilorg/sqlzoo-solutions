/*
The JOIN Operation

This tutorial introduces JOIN which allows you to use data from two or more tables.
The tables contain all matches and goals from UEFA EURO 2012 Football Championship in Poland and Ukraine.
The data is available (mysql format) at http://sqlzoo.net/euro2012.sql
*/



/*
#1)

Q. Show the matchid and player name for all goals scored by Germany.
   To identify German players, check for: teamid = 'GER'
*/
SELECT matchid, player
FROM goal
WHERE teamid = 'GER';


/*
#2)

Q. Show id, stadium, team1, team2 for just game 1012.
*/
SELECT id, stadium, team1, team2
FROM game
WHERE id = 1012;


/*
#3)

Q. Show the player, teamid, stadium and mdate for every German goal.
*/
SELECT player, teamid, stadium, mdate
FROM game JOIN goal ON game.id = goal.matchid
WHERE teamid = 'GER';


/*
#4)

Q. Show the team1, team2 and player for every goal scored by a player called Mario
*/
SELECT team1, team2, player
FROM goal JOIN game ON goal.matchid = game.id
WHERE player LIKE 'Mario%';


/*
#5)

Q. Show player, teamid, coach, gtime for all goals scored in the first 10 minutes gtime<=10
*/
SELECT player, teamid, coach, gtime
FROM goal JOIN eteam ON goal.teamid = eteam.id
WHERE gtime <= 10;


/*
#6)

Q. List the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach.
*/
SELECT mdate, teamname
FROM game JOIN eteam ON game.team1 = eteam.id
WHERE coach = 'Fernando Santos';


/*
#7)

Q. List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'
*/
SELECT player
FROM goal JOIN game ON game.id = goal.matchid
WHERE stadium = 'National Stadium, Warsaw';


/*
#8) More difficult questions

Q. Show the name of all players who scored a goal against Germany.
*/
SELECT DISTINCT(player) players
FROM game JOIN goal ON matchid = id
WHERE (team1 = 'GER' OR team2 = 'GER') AND (teamid != 'GER');


/*
#9) More difficult questions

Q. Show teamname and the total number of goals scored.
*/
SELECT teamname, COUNT(player) goals
FROM eteam JOIN goal ON id = teamid
GROUP BY teamname
ORDER BY teamname;


/*
#10) More difficult questions

Q. Show the stadium and the number of goals scored in each stadium.
*/
SELECT stadium, COUNT(matchid) goals
FROM game JOIN goal ON game.id = goal.matchid
GROUP BY stadium;


/*
#11) More difficult questions

Q. For every match involving 'POL', show the matchid, date and the number of goals scored.
*/
SELECT matchid, mdate, COUNT(teamid) goals
FROM game JOIN goal ON matchid = id
WHERE (team1 = 'POL' OR team2 = 'POL')
GROUP BY matchid, mdate;


/*
#12) More difficult questions

Q. For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'.
*/
SELECT matchid, mdate, COUNT(gtime) goals_GER
FROM goal JOIN game ON game.id = goal.matchid
WHERE teamid = 'GER'
GROUP BY matchid, mdate;


/*
#13) More difficult questions

Q. List every match with the goals scored by each team as shown.

   Notice in the query given every goal is listed.
   If it was a team1 goal then a 1 appears in score1, otherwise there is a 0.

   Sort your result by mdate, matchid, team1 and team2.
*/
SELECT mdate, team1,
  SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END) score1,
  team2,
  SUM(CASE WHEN teamid=team2 THEN 1 ELSE 0 END) score2
FROM game LEFT JOIN goal ON matchid = id
GROUP BY mdate, team1, team2
ORDER BY mdate, matchid, team1, team2;
