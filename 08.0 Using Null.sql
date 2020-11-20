
/*
Using Null

The school includes many departments.
Most teachers work exclusively for a single department.
Some teachers have no department.
*/



/*
#1) NULL, INNER JOIN, LEFT JOIN, RIGHT JOIN

Q. List the teachers who have NULL for their department.
*/
SELECT name
FROM teacher
WHERE dept IS NULL;


/*
#2)

Q. Note the INNER JOIN misses the teachers with no department and the departments with no teacher.
*/
SELECT teacher.name, dept.name
FROM teacher JOIN dept ON teacher.dept = dept.id;


/*
#3)

Q. Use a different JOIN so that all teachers are listed.
*/
SELECT teacher.name, dept.name
FROM teacher LEFT JOIN dept ON teacher.dept = dept.id;


/*
#4)

Q. Use a different JOIN so that all departments are listed.
*/
SELECT teacher.name, dept.name
FROM teacher RIGHT JOIN dept ON teacher.dept = dept.id;


/*
#5) Using the COALESCE function

Use COALESCE to print the mobile number.
Use the number '07986 444 2266' if there is no number given.

Q. Show teacher name and mobile number or '07986 444 2266'
*/
SELECT name, COALESCE(mobile, '07986 444 2266') mobile
FROM teacher;


/*
#6)

Q. Use the COALESCE function and a LEFT JOIN to print the teacher name and department name.
   Use the string 'None' where there is no department.
*/
SELECT teacher.name, COALESCE(dept.name, 'None') dept_name
FROM teacher LEFT JOIN dept ON teacher.dept = dept.id;


/*
#7)

Q. Use COUNT to show the number of teachers and the number of mobile phones.
*/
SELECT COUNT(name) teacher_count, COUNT(mobile) mobile_count
FROM teacher;


/*
#8)

Q. Use COUNT and GROUP BY dept.name to show each department and the number of staff.
   Use a RIGHT JOIN to ensure that the Engineering department is listed.
*/
SELECT dept.name, COUNT(teacher.dept) staff_count
FROM dept LEFT JOIN teacher ON dept.id = teacher.dept
GROUP BY dept.name;


/*
#9) Using CASE

Q. Use CASE to show the name of each teacher followed by 'Sci' if the teacher is in dept 1 or 2 and 'Art' otherwise.
*/
SELECT name, CASE
  WHEN dept IN (1,2) THEN 'Sci'
  ELSE 'Art'
  END AS dept_type
FROM teacher;


/*
#10)

Q. Use CASE to show the name of each teacher followed by 'Sci' if the teacher is in dept 1 or 2.
   Show 'Art' if the teacher's dept is 3.
   Show 'None' otherwise.
*/
SELECT name, CASE
  WHEN dept IN (1,2) THEN 'Sci'
  WHEN dept in (3) Then 'Art'
  ELSE 'None'
  END AS dept_type
FROM teacher;
