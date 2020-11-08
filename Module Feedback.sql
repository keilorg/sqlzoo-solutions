/*
Module Feedback
This system records the responses of students on their learning experience at university.
Most students study three modules every session, they are invited to respond to 19 questions regarding their experience.
For each question, for each student the response can be from 1 (definitely disagree) to 5 (strongly agree).
*/



/*
#1) Find the student name from a matriculation number

Q. Find the name of the student with number 50200100
*/
SELECT SPR_FNM1, SPR_SURN
FROM INS_SPR
WHERE SPR_CODE='50200100'



/*
#2) Find the modules studied by a student

Q. Show the module code and module name for modules studied by the student with number 50200100 in session 2016/7 TR1
*/
SELECT CAM_SMO.MOD_CODE,INS_MOD.MOD_NAME
FROM INS_MOD JOIN CAM_SMO ON (INS_MOD.MOD_CODE=CAM_SMO.MOD_CODE)
WHERE CAM_SMO.SPR_CODE = '50200100'
   AND CAM_SMO.AYR_CODE = '2016/7'
   AND CAM_SMO.PSL_CODE = 'TR1'


/*
#3) Find the modules and module leader studied by a student

Q. Show the module code and module name and details of the module leader for modules studied by the student with number 50200100 in session 2016/7 TR1
*/
SELECT CAM_SMO.MOD_CODE, INS_MOD.MOD_NAME, INS_PRS.PRS_CODE, INS_PRS.PRS_FNM1, INS_PRS.PRS_SURN
FROM CAM_SMO JOIN INS_MOD ON (INS_MOD.MOD_CODE=CAM_SMO.MOD_CODE)
JOIN INS_PRS ON (INS_MOD.PRS_CODE=INS_PRS.PRS_CODE)
WHERE CAM_SMO.SPR_CODE = '50200100'
  AND CAM_SMO.AYR_CODE = '2016/7'
  AND CAM_SMO.PSL_CODE = 'TR1';


/*
#4) Show the scores for module SET08108

Q. Show the Percentage of students who gave 4 or 5 to module SET08108 in session 2016/7 TR1.
*/
SELECT INS_RES.QUE_CODE, QUE_TEXT,CAT_NAME, ROUND(100*SUM(FLOOR(RES_VALU/4))/COUNT(1)) as score
FROM INS_RES JOIN INS_QUE ON INS_RES.QUE_CODE=INS_QUE.QUE_CODE
JOIN INS_CAT ON INS_QUE.CAT_CODE=INS_CAT.CAT_CODE
WHERE INS_RES.MOD_CODE='SET08108'
   AND INS_RES.AYR_CODE='2016/7'
   AND INS_RES.PSL_CODE='TR1'
GROUP BY QUE_CODE,QUE_TEXT,CAT_NAME;


/*
#5) Show the frequency chart for module SET08108 for question 4.1

Q. For each response 1-5 show the number of students who gave that response (Module SET08108, 2016/7, TR1)
*/
SELECT MOD_CODE,RES_VALU,COUNT(1)
FROM INS_RES
WHERE INS_RES.MOD_CODE = 'SET08108'
  AND INS_RES.AYR_CODE='2016/7'
  AND INS_RES.PSL_CODE='TR1'
  AND INS_RES.QUE_CODE='4.1'
GROUP BY MOD_CODE, RES_VALU;
