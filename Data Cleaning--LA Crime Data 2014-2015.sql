/* 
Data Cleaning of the Kaggle dataset "Los Angeles Crime Data 2010-2020: Public Safety Data released by the LAPD" by Sumaia P.:
	https://www.kaggle.com/datasets/sumaiaparveenshupti/los-angeles-crime-data-20102020

Link to the City of Los Angeles website with the original data: 
	https://data.lacity.org/Public-Safety/Crime-Data-from-2010-to-2019/63jg-8b9z

This dataset is in the public domain per the Kaggle page and the City of Los Angeles website

Dataset was first filtered in Excel to limit it to crimes that occurred from 2014 to 2015
*/



SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--DATE REPORTED and DATE OCCURRED

--Change Date Reported and Date Occurred to Date data type from Datetime data type
SELECT CAST([Date Rptd] AS Date) AS 'Date Reported', 
	CAST([DATE OCC] AS Date) AS 'Date Occurred'
FROM RTDatabase..LA_Crime_2014_2015

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ALTER COLUMN [Date Rptd] Date

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ALTER COLUMN [DATE OCC] Date

SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--TIME OCCURRED

--Check if any out-of-range times
SELECT [TIME OCC]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [TIME OCC] < 0 OR [TIME OCC] >2359

--No values returned--no out-of-range times

SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--AREA and AREA NAME

--Check if any NULLs in Area or Area Name that can be filled in 
SELECT [AREA ], [AREA NAME]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([AREA ]IS NULL) OR ([AREA NAME] IS NULL)

--No NULLs in either column




--PART 1-2

--Check if column Part 1-2 has any values besides 1 or 2
SELECT DISTINCT([Part 1-2])
FROM RTDatabase..LA_Crime_2014_2015

--No values returned besides 1 or 2

SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--CRIME CODE and CRIME CODE DESCRIPTION

--Check if any NULL values in Crime Code or Crime Code Description column (each row should have a Crime Code listed)
SELECT [Crm Cd], [Crm Cd Desc]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Crm Cd] IS NULL) OR ([Crm Cd Desc] IS NULL)

--Nothing returned, no values missing

SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--VICTIM AGE

--Check for potential out-of-range victim ages
SELECT DISTINCT([Vict Age])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Vict Age] 

--Negative values (-1 to -6) are out-of-range; age 0 and age 114 are potentially out-of-range
--No NULL values

--Review the negative values
SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] < 0
ORDER BY [Crm Cd]

--Based on the crimes, some of the ages may have had a minus sign placed in front in error, e.g., child neglect 
--Other crimes seem unlikely to have a child as a victim, e.g., "dishonest employee-grand theft"
--Other crimes might or might not have a child as a victim, e.g., human trafficking 

--Check which Crime Codes specifically deal with children
SELECT DISTINCT([Crm Cd Desc]), [Crm Cd]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Crm Cd]

SELECT DISTINCT([Crm Cd Desc]), [Crm Cd]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd Desc] LIKE '%CHILD%' OR [Crm Cd Desc] LIKE '%CHLD%' OR [Crm Cd Desc] LIKE '%MINOR%' OR [Crm Cd Desc] LIKE '%SCHOOL%'
ORDER BY [Crm Cd]

--Crime Codes that are child-related: 235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922 

--For non-child-specific primary crimes, check if any additional crimes (Crime Codes 2, 3, 4) are child-related
--Crime Code 1 should match the Crime Code--will check first for any discrepancies between the two columns




--CRIME CODE 1, CRIME CODE 2, CRIME CODE 3

--Check if Crime Code 1 and the Crime Code match
SELECT [Crm Cd], [Crm Cd 1]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1]

SELECT [Crm Cd], [Crm Cd 1], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1]

--In these rows, the values of Crime Code 1 and Crime Code 2 appear to be switched

--Check if in all of these rows Crime Code 1 = Crime Code 2
SELECT [Crm Cd], [Crm Cd 1], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1] AND [Crm Cd] <> [Crm Cd 2]

--In 5 rows, the Crime Code = Crime Code 3
--For these rows, will set Crime Code 3 = Crime Code 2, Crime Code 2 = Crime Code 1, and Crime Code 1 = the Crime Code

--Preview the data using REPLACE to switch the columns
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 1], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4],
	REPLACE([Crm Cd 1], [Crm Cd 1], [Crm Cd]) AS 'Crm Cd 1 Corrected',
	REPLACE([Crm Cd 2], [Crm Cd 2], [Crm Cd 1]) AS 'Crm Cd 2 Corrected',
	REPLACE([Crm Cd 3], [Crm Cd 3], [Crm Cd 2]) AS 'Crm Cd 3 Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] = [Crm Cd 3]

--Update Crime Codes 1, 2, and 3
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Crm Cd 3] = [Crm Cd 2]
WHERE [Crm Cd] <> [Crm Cd 1] AND [Crm Cd] <> [Crm Cd 2]

SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 1], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1] AND [Crm Cd] <> [Crm Cd 2]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Crm Cd 2] = [Crm Cd 1]
WHERE [Crm Cd] <> [Crm Cd 1] AND [Crm Cd] <> [Crm Cd 2]

SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 1], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd 1] = [Crm Cd 2]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Crm Cd 1] = [Crm Cd]
WHERE [Crm Cd 1] = [Crm Cd 2]

--Review results
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 1], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd 1] = [Crm Cd 2]

--Now address the rows where the Crime Code = Crime Code 2

--Switch the values of Crime Code 1 and Crime Code 2
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 1], [Crm Cd 2], 
	REPLACE([Crm Cd 1], [Crm Cd 1], [Crm Cd 2]) AS 'Crm Cd 1 Corrected',
	REPLACE([Crm Cd 2], [Crm Cd 2], [Crm Cd 1]) AS 'Crm Cd 2 Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Crm Cd 2] = [Crm Cd 1]
WHERE [Crm Cd] <> [Crm Cd 1]

SELECT [Crm Cd], [Crm Cd 1], [Crm Cd Desc], [Crm Cd 2]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1]

--Update Crime Code 1 to match the Crime Code
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Crm Cd 1] = [Crm Cd]
WHERE [Crm Cd] <> [Crm Cd 1]

SELECT [Crm Cd], [Crm Cd 1], [Crm Cd Desc], [Crm Cd 2]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Crm Cd] <> [Crm Cd 1]

--This query now returns nothing, all Crime Codes match their Crime Code 1




--VICTIM AGE, cont.

