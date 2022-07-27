/* 
Data Cleaning, Part 2--Further Cleaning of Street/Cross Street Names and Types

Link to the Kaggle dataset "Los Angeles Crime Data 2010-2020: Public Safety Data released by the LAPD" by Sumaia P.:
	https://www.kaggle.com/datasets/sumaiaparveenshupti/los-angeles-crime-data-20102020

Link to the City of Los Angeles website with the original data: 
	https://data.lacity.org/Public-Safety/Crime-Data-from-2010-to-2019/63jg-8b9z

This dataset is in the public domain per the Kaggle page and the City of Los Angeles website

Dataset was first filtered in Excel to limit it to crimes that occurred from 2014 to 2015
*/


--Review the columns relating to streets and cross streets
SELECT [Street Number], [Street Name], [Street Type], [Location Updated], [Cross Street Name], [Cross Street Type], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Street Name]

SELECT DISTINCT([Street Number])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Street Number]

SELECT DISTINCT([Street Name])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Street Name]

SELECT DISTINCT([Street Type])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Street Type]

SELECT DISTINCT([Cross Street Name])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Cross Street Name]

SELECT DISTINCT([Cross Street Type])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Cross Street Type]

--Will address: invalid Street and Cross Street Types, Cross Street Types still included in Cross Street Name, and unstandardized "freeway" abbreviations




--STREET TYPE


--Review Street Types that are numbers
SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

--These Street Names/Types were improperly split
--Street Names were either a number, e.g., W 110TH, split as Street Name = W 11, Street Type = 0TH
--Or they were AVENUE + number, e.g., S AVENUE 17, split as Street Name = S AVENUE, Street Type = 17

--Start with Street Names like AVENUE + number
SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%' AND [Street Name] LIKE '%AVENUE%'
ORDER BY [Street Type]

SELECT [Street Name], [Street Type], [Location Updated], (TRIM([Street Name]) + ' ' + TRIM([Street Type])) AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%' AND [Street Name] LIKE '%AVENUE%'
ORDER BY [Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM([Street Name]) + ' ' + TRIM([Street Type])
WHERE [Street Type] LIKE '%[0-9]%' AND [Street Name] LIKE '%AVENUE%'

SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%' AND [Street Name] LIKE '%AVENUE%'
ORDER BY [Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULL 
WHERE [Street Type] LIKE '%[0-9]%' AND [Street Name] LIKE '%AVENUE%'



--Address remaining Street Types that contain numbers 
SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

SELECT [Street Name], [Street Type], [Location Updated], (TRIM([Street Name]) + TRIM([Street Type])) AS 'Street Name Corrected'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM([Street Name]) + TRIM([Street Type])
WHERE [Street Type] LIKE '%[0-9]%'

SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

--Update Location Updated column as there is an extra space where Street Name and Street Type were incorrectly split, e.g., 800 W 11 0TH
SELECT [Street Number], [Street Name], [Street Type], [Location Updated], 
	(TRIM([Street Number]) + ' ' + TRIM([Street Name])) AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = TRIM([Street Number]) + ' ' + TRIM([Street Name])
WHERE [Street Type] LIKE '%[0-9]%'

SELECT [Street Number], [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0-9]%'
ORDER BY [Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULL
WHERE [Street Type] LIKE '%[0-9]%'

SELECT [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] LIKE '%[0=9]%'



SELECT DISTINCT([Street Type])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Street Type]

--Review invalid values 
SELECT DISTINCT([Street Name]), [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Street Name]

--Standardize 'PWY' to 'PY' and update Location Updated column
SELECT [Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] = 'PWY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = 'PY'
WHERE [Street Type] = 'PWY'

SELECT [Street Number], [Street Name], [Street Type], [Location Updated],
	(TRIM([Street Number]) + ' ' + TRIM([Street Name]) + ' ' + TRIM([Street Type])) AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] LIKE '%PWY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = TRIM([Street Number]) + ' ' + TRIM([Street Name]) + ' ' + TRIM([Street Type])
WHERE [Location Updated] LIKE '%PWY'

SELECT DISTINCT([Street Name]), [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Street Name]



--Address row with Street Name = W and Street Type = OST
SELECT [Street Name], [Street Type], [Location Updated], 
	(TRIM([Street Name]) + ' ' + TRIM([Street Type])) AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] = 'OST'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM([Street Name]) + ' ' + TRIM([Street Type])
