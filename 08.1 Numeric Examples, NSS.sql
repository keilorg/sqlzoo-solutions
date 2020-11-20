/*
Numeric Examples - NSS Tutorial

The National Student Survey http://www.thestudentsurvey.com/ is presented to thousands of graduating students in UK Higher Education.
The survey asks 22 questions, students can respond with STRONGLY DISAGREE, DISAGREE, NEUTRAL, AGREE or STRONGLY AGREE.
The values in these columns represent PERCENTAGES of the total students who responded with that answer.

The table nss has one row per institution, subject and question.
*/



/*
#1) Check out one row

The example shows the number who responded for:
 - question 1
 - at 'Edinburgh Napier University'
 - studying '(8) Computer Science'

Q. Show the percentage who STRONGLY AGREE
*/
SELECT A_STRONGLY_AGREE
FROM nss
WHERE (question = 'Q01') AND
      (institution = 'Edinburgh Napier University') AND
      (subject = '(8) Computer Science');


/*
#2) Calculate how many agree or strongly agree

Q. Show the institution and subject where the score is at least 100 for question 15.
*/
SELECT institution, subject
FROM nss
WHERE (score >= 100) AND (question = 'Q15');


/*
#3) Unhappy Computer Students

Q. Show the institution and score where the score for '(8) Computer Science' is less than 50 for question 'Q15'.
*/
SELECT institution, score
FROM nss
WHERE (score < 50) AND (question = 'Q15') AND (subject = '(8) Computer Science');


/*
#4) More Computing or Creative Students?

Q. Show the subject and total number of students who responded to question 22 for each of the subjects '(8) Computer Science' and '(H) Creative Arts and Design'.
*/
SELECT subject, SUM(response) respondents
FROM nss
WHERE (question = 'Q22') AND (subject IN ('(8) Computer Science', '(H) Creative Arts and Design'))
GROUP BY subject;


/*
#5) Strongly Agree Numbers

Q. Show the subject and total number of students who A_STRONGLY_AGREE to question 22 for each of the subjects '(8) Computer Science' and '(H) Creative Arts and Design'.
*/
SELECT subject, SUM(cnt) student_count
FROM (
   SELECT subject, (A_STRONGLY_AGREE * response)/100 cnt
   FROM nss
   WHERE (question = 'Q22') AND (subject IN ('(8) Computer Science', '(H) Creative Arts and Design'))
) temp1
GROUP BY subject;


/*
#6) Strongly Agree, Percentage

Q. Show the percentage of students who A_STRONGLY_AGREE to question 22 for the subject '(8) Computer Science' show the same figure for the subject '(H) Creative Arts and Design'.
   Use the ROUND function to show the percentage without decimal places.
*/
SELECT subject, ROUND(SUM(A_STRONGLY_AGREE*response/100)/sum(response)*100,0) percentage
FROM nss
WHERE (question = 'Q22') AND (subject IN ('(8) Computer Science', '(H) Creative Arts and Design'))
GROUP BY subject;


/*
#7) Scores for Institutions in Manchester

Q. Show the average scores for question 'Q22' for each institution that include 'Manchester' in the name.

The column score is a percentage - you must use the method outlined above to multiply the percentage by the response and divide by the total response.
Give your answer rounded to the nearest whole number.

*/
SELECT institution, ROUND(SUM(score*response)/SUM(response),0) avg_score
FROM nss
WHERE (question = 'Q22') AND (institution LIKE '%Manchester%')
GROUP BY institution;


/*
#8) Number of Computing Students in Manchester

Q. Show the institution, the total sample size and the number of computing students for institutions in Manchester for 'Q01'.
*/
SELECT institution, SUM(sample) total_sample, SUM(IF(subject = '(8) Computer Science', sample, 0)) comp_students
FROM nss
WHERE (institution LIKE '%Manchester%') AND (question = 'Q01')
GROUP BY institution;