--Check if any non-child-specific primary crimes have additional crimes (Crime Codes 2, 3, 4) that are child-related
SELECT [Vict Age], [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] < 0) AND 
	([Crm Cd] NOT IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) AND 
	(([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

--There is 1 non-child-specific primary crime that has an additional child-related crime 

--Will remove the minus sign from negative ages where the primary or additional crimes are child-related
--For the rest will set age to NULL as there are no other indications as to what the accurate age is

SELECT [Vict Age], [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] < 0) AND 
	(([Crm Cd] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

SELECT [Vict Age], [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4],
	ABS([Vict Age]) AS 'Age Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] < 0) AND 
	(([Crm Cd] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Vict Age] = ABS([Vict Age])
WHERE ([Vict Age] < 0) AND 
	(([Crm Cd] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))

--Review results
SELECT [Vict Age], [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] < 0) AND 
	(([Crm Cd] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

--Set other negatives ages to NULL
SELECT [Vict Age], NULLIF([Vict Age], [Vict Age]) AS 'Corrected Age'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] < 0

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Vict Age] = NULLIF([Vict Age], [Vict Age])
WHERE [Vict Age] < 0

SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] < 0

--No more rows returned--all negative values removed


--Review cases where victim age is 114
SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] > 100

--Per research, there are people in the United States who have lived to 114, so a victim of age 114 is possible
--Will keep this value


--Review crimes where age is listed as 0                         
SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] = 0

--Some crimes may have 0 listed if the age is unknown (seems likely considering in several rows, victim sex and descent are also unknown)
--Again, some crimes could have an infant as a victim, e.g., child neglect
--Other crimes are not likely to have an infant as a victim, e.g., shoplifting
--And others could have an infant victim or not, e.g., "other miscellaneous crime"

--Review those rows where Victim Age is 0 and Victim Sex and Descent are NULL
--Those cases seem the most likely to have Victim Age listed as 0 because nothing is known about the victim's demographics at all 

SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] = 0) AND ([Vict Sex] IS NULL) AND ([Vict Descent] IS NULL)

SELECT DISTINCT([Crm Cd Desc])
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] = 0) AND ([Vict Sex] IS NULL) AND ([Vict Descent] IS NULL)
ORDER BY [Crm Cd Desc]

--Crimes still include infant-related ones, e.g., child abuse, child neglect, as well as others, e.g., stolen boats and vehicles, arson, assault

--Review list of crimes for cases where Victim Age = 0
SELECT DISTINCT([Crm Cd Desc]), [Crm Cd]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] = 0 
ORDER BY [Crm Cd Desc]

--Review all of the Crime Codes for cases where Victim Age = 0
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Age] = 0
ORDER BY [Crm Cd Desc]

--Check Crime Codes 2, 3, and 4 of non-infant-specific primary crimes to see if any additional crimes are infant-related
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] = 0) AND 
	([Crm Cd] NOT IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) AND 
	(([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

--There are a few crimes where the primary crime is not listed as being infant-related but an additional crime (Crime Code 2) is
--Will keep the Victim Age as 0 for all the rows where either the primary or additional crimes are infant-related 
--For the rest will set age to NULL as there are no other indications as to what the accurate age is

--Review which rows have infant-related primary or additional crimes with Victim Age = 0
SELECT [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] = 0) AND 
	(([Crm Cd] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 2] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR 
	([Crm Cd 3] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)) OR
	([Crm Cd 4] IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922)))
ORDER BY [Crm Cd Desc]

--Set age as NULL for the other rows                                                                                                                 
SELECT [Vict Age], NULLIF([Vict Age], [Vict Age]) AS 'Corrected Age', [Crm Cd], [Crm Cd Desc], [Crm Cd 2], [Crm Cd 3], [Crm Cd 4]            
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Vict Age] = 0) AND 
	([Crm Cd] NOT IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922) AND
	([Crm Cd 2] NOT IN (812, 865) OR [Crm Cd 2] IS NULL))
ORDER BY [Crm Cd Desc]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Vict Age] = NULLIF([Vict Age], [Vict Age])
WHERE ([Vict Age] = 0) AND 
	([Crm Cd] NOT IN (235, 237, 627, 760, 812, 813, 814, 865, 870, 880, 922) AND
	([Crm Cd 2] NOT IN (812, 865) OR [Crm Cd 2] IS NULL))

SELECT *
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Vict Age]




--VICTIM SEX 

--Check if any values besides M, F, or X are in the Victim Sex column
SELECT DISTINCT([Vict Sex])
FROM RTDatabase..LA_Crime_2014_2015

--There is a value H, which is not one of the accepted values

--Review rows where Victim Sex = H
SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Sex] = 'H'

--It is possible that the code for Victim Descent was input in the Victim Sex column in error
--However, that doesn't account for one of the rows, where Victim Sex is H and Victim Descent is O
--No way to determine what the actual value is
--Will replace with null to differentiate from the rows where Victim Sex is explicitly noted as being X = Unknown

SELECT [Vict Sex], NULLIF([Vict Sex], 'H') AS 'Corrected Sex'            
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Vict Sex] = 'H'
                                                       
UPDATE RTDatabase..LA_Crime_2014_2015                                   
SET [Vict Sex] = NULLIF([Vict Sex], 'H')             
WHERE [Vict Sex] = 'H'

--Check the distinct values of the Victim Sex column again
SELECT DISTINCT([Vict Sex])
FROM RTDatabase..LA_Crime_2014_2015

--H is no longer one of the values


--Add a column with the description of the Victim Sex codes  
--Preview the data
SELECT [Vict Sex], 
	CASE
	WHEN [Vict Sex] = 'F' THEN 'Female'
	WHEN [Vict Sex] = 'M' THEN 'Male'
	WHEN [Vict Sex] = 'X' THEN 'Unknown'
	ELSE NULL
	END AS 'Vict Sex Desc'
FROM RTDatabase..LA_Crime_2014_2015

--Add the column to the table
ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Vict Sex Desc] Nvarchar(10)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Vict Sex Desc] = 
	CASE
	WHEN [Vict Sex] = 'F' THEN 'Female'
	WHEN [Vict Sex] = 'M' THEN 'Male'
	WHEN [Vict Sex] = 'X' THEN 'Unknown'
	ELSE NULL
	END 

SELECT [Vict Sex], [Vict Sex Desc]
FROM RTDatabase..LA_Crime_2014_2015




--VICTIM DESCENT 

--Review table
SELECT *
FROM RTDatabase..LA_Crime_2014_2015

--Check if any value in the Victim Descent column is not one of the accepted codes
SELECT DISTINCT([Vict Descent])
FROM RTDatabase..LA_Crime_2014_2015

--All values are one of the accepted codes

