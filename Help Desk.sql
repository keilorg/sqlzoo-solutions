/*
Help Desk
A software company has been successful in selling its products to a number of customer organisations, and there is now a high demand for technical support.
There is already a system in place for logging support calls taken over the telephone and assigning them to engineers, but it is based on a series of spreadsheets.
With the growing volume of data, using the spreadsheet system is becoming slow, and there is a significant risk that errors will be made.
*/



/*
#1) Helpdesk Easy Questions
Q. There are three issues that include the words "index" and "Oracle".
   Find the call_date for each of them
*/
SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') AS call_date, call_ref
FROM Issue
WHERE (detail LIKE '%index%') AND (detail LIKE '%oracle%');


/*
#2) Helpdesk Easy Questions
Q. Samantha Hall made three calls on 2017-08-14. Show the date and time for each
*/
SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') AS call_date, first_name, last_name
FROM Issue i JOIN Caller c ON i.caller_id = c.caller_id
WHERE (first_name = 'Samantha') AND
      (last_name = 'Hall') AND
      (DATE_FORMAT(call_date, '%Y-%m-%d') = '2017-08-14');


/*
#3) Helpdesk Easy Questions
Q. There are 500 calls in the system (roughly).
   Write a query that shows the number that have each status.
*/
SELECT status, COUNT(*) Volume
FROM Issue
GROUP BY status;


/*
#4) Helpdesk Easy Questions

Calls are not normally assigned to a manager but it does happen.

Q. How many calls have been assigned to staff who are at Manager Level?.
*/
SELECT COUNT(*) AS mlcc
FROM Issue i JOIN Staff s ON i.assigned_to = s.staff_code
JOIN Level l ON s.level_code = l.level_code
WHERE manager = 'Y';


/*
#5) Helpdesk Easy Questions
Q. Show the manager for each shift.
   Your output should include the shift date and type; also the first and last name of the manager.
*/
SELECT DATE_FORMAT(Shift_date, '%Y-%m-%d') Shift_date, Shift_type, first_name, last_name
FROM Shift JOIN Staff ON Shift.manager = Staff.staff_code
ORDER BY Shift_date;;


/*
#6) Helpdesk Medium Questions
Q. List the Company name and the number of calls for those companies with more than 18 calls.
*/
SELECT company_name, COUNT(call_ref) cc
FROM Customer c JOIN Caller cl ON c.company_ref = cl.company_ref
JOIN Issue i ON cl.caller_id = i.caller_id
GROUP BY company_name
HAVING cc > 18;


/*
#7) Helpdesk Medium Questions
Q. Find the callers who have never made a call. Show first name and last name
*/
SELECT first_name, last_name
FROM Caller c LEFT OUTER JOIN Issue i ON c.caller_id = i.caller_id
WHERE i.caller_id IS NULL;


/*
#8) Helpdesk Medium Questions
Q. For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5
*/
WITH temp1 AS (
  SELECT company_name, COUNT(call_ref) nc
  FROM Customer c JOIN Caller cl ON c.company_ref = cl.company_ref
  JOIN Issue i ON cl.caller_id = i.caller_id
  GROUP BY company_name
  HAVING nc < 5
), temp2 AS (
  SELECT company_name, first_name, last_name
  FROM Customer c JOIN Caller cl ON c.contact_id = cl.caller_id
)
SELECT temp1.company_name, first_name, last_name, nc
FROM temp1 JOIN temp2 on temp1.company_name = temp2.company_name
ORDER BY nc DESC;;


/*
#9) Helpdesk Medium Questions
Q. For each shift show the number of staff assigned.
   Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').
*/
WITH temp1 AS (
  (SELECT shift_date, shift_type, manager AS staff
  FROM Shift) UNION ALL
  (SELECT shift_date, shift_type, operator
  FROM Shift) UNION ALL
  (SELECT shift_date, shift_type, engineer1
  FROM Shift) UNION ALL
  (SELECT shift_date, shift_type, engineer2
  FROM Shift)
  ORDER BY shift_date
)
SELECT DATE_FORMAT(shift_date, '%Y-%m-%d') shift_date, shift_type, COUNT(DISTINCT(staff)) cw
FROM temp1
WHERE staff IS NOT NULL
GROUP BY shift_date, shift_type;


/*
#10) Helpdesk Medium Questions
Q. Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting.
   Find out who took the call (full name) and when.
*/
SELECT s.first_name, s.last_name, DATE_FORMAT(call_date, '%Y-%m-%d %h:%i:%s') call_date
FROM Caller c JOIN Issue i ON c.caller_id = i.caller_id
JOIN Staff s ON i.taken_by = s.staff_code
WHERE c.first_name = 'Harry'
ORDER BY call_date DESC
LIMIT 1;


