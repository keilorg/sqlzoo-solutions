/*
Musicians

*/



/*
#1) Musicians Easy Questions

Q. Give the organiser's name of the concert in the Assembly Rooms after the first of Feb, 1997.
*/
SELECT m_name
FROM concert c JOIN musician m ON c.concert_orgniser = m.m_no
WHERE (concert_venue = 'Assembly Rooms') AND (con_date > '01/02/1997');


/*
#2) Musicians Easy Questions

Q. Find all the performers who played guitar or violin and were born in England.
*/
SELECT m_name, instrument
FROM performer p JOIN musician m ON p.perf_is = m.m_no
JOIN place pl ON pl.place_no = m.born_in
WHERE (pl.place_country = 'England') AND
      ((instrument = 'guitar') OR (instrument = 'violin'));


/*
#3) Musicians Easy Questions

Q. List the names of musicians who have conducted concerts in USA together with the towns and dates of these concerts.
*/
SELECT DISTINCT m_name, place_town, con_date
FROM performance p JOIN musician m ON p.conducted_by = m.m_no
JOIN concert c ON p.performed_in = c.concert_no
JOIN place pl ON c.concert_in = pl.place_no
WHERE place_country = 'USA';


/*
#4) Musicians Easy Questions

Q. How many concerts have featured at least one composition by Andy Jones?
   List concert date, venue and the composition's title.
*/
SELECT con_date, concert_venue, c_title
FROM musician m JOIN composer c ON m.m_no = c.comp_is
JOIN has_composed hc ON c.comp_no = hc.cmpr_no
JOIN composition cm ON hc.cmpn_no = cm.c_no
JOIN performance p ON cm.c_no = p.performed
JOIN concert cn ON p.performed_in = cn.concert_no
WHERE m_name = 'Andy Jones'


/*
#5) Musicians Easy Questions

Q. list the different instruments played by the musicians and avg number of musicians who play the instrument.
*/
SELECT m_name, instrument,
  COUNT(m_name) OVER (PARTITION BY instrument) AS total_players
FROM musician m JOIN performer p ON perf_is = m_no
ORDER BY m_name;


/*
#6) Musicians Medium Questions

Q. List the names, dates of birth and the instrument played of living musicians who play a instrument which Theo also plays.
*/
WITH temp1 AS (
  SELECT instrument
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  WHERE m_name = 'Theo Mengel'
)
SELECT DISTINCT m_name, DATE_FORMAT(born, '%d/%m/%y') born, instrument
FROM musician m JOIN performer p ON m.m_no = p.perf_is
JOIN place pl ON pl.place_no = m.born_in
WHERE (instrument IN (SELECT * FROM temp1)) AND (died IS NULL) AND (m_name NOT LIKE '%Theo%');


/*
#7) Musicians Medium Questions

Q. List the name and the number of players for the band whose number of players is greater than
   the average number of players in each band.
*/
WITH temp1 AS (
  SELECT band_name, COUNT(*) cnt
  FROM band b JOIN plays_in pi ON b.band_no = pi.band_id
  GROUP BY band_name
)
SELECT band_name, cnt
FROM temp1
WHERE cnt > (SELECT AVG(cnt) FROM temp1);



/*
#8) Musicians Medium Questions

Q. List the names of musicians who both conduct and compose and live in Britain.
*/
SELECT DISTINCT m_name
FROM musician m JOIN performance p ON m.m_no = p.conducted_by
JOIN composer c ON m.m_no = c.comp_is
JOIN place pl ON m.living_in = pl.place_no
WHERE (place_country = 'England') OR (place_country = 'Scotland');



/*
#9) Musicians Medium Questions

Q. Show the least commonly played instrument and the number of musicians who play it.
*/
WITH temp1 AS (
  SELECT instrument, COUNT(*) cnt
  FROM performer
  GROUP BY instrument
  ORDER BY cnt
)
SELECT *
FROM temp1
WHERE cnt = (SELECT MIN(cnt) FROM temp1);


/*
#10) Musicians Medium Questions

Q. List the bands that have played music composed by Sue Little;
   Give the titles of the composition in each case.
*/
SELECT band_name, c_title
FROM musician m JOIN composer c ON m.m_no = c.comp_is
JOIN has_composed hc ON c.comp_no = hc.cmpr_no
JOIN composition cm ON hc.cmpn_no = cm.c_no
JOIN performance p ON cm.c_no = p.performed
JOIN band b ON p.gave = b.band_no
WHERE m_name = 'Sue Little'
ORDER BY band_name;