--Make a new column with the description of each of the codes
SELECT [Vict Descent], 
	CASE
	WHEN [Vict Descent] = 'A' THEN 'Other Asian'
	WHEN [Vict Descent] = 'B' THEN 'Black'
	WHEN [Vict Descent] = 'C' THEN 'Chinese'
	WHEN [Vict Descent] = 'D' THEN 'Cambodian'
	WHEN [Vict Descent] = 'F' THEN 'Filipino'
	WHEN [Vict Descent] = 'G' THEN 'Guamanian'
	WHEN [Vict Descent] = 'H' THEN 'Hispanic/Latin/Mexican'
	WHEN [Vict Descent] = 'I' THEN 'American Indian/Alaskan Native'
	WHEN [Vict Descent] = 'J' THEN 'Japanese'
	WHEN [Vict Descent] = 'K' THEN 'Korean'
	WHEN [Vict Descent] = 'L' THEN 'Laotian'
	WHEN [Vict Descent] = 'O' THEN 'Other'
	WHEN [Vict Descent] = 'P' THEN 'Pacific Islander'
	WHEN [Vict Descent] = 'S' THEN 'Samoan'
	WHEN [Vict Descent] = 'U' THEN 'Hawaiian'
	WHEN [Vict Descent] = 'V' THEN 'Vietnamese'
	WHEN [Vict Descent] = 'W' THEN 'White'
	WHEN [Vict Descent] = 'X' THEN 'Unknown'
	WHEN [Vict Descent] = 'Z' THEN 'Asian Indian'
	ELSE NULL
	END AS 'Vict Descent Desc'
FROM RTDatabase..LA_Crime_2014_2015

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Vict Descent Desc] Nvarchar(50)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Vict Descent Desc] = 
	CASE
	WHEN [Vict Descent] = 'A' THEN 'Other Asian'
	WHEN [Vict Descent] = 'B' THEN 'Black'
	WHEN [Vict Descent] = 'C' THEN 'Chinese'
	WHEN [Vict Descent] = 'D' THEN 'Cambodian'
	WHEN [Vict Descent] = 'F' THEN 'Filipino'
	WHEN [Vict Descent] = 'G' THEN 'Guamanian'
	WHEN [Vict Descent] = 'H' THEN 'Hispanic/Latin/Mexican'
	WHEN [Vict Descent] = 'I' THEN 'American Indian/Alaskan Native'
	WHEN [Vict Descent] = 'J' THEN 'Japanese'
	WHEN [Vict Descent] = 'K' THEN 'Korean'
	WHEN [Vict Descent] = 'L' THEN 'Laotian'
	WHEN [Vict Descent] = 'O' THEN 'Other'
	WHEN [Vict Descent] = 'P' THEN 'Pacific Islander'
	WHEN [Vict Descent] = 'S' THEN 'Samoan'
	WHEN [Vict Descent] = 'U' THEN 'Hawaiian'
	WHEN [Vict Descent] = 'V' THEN 'Vietnamese'
	WHEN [Vict Descent] = 'W' THEN 'White'
	WHEN [Vict Descent] = 'X' THEN 'Unknown'
	WHEN [Vict Descent] = 'Z' THEN 'Asian Indian'
	ELSE NULL
	END 

SELECT [Vict Descent], [Vict Descent Desc]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Vict Descent]




--PREMISES CODE and PREMISES DESCRIPTION 

SELECT *
FROM RTDatabase..LA_Crime_2014_2015

--Check if any NULL values in Premises Code and Premises Description columns
SELECT [Premis Cd], [Premis Desc]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Premis Cd] IS NULL) OR ([Premis Desc] IS NULL)

--When one column is NULL, the other is also NULL, so unable to fill in one column based on the other




--WEAPON USED CODE and WEAPON DESCRIPTION / STATUS and STATUS DESCRIPTION

SELECT *
FROM RTDatabase..LA_Crime_2014_2015

--Check for NULLs in Weapon Used Code/Weapon Description and Status/Status Description columns
SELECT [Weapon Used Cd], [Weapon Desc]
FROM RTDatabase..LA_Crime_2014_2015
WHERE (([Weapon Used Cd] IS NULL) OR ([Weapon Desc] IS NULL)) AND (([Weapon Used Cd] IS NOT NULL) OR ([Weapon Desc] IS NOT NULL))


SELECT Status, [Status Desc]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ((Status IS NULL) OR ([Status Desc] IS NULL)) AND ((Status IS NOT NULL) OR ([Status Desc] IS NOT NULL))

--For both pairs of columns, when one column is NULL, the other is also NULL, so unable to fill in one column based on the other's value




--LOCATION 

SELECT *
FROM RTDatabase..LA_Crime_2014_2015

--Clean up the Location column by reducing the spaces in between the street name and the street type, e.g., ST, AV
SELECT LOCATION, REPLACE(LOCATION, '       ', ' ') AS 'Location Corrected'
FROM RTDatabase..LA_Crime_2014_2015

--It did not remove all of the space, and the space removed was not equal between rows
--There might be hidden characters, instead of spaces, in between the words

--Try trimming the large spaces from the Location column
SELECT LOCATION, TRIM('     ' FROM LOCATION) AS 'Location Trimmed'
FROM RTDatabase..LA_Crime_2014_2015

--No change 

--Try using PARSENAME
SELECT LOCATION, PARSENAME(REPLACE(LOCATION, ' ', '.'), 3) AS 'Street Number', 
PARSENAME(REPLACE(LOCATION, ' ', '.'), 2) AS 'Street', 
PARSENAME(REPLACE(LOCATION, ' ', '.'), 1) AS 'Street Type'
FROM RTDatabase..LA_Crime_2014_2015

--No change
--Spaces were only recognized in certain instances, like in between parts of a multi-word street name (e.g., La Brea)

--Try dividing up names in a different way

--First check the actual length of the entries in the Location column
SELECT LOCATION, LEN(LOCATION) AS 'Actual Length'
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Actual Length]

--In many cases, the length is greater than the number of visible characters and regular spaces
--Some rows have a different number of visible characters but still show the same length (e.g., "00 65TH ST" and "00 ANCHORAGE ST")

--Start with separating the street numbers from the Locations that have them
SELECT LOCATION, TRIM(SUBSTRING(LOCATION, 0, CHARINDEX(LOCATION, '00')+6)) AS 'Street Number'
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE '%00%'

--Needed to include +6 to obtain the correct street number in most cases
--Was able to extract the whole street number from each row 
--However, 3-digit street numbers also included the direction from the street name (e.g., 500 S)--can address later
--Cannot cut the direction without removing a digit from some of the other street numbers 