WHERE [Street Type] = 'OST'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULL
WHERE [Street Type] = 'OST'



--Address rows with Street Name = S PASEO DEL and Street Type = MAR
SELECT [Street Name], [Street Type], [Location Updated], (TRIM([Street Name]) + ' ' + TRIM([Street Type])) AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] = 'MAR'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM([Street Name]) + ' ' + TRIM([Street Type])
WHERE [Street Type] = 'MAR'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULL
WHERE [Street Type] = 'MAR'



--Combine Street Name and Street Type where they have been improperly split in the middle of a word and update Location Updated column
SELECT [Street Name], [Street Type], [Location Updated], (TRIM([Street Name]) + TRIM([Street Type])) AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM([Street Name]) + TRIM([Street Type])
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

SELECT [Street Number], [Street Name], [Street Type], [Location Updated], 
	(TRIM([Street Number]) + ' ' + TRIM([Street Name])) AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = TRIM([Street Number]) + ' ' + TRIM([Street Name])
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = NULL
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

SELECT DISTINCT([Street Name]), [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Street Name]

--No values returned, no more invalid Street Types




--STREET NAME 


--Create a separate column for the Street Direction, e.g., N, S, E, W
SELECT DISTINCT([Street Name]), [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] LIKE 'N %' OR [Street Name] LIKE 'S %' OR [Street Name] LIKE 'E %' OR [Street Name] LIKE 'W %'
ORDER BY [Street Name]

SELECT DISTINCT([Street Name]), [Street Type], 
	TRIM(SUBSTRING([Street Name], 2, LEN([Street Name]))) AS 'Street Name Updated',
	TRIM(SUBSTRING([Street Name], 1, 1)) AS 'Street Direction'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] LIKE 'N %' OR [Street Name] LIKE 'S %' OR [Street Name] LIKE 'E %' OR [Street Name] LIKE 'W %'
ORDER BY [Street Name]

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Street Direction] Nvarchar(5)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Direction] = TRIM(SUBSTRING([Street Name], 1, 1))
WHERE [Street Name] LIKE 'N %' OR [Street Name] LIKE 'S %' OR [Street Name] LIKE 'E %' OR [Street Name] LIKE 'W %'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(SUBSTRING([Street Name], 2, LEN([Street Name])))
WHERE [Street Name] LIKE 'N %' OR [Street Name] LIKE 'S %' OR [Street Name] LIKE 'E %' OR [Street Name] LIKE 'W %'

SELECT DISTINCT([Street Name]), [Street Type], [Street Direction]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Direction] IS NOT NULL
ORDER BY [Street Name]



--Standardize abbreviation for "freeway"
SELECT DISTINCT([Street Name]), [Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] IS NULL
ORDER BY [Street Name]

SELECT [Street Number],[Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] LIKE '%FRWY' OR [Street Name] LIKE '%FWY'

SELECT [Street Name], REPLACE([Street Name], 'FWY', '') AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] LIKE '%FWY'

SELECT [Street Name], REPLACE([Street Name], 'FRWY', '') AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Name] LIKE '%FRWY' 

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = REPLACE([Street Name], 'FWY', '')
WHERE [Street Name] LIKE '%FWY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = REPLACE([Street Name], 'FRWY', '')
WHERE [Street Name] LIKE '%FRWY' 

SELECT [Street Number],[Street Name], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] LIKE '%FRWY' OR [Location Updated] LIKE '%FWY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Type] = 'FY'
WHERE [Location Updated] LIKE '%FRWY' OR [Location Updated] LIKE '%FWY'

SELECT [Street Number], [Street Name], [Street Type], [Location Updated], 
	(TRIM([Street Name]) + ' ' + TRIM([Street Type])) AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] LIKE '%FRWY' OR [Location Updated] LIKE '%FWY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = TRIM([Street Name]) + ' ' + TRIM([Street Type])
WHERE [Location Updated] LIKE '%FRWY' OR [Location Updated] LIKE '%FWY'

--Check the rows where Street Type = FY
SELECT DISTINCT([Street Name]), [Street Number], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] = 'FY'
ORDER BY [Street Name]

--Address row where Street Name = FREEWAY 110 and Location Updated = FREEWAY 110 FY
SELECT [Street Name], [Street Type], [Location Updated],
	TRIM(REPLACE([Street Name], 'FREEWAY', '')) AS 'Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] LIKE 'FREEWAY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Street Name] = TRIM(REPLACE([Street Name], 'FREEWAY', ''))
