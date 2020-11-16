/*
Congestion Charge

*/



/*
#1) Congestion Charge Easy Questions

Q. Show the name and address of the keeper of vehicle SO 02 PSP.
*/
SELECT name, address
FROM keeper k JOIN vehicle v ON k.id = v.keeper
WHERE v.id = 'SO 02 PSP';


/*
#2) Congestion Charge Easy Questions

Q. Show the number of cameras that take images for incoming vehicles.
*/
SELECT COUNT(*) cnt
FROM camera
WHERE perim = 'IN';


/*
#3) Congestion Charge Easy Questions

Q. List the image details taken by Camera 10 before 26 Feb 2007.
*/
SELECT *
FROM image
WHERE (camera = 10) AND (DATE_FORMAT(whn, '%y-%m-%d') < '07-02-26');


/*
#4) Congestion Charge Easy Questions

Q. List the number of images taken by each camera.
   Your answer should show how many images have been taken by camera 1, camera 2 etc.
   The list must NOT include the images taken by camera 15, 16, 17, 18 and 19.
*/
SELECT camera, COUNT(*) image_count
FROM image
WHERE camera < 15
GROUP BY camera;


/*
#5) Congestion Charge Easy Questions

Q. A number of vehicles have permits that start on 30th Jan 2007.
   List the name and address for each keeper in alphabetical order without duplication.
*/
SELECT DISTINCT name, address
FROM permit p JOIN vehicle v ON p.reg = v.id
JOIN keeper k ON v.keeper = k.id
WHERE DATE_FORMAT(sDate, '%y-%m-%d') = '07-01-30'
ORDER BY name;


/*
#1) Congestion Charge Medium Questions

Q. List the owners (name and address) of Vehicles caught by camera 1 or 18 without duplication.
*/
SELECT DISTINCT name, address
FROM keeper k JOIN vehicle v ON k.id = v.keeper
JOIN image i ON v.id = i.reg
WHERE (camera = 1) OR (camera = 18);


/*
#2) Congestion Charge Medium Questions

Q. Show keepers (name and address) who have more than 5 vehicles.
*/
SELECT name, address, COUNT(*) vehicle_count
FROM keeper k JOIN vehicle v ON k.id = v.keeper
GROUP BY name, address
HAVING vehicle_count > 5;



/*
#3) Congestion Charge Medium Questions

Q. For each vehicle show the number of current permits (suppose today is the 1st of Feb 2007).
   The list should include the vehicle.s registration and the number of permits.
   Current permits can be determined based on charge types,
   e.g. for weekly permit you can use the date after 24 Jan 2007 and before 02 Feb 2007.
*/
WITH temp1 AS (
  SELECT reg, DATE_FORMAT(sDate, '%Y-%m-%d') sDate, chargeType, DATE_FORMAT(CASE
    WHEN chargeType = 'Daily' THEN DATE_ADD(sDate, INTERVAL 1 DAY)
    WHEN chargeType = 'Weekly' THEN DATE_ADD(sDate, INTERVAL 1 WEEK)
    WHEN chargeType = 'Monthly' THEN DATE_ADD(sDate, INTERVAL 1 MONTH)
    WHEN chargeType = 'Annual' THEN DATE_ADD(sDate, INTERVAL 1 YEAR)
    ELSE '' END, '%Y-%m-%d') AS fDate
  FROM vehicle v JOIN permit p ON v.id = p.reg
)
SELECT reg, COUNT(*) current_permit_count
FROM temp1
WHERE ('2007-02-01' >= sDate) AND ('2007-02-01' < fDate)
GROUP BY reg;



/*
#4) Congestion Charge Medium Questions

Q. Obtain a list of every vehicle passing camera 10 on 25th Feb 2007.
   Show the time, the registration and the name of the keeper if available.
*/
SELECT DATE_FORMAT(whn, '%H:%i:%s') time, reg, name
FROM image i JOIN vehicle v ON i.reg = v.id
JOIN keeper k ON v.keeper = k.id
WHERE (camera = 10) AND (DATE_FORMAT(whn, '%Y-%m-%d') = '2007-02-25');


/*
#5) Congestion Charge Medium Questions

Q. List the keepers who have more than 4 vehicles and one of them must have more than 2 permits.
   The list should include the names and the number of vehicles.
*/
WITH temp1 AS (
  SELECT name, v.id, COUNT(*) permit_count
  FROM vehicle v JOIN permit p ON v.id = p.reg
  JOIN keeper k ON v.keeper = k.id
  GROUP BY name, v.id
  HAVING permit_count > 2
), temp2 AS (
  SELECT name, COUNT(*) vehicle_count
  FROM keeper k JOIN vehicle v ON v.keeper = k.id
  GROUP BY name
  HAVING vehicle_count > 4
)
SELECT temp1.name, vehicle_count, permit_count
FROM temp1 JOIN temp2 ON temp1.name = temp2.name;