--Now try extracting the street name with street type

SELECT LOCATION, TRIM(SUBSTRING(LOCATION, CHARINDEX(LOCATION, '00')+6, LEN(LOCATION))) AS 'Street'
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE '%00%'

--This mostly worked to extract the street name and street type
--Street names with a 3-digit street number and a direction (N/S/E/W) are missing the direction from the beginning--can address later
--For example, "500 S FLOWER ST" was extracted as "FLOWER ST"

--Add a column for the street number 
ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Street Number] Nvarchar(25)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Number] = TRIM(SUBSTRING(LOCATION, 0, CHARINDEX(LOCATION, '00')+6))
WHERE LOCATION LIKE '%00%'

SELECT LOCATION, [Street Number]
FROM RTDatabase..LA_Crime_2014_2015

--Add a column for the street name with street type
ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Street Name and Type] Nvarchar(255)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name and Type] =TRIM(SUBSTRING(LOCATION, CHARINDEX(LOCATION, '00')+6, LEN(LOCATION))) 
WHERE LOCATION LIKE '%00%'

SELECT LOCATION, [Street Number], [Street Name and Type]
FROM RTDatabase..LA_Crime_2014_2015


--Try to split up [Street Name and Type] in the rows without a missing direction from the beginning 

SELECT DISTINCT([Street Name and Type])
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] NOT LIKE '%[A-Z]%'
ORDER BY [Street Name and Type]

SELECT [Street Name and Type], 
	TRIM(SUBSTRING([Street Name and Type], 0, 25)) AS 'Street Name', 
	TRIM(SUBSTRING([Street Name and Type], 25, LEN([Street Name and Type]))) AS 'Street Type'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] NOT LIKE '%[A-Z]%'

--The Street Name and the Street Type were successfully separated and trimmed
--Index of 25 based on the length of the longest street name noted (W Martin Luther King Jr)

--Update table
ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Street Name] Nvarchar(75)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING([Street Name and Type], 0, 25)) 
WHERE [Street Number] NOT LIKE '%[A-Z]%'

SELECT [Street Name and Type], [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL


ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Street Type] Nvarchar(5)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(SUBSTRING([Street Name and Type], 25, LEN([Street Name and Type]))) 
WHERE [Street Number] NOT LIKE '%[A-Z]%'

SELECT [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL

--Upon further review, some Street Types are blank but not NULL--may be filled with hidden characters

--Review those rows
SELECT [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PK', 'CR'))
ORDER BY [Street Name and Type]

--Most have no Street Type indicated in the [Street Name and Type] column
--Some have the Street Type still included in the Street Name column, e.g., CAHUENGA BL

--Review those rows with Street Type still included in the Street Name column
SELECT [Street Name and Type], [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PK', 'CR')) AND
	(([Street Name] LIKE '%BL') OR ([Street Name] LIKE '%AV') OR ([Street Name] LIKE '%ST') OR ([Street Name] LIKE '%CI') OR ([Street Name] LIKE '%PL') OR
	([Street Name] LIKE '%WY') OR ([Street Name] LIKE '%DR') OR ([Street Name] LIKE '%TL') OR ([Street Name] LIKE '%RD') OR ([Street Name] LIKE '%WK') OR
	([Street Name] LIKE '%LN') OR ([Street Name] LIKE '%CT') OR ([Street Name] LIKE '%HY') OR ([Street Name] LIKE '%TR') OR ([Street Name] LIKE '%PY') OR
	([Street Name] LIKE '%ML') OR ([Street Name] LIKE '%PA') OR ([Street Name] LIKE '%PK') OR ([Street Name] LIKE '%CR'))
ORDER BY [Street Name]

--Only noted Street Types in those Street Names are DR, BL, CI, WY, PWY, ST, and AV
--In these rows, the Street Type appears to be separated from the Street Name by a regular space

--Try to use PARSENAME to split up the Street Types from the Street Names
SELECT [Street Name and Type], [Street Name], [Street Type], 
	PARSENAME(REPLACE([Street Name], ' ', '.'), 1) AS 'Street Type Corrected', 
	PARSENAME(REPLACE([Street Name], ' ', '.'), 2) AS 'Street Name Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL AND
	[Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PK', 'CR') AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY'))
ORDER BY [Street Name]

--This worked, except for Street Names with a space in them, e.g. LONG BEACH

--Try to use SUBSTRING instead
SELECT [Street Name and Type], [Street Name], [Street Type],
	TRIM(SUBSTRING([Street Name], 0, LEN([Street Name])-2)) AS 'Street Name Corrected',
	TRIM(SUBSTRING([Street Name], LEN([Street Name])-2, LEN([Street Name]))) AS 'Street Type Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL AND
	[Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PK', 'CR') AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY'))
ORDER BY [Street Name]

--The Street Name and Street Type are now correctly split in these rows, even when Street Type was PWY

--Update table
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(SUBSTRING([Street Name], LEN([Street Name])-2, LEN([Street Name])))
WHERE [Street Name] IS NOT NULL AND
	[Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PK', 'CR') AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY'))

--Review the updated Street Type column
SELECT [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY'))
ORDER BY [Street Name]

--Exclude "UNIVERSAL CI" and "UNIVERSAL ST" from the following queries as those rows already have a Street Type and do not need to be shortened 
--In those rows, e.g., [Street Name and Type] = UNIVERSAL CI DR, Street Name = UNIVERSAL CI, Street Type = DR

--Trim the Street Type from the Street Name column
SELECT [Street Name and Type], [Street Name], [Street Type],
	TRIM(SUBSTRING([Street Name], 0, LEN([Street Name])-2)) AS 'Street Name Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NOT NULL AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY')) AND
	[Street Name] NOT LIKE 'UNIVERSAL%'
ORDER BY [Street Name]

--Update table
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING([Street Name], 0, LEN([Street Name])-2))
WHERE [Street Name] IS NOT NULL AND
	(([Street Name] LIKE '% BL') OR ([Street Name] LIKE '% AV') OR ([Street Name] LIKE '% ST') OR ([Street Name] LIKE '% CI') OR
	([Street Name] LIKE '% WY') OR ([Street Name] LIKE '% DR') OR ([Street Name] LIKE '% PWY')) AND
	[Street Name] NOT LIKE 'UNIVERSAL%'