WHERE [Location Updated] LIKE 'FREEWAY%'

SELECT [Street Name], [Street Type], [Location Updated],
	TRIM([Street Name] + ' ' + [Street Type]) AS 'New Location Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Location Updated] LIKE 'FREEWAY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Location Updated] = TRIM([Street Name] + ' ' + [Street Type])
WHERE [Location Updated] LIKE 'FREEWAY%'

SELECT DISTINCT([Street Name]), [Street Number], [Street Type], [Location Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Street Type] = 'FY'
ORDER BY [Street Name]




--CROSS STREET TYPE


SELECT DISTINCT([Cross Street Type])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Cross Street Type]

--Review Cross Street Types that are numbers
SELECT [Cross Street Type], [Cross Street Name], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] LIKE '%[0-9]%'
ORDER BY [Cross Street Type]

--These Cross Street Types were as a result of improper splitting of the cross street name
--E.g., E AVENUE 36 was split as Cross Street Name = E AVENUE, Cross Street Type = 36
--In these cases, Cross Street Name should be the same as Cross Street Updated 

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = [Cross Street Updated]
WHERE [Cross Street Type] LIKE '%[0-9]%'

SELECT [Cross Street Type], [Cross Street Name], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] LIKE '%[0-9]%'
ORDER BY [Cross Street Type]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = NULL
WHERE [Cross Street Type] LIKE '%[0-9]%'



SELECT DISTINCT([Cross Street Type])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Cross Street Type]

--Review Cross Street Types that are invalid
SELECT DISTINCT([Cross Street Type]), [Cross Street Name], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Cross Street Type]

--Invalid Cross Street Types were due to incorrect splitting of the cross street's name              
--E.g. S PASEO NUEVO was split as Cross Street Name = S PASEO NU, Cross Street Type = EVO

SELECT [Cross Street Name], [Cross Street Type],
	(TRIM([Cross Street Name]) + TRIM([Cross Street Type])) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Cross Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM([Cross Street Name]) + TRIM([Cross Street Type])
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street Name]
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = NULL
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')

SELECT DISTINCT([Cross Street Type]), [Cross Street Name], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] NOT IN ('BL', 'AV', 'ST', 'CI', 'PL', 'WY', 'DR', 'TL', 'RD', 'WK', 'LN', 'CT', 'HY', 'TR', 'PY', 'ML', 'PA', 'CR', 'PK', 'FY')
ORDER BY [Cross Street Type]

--No values returned, no more invalid Cross Street Types




--CROSS STREET NAME


SELECT DISTINCT([Cross Street Name])
FROM RTDatabase..LA_Crime_2014_2015
ORDER BY [Cross Street Name]

--Create a separate column for Cross Street Direction
SELECT DISTINCT([Cross Street Name]), [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE 'N %' OR [Cross Street Name] LIKE 'S %' OR [Cross Street Name] LIKE 'E %' OR [Cross Street Name] LIKE 'W %'
ORDER BY [Cross Street Name]

SELECT DISTINCT([Cross Street Name]), [Cross Street Type], 
	TRIM(SUBSTRING([Cross Street Name], 2, LEN([Cross Street Name]))) AS 'Cross Street Name Updated',
	TRIM(SUBSTRING([Cross Street Name], 1, 1)) AS 'Cross Street Direction'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE 'N %' OR [Cross Street Name] LIKE 'S %' OR [Cross Street Name] LIKE 'E %' OR [Cross Street Name] LIKE 'W %'
ORDER BY [Cross Street Name]

ALTER TABLE RTDatabase..LA_Crime_2014_2015
ADD [Cross Street Direction] Nvarchar(5)

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Direction] = TRIM(SUBSTRING([Cross Street Name], 1, 1))
WHERE [Cross Street Name] LIKE 'N %' OR [Cross Street Name] LIKE 'S %' OR [Cross Street Name] LIKE 'E %' OR [Cross Street Name] LIKE 'W %'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(SUBSTRING([Cross Street Name], 2, LEN([Cross Street Name])))
WHERE [Cross Street Name] LIKE 'N %' OR [Cross Street Name] LIKE 'S %' OR [Cross Street Name] LIKE 'E %' OR [Cross Street Name] LIKE 'W %'

SELECT [Cross Street Name], [Cross Street Type], [Cross Street Direction]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Direction] IS NOT NULL
ORDER BY [Cross Street Direction]



