/*
Data Exploration of Provisional COVID-19 Deaths by Week and Age 12/29/2019 - 7/24/2021, data as of 8/2/2021
Additional data from Weekly Provisional Counts of Deaths by State and Select Causes 2020-2022, data as of 5/18/2022
Data from the CDC's National Center for Health Statistics
*/


--The earliest dates in which COVID deaths occurred. Per footnote, NULL entries under COVID-19_Deaths indicate a count of 1-9 that was suppressed
SELECT DISTINCT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', [COVID-19_Deaths], Footnote
FROM RTDatabase..COVID_Deaths_Age
WHERE ([COVID-19_Deaths] IS NULL OR [COVID-19_Deaths] <> 0) AND State NOT IN ('United States','New York City')
ORDER BY Start_Date, State


--Starting date of week when each state had its first COVID death
SELECT State, MIN(CAST(Start_Date AS date)) AS 'Earliest_Start_Date'
FROM RTDatabase..COVID_Deaths_Age
WHERE ([COVID-19_Deaths] IS NULL OR [COVID-19_Deaths] <> 0) AND State NOT IN ('United States','New York City')
GROUP BY State 
ORDER BY State 


--Weekly COVID deaths as a percentage of total deaths by age group 
--By state
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, ([COVID-19_Deaths]/NULLIF(Total_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE State NOT IN ('United States','New York City') 
ORDER BY State, Start_Date

--For whole U.S.
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, [COVID-19_Deaths]/Total_Deaths*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE State = 'United States'
ORDER BY Start_Date


--Dates when pediatric COVID deaths occurred in the U.S.
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', Age_Group, [COVID-19_Deaths], Total_Deaths
FROM RTDatabase..COVID_Deaths_Age
WHERE ([COVID-19_Deaths] IS NULL OR [COVID-19_Deaths] <> 0) AND Age_Group = '0-17 years' AND State = 'United States'
ORDER BY Start_Date 


--Weekly percentage of COVID deaths for Nevada only by age group
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, [COVID-19_Deaths]/Total_Deaths*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE State = 'Nevada'
ORDER BY Start_Date

--Weekly Nevada pediatric data
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, [COVID-19_Deaths]/Total_Deaths*100 AS 'Percentage_of_COVID_Deaths', Footnote
FROM RTDatabase..COVID_Deaths_Age
WHERE State = 'Nevada' AND Age_Group = '0-17 years'
ORDER BY Start_Date

--Dates when pediatric COVID deaths occurred in Nevada
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, Footnote
FROM RTDatabase..COVID_Deaths_Age
WHERE ([COVID-19_Deaths] IS NULL OR [COVID-19_Deaths] <> 0) AND State = 'Nevada' AND Age_Group = '0-17 years' 
ORDER BY Start_Date


--Weekly COVID deaths and percentage grouped as <65 years old and 65+ years old 
--By state
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, ([COVID-19_Deaths]/NULLIF(Total_Deaths,0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE Age_Group IN ('<65 years', '65+ years') AND State NOT IN ('United States','New York City') 
ORDER BY State, Start_Date

--For whole U.S.
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, ([COVID-19_Deaths]/NULLIF(Total_Deaths,0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE Age_Group IN ('<65 years', '65+ years') AND State = 'United States'
ORDER BY State, Start_Date


--Weekly total COVID deaths
--Create view 
CREATE VIEW vWeekly_COVID_Deaths AS
SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, 
  SUM([COVID-19_Deaths]) AS 'All_COVID-19_Deaths', SUM(Total_Deaths) AS 'All_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE Age_Group IN ('<65 years', '65+ years') 
GROUP BY State, Start_Date, End_Date, MMWR_Year, MMWR_Week

--Weekly total COVID deaths and percentage using view
--By state
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..vWeekly_COVID_Deaths
WHERE State NOT IN ('United States','New York City') 
ORDER BY State, Start_Date

--For New York City 
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..vWeekly_COVID_Deaths
WHERE State = 'New York City'
ORDER BY State, Start_Date

--For whole U.S.
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..vWeekly_COVID_Deaths
WHERE State = 'United States'
ORDER BY State, Start_Date

--Highest percentages of weekly total COVID deaths per all deaths
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM RTDatabase..vWeekly_COVID_Deaths
WHERE State NOT IN ('United States','New York City') 
ORDER BY Percentage_of_COVID_Deaths desc

--Highest percentages of COVID deaths per total deaths in the U.S. by season
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths',
  CASE
  WHEN (Start_Date BETWEEN '2019-12-01' AND '2020-02-29') OR (Start_Date BETWEEN '2020-12-01' AND '2021-02-28') THEN 'Winter'
  WHEN (Start_Date BETWEEN '2020-03-01' AND '2020-05-31') OR (Start_Date BETWEEN '2021-03-01' AND '2021-05-31') THEN 'Spring'
  WHEN (Start_Date BETWEEN '2020-06-01' AND '2020-08-31') OR (Start_Date BETWEEN '2021-06-01' AND '2021-08-31') THEN 'Summer'
  WHEN (Start_Date BETWEEN '2020-09-01' AND '2020-11-30') OR (Start_Date BETWEEN '2021-09-01' AND '2021-11-30') THEN 'Fall'
  ELSE 'Other'
  END AS 'Season'
FROM RTDatabase..vWeekly_COVID_Deaths
WHERE State = 'United States'
ORDER BY State, Percentage_of_COVID_Deaths DESC


--Total COVID deaths per all deaths for whole dataset time period (12/29/2019 - 7/24/2021)
--Create temp table
DROP TABLE IF EXISTS #Total_COVID_Deaths
CREATE TABLE #Total_COVID_Deaths
(State nvarchar(255),
[All_COVID-19_Deaths] float,
All_Deaths float)

INSERT INTO #Total_COVID_Deaths
SELECT State, SUM([COVID-19_Deaths]) AS 'All_COVID-19_Deaths', SUM(Total_Deaths) AS 'All_Deaths'
FROM RTDatabase..COVID_Deaths_Age
WHERE Age_Group IN ('<65 years', '65+ years') 
GROUP BY State

--Percentage of total COVID deaths per all deaths using temp table
--By state
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM #Total_COVID_Deaths
WHERE State NOT IN ('United States','New York City') 
ORDER BY Percentage_of_COVID_Deaths DESC

--For whole U.S. 
SELECT *, ([All_COVID-19_Deaths]/NULLIF(All_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
FROM #Total_COVID_Deaths
WHERE State = 'United States'
ORDER BY Percentage_of_COVID_Deaths DESC


--Highest percentage of COVID deaths per total deaths in dataset using CTE
WITH CTE_COVID_Deaths_Percentage AS
  (SELECT State, CAST(Start_Date AS date) AS 'Start_Date', CAST(End_Date AS date) AS 'End_Date', MMWR_Year, MMWR_Week, Age_Group, [COVID-19_Deaths], 
  Total_Deaths, ([COVID-19_Deaths]/NULLIF(Total_Deaths, 0))*100 AS 'Percentage_of_COVID_Deaths'
  FROM RTDatabase..COVID_Deaths_Age)
SELECT *
FROM CTE_COVID_Deaths_Percentage
WHERE Percentage_of_COVID_Deaths = 
  (SELECT MAX(Percentage_of_COVID_Deaths)
  FROM CTE_COVID_Deaths_Percentage)
ORDER BY Start_Date


--COVID deaths compared with other causes of death
--Join to table with information regarding other causes of death and create a view 
CREATE VIEW vCOVID_Other_Causes_of_Death AS
SELECT cov.State, cov.MMWR_Year, cov.MMWR_Week, CAST(cov.End_Date AS date) AS End_Date, SUM(cov.Total_Deaths) AS 'All_Deaths', 
  SUM(cov.[COVID-19_Deaths]) AS 'All_COVID-19_Deaths', causes.Septicemia, causes.Malignant_neoplasms, causes.Diabetes_mellitus, causes.Alzheimer_disease, 
  causes.Influenza_and_pneumonia, causes.Chronic_lower_respiratory_diseases, causes.Other_diseases_of_respiratory_system, 
  causes.Nephritis_nephrotic_syndrome_and_nephrosis, causes.Symptoms_signs_and_abnormal_findings_not_elsewhere_classified, 
  causes.Diseases_of_heart, causes.Cerebrovascular_diseases
FROM RTDatabase..COVID_Deaths_Age AS cov
LEFT JOIN RTDatabase..Causes_of_Death AS causes
ON
  cov.MMWR_Year = causes.MMWR_Year AND
  cov.MMWR_Week = causes.MMWR_Week AND
  cov.End_Date = causes.Week_Ending_Date AND
  cov.State = causes.Jurisdiction_of_Occurrence
WHERE cov.State = 'United States' AND cov.Age_Group IN ('<65 years', '65+ years')
GROUP BY cov.State, cov.MMWR_Year, cov.MMWR_Week, cov.End_Date, causes.Septicemia, causes.Malignant_neoplasms, causes.Diabetes_mellitus, 
  causes.Alzheimer_disease, causes.Influenza_and_pneumonia, causes.Chronic_lower_respiratory_diseases, causes.Other_diseases_of_respiratory_system, 
  causes.Nephritis_nephrotic_syndrome_and_nephrosis, causes.Symptoms_signs_and_abnormal_findings_not_elsewhere_classified, 
  causes.Diseases_of_heart, causes.Cerebrovascular_diseases

--Percentages of causes of death per total deaths using view
SELECT State, MMWR_Year, MMWR_Week, End_Date, All_Deaths, ([All_COVID-19_Deaths]/All_Deaths)*100 AS 'COVID_Death_Percentage', 
  (Septicemia/All_Deaths)*100 AS 'Septicemia_Death_Percentage', 
  (Malignant_neoplasms/All_Deaths)*100 AS 'Malignant_Neoplasms_Death_Percentage', 
  (Diabetes_mellitus/All_Deaths)*100 AS 'DM_Death_Percentage', 
  (Alzheimer_disease/All_Deaths)*100 AS 'Alzheimer_Disease_Death_Percentage', 
  (Influenza_and_pneumonia/All_Deaths)*100 AS 'Flu_and_PNA_Death_Percentage', 
  (Chronic_lower_respiratory_diseases/All_Deaths)*100 AS 'Chronic__Lower_Respiratory_Death_Percentage', 
  (Other_diseases_of_respiratory_system/All_Deaths)*100 AS 'Other_Respiratory_Death_Percentage', 
  (Nephritis_nephrotic_syndrome_and_nephrosis/All_Deaths)*100 AS 'Nephro_Death_Percentage', 
  (Symptoms_signs_and_abnormal_findings_not_elsewhere_classified/All_Deaths)*100 AS 'Deaths_Not_Elsewhere_Classified_Percentage', 
  (Diseases_of_heart/All_Deaths)*100 AS 'Heart_Diseases_Death_Percentage', 
  (Cerebrovascular_diseases/All_Deaths)*100 AS 'Cerebrovascular_Diseases_Death_Percentage'
FROM RTDatabase..vCOVID_Other_Causes_of_Death
ORDER BY MMWR_Year, MMWR_Week