/*
#2) Congestion Charge Hard Questions

Q. There are four types of permit.
   The most popular type means that this type has been issued the highest number of times.
   Find out the most popular type, together with the total number of permits issued.
*/
WITH temp1 AS (
  SELECT chargeType, COUNT(*) permit_count
  FROM vehicle v JOIN permit p ON v.id = p.reg
  GROUP BY chargeType
)
SELECT *
FROM temp1
WHERE permit_count = (SELECT MAX(permit_count) FROM temp1)


/*
#3) Congestion Charge Hard Questions

Q.  For each of the vehicles caught by camera 19 - show the registration,
     the earliest time at camera 19 and the time and camera at which it left the zone.
*/
WITH temp0 AS (
  SELECT reg, MIN(whn) first_capture_19
  FROM image i JOIN vehicle v ON i.reg = v.id
  WHERE camera = 19
  GROUP BY reg
),temp1 AS (
  SELECT *
  FROM image i JOIN vehicle v ON i.reg = v.id
  ORDER BY reg, whn
), temp2 AS (
  SELECT *, LEAD(whn, 1) OVER (PARTITION BY reg ORDER BY whn) leave_time
  FROM temp1
)
SELECT temp0.reg, first_capture_19, leave_time, i.camera leave_camera
FROM temp0 JOIN temp2 ON (temp0.reg = temp2.reg AND temp0.first_capture_19 = temp2.whn)
JOIN image i ON (temp2.reg = i.reg AND temp2.leave_time = i.whn);


/*
#4) Congestion Charge Hard Questions

Q.  For all 19 cameras - show the position as IN, OUT or INTERNAL and the busiest hour for that camera.
*/
WITH temp1 AS (
  SELECT id, HOUR(whn) hr
  FROM camera c LEFT JOIN image i ON c.id = i.camera
), temp2 AS (
  SELECT id, hr, COUNT(*) hour_count
  FROM temp1
  GROUP BY id, hr
), temp3 AS (
  SELECT id, MAX(hour_count) max_hr_cnt
  FROM temp2
  GROUP BY id
), temp4 AS (
  SELECT temp2.id, hr, max_hr_cnt
  FROM temp2 JOIN temp3 ON temp2.id = temp3.id
  WHERE hour_count = max_hr_cnt
)
  SELECT temp4.id, COALESCE(perim, 'INTERNAL') position, hr busiest_hr, IF(hr IS NULL, NULL, max_hr_cnt) image_count
  FROM camera c JOIN temp4 ON c.id = temp4.id


/*
#5) Congestion Charge Hard Questions

Q.  Anomalous daily permits.
    Daily permits should not be issued for non-charging days (weekends).
    Find a way to represent charging days.
    Identify the anomalous daily permits.

*/
SELECT reg, sDate, chargeType
FROM permit
WHERE (chargeType = 'Daily') AND (WEEKDAY(sDate) IN (5, 6));


/*
#6) Congestion Charge Hard Questions

Q.  Issuing fines: Vehicles using the zone during the charge period, on charging days (weekdays)
      must be issued with fine notices unless they have a permit covering that day.
    List the name and address of such culprits, give the camera and the date and time of the first offence.
*/
WITH temp1 AS (
  SELECT i.reg, name, address, camera, whn, sDate, CASE
    WHEN chargeType = 'Daily' THEN DATE_ADD(sDate, INTERVAL 1 DAY)
    WHEN chargeType = 'Weekly' THEN DATE_ADD(sDate, INTERVAL 1 WEEK)
    WHEN chargeType = 'Monthly' THEN DATE_ADD(sDate, INTERVAL 1 MONTH)
    WHEN chargeType = 'Annual' THEN DATE_ADD(sDate, INTERVAL 1 YEAR)
    ELSE '' END fDate
  FROM image i JOIN vehicle v ON i.reg = v.id
  JOIN keeper k ON v.keeper = k.id
  JOIN permit p ON v.id = p.reg
), temp2 AS (
  SELECT *, RANK() OVER (PARTITION BY name ORDER BY whn) rnk
  FROM temp1
  WHERE ((sDate <= whn) AND (fDate > whn)) AND (WEEKDAY(whn) NOT IN (5, 6))
)
SELECT name, address, camera, whn
FROM temp2
WHERE rnk = 1;
