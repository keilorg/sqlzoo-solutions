/*
Guest House

Background:
Guests stay at a small hotel.
Each booking is recorded in the table booking, the date of the first night of the booking is stored here (we do not record the date the booking was made).
At the time of booking the room to be used is decided.
There are several room types (single, double..).
The amount charged depends on the room type and the number of people staying and the number of nights.
Guests may be charged extras (for breakfast or using the minibar).
*/



/*
#1) Guest House Easy Questions

Q. Give the booking_date and the number of nights for guest 1183.
*/
SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') booking_date, nights
FROM booking
WHERE guest_id = 1183;


/*
#2) Guest House Easy Questions

When do they get here?

Q. List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival.
*/
SELECT arrival_time, first_name, last_name
FROM booking b JOIN guest g ON b.guest_id = g.id
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') = '2016-11-05'
ORDER BY arrival_time;


/*
#3) Guest House Easy Questions

Look up daily rates.

Q. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295.
   Include booking id, room type, number of occupants and the amount.
*/
SELECT booking_id, room_type_requested, occupants, amount
FROM booking b JOIN rate r ON b.room_type_requested = r.room_type
WHERE booking_id IN (5152, 5165, 5154, 5295) AND occupants = occupancy;


/*
#4) Guest House Easy Questions

Who's in 101?

Q. Find who is staying in room 101 on 2016-12-03, include first name, last name and address.
*/
SELECT first_name, last_name, address
FROM guest g JOIN booking b ON g.id = b.guest_id
WHERE room_no = 101 AND DATE_FORMAT(booking_date, '%Y-%m-%d') = '2016-12-03';


/*
#5) Guest House Easy Questions

How many bookings, how many nights?

Q. For guests 1185 and 1270 show the number of bookings made and the total number of nights.
   Your output should include the guest id and the total number of bookings and the total number of nights.
*/
SELECT guest_id, COUNT(nights) bookings, SUM(nights) total_nights
FROM booking
WHERE guest_id IN (1185, 1270)
GROUP BY guest_id;


/*
#6) Guest House Medium Questions

Q. Show the total amount payable by guest Ruth Cadbury for her room bookings.
*/
SELECT SUM(nights*amount) amount_payable
FROM booking b JOIN rate r ON (b.room_type_requested = r.room_type AND occupants = occupancy)
JOIN guest g ON b.guest_id = g.id
WHERE first_name = 'Ruth' AND last_name = 'Cadbury';


/*
#7) Guest House Medium Questions

Including Extras.

Q. Calculate the total bill for booking 5346 including extras.
*/
WITH temp1 AS (
  SELECT SUM(nights * r.amount) t1
  FROM booking b JOIN rate r ON (b.room_type_requested = r.room_type AND occupancy = occupants)
  WHERE b.booking_id = 5346
), temp2 AS (
  SELECT SUM(amount) t2
  FROM booking b JOIN extra e ON b.booking_id = e.booking_id
  WHERE b.booking_id = 5346
)
SELECT (SELECT t1 FROM temp1) + (SELECT t2 FROM temp2) AS total;


/*
#8) Guest House Medium Questions

Edinburgh Residents.

Q. For every guest who has the word “Edinburgh” in their address show the total number of nights booked.
   Be sure to include 0 for those guests who have never had a booking.
   Show last name, first name, address and number of nights.
   Order by last name then first name.
*/
SELECT last_name, first_name, address, SUM(CASE
  WHEN nights IS NULL THEN 0
  ELSE nights
  END) total_nights
FROM guest g LEFT JOIN booking b ON g.id = b.guest_id
WHERE address LIKE '%Edinburgh%'
GROUP BY last_name, first_name, address
ORDER BY last_name, first_name;


/*
#9) Guest House Medium Questions

Q. For each day of the week beginning 2016-11-25 show the number of bookings starting that day.
   Be sure to show all the days of the week in the correct order.
*/
SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') days, COUNT(booking_id) arrivals
FROM booking
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') BETWEEN '2016-11-25' AND '2016-12-01'
GROUP BY days;


/*
#10) Guest House Medium Questions

How many guests?

Q. Show the number of guests in the hotel on the night of 2016-11-21.
   Include all occupants who checked in that day but not those who checked out.
*/
WITH temp1 AS (
  SELECT occupants, DATE_FORMAT(booking_date, '%Y-%m-%d') booking_date, DATE_FORMAT(booking_date + nights, '%Y-%m-%d') departure
  FROM booking
  WHERE booking_date <= '2016-11-21' AND DATE_FORMAT(booking_date + nights, '%Y-%m-%d') > '2016-11-21'
)
SELECT SUM(occupants)
FROM temp1;