/*
#11) Helpdesk Hard Questions
Q. Show the manager and number of calls received for each hour of the day on 2017-08-12
*/
WITH temp1 AS (
  SELECT DATE_FORMAT(call_date, '%Y-%m-%d %H') day_hr,
    DATE_FORMAT(call_date, '%Y-%m-%d') day,
    DATE_FORMAT(call_date, '%H') hr,
    COUNT(call_ref) cc
  FROM Issue
  WHERE DATE_FORMAT(call_date, '%Y-%m-%d') = '2017-08-12'
  GROUP BY day_hr, day, hr
), temp2 AS (
  SELECT manager,
    DATE_FORMAT(shift_date, '%Y-%m-%d') day2,
    LEFT(start_time, 2) start_hr,
    LEFT(end_time, 2) end_hr
  FROM Shift s JOIN Shift_type st ON s.shift_type = st.shift_type
  WHERE DATE_FORMAT(shift_date, '%Y-%m-%d') = '2017-08-12'
)
SELECT manager, day_hr AS Hr, cc
FROM temp1 JOIN temp2 ON (temp1.hr >= temp2.start_hr AND temp1.hr < temp2.end_hr);


/*
#12) Helpdesk Hard Questions

80/20 rule. It is said that 80% of the calls are generated by 20% of the callers.

Q. Is this true? What percentage of calls are generated by the most active 20% of callers.
*/
SELECT ROUND(SUM(p2.cc / (SELECT COUNT(*) FROM Issue)) * 100, 4) t20pc
FROM (
  SELECT p1.*, @counter := @counter + 1 AS counter
  FROM (SELECT @counter := 0) AS initvar,
       (SELECT Caller_id, COUNT(*) AS cc
        FROM Issue
        GROUP BY Caller_id
	ORDER BY COUNT(*) DESC) AS p1
     ) AS p2
WHERE
counter <= (.2 * @counter);;


/*
#13) Helpdesk Hard Questions

Annoying customers.
Customers who call in the last five minutes of a shift are annoying.

Q. Find the most active customer who has never been annoying.
*/
WITH temp1 AS (
  SELECT company_name, HOUR(call_date) hr, MINUTE(call_date) min, call_ref
  FROM Issue i JOIN Caller c ON i.caller_id = c.caller_id
  JOIN Customer cs ON c.company_ref = cs.company_ref
), temp2 AS (
  SELECT DISTINCT(company_name) block_list
  FROM temp1
  WHERE (hr IN (13, 19)) AND (min >= 55)
)
SELECT company_name, COUNT(call_ref) abna
FROM Issue i2 JOIN Caller c2 ON i2.caller_id = c2.caller_id
JOIN Customer cs2 ON c2.company_ref = cs2.company_ref
WHERE company_name NOT IN (SELECT block_list FROM temp2)
GROUP BY company_name
ORDER BY abna DESC
LIMIT 1;


/*
#14) Helpdesk Hard Questions

Maximal usage.
If every caller registered with a customer makes a call in one day then that customer has "maximal usage" of the service.

Q. List the maximal customers for 2017-08-13.
*/
WITH temp1 AS (
  SELECT company_name, COUNT(caller_id) caller_count
  FROM Customer cs JOIN Caller c ON cs.company_ref = c.company_ref
  GROUP BY company_name
), temp2 AS (
  SELECT company_name, COUNT(DISTINCT(i.caller_id)) issue_count
  FROM Customer cs JOIN Caller c ON cs.company_ref = c.company_ref
  JOIN Issue i ON c.caller_id = i.caller_id
  WHERE DATE_FORMAT(call_date, '%Y-%m-%d') = '2017-08-13'
  GROUP BY company_name
)
SELECT temp1.company_name, caller_count, issue_count
FROM temp1 JOIN temp2 ON temp1.company_name = temp2.company_name
WHERE caller_count = issue_count;


/*
#14) Helpdesk Hard Questions

Consecutive calls occur when an operator deals with two callers within 10 minutes.

Q. Find the longest sequence of consecutive calls – give the name of the operator and the first and last call date in the sequence.
*/
SELECT a.taken_by, a.first_call, a.last_call, a.call_count AS calls
FROM (
  SELECT taken_by, DATE_FORMAT(call_date, '%Y-%m-%d %H:%i:%s') AS last_call,
    @row_number1:= (CASE
      WHEN (TIMESTAMPDIFF(MINUTE, @call_date, call_date) <= 10) THEN (@row_number1 + 1)
      ELSE 1
    END) AS call_count,
    @first_call_date:= (CASE
      WHEN (@row_number1 = 1) THEN call_date
      ELSE @first_call_date
    END) AS first_call,
    @call_date:= Issue.call_date AS call_date
  FROM Issue, (SELECT @row_number1 := 0, @call_date := 0, @first_call_date := 0) AS row_number_init
  ORDER BY taken_by, call_date) AS a
ORDER BY a.call_count DESC
LIMIT 1;