SELECT LOCATION, [Street Name and Type], [Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015


--Address the Street Types that still have non-NULL blanks/hidden characters 
SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PWY', 'CR', 'PK'))
ORDER BY [Street Name]

--Set their Street Type to NULL
SELECT [Street Name and Type], [Street Name], [Street Type], NULLIF([Street Type], [Street Type]) AS 'Street Type Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PWY', 'CR', 'PK'))
ORDER BY [Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULLIF([Street Type], [Street Type])
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PWY', 'CR', 'PK'))

--Check table for any more blank Street Types
SELECT LOCATION, [Street Name and Type], [Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name] IS NOT NULL) AND 
	([Street Type] NOT IN('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'PWY', 'CR', 'PK'))

--Nothing returned--no more blanks


SELECT LOCATION, [Street Name and Type],[Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015

--Address the [Street Name and Type] values with a missing direction--find those rows by using the Street Numbers that have non-digit characters
SELECT LOCATION, [Street Number], [Street Name and Type]           
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%'

--The extra characters in the Street Number columns are for North, South, etc. Check if any other extra letters
SELECT LOCATION, [Street Number], [Street Name and Type]           
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '%N%' AND [Street Number] NOT LIKE '%S%' AND [Street Number] NOT LIKE '%E%'
	AND [Street Number] NOT LIKE '%W%'

--100th St. is the only other Street Number with a non-digit character. Will exclude from the following queries and will address later

SELECT LOCATION, [Street Number], [Street Name and Type]           
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%'

SELECT LOCATION, [Street Number], [Street Name and Type], 
	TRIM(SUBSTRING(LOCATION, 0, 4)) AS 'Street Number Corrected',
	TRIM(SUBSTRING(LOCATION, 5, LEN(LOCATION))) AS 'Street Name and Type Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%'
ORDER BY LOCATION

--Street Number and [Street Name and Type] are correct now except for rows with Street Number of only 2 digits (00) and rows with Location = BERTH 200/400     

--First address those rows with Street Number of only 2 digits
--In these rows, the Street Number still includes the direction while [Street Name and Type] is missing the N/S/E/W from the beginning

SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] LIKE '00%'
ORDER BY LOCATION

--Will try to correct by taking new substrings from the LOCATION column
SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type],
	TRIM(SUBSTRING(LOCATION, 0, 3)) AS 'Street Number',
	TRIM(SUBSTRING(LOCATION, 3, LEN(LOCATION)-4)) AS 'Street Name',
	TRIM(SUBSTRING(LOCATION, LEN(LOCATION)-1, LEN(LOCATION))) AS 'Street Type'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] LIKE '00%'
ORDER BY LOCATION

--Needed to experiment with different indices for the Street Number, Street Name, and Street Type to be extracted correctly

--Update the table
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(SUBSTRING(LOCATION, LEN(LOCATION)-1, LEN(LOCATION)))
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] LIKE '00%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING(LOCATION, 3, LEN(LOCATION)-4))
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] LIKE '00%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Number] = TRIM(SUBSTRING(LOCATION, 0, 3))
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] LIKE '00%'

SELECT LOCATION, [Street Name and Type], [Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE '00%'
ORDER BY LOCATION


--Next address rows with Location = BERTH 200 or BERTH 400 
SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%' AND LOCATION LIKE 'BERTH%'
ORDER BY LOCATION

--In these rows, Street Number = BERTH and [Street Name and Type] = 200 or 400

--Update the table
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Number] = NULL
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%' AND LOCATION LIKE 'BERTH%'

SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE 'BERTH%' AND [Street Name and Type] LIKE '%00'
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = LOCATION
WHERE LOCATION LIKE 'BERTH%' AND [Street Name and Type] LIKE '%00'

SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE 'BERTH%' 
ORDER BY LOCATION


--Check if the rest of the rows missing the direction in the [Street Name and Type] column have been split correctly 
SELECT LOCATION, [Street Number], [Street Name and Type], 
	TRIM(SUBSTRING(LOCATION, 0, 4)) AS 'Street Number Corrected',
	TRIM(SUBSTRING(LOCATION, 5, LEN(LOCATION))) AS 'Street Name and Type Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%'
ORDER BY LOCATION

--Update the table
UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name and Type] = TRIM(SUBSTRING(LOCATION, 5, LEN(LOCATION)))
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%'

SELECT LOCATION, [Street Number], [Street Name and Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '100TH%'
ORDER BY LOCATION


--Can now address the row where Location = 100TH ST (Street Number = 100TH, [Street Name and Type] = ST)
SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION LIKE '100TH%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Number] = NULL
WHERE LOCATION LIKE '100TH%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = '100TH'
WHERE LOCATION LIKE '100TH%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = 'ST'
WHERE LOCATION LIKE '100TH%'

SELECT LOCATION, [Street Number], [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] = '100TH'


--Will now address the remaining Street Numbers with extra characters (the direction abbreviations)                             
SELECT LOCATION, [Street Number]              
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%'
ORDER BY LOCATION

--All the extra characters should now be for North, South, etc. Check if any other extra letters
SELECT LOCATION, [Street Number]              
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%' AND [Street Number] NOT LIKE '%N%' AND [Street Number] NOT LIKE '%S%' AND [Street Number] NOT LIKE '%E%'
	AND [Street Number] NOT LIKE '%W%'

--No other letters in the Street Number column; remove the letter from the Street Number

SELECT [Street Number], 
	TRIM(SUBSTRING([Street Number], 0, 4)) AS 'Street Number Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%'
ORDER BY [Street Number]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Number] = TRIM(SUBSTRING([Street Number], 0, 4))
WHERE [Street Number] LIKE '%[A-Z]%'

SELECT LOCATION, [Street Number]              
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Number] LIKE '%[A-Z]%'
ORDER BY LOCATION

--No Street Numbers returned--all letters in the Street Number column removed


--Review the table--check rows where [Street Name and Type] and Street Name are still NULL
SELECT LOCATION, [Street Name and Type],[Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NULL AND [Street Name] IS NULL

--Fill in the Street Name column for those values in the Location column that only include a street name
SELECT LOCATION, [Street Name and Type],[Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name and Type] IS NULL) AND 
	(LOCATION NOT LIKE '%BL%') AND (LOCATION NOT LIKE '%AV%') AND (LOCATION NOT LIKE '%ST%') AND (LOCATION NOT LIKE '%CI%') AND (LOCATION NOT LIKE '%PL%') AND
	(LOCATION NOT LIKE '%WY%') AND (LOCATION NOT LIKE '%DR%') AND (LOCATION NOT LIKE '%TL%') AND (LOCATION NOT LIKE '%RD%') AND (LOCATION NOT LIKE '%WK%') AND
	(LOCATION NOT LIKE '%LN%') AND (LOCATION NOT LIKE '%CT%') AND (LOCATION NOT LIKE '%HY%') AND (LOCATION NOT LIKE '%TR%') AND (LOCATION NOT LIKE '%PY%') AND
	(LOCATION NOT LIKE '%ML%') AND (LOCATION NOT LIKE '%PA%') AND (LOCATION NOT LIKE '%FY%') AND (LOCATION NOT LIKE '%CR%') AND (LOCATION NOT LIKE '%PK%')