/*
#11) Guest House Hard Questions

Coincidence

Q. Have two guests with the same surname ever stayed in the hotel on the evening?
   Show the last name and both first names.
   Do not include duplicates.
*/
WITH temp1 AS (
  SELECT DISTINCT a.last_name, a.first_name fn1, b.first_name fn2
  FROM (SELECT * FROM booking bo JOIN guest g ON bo.guest_id = g.id) a,
       (SELECT * FROM booking bo JOIN guest g ON bo.guest_id = g.id) b
  WHERE (a.last_name = b.last_name AND a.first_name != b.first_name) AND (
        ((a.booking_date < b.booking_date + INTERVAL b.nights DAY) AND a.booking_date >= b.booking_date) OR
        ((b.booking_date < a.booking_date + INTERVAL a.nights DAY) AND b.booking_date >= a.booking_date))
), temp2 AS (
  SELECT last_name, fn1, fn2,
    MAX(fn1) OVER (PARTITION BY last_name) AS rnum
  FROM temp1
  ORDER BY last_name
)
SELECT last_name, fn1, fn2
FROM temp2
WHERE fn1 = rnum;


/*
#12) Guest House Hard Questions

Check out per floor.
The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor.

Q. For each day of the week beginning 2016-11-14 show how many rooms are being vacated that day by floor number.
   Show all days in the correct order.
*/
WITH temp1 AS (
  SELECT *, DATE_FORMAT((booking_date + INTERVAL nights DAY), '%Y-%m-%d') departure, LEFT(room_no, 1) floor
  FROM booking
), temp2 AS (
  SELECT *
  FROM temp1
  WHERE (departure >= '2016-11-14' AND departure < '2016-11-21')
), temp3 AS(
  SELECT departure,
    CASE
      WHEN floor = 1 THEN 1
      ELSE 0
    END AS 1st,
    CASE
      WHEN floor = 2 THEN 1
      ELSE 0
    END AS 2nd,
    CASE
      WHEN floor = 3 THEN 1
      ELSE 0
    END AS 3rd
  FROM temp2
)
SELECT departure, SUM(1st) 1st, SUM(2nd) 2nd, SUM(3rd) 3rd
FROM temp3
GROUP BY departure;


/*
#13) Guest House Hard Questions

Free rooms?

Q. List the rooms that are free on the day 25th Nov 2016.
*/
WITH temp1 AS (
  SELECT DISTINCT id
  FROM room
  ORDER BY id ASC
), temp2 AS (
  SELECT DISTINCT room_no
  FROM booking
  WHERE (DATE_FORMAT(booking_date, '%Y-%m-%d') <= '2016-11-25') AND
        (DATE_FORMAT(booking_date + INTERVAL nights DAY, '%Y-%m-%d') > '2016-11-25')
)
SELECT temp1.id
FROM temp1 LEFT OUTER JOIN temp2 ON temp1.id = temp2.room_no
WHERE temp2.room_no IS NULL;


/*
#14) Guest House Hard Questions

Single room for three nights required.

Q. A customer wants a single room for three consecutive nights.
   Find the first available date in December 2016.
*/
WITH temp1 AS (
  SELECT *,(booking_date + INTERVAL nights DAY) as departure, @rownum:=@rownum + 1 as rank1
  FROM booking, (SELECT @rownum:= 0) as r1
  ORDER BY room_no, booking_date
), temp2 AS (
  SELECT (booking_date + INTERVAL nights DAY) as previous_departure, @rownum2:=@rownum2 + 1 as rank2
  FROM booking, (SELECT @rownum2:= 1) as r2
  ORDER BY room_no, booking_date
), temp3 AS (
  SELECT *
  FROM temp1 JOIN temp2 ON temp1.rank1 = temp2.rank2
  WHERE room_type_requested = 'single' AND DATE_FORMAT(booking_date, '%M') = 'December'
), temp4 AS (
  SELECT MIN(previous_departure) date1
  FROM temp3
  WHERE booking_date - INTERVAL 3 DAY >= previous_departure
), temp5 AS (
  SELECT room_no, MAX(departure) date2
  FROM temp3
  GROUP BY room_no
), temp6 AS (
  SELECT MIN(date2) date3
  FROM temp5
)
SELECT DATE_FORMAT(COALESCE((SELECT date1 FROM temp4), date3), '%Y-%m-%d') earliest_date
FROM temp6;


/*
#15) Guest House Hard Questions

Gross income by week.
Money is collected from guests when they leave.

Q. For each Thursday in November and December 2016, show the total amount of money collected from the previous Friday to that day, inclusive.
*/
WITH temp1 AS (
SELECT DATE_ADD(MAKEDATE(2016, 7), INTERVAL WEEK(DATE_ADD(booking.booking_date, INTERVAL booking.nights - 5 DAY), 0) WEEK) AS Thursday,
  SUM(booking.nights * rate.amount) + SUM(e.amount) AS weekly_income
FROM booking JOIN rate ON (booking.occupants = rate.occupancy AND booking.room_type_requested = rate.room_type)
LEFT JOIN (SELECT booking_id, SUM(amount) as amount
           FROM extra
           GROUP BY booking_id) AS e
     ON (e.booking_id = booking.booking_id)
GROUP BY Thursday
)
SELECT DATE_FORMAT(Thursday, '%Y-%m-%d') Thursday, weekly_income
FROM temp1;