/*
#11) Musicians Hard Questions

Q. List the name and town of birth of any performer born in the same city as James First.
*/
WITH temp1 AS (
  SELECT place_town
  FROM musician m JOIN place pl ON m.born_in = pl.place_no
  WHERE m_name = 'James First'
)
SELECT DISTINCT m_name, place_town
FROM musician m JOIN place pl ON m.born_in = pl.place_no
JOIN performer p ON m.m_no = p.perf_is
WHERE (place_town = (SELECT * FROM temp1)) AND
      (m_name != 'James First');


/*
#12) Musicians Hard Questions

Q. Create a list showing for EVERY musician born in Britain the number of compositions and the number of instruments played.
*/
WITH temp1 AS (
  SELECT m_name
  FROM musician m JOIN place pl ON m.born_in = pl.place_no
  WHERE (place_country = 'England') OR
        (place_country = 'Scotland')
), temp2 AS (
SELECT m_name, COUNT(*) comp_cnt
FROM musician m JOIN composer c ON m.m_no = c.comp_is
JOIN has_composed hc ON c.comp_no = hc.cmpr_no
JOIN composition cm ON hc.cmpn_no = cm.c_no
GROUP BY m_name
), temp3 AS (
SELECT m_name, COUNT(*) instr_cnt
FROM musician m JOIN performer p ON m.m_no = p.perf_is
GROUP BY m_name
)
SELECT temp1.m_name, COALESCE(comp_cnt, 0), COALESCE(instr_cnt, 0)
FROM temp1 LEFT JOIN temp2 ON temp1.m_name = temp2.m_name
LEFT JOIN temp3 ON temp1.m_name = temp3.m_name


/*
#13) Musicians Hard Questions

Q.  Give the band name, conductor and contact of the bands performing at the most recent concert in the Royal Albert Hall.
*/
SELECT band_name, m.m_name conductor, m1.m_name contact
FROM concert c JOIN performance p ON c.concert_no = p.performed_in
JOIN band b ON b.band_no = p.gave
JOIN musician m1 ON b.band_contact = m1.m_no
JOIN musician m ON p.conducted_by = m.m_no
WHERE concert_venue = 'Royal Albert Hall';


/*
#14) Musicians Hard Questions

Q.  Give a list of musicians associated with Glasgow.
    Include the name of the musician and the nature of the association -
      one or more of 'LIVES_IN', 'BORN_IN', 'PERFORMED_IN' AND 'IN_BAND_IN'.
*/
(
  SELECT m_name, 'LIVES_IN' association
  FROM musician m JOIN place pl ON m.living_in = pl.place_no
  WHERE pl.place_town = 'Glasgow'
) UNION ALL (
  SELECT m_name, 'BORN_IN' association
  FROM musician m JOIN place pl ON m.born_in = pl.place_no
  WHERE pl.place_town = 'Glasgow'
) UNION ALL (
  SELECT m_name, 'IN_BAND_IN' association
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  JOIN plays_in pi ON p.perf_no = pi.player
  JOIN band b ON pi.band_id = b.band_no
  JOIN place pl ON b.band_home = pl.place_no
  WHERE pl.place_town = 'Glasgow'
) UNION ALL (
  SELECT m_name, 'PERFORMED_IN' association
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  JOIN plays_in pi ON p.perf_no = pi.player
  JOIN performance pf ON pi.band_id = pf.gave
  JOIN concert cn ON pf.performed_in = cn.concert_no
  JOIN place pl ON cn.concert_in = pl.place_no
  WHERE pl.place_town = 'Glasgow'
)
ORDER BY m_name



/*
#15) Musicians Hard Questions

Q.  Jeff Dawn plays in a band with someone who plays in a band with Sue Little.
    Who is it and what are the bands?
*/
WITH temp_jd_bands AS (
  SELECT m_name, band_id
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  JOIN plays_in pi ON p.perf_no = pi.player
  JOIN band b ON pi.band_id = b.band_no
  JOIN place pl ON b.band_home = pl.place_no
  WHERE m_name = 'Jeff Dawn'
), temp_sl_bands AS (
  SELECT m_name, band_id
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  JOIN plays_in pi ON p.perf_no = pi.player
  JOIN band b ON pi.band_id = b.band_no
  JOIN place pl ON b.band_home = pl.place_no
  WHERE m_name = 'Sue Little'
)
  SELECT m.m_name, pi.band_id, t.m_name, s.m_name
  FROM musician m JOIN performer p ON m.m_no = p.perf_is
  JOIN plays_in pi ON p.perf_no = pi.player
  JOIN band b ON pi.band_id = b.band_no
  JOIN place pl ON b.band_home = pl.place_no
  LEFT JOIN temp_jd_bands t ON pi.band_id = t.band_id
  LEFT JOIN temp_sl_bands s ON pi.band_id = s.band_id
  WHERE (t.m_name IS NOT NULL) AND (s.m_name IS NOT NULL)
  ORDER BY m.m_name, pi.band_id