--Standardize abbreviation for "freeway"
SELECT [Cross Street Name], [Cross Street Type], [Cross Street Updated]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE '%FRWY%' OR [Cross Street Name] LIKE '%FWY%' OR [Cross Street Name] LIKE '%FREEWAY%'

SELECT [Cross Street Name], TRIM(REPLACE([Cross Street Name], 'FRWY', '')) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] LIKE '%FRWY%'

SELECT [Cross Street Name], TRIM(REPLACE([Cross Street Name], 'FWY', '')) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] LIKE '%FWY%'

SELECT [Cross Street Name], TRIM(REPLACE([Cross Street Name], 'FREEWAY', '')) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] LIKE '%FREEWAY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(REPLACE([Cross Street Name], 'FRWY', ''))
WHERE [Cross Street Updated] LIKE '%FRWY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(REPLACE([Cross Street Name], 'FWY', ''))
WHERE [Cross Street Updated] LIKE '%FWY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(REPLACE([Cross Street Name], 'FREEWAY', ''))
WHERE [Cross Street Updated] LIKE '%FREEWAY%'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = 'FY'
WHERE [Cross Street Updated] LIKE '%FRWY%' OR [Cross Street Updated] LIKE '%FWY%' OR [Cross Street Updated] LIKE '%FREEWAY%'

SELECT [Cross Street Direction], [Cross Street Name], [Cross Street Type], [Cross Street Updated],
	([Cross Street Name] + ' ' + [Cross Street Type]) AS 'New Cross Street Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Direction] IS NULL AND
	([Cross Street Updated] LIKE '%FRWY%' OR [Cross Street Updated] LIKE '%FWY%' OR [Cross Street Updated] LIKE '%FREEWAY%')

SELECT [Cross Street Direction], [Cross Street Name], [Cross Street Type], [Cross Street Updated],
	(TRIM([Cross Street Direction]) + ' ' + [Cross Street Name] + ' ' + [Cross Street Type]) AS 'New Cross Street Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Direction] IS NOT NULL AND
	([Cross Street Updated] LIKE '%FRWY%' OR [Cross Street Updated] LIKE '%FWY%' OR [Cross Street Updated] LIKE '%FREEWAY%')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street Name] + ' ' + [Cross Street Type]
WHERE [Cross Street Direction] IS NULL AND
	([Cross Street Updated] LIKE '%FRWY%' OR [Cross Street Updated] LIKE '%FWY%' OR [Cross Street Updated] LIKE '%FREEWAY%')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = TRIM([Cross Street Direction]) + ' ' + [Cross Street Name] + ' ' + [Cross Street Type]
WHERE [Cross Street Direction] IS NOT NULL AND
	([Cross Street Updated] LIKE '%FRWY%' OR [Cross Street Updated] LIKE '%FWY%' OR [Cross Street Updated] LIKE '%FREEWAY%')



--Address the Cross Street Names that still have the Cross Street Type abbreviation included
SELECT [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE '%[^A-Z0-9]AV' OR [Cross Street Name] LIKE '%[^A-Z0-9]BL' OR [Cross Street Name] LIKE '%[^A-Z0-9]CI' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]CR' OR [Cross Street Name] LIKE '%[^A-Z0-9]CT' OR [Cross Street Name] LIKE '%[^A-Z0-9]DR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]FY' OR [Cross Street Name] LIKE '%[^A-Z0-9]HY' OR [Cross Street Name] LIKE '%[^A-Z0-9]LN' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]ML' OR [Cross Street Name] LIKE '%[^A-Z0-9]PA' OR [Cross Street Name] LIKE '%[^A-Z0-9]PK' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]PL' OR [Cross Street Name] LIKE '%[^A-Z0-9]PY' OR [Cross Street Name] LIKE '%[^A-Z0-9]RD' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]ST' OR [Cross Street Name] LIKE '%[^A-Z0-9]TL' OR [Cross Street Name] LIKE '%[^A-Z0-9]TR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9]WK' OR [Cross Street Name] LIKE '%[^A-Z0-9]WY'
ORDER BY [Cross Street Name]

SELECT [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]AV' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]BL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CI' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CT' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]DR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]FY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]HY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]LN' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ML' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PA' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PK' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]RD' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ST' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WK' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WY'
ORDER BY [Cross Street Name]