ORDER BY LOCATION

--Some Locations = 0; will address them first
SELECT *
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = '0'

--Seems that Location was set to 0 because the Location was unknown; Cross Street, Latitude, and Longitude for those rows are also NULL or 0

--Change the 0 to NULL in the Location column
SELECT LOCATION, NULLIF(LOCATION, '0') AS 'Location Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = '0'

UPDATE RTDatabase..LA_Crime_2014_2015
SET LOCATION = NULLIF(LOCATION, '0')
WHERE LOCATION = '0'

SELECT LOCATION
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = '0'

--Nothing returned, no more Locations with value 0


--Set Street Name = Location for rows which only have a street name (no street type) in the LOCATION column

--With this query, should exclude the Locations with the street types separated from the street names by hidden, non-alphanumeric characters
SELECT LOCATION, [Street Name], [Street Name and Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name and Type] IS NULL) AND ([Street Name] IS NULL) AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]BL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]AV%') AND (LOCATION NOT LIKE '%[^A-Z0-9]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CI%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]DR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]WK%') AND (LOCATION NOT LIKE '%[^A-Z0-9]LN%') AND (LOCATION NOT LIKE '%[^A-Z0-9]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]HY%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]ML%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PA%') AND (LOCATION NOT LIKE '%[^A-Z0-9]FY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PK%')
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = LOCATION
WHERE ([Street Name and Type] IS NULL) AND ([Street Name] IS NULL) AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]BL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]AV%') AND (LOCATION NOT LIKE '%[^A-Z0-9]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CI%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]DR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]WK%') AND (LOCATION NOT LIKE '%[^A-Z0-9]LN%') AND (LOCATION NOT LIKE '%[^A-Z0-9]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]HY%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]ML%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PA%') AND (LOCATION NOT LIKE '%[^A-Z0-9]FY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PK%')

--Review table
SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name and Type] IS NULL) AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]BL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]AV%') AND (LOCATION NOT LIKE '%[^A-Z0-9]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CI%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]DR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TL%') AND (LOCATION NOT LIKE '%[^A-Z0-9]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]WK%') AND (LOCATION NOT LIKE '%[^A-Z0-9]LN%') AND (LOCATION NOT LIKE '%[^A-Z0-9]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]HY%') AND (LOCATION NOT LIKE '%[^A-Z0-9]TR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]ML%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PA%') AND (LOCATION NOT LIKE '%[^A-Z0-9]FY%') AND 
	(LOCATION NOT LIKE '%[^A-Z0-9]CR%') AND (LOCATION NOT LIKE '%[^A-Z0-9]PK%')
ORDER BY LOCATION


--Check rows that still have NULL [Street Name and Type] and NULL Street Name columns
SELECT LOCATION,[Street Number], [Street Name and Type], [Street Name],[Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NULL AND [Street Name] IS NULL 
ORDER BY LOCATION

--Still a few Locations that only include a street name that did not have the Street Name column filled in

SELECT DISTINCT(LOCATION)
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NULL AND [Street Name] IS NULL 
ORDER BY LOCATION

--The previous table update had excluded them becase within their names, they had a street type abbreviation that was preceded by a non-alphanumeric character 
--For example: CENTURY PARK (the "PA" is preceded by a space)
--Also one instace of a street name and a street type that were separated by a regular space (HUNTINGTON DR)

--Address HUNTINGTON DR first
SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = 'HUNTINGTON DR'

SELECT LOCATION, 
	TRIM(PARSENAME(REPLACE(LOCATION, ' ', '.'), 1)) AS 'Street Type',
	TRIM(PARSENAME(REPLACE(LOCATION, ' ', '.'), 2)) AS 'Street Name'
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = 'HUNTINGTON DR'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(PARSENAME(REPLACE(LOCATION, ' ', '.'), 1))
WHERE LOCATION = 'HUNTINGTON DR'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(PARSENAME(REPLACE(LOCATION, ' ', '.'), 2))
WHERE LOCATION = 'HUNTINGTON DR'

SELECT LOCATION, [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE LOCATION = 'HUNTINGTON DR'


--Address the remaining Locations that only include a Street Name but did not have the Street Name column filled in
SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE (([Street Name and Type] IS NULL) AND ([Street Name] IS NULL)) AND
	((LOCATION LIKE '%[A-Z] BL%') OR (LOCATION LIKE '%[A-Z] AV%') OR (LOCATION LIKE '%[A-Z] ST%') OR (LOCATION LIKE '%[A-Z] CI%') OR 
	(LOCATION LIKE '%[A-Z] PL%') OR (LOCATION LIKE '%[A-Z] WY%') OR (LOCATION LIKE '%[A-Z] DR%') OR (LOCATION LIKE '%[A-Z] TL%') OR 
	(LOCATION LIKE '%[A-Z] RD%') OR (LOCATION LIKE '%[A-Z] WK%') OR (LOCATION LIKE '%[A-Z] LN%') OR (LOCATION LIKE '%[A-Z] CT%') OR 
	(LOCATION LIKE '%[A-Z] HY%') OR (LOCATION LIKE '%[A-Z] TR%') OR (LOCATION LIKE '%[A-Z] PY%') OR (LOCATION LIKE '%[A-Z] ML%') OR 
	(LOCATION LIKE '%[A-Z] PA%') OR (LOCATION LIKE '%[A-Z] FY%') OR (LOCATION LIKE '%[A-Z] CR%') OR (LOCATION LIKE '%[A-Z] PK%')) AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]BL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]AV%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]CI%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]DR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]WK%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]LN%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]HY%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PY%') AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]ML%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PA%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]FY%')
ORDER BY LOCATION

