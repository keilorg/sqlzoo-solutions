/*
Neeps

The "Neeps" database includes details of all teaching events in the School of Computing at Napier University in Semester 1 of the 2000/2001 academic year.

*/



/*
#1) Neeps Easy Questions

Q. Give the room id in which the event co42010.L01 takes place.
*/
SELECT room
FROM event
WHERE id = 'co42010.L01';


/*
#2) Neeps Easy Questions

Q. For each event in module co72010 show the day, the time and the place.
*/
SELECT id, dow, tod, room
FROM event
WHERE modle = 'co72010';


/*
#3) Neeps Easy Questions

Q. List the names of the staff who teach on module co72010.
*/
SELECT DISTINCT name
FROM staff s JOIN teaches t ON s.id = t.staff
JOIN event e ON t.event = e.id
WHERE modle = 'co72010';


/*
#4) Neeps Easy Questions

Q. Give a list of the staff and module number associated with events using room cr.132 on Wednesday,
   include the time each event starts.
*/
SELECT name, modle, tod
FROM staff s JOIN teaches t ON s.id = t.staff
JOIN event e ON t.event = e.id
WHERE (room = 'cr.132') AND (dow = 'Wednesday');


/*
#5) Neeps Easy Questions

Q. Give a list of the student groups which take modules with the word 'Database' in the name.
*/
SELECT DISTINCT s.name
FROM student s JOIN attends a ON s.id = a.student
JOIN event e ON a.event = e.id
JOIN modle m ON e.modle = m.id
WHERE m.name LIKE '%database%';


/*
#6) Neeps Medium Questions

Q. Show the 'size' of each of the co72010 events.
   Size is the total number of students attending each event.
*/
SELECT e.id, SUM(sze) size
FROM student s JOIN attends a ON s.id = a.student
JOIN event e ON a.event = e.id
WHERE modle = 'co72010'
GROUP BY e.id;


/*
#7) Neeps Medium Questions

Q. For each post-graduate module, show the size of the teaching team.
   (post graduate modules start with the code co7).
*/
SELECT modle, COUNT(DISTINCT staff) staff_count
FROM teaches t JOIN event e ON t.event = e.id
WHERE LEFT(modle, 3) = 'co7'
GROUP BY modle;


/*
#8) Neeps Medium Questions

Q. Give the full name of those modules which include events taught for fewer than 10 weeks.
*/
SELECT DISTINCT name
FROM (
  SELECT m.name, e.id, COUNT(e.id) week_ct
  FROM event e JOIN occurs o ON e.id = o.event
  JOIN modle m ON e.modle = m.id
  GROUP BY m.name, e.id
  HAVING week_ct < 10) temp1;


/*
#9) Neeps Medium Questions

Q. Identify those events which start at the same time as one of the co72010 lectures.
*/
WITH temp1 AS (
  SELECT DISTINCT CONCAT(dow, tod) start_time
  FROM event
  WHERE modle = 'co72010'
)
SELECT id
FROM event
WHERE CONCAT(dow, tod) IN (SELECT start_time FROM temp1);


/*
#10) Neeps Medium Questions

Q. How many members of staff have contact time which is greater than the average?
*/
WITH temp1 AS (
  SELECT staff, SUM(duration) staff_hrs
  FROM teaches t JOIN event e ON t.event = e.id
  GROUP BY staff
)
SELECT COUNT(*) staff_count
FROM temp1
WHERE staff_hrs > (SELECT AVG(staff_hrs) FROM temp1);


/*
#11) Neeps Hard Questions

Q. co.CHt is to be given all the teaching that co.ACg currently does.
   Identify those events which will clash.
*/
WITH acg AS (
  SELECT id, dow, tod, duration, week, tod start_time, tod + duration end_time
  FROM teaches t JOIN event e ON t.event = e.id
  JOIN occurs o ON e.id = o.event
  WHERE staff = 'co.ACg'
), cht AS (
  SELECT id, dow, tod, duration, week, tod start_time, tod + duration end_time
  FROM teaches t JOIN event e ON t.event = e.id
  JOIN occurs o ON e.id = o.event
  WHERE staff = 'co.CHt'
)
SELECT DISTINCT cht.id cht_id, acg.id acg_id
FROM cht CROSS JOIN acg
WHERE (cht.week = acg.week AND cht.dow = acg.dow) AND
      ((cht.start_time >= acg.start_time AND cht.start_time < acg.end_time) OR
       (acg.start_time >= cht.start_time AND acg.start_time < cht.end_time));


/*
#12) Neeps Hard Questions

Q. Produce a table showing the utilisation rate and the occupancy level for all rooms with a capacity more than 60.
*/
WITH temp1 AS (
  SELECT r.id, r.capacity, o.event, o.week, e.dow, tod, SUM(s.sze) class_size
  FROM room r JOIN event e ON r.id = e.room
  JOIN attends a ON e.id = a.event
  JOIN student s ON a.student = s.id
  JOIN occurs o ON e.id = o.event
  WHERE capacity > 60
  GROUP BY r.id, r.capacity, o.week, e.dow, o.event, tod
  ORDER BY o.week, e.dow, tod, o.event
)
SELECT *, CONCAT(ROUND(class_size / capacity * 100, 0), '%') utlization
FROM temp1;


/*
#1) Neeps Resit Questions

Q.  Give the day and the time of the event co72002.L01.
*/
SELECT dow, tod
FROM event
WHERE id = 'co72002.L01';


/*
#2) Neeps Resit Questions

Q.  For each event in module co72003 show the day, the time and the place.
*/
SELECT id, dow, tod, room
FROM event
WHERE modle = 'co72003';


/*
#3) Neeps Resit Questions

Q.  List the id of the events taught by 'Chisholm, Ken'.
*/
SELECT DISTINCT e.id
FROM staff s JOIN teaches t ON s.id = t.staff
JOIN event e ON t.event = e.id
WHERE name = 'Chisholm, Ken';


/*
#4) Neeps Resit Questions

Q.  List the staff who teach in cr.SMH.
*/
SELECT DISTINCT s.name
FROM staff s JOIN teaches t ON s.id = t.staff
JOIN event e ON t.event = e.id
WHERE room = 'cr.SMH';


/*
#5) Neeps Resit Questions

Q.  Show the total number of hours (over the whole semester) of classes for com.IS.a
*/
SELECT SUM(duration) total_hrs
FROM student s JOIN attends a ON s.id = a.student
JOIN event e ON a.event = e.id
JOIN occurs o ON e.id = o.event
WHERE s.id LIKE '%com.IS.a%';