SELECT [Cross Street Name], [Cross Street Type], [Cross Street Updated],
	TRIM(SUBSTRING([Cross Street Name], LEN([Cross Street Name])-2, LEN([Cross Street Name]))) AS 'Cross Street Type Updated',
	TRIM(SUBSTRING([Cross Street Name], 1, LEN([Cross Street Name])-3)) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]AV' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]BL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CI' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CT' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]DR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]FY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]HY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]LN' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ML' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PA' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PK' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]RD' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ST' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WK' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WY'
ORDER BY [Cross Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = TRIM(SUBSTRING([Cross Street Name], LEN([Cross Street Name])-2, LEN([Cross Street Name])))
WHERE [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]AV' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]BL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CI' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CT' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]DR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]FY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]HY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]LN' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ML' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PA' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PK' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]RD' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ST' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WK' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WY'

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(SUBSTRING([Cross Street Name], 1, LEN([Cross Street Name])-3))
WHERE [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]AV' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]BL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CI' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]CT' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]DR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]FY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]HY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]LN' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ML' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PA' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PK' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]PY' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]RD' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]ST' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TL' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]TR' OR
	[Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WK' OR [Cross Street Name] LIKE '%[^A-Z0-9][^A-Z0-9]WY'

SELECT [Cross Street Name], [Cross Street Type], [Cross Street Updated],
	([Cross Street Name] + ' ' + [Cross Street Type]) AS 'New Cross Street Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Updated] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Updated] LIKE '%[^A-Z0-9][^A-Z0-9]PK'
ORDER BY [Cross Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Updated] = [Cross Street Name] + ' ' + [Cross Street Type]
WHERE [Cross Street Updated] LIKE '%[^A-Z0-9][^A-Z0-9]CR' OR [Cross Street Updated] LIKE '%[^A-Z0-9][^A-Z0-9]PK'

SELECT [Cross Street Name], [Cross Street Type]
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] IS NULL AND ([Cross Street Name] LIKE '% AV' OR [Cross Street Name] LIKE '% BL' OR [Cross Street Name] LIKE '% CI' OR
	[Cross Street Name] LIKE '% CR' OR [Cross Street Name] LIKE '% CT' OR [Cross Street Name] LIKE '% DR' OR
	[Cross Street Name] LIKE '% FY' OR [Cross Street Name] LIKE '% HY' OR [Cross Street Name] LIKE '% LN' OR
	[Cross Street Name] LIKE '% ML' OR [Cross Street Name] LIKE '% PA' OR [Cross Street Name] LIKE '% PK' OR
	[Cross Street Name] LIKE '% PL' OR [Cross Street Name] LIKE '% PY' OR [Cross Street Name] LIKE '% RD' OR
	[Cross Street Name] LIKE '% ST' OR [Cross Street Name] LIKE '% TL' OR [Cross Street Name] LIKE '% TR' OR
	[Cross Street Name] LIKE '% WK' OR [Cross Street Name] LIKE '% WY')
ORDER BY [Cross Street Name]

SELECT [Cross Street Direction], [Cross Street Name], [Cross Street Type], [Cross Street Updated], 
	TRIM(SUBSTRING([Cross Street Name], LEN([Cross Street Name])-2, LEN([Cross Street Name]))) AS 'Cross Street Type Updated',
	TRIM(SUBSTRING([Cross Street Name], 1, LEN([Cross Street Name])-2)) AS 'Cross Street Name Updated'
FROM RTDatabase..LA_Crime_2014_2015
WHERE [Cross Street Type] IS NULL AND 
	([Cross Street Updated] LIKE '% BL' OR [Cross Street Updated] LIKE '% DR' OR [Cross Street Updated] LIKE '% ST')
ORDER BY [Cross Street Name]

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Name] = TRIM(SUBSTRING([Cross Street Name], 1, LEN([Cross Street Name])-2))
WHERE [Cross Street Type] IS NULL AND 
	([Cross Street Updated] LIKE '% BL' OR [Cross Street Updated] LIKE '% DR' OR [Cross Street Updated] LIKE '% ST')

UPDATE RTDatabase..LA_Crime_2014_2015
SET [Cross Street Type] = TRIM(SUBSTRING([Cross Street Name], LEN([Cross Street Name])-2, LEN([Cross Street Name])))
WHERE [Cross Street Type] IS NULL AND 
	([Cross Street Updated] LIKE '% BL' OR [Cross Street Updated] LIKE '% DR' OR [Cross Street Updated] LIKE '% ST')