--Preceding query able to retrieve most of the needed Locations while excluding their variations that include a street type
--2 values were not able to be retrieved using this query (N AVENUE and W AVENUE)--will address later

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = LOCATION
WHERE (([Street Name and Type] IS NULL) AND ([Street Name] IS NULL)) AND
	((LOCATION LIKE '%[A-Z] BL%') OR (LOCATION LIKE '%[A-Z] AV%') OR (LOCATION LIKE '%[A-Z] ST%') OR (LOCATION LIKE '%[A-Z] CI%') OR 
	(LOCATION LIKE '%[A-Z] PL%') OR (LOCATION LIKE '%[A-Z] WY%') OR (LOCATION LIKE '%[A-Z] DR%') OR (LOCATION LIKE '%[A-Z] TL%') OR 
	(LOCATION LIKE '%[A-Z] RD%') OR (LOCATION LIKE '%[A-Z] WK%') OR (LOCATION LIKE '%[A-Z] LN%') OR (LOCATION LIKE '%[A-Z] CT%') OR 
	(LOCATION LIKE '%[A-Z] HY%') OR (LOCATION LIKE '%[A-Z] TR%') OR (LOCATION LIKE '%[A-Z] PY%') OR (LOCATION LIKE '%[A-Z] ML%') OR 
	(LOCATION LIKE '%[A-Z] PA%') OR (LOCATION LIKE '%[A-Z] FY%') OR (LOCATION LIKE '%[A-Z] CR%') OR (LOCATION LIKE '%[A-Z] PK%')) AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]BL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]AV%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]CI%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]DR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]WK%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]LN%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]HY%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PY%') AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]ML%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PA%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]FY%')

SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Street Name and Type] IS NULL) AND
	((LOCATION LIKE '%[A-Z] BL%') OR (LOCATION LIKE '%[A-Z] AV%') OR (LOCATION LIKE '%[A-Z] ST%') OR (LOCATION LIKE '%[A-Z] CI%') OR 
	(LOCATION LIKE '%[A-Z] PL%') OR (LOCATION LIKE '%[A-Z] WY%') OR (LOCATION LIKE '%[A-Z] DR%') OR (LOCATION LIKE '%[A-Z] TL%') OR 
	(LOCATION LIKE '%[A-Z] RD%') OR (LOCATION LIKE '%[A-Z] WK%') OR (LOCATION LIKE '%[A-Z] LN%') OR (LOCATION LIKE '%[A-Z] CT%') OR 
	(LOCATION LIKE '%[A-Z] HY%') OR (LOCATION LIKE '%[A-Z] TR%') OR (LOCATION LIKE '%[A-Z] PY%') OR (LOCATION LIKE '%[A-Z] ML%') OR 
	(LOCATION LIKE '%[A-Z] PA%') OR (LOCATION LIKE '%[A-Z] FY%') OR (LOCATION LIKE '%[A-Z] CR%') OR (LOCATION LIKE '%[A-Z] PK%')) AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]BL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]AV%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]ST%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]CI%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]WY%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]DR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TL%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]RD%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]WK%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]LN%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]CT%') AND 
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]HY%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]TR%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PY%') AND
	(LOCATION NOT LIKE '%[^A-Z][^A-Z]ML%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]PA%') AND (LOCATION NOT LIKE '%[^A-Z][^A-Z]FY%')
ORDER BY LOCATION

--Address N AVENUE and W AVENUE
SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NULL AND [Street Name and Type] IS NULL AND LOCATION LIKE '% AVENUE %'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = LOCATION 
WHERE [Street Name] IS NULL AND [Street Name and Type] IS NULL AND LOCATION LIKE '% AVENUE %'

SELECT LOCATION, [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NULL AND LOCATION LIKE '% AVENUE %'


--Review table--check which rows still do not have the Street Name column filled in
SELECT LOCATION, [Street Name and Type], [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NULL
ORDER BY LOCATION

--Start with the rows that do not have the [Street Name and Type] column filled in
SELECT LOCATION,
	TRIM(SUBSTRING(LOCATION, 0, LEN(LOCATION)-2)) AS 'Street Name',
	TRIM(SUBSTRING(LOCATION, LEN(LOCATION)-2, LEN(LOCATION))) AS 'Street Type'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NULL AND [Street Name and Type] IS NULL AND LOCATION IS NOT NULL
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(SUBSTRING(LOCATION, LEN(LOCATION)-2, LEN(LOCATION)))
WHERE [Street Name] IS NULL AND [Street Name and Type] IS NULL AND LOCATION IS NOT NULL

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING(LOCATION, 0, LEN(LOCATION)-2))
WHERE [Street Name] IS NULL AND [Street Name and Type] IS NULL AND LOCATION IS NOT NULL

SELECT LOCATION, [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NULL AND LOCATION IS NOT NULL AND [Street Type] IS NOT NULL
ORDER BY LOCATION


--Work on rows with the [Street Name and Type] column filled in
SELECT LOCATION, [Street Name and Type], [Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NOT NULL AND [Street Name] IS NULL
ORDER BY LOCATION

SELECT LOCATION, [Street Name and Type], 
	TRIM(SUBSTRING([Street Name and Type], 0, LEN([Street Name and Type])-2)) AS 'Street Name',
	TRIM(SUBSTRING([Street Name and Type], LEN([Street Name and Type])-2, LEN([Street Name and Type]))) AS 'Street Type'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NOT NULL AND [Street Name] IS NULL
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = TRIM(SUBSTRING([Street Name and Type], LEN([Street Name and Type])-2, LEN([Street Name and Type])))
WHERE [Street Name and Type] IS NOT NULL AND [Street Name] IS NULL

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING([Street Name and Type], 0, LEN([Street Name and Type])-2))
WHERE [Street Name and Type] IS NOT NULL AND [Street Name] IS NULL

SELECT LOCATION, [Street Name and Type], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name and Type] IS NOT NULL AND [Street Type] IS NOT NULL
ORDER BY LOCATION


--Check if any more rows have NULL Street Name columns
SELECT LOCATION, [Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] IS NULL AND LOCATION IS NOT NULL

--No more NULL Street Names, all are filled in


SELECT LOCATION, [Street Name and Type], [Street Number], [Street Name], [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LOCATION

--Create new Location column using the Street Number, Street Name, and Street Type columns
SELECT LOCATION, [Street Number], [Street Name], [Street Type],
	[Street Number] + ' ' + [Street Name] + ' ' + [Street Type] AS 'Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LOCATION

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Location Updated] Nvarchar(255)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = [Street Number] + ' ' + [Street Name] + ' ' + [Street Type]

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LOCATION


SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL
ORDER BY LOCATION

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated],
	[Street Number] + ' ' + [Street Name] AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL AND [Street Type] IS NULL AND LOCATION IS NOT NULL
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = [Street Number] + ' ' + [Street Name]
WHERE [Location Updated] IS NULL AND [Street Type] IS NULL AND LOCATION IS NOT NULL


SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL
ORDER BY LOCATION

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated],
	[Street Name] + ' ' + [Street Type] AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL AND [Street Number] IS NULL AND LOCATION IS NOT NULL
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = [Street Name] + ' ' + [Street Type]
WHERE [Location Updated] IS NULL AND [Street Number] IS NULL AND LOCATION IS NOT NULL


SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL
ORDER BY LOCATION

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated],
	[Street Name] AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL AND [Street Number] IS NULL AND [Street Type] IS NULL AND LOCATION IS NOT NULL
ORDER BY LOCATION

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = [Street Name]
WHERE [Location Updated] IS NULL AND [Street Number] IS NULL AND [Street Type] IS NULL AND LOCATION IS NOT NULL

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] IS NULL AND LOCATION IS NOT NULL
ORDER BY LOCATION

SELECT LOCATION, [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LOCATION


--Drop [Street Name and Type] column
ALTER TABLE RTDatabase..LA_Crime_2014_2015
DROP COLUMN [Street Name and Type]




--CROSS STREET 

--Clean up the Cross Street column
SELECT [Cross Street]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street] IS NOT NULL
ORDER BY [Cross Street]

--Start with Cross Streets without cross street types
SELECT [Cross Street]
FROM RTDatabase..LA_Crime_2014_2015
WHERE ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]BL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]AV%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]ST%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]CI%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]WY%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]DR%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]TL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]RD%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]WK%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]LN%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]CT%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]HY%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]TR%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PY%') AND
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]ML%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PA%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]FY%')
ORDER BY [Cross Street]

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Cross Street Name] Nvarchar(75)

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Cross Street Type] Nvarchar(5)

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Cross Street Updated] Nvarchar(255)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = [Cross Street]
WHERE ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]BL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]AV%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]ST%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]CI%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]WY%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]DR%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]TL%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]RD%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]WK%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]LN%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]CT%') AND 
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]HY%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]TR%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PY%') AND
	([Cross Street] NOT LIKE '%[^A-Z][^A-Z]ML%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]PA%') AND ([Cross Street] NOT LIKE '%[^A-Z][^A-Z]FY%')

SELECT [Cross Street], [Cross Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NOT NULL 
ORDER BY [Cross Street]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street Name]
WHERE [Cross Street Name] IS NOT NULL

SELECT [Cross Street], [Cross Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL
ORDER BY [Cross Street]


--Some Cross Streets without a cross street type still do not have Cross Street Name filled in
--Work on the Cross Streets that do include a cross street type instead

SELECT [Cross Street], [Cross Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL AND 
	(([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]BL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]AV%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ST%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CI%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WY%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]DR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]RD%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WK%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]LN%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CT%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]HY%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PY%') OR
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ML%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PA%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]FY%'))
ORDER BY [Cross Street]

SELECT [Cross Street], 
	TRIM(SUBSTRING([Cross Street], 0, LEN([Cross Street])-2)) AS 'Cross Street Name',
	TRIM(SUBSTRING([Cross Street], LEN([Cross Street])-2, LEN([Cross Street]))) AS 'Cross Street Type'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL AND 
	(([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]BL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]AV%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ST%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CI%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WY%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]DR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]RD%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WK%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]LN%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CT%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]HY%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PY%') OR
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ML%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PA%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]FY%'))
ORDER BY [Cross Street]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = TRIM(SUBSTRING([Cross Street], LEN([Cross Street])-2, LEN([Cross Street])))
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL AND 
	(([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]BL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]AV%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ST%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CI%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WY%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]DR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]RD%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WK%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]LN%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CT%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]HY%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PY%') OR
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ML%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PA%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]FY%'))

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(SUBSTRING([Cross Street], 0, LEN([Cross Street])-2))
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL AND 
	(([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]BL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]AV%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ST%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CI%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WY%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]DR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TL%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]RD%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]WK%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]LN%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]CT%') OR 
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]HY%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]TR%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PY%') OR
	([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]ML%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]PA%') OR ([Cross Street] LIKE '%[^A-Z0-9][^A-Z0-9]FY%'))

SELECT [Cross Street], [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street] IS NOT NULL
ORDER BY [Cross Street]


--Address the remaining Cross Streets with a NULL Cross Street Name column
SELECT [Cross Street], [Cross Street Name]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street]
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = [Cross Street]
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL

SELECT [Cross Street], [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street] IS NOT NULL
ORDER BY [Cross Street]


SELECT [Cross Street], [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] IS NULL AND [Cross Street] IS NOT NULL
ORDER BY [Cross Street]

--Fill in the rows where Cross Street Updated is still NULL
SELECT [Cross Street], [Cross Street Name], [Cross Street Type], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] IS NULL AND [Cross Street] IS NOT NULL
ORDER BY [Cross Street]

SELECT [Cross Street], [Cross Street Name], [Cross Street Type],
	[Cross Street Name] + ' ' + [Cross Street Type] AS 'Cross Street Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] IS NULL AND [Cross Street] IS NOT NULL
ORDER BY [Cross Street]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street Name] + ' ' + [Cross Street Type]
WHERE [Cross Street Updated] IS NULL AND [Cross Street] IS NOT NULL

SELECT [Cross Street], [Cross Street Name], [Cross Street Type], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street] IS NOT NULL
ORDER BY [Cross Street]




--LATITUDE and LONGITUDE 

--Review Latitude and Longitude columns
SELECT LOCATION, LAT, LON
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LAT

--Besides the 0 values, check if any Latitudes or Longitudes are out-of-range 
--Latitude should be 33 to 34 while Longitude should be -118 to -117

SELECT LOCATION, LAT, LON
FROM RTDatabase..LA_Crime_2014_2015
WHERE (LAT < 33) OR (LAT > 35) OR (LON < -119) OR (LON > -117)
ORDER BY LAT

--Besides 0 values, no other out-of-range Latitudes or Longitudes 

--Set 0 Latitudes and Longitudes to NULL
SELECT LAT, LON, 
	NULLIF(LAT, LAT) AS 'Latitude Updated', 
	NULLIF(LON, LON) AS 'Longitude Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE LAT = 0 OR LON = 0

UPDATE RTDatabase..LA_Crime_2014_2015
SET LAT = NULL
WHERE LAT = 0

UPDATE RTDatabase..LA_Crime_2014_2015
SET LON = NULL
WHERE LON = 0

SELECT LOCATION, LAT, LON
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY LAT




--Review full table
SELECT *
FROM RTDatabase..LA_Crime_2014_2015




--Drop the original Location and Cross Street columns
ALTER TABLE RTDatabase..LA_Crime_2014_2015
DROP COLUMN LOCATION 

ALTER TABLE RTDatabase..LA_Crime_2014_2015
DROP COLUMN [Cross Street]




SELECT *
FROM RTDatabase..LA_Crime_2014_2015
