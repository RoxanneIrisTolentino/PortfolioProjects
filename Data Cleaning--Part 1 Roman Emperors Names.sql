/*
Data Cleaning of the Kaggle dataset "List of all Roman Emperors" by Felipe Oliveira:
	https://www.kaggle.com/datasets/felipehlvo/list-of-roman-emperors-from-wikipedia
Dataset was scraped from the Wikipedia page on Roman Emperors: 
	https://en.wikipedia.org/wiki/List_of_Roman_emperors

Some preliminary data cleaning done beforehand in Excel

PART 1: Names Column
*/

--Review dataset
SELECT *
FROM RTDatabase..Roman_Emperors




--Work on all names without regnal names / co-emperors / notes, e.g. '(second reign)'
SELECT Names
FROM RTDatabase..Roman_Emperors
WHERE (Names NOT LIKE '%,%') AND (Names NOT LIKE '%with%') AND (Names NOT LIKE '%(%')

--Create column for name only
ALTER TABLE RTDatabase..Roman_Emperors
ADD Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Name = Names
FROM RTDatabase..Roman_Emperors
WHERE (Names NOT LIKE '%,%') AND (Names NOT LIKE '%with%') AND (Names NOT LIKE '%(%')




--Review dataset 
SELECT Names, Name 
FROM RTDatabase..Roman_Emperors

--Divide up Names column into Name and Regnal Name for those with no co-emperors listed and no extra notes--decided to work on those separately 
--Divide the regnal name and name, also trim the extra spaces from some of the regnal names on the left
SELECT 
	LTRIM(PARSENAME(REPLACE(Names, ',', '.'), 1)) AS Regnal_Name,
	PARSENAME(REPLACE(Names, ',', '.'), 2) AS Name
FROM RTDatabase..Roman_Emperors
WHERE (Names NOT LIKE '%with%') AND (Names NOT LIKE '%(%') AND (Names NOT LIKE '%]%') AND (Name IS NULL)

ALTER TABLE RTDatabase..Roman_Emperors
ADD Regnal_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = LTRIM(PARSENAME(REPLACE(Names, ',', '.'), 1))
FROM RTDatabase..Roman_Emperors
WHERE (Names NOT LIKE '%with%') AND (Names NOT LIKE '%(%') AND (Names NOT LIKE '%]%') AND (Name IS NULL)

UPDATE RTDatabase..Roman_Emperors
SET Name = PARSENAME(REPLACE(Names, ',', '.'), 2)
FROM RTDatabase..Roman_Emperors
WHERE (Names NOT LIKE '%with%') AND (Names NOT LIKE '%(%') AND (Names NOT LIKE '%]%') AND (Name IS NULL)




--Review dataset
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors

--Divide up names with 1 co-emperor, excluding the one with brackets at the end as the queries were not working for that one
SELECT 
	PARSENAME(REPLACE(Names,'with', '.'), 1) AS Coemperor_Name,
	PARSENAME(REPLACE(Names,'with', '.'), 2) AS Name
FROM RTDatabase..Roman_Emperors
WHERE (Name IS NULL) AND (Names LIKE '%with%') AND (Names NOT LIKE '%and%') AND (Names NOT LIKE '%]%')

ALTER TABLE RTDatabase..Roman_Emperors
ADD Coemperor_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = PARSENAME(REPLACE(Names,'with', '.'), 1)
FROM RTDatabase..Roman_Emperors
WHERE (Name IS NULL) AND (Names LIKE '%with%') AND (Names NOT LIKE '%and%') AND (Names NOT LIKE '%]%')

UPDATE RTDatabase..Roman_Emperors
SET Name = PARSENAME(REPLACE(Names,'with', '.'), 2)
FROM RTDatabase..Roman_Emperors
WHERE (Name IS NULL) AND (Names LIKE '%with%') AND (Names NOT LIKE '%and%') AND (Names NOT LIKE '%]%')




--Review dataset
SELECT Names, Name, Coemperor_Name
FROM RTDatabase..Roman_Emperors

--Divide up the name and regnal name for those with 1 co-emperor. Also trim the Name column on the left
SELECT 
	Name, 
	(PARSENAME(REPLACE(Name, ',', '.'), 1)) AS Regnal_Name,
	LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 2)) AS Name
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Name LIKE '%,%')

--And divide up the co-emperor names and regnal names
SELECT 
	Coemperor_Name, 
	(PARSENAME(REPLACE(Coemperor_Name, ',', '.'), 1)) AS Coemperor_Regnal_Name,
	(PARSENAME(REPLACE(Coemperor_Name, ',', '.'), 2)) AS Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Coemperor_Name LIKE '%,%')

ALTER TABLE RTDatabase..Roman_Emperors
ADD Coemperor_Regnal_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = (PARSENAME(REPLACE(Name, ',', '.'), 1)) 
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Name LIKE '%,%')

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 2))
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Name LIKE '%,%')

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = (PARSENAME(REPLACE(Coemperor_Name, ',', '.'), 1))
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Coemperor_Name LIKE '%,%')

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = (PARSENAME(REPLACE(Coemperor_Name, ',', '.'), 2))
FROM RTDatabase..Roman_Emperors
WHERE (Coemperor_Name IS NOT NULL) AND (Coemperor_Name LIKE '%,%')




--Review dataset
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors

--Start to clean up names that have parentheses or brackets; review the relevant rows
SELECT Names
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%(%') OR (Names LIKE '%]%') 

--Focus on the names with extraneous info in the parentheses and those with brackets
SELECT Names
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%]%') OR (Names LIKE '%(possibly)%')

--Try to extract a substring to exclude the brackets
SELECT 
	Names, 
	LTRIM(SUBSTRING(Names, 1, CHARINDEX(',', Names)-1)) AS Name,
	LTRIM(SUBSTRING(Names, CHARINDEX(',', Names)+1, CHARINDEX('[', Names)-1)) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%]%') 

--Unable to remove the brackets from the end using substring, will split up the names first into Name and Regnal Name
SELECT 
	Names, 
	LTRIM(SUBSTRING(Names, 1, CHARINDEX(',', Names)-1)) AS Name,
	LTRIM(SUBSTRING(Names, CHARINDEX(',', Names)+1, LEN(Names))) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%]%') OR (Names LIKE '%(possibly)%')

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = LTRIM(SUBSTRING(Names, CHARINDEX(',', Names) +1, LEN(Names)))
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%]%') OR (Names LIKE '%(possibly)%')

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(SUBSTRING(Names,1, CHARINDEX(',', Names)-1))
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%]%') OR (Names LIKE '%(possibly)%')

--Remove the parentheses and brackets
SELECT 
	Names, 
	REPLACE(Name, '(possibly)', '') AS Name
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%Ulpia%'

UPDATE RTDatabase..Roman_Emperors
SET Name = REPLACE(Name, '(possibly)', '')
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%Ulpia%'

--Check the length of the entries with brackets to see if there are extra characters at the end 
SELECT 
	Names, 
	Regnal_Name, 
	LEN(Regnal_Name) AS Length
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%]%'

--There appears to be hidden characters at the end after the brackets; try substring again but subtract greater amount from length of Regnal_Name
SELECT 
	Names, 
	Regnal_Name, 
	SUBSTRING(Regnal_Name, 1, LEN(Regnal_Name)-7) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%]%'

--Works completely for all except Justinian II (has 1 extra hidden character, leaving opening bracket '[' at the end); will address later
UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = SUBSTRING(Regnal_Name, 1, LEN(Regnal_Name)-7)
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%]%'




--Work on names with EAST/WEST/MIDDLE/EAST AND WEST
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) AND (Name IS NULL)

--Try PARSENAME--but some entries have multiple commas, resulting in incorrect results
SELECT 
	Names, 
	PARSENAME(REPLACE(Names, ',', '.'), 1) AS Regnal_Name,
	PARSENAME(REPLACE(Names, ',', '.'), 2) AS Name
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) AND (Name IS NULL)

--Use SUBSTRING to separate the names instead; include LTRIM to trim the names on the left side
SELECT 
	Names, 
	LTRIM(SUBSTRING(Names, 1, CHARINDEX(',', Names)-1)) AS Name,
	LTRIM(SUBSTRING(Names, CHARINDEX(',', Names)+1, LEN(Names))) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) AND (Name IS NULL)

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(SUBSTRING(Names, 1, CHARINDEX(',', Names)-1))
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) AND (Name IS NULL)

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = LTRIM(SUBSTRING(Names, CHARINDEX(',', Names)+1, LEN(Names)))
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) AND (Regnal_Name IS NULL)

--Check results
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Names LIKE '%MIDDLE%')) 

--Create a column for the empire regions
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Regnal_Name LIKE '%EAST%') OR (Regnal_Name  LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%')) 

SELECT 
	Regnal_Name, 
	CASE
	WHEN REGNAL_NAME LIKE '%(MIDDLE)%' THEN 'MIDDLE'
	WHEN Regnal_Name LIKE '%(WEST)%then%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%(EAST AND WEST)%then%' THEN 'EAST AND WEST'
	WHEN REGNAL_NAME LIKE '%(EAST)%' THEN 'EAST'
	WHEN Regnal_Name LIKE '%(WEST)%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%(EAST AND WEST)%' THEN 'EAST AND WEST'
	ELSE 'ERROR'
	END AS 'Empire'
FROM RTDatabase..Roman_Emperors
WHERE ((Regnal_Name LIKE '%EAST%') OR (Regnal_Name  LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%'))

--Create a column for the later empire regions
SELECT 
	Regnal_Name, 
	CASE
	WHEN Regnal_Name LIKE '%after%(WEST)%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%after%(EAST AND WEST)%' THEN 'EAST AND WEST'
	WHEN REGNAL_NAME LIKE '%after%(EAST)%' THEN 'EAST'
	ELSE NULL
	END AS 'Later_Empire'
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%then, after%'

ALTER TABLE RTDatabase..Roman_Emperors
ADD Empire nvarchar(255)

ALTER TABLE RTDatabase..Roman_Emperors
ADD Later_Empire nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Empire = 
	CASE
	WHEN REGNAL_NAME LIKE '%(MIDDLE)%' THEN 'MIDDLE'
	WHEN Regnal_Name LIKE '%(WEST)%then%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%(EAST AND WEST)%then%' THEN 'EAST AND WEST'
	WHEN REGNAL_NAME LIKE '%(EAST)%' THEN 'EAST'
	WHEN Regnal_Name LIKE '%(WEST)%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%(EAST AND WEST)%' THEN 'EAST AND WEST'
	ELSE 'ERROR'
	END
FROM RTDatabase..Roman_Emperors
WHERE ((Regnal_Name LIKE '%EAST%') OR (Regnal_Name  LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%'))

UPDATE RTDatabase..Roman_Emperors
SET Later_Empire = 
	CASE
	WHEN Regnal_Name LIKE '%after%(WEST)%' THEN 'WEST'
	WHEN Regnal_Name LIKE '%after%(EAST AND WEST)%' THEN 'EAST AND WEST'
	WHEN REGNAL_NAME LIKE '%after%(EAST)%' THEN 'EAST'
	ELSE NULL
	END 
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%then, after%'

--Check results
SELECT Names, Name, Regnal_Name, Empire, Later_Empire
FROM RTDatabase..Roman_Emperors
WHERE Empire IS NOT NULL

--Remove the empire region/years empire regions changed from the regnal names, excluding those with co-emperors 
SELECT 
	Regnal_Name, 
	SUBSTRING(Regnal_Name, 1, CHARINDEX('(', Regnal_Name)-1) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Regnal_Name LIKE '%EAST%') OR (Regnal_Name LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%')) AND (Regnal_Name NOT LIKE '%with%')

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = SUBSTRING(Regnal_Name, 1, CHARINDEX('(', Regnal_Name)-1)
FROM RTDatabase..Roman_Emperors
WHERE ((Regnal_Name LIKE '%EAST%') OR (Regnal_Name LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%')) AND (Regnal_Name NOT LIKE '%with%')

--Check results
SELECT Names, Name, Regnal_Name, Empire, Later_Empire
FROM RTDatabase..Roman_Emperors
WHERE ((Names LIKE '%EAST%') OR (Names LIKE '%WEST%') OR (Regnal_Name LIKE '%MIDDLE%')) AND (Names NOT LIKE '%with%')




--Review dataset
SELECT Names, Name, Regnal_Name, Empire, Later_Empire
FROM RTDatabase..Roman_Emperors
WHERE Name IS NULL

--Clean up names with notes in parentheses and no co-emperor
--Use REPLACE to remove the final parenthesis in the Note column as different variations of CHARINDEX and LEN using SUBSTRING did not work
SELECT 
	Names, 
	LTRIM(SUBSTRING(Names, 1, CHARINDEX('(', Names)-1)) AS Name,
	SUBSTRING(REPLACE(Names, ')', ''), CHARINDEX('(', Names)+1, LEN(Names)) AS Note
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%(%' AND Name IS NULL

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(SUBSTRING(Names, 1, CHARINDEX('(', Names)-1))
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%(%' AND Name IS NULL

ALTER TABLE RTDatabase..Roman_Emperors
ADD Note nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Note = SUBSTRING(REPLACE(Names, ')', ''), CHARINDEX('(', Names)+1, LEN(Names))
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%reign%') AND (Names NOT LIKE '%with%')

--Check results
SELECT Names, Name, Note
FROM RTDatabase..Roman_Emperors
WHERE (Names LIKE '%reign%') AND (Names NOT LIKE '%with%')




--Review dataset--those remaining have 2 or more co-emperors 
SELECT Names, Name, Regnal_Name, Empire, Later_Empire, Note
FROM RTDatabase..Roman_Emperors
WHERE Name IS NULL

--Divide up the names of the emperors and co-emperors  
SELECT 
	Names, 
	PARSENAME(REPLACE(Names,'with', '.'), 1) AS Coemperor_Name,
	LTRIM(PARSENAME(REPLACE(Names,'with', '.'), 2)) AS Name
FROM RTDatabase..Roman_Emperors
WHERE Names IS NULL

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(PARSENAME(REPLACE(Names,'with', '.'), 2))
FROM RTDatabase..Roman_Emperors
WHERE Name IS NULL

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = PARSENAME(REPLACE(Names,'with', '.'), 1)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name IS NULL AND Names LIKE '%with%'




--Review dataset and remaining names to clean up
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%with%'

--Divide up names with regnal name still in Name column (x2)
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Name LIKE '%,%'

SELECT 
	Name, 
	LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 1)) AS Regnal_Name,
	LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 2)) AS Name
FROM RTDatabase..Roman_Emperors
WHERE Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 1))
FROM RTDatabase..Roman_Emperors
WHERE Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Name = LTRIM(PARSENAME(REPLACE(Name, ',', '.'), 2))
FROM RTDatabase..Roman_Emperors
WHERE Name LIKE '%,%'




--Divide up names with co-emperors still in Regnal_Name column (x3); all of the co-emperors have regnal names, as well 
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name, Empire
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'

SELECT 
	Names, 
	Regnal_Name, 
	SUBSTRING(Regnal_Name, 1, CHARINDEX('(', Regnal_Name)-1) AS Regnal_Name, 
	SUBSTRING(Regnal_Name, CHARINDEX('with', Regnal_Name)+5, CHARINDEX(',', Regnal_Name)) AS Coemperor_Name,
	SUBSTRING(Regnal_Name, CHARINDEX(',', Regnal_Name)+2, LEN(Regnal_Name)) AS Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'

--Query successful except for the Coemperor_Name, where it still included all/most of the characters after the comma

--Attempt to use PARSENAME function instead
SELECT 
	Names, 
	Regnal_Name, 
	PARSENAME(REPLACE(Regnal_Name, 'with', '.'), 1) AS Coemperor_Name,
	PARSENAME(REPLACE(Regnal_Name, 'with', '.'), 2) AS Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'

--Query only successfuly for 1/3 of the names, PARSENAME did not return any Coemperor_Name or Regnal_Name for 2 of the rows

--Will work with the substring query
UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = SUBSTRING(Regnal_Name, CHARINDEX(',', Regnal_Name)+2, LEN(Regnal_Name))
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = SUBSTRING(Regnal_Name, CHARINDEX('with', Regnal_Name)+5, CHARINDEX(',', Regnal_Name))
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = SUBSTRING(Regnal_Name, 1, CHARINDEX('(', Regnal_Name)-1)
FROM RTDatabase..Roman_Emperors
WHERE Regnal_Name LIKE '%with%'




--Divide up names with additional co-emperors still in Coemperor_Name column (x6)
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%and%'

--Clean up the entry for Co-emperor Valerius Valens separately due to different formatting
SELECT 
	Coemperor_Name, 
	SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1) AS Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%Valerius%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%Valerius%'

--Divide up those names that have 2 additional co-emperors in the Coemperor_Name column 
SELECT 
	Coemperor_Name, 
	PARSENAME(REPLACE(Coemperor_Name, 'and', '.'), 1) AS Third_Coemperor_Name,
	PARSENAME(REPLACE(Coemperor_Name, 'and', '.'), 2) AS Second_Coemperor_Name,
	PARSENAME(REPLACE(Coemperor_Name, 'and', '.'), 3) AS Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%and%and%'

--Some of the names were cut off in the middle using PARSENAME

--Use substring instead; focus on co-emperors with regnal names 
SELECT 
	Coemperor_Name, 
	LTRIM(SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1)) AS Coemperor_Name,
	LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX(',', Coemperor_Name)+2, CHARINDEX('AVGVSTVS ', Coemperor_Name))) AS Coemperor_Regnal_Name,
	LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX('and ', Coemperor_Name)+5, LEN(Coemperor_Name))) AS Second_Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%' AND Coemperor_Name LIKE '%and%'

--Coemperor_Regnal_Name still has extra characters despite multiple attempts to exclude anything after the co-emperor regnal name 
--Will clean that data at a later time

ALTER TABLE RTDatabase..Roman_Emperors
ADD Second_Coemperor_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Name = LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX('and ', Coemperor_Name)+5, LEN(Coemperor_Name)))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%' AND Coemperor_Name LIKE '%and%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX(',', Coemperor_Name)+2, CHARINDEX('AVGVSTVS ', Coemperor_Name)))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%' AND Coemperor_Name LIKE '%and%'
 
UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = LTRIM(SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%' AND Coemperor_Name LIKE '%and%'

--Divide up the rest of the names with additional co-emperors still in the Coemperor_Name column
--Started queries on position 3/CHARINDEX ' and ' + 7 so that the names would line up on the left side; LTRIM was not affecting them
SELECT 
	Coemperor_Name, 
	LTRIM(SUBSTRING(Coemperor_Name, 3, CHARINDEX(' and ', Coemperor_Name)-2)) AS Coemperor_Name,
	LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX(' and ', Coemperor_Name)+7, LEN(Coemperor_Name))) AS Second_Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%and%'

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Name = LTRIM(SUBSTRING(Coemperor_Name, CHARINDEX(' and ', Coemperor_Name)+7, LEN(Coemperor_Name)))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%and%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = LTRIM(SUBSTRING(Coemperor_Name, 3, CHARINDEX(' and ', Coemperor_Name)-2))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%and%'




--Clean up Second_Coemperor_Name column
--Review dataset
SELECT Second_Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Second_Coemperor_Name IS NOT NULL

--Focus on those with regnal names
SELECT 
	Second_Coemperor_Name, 
	PARSENAME(REPLACE(Second_Coemperor_Name, ',', '.'), 2) AS Second_Coemperor_Name, 
	LTRIM(PARSENAME(REPLACE(Second_Coemperor_Name, ',', '.'), 1)) AS Second_Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%,%')

ALTER TABLE RTDatabase..Roman_Emperors
ADD Second_Coemperor_Regnal_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Regnal_Name = LTRIM(PARSENAME(REPLACE(Second_Coemperor_Name, ',', '.'), 1))
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%,%')

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Name = PARSENAME(REPLACE(Second_Coemperor_Name, ',', '.'), 2)
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%,%')

--Now focus on the names with a third co-emperor name in the Second_Coemperor_Name column 
SELECT Second_Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%and%C%')

SELECT 
	Second_Coemperor_Name, 
	SUBSTRING(Second_Coemperor_Name, 1, CHARINDEX(' and', Second_Coemperor_Name)) AS Second_Coemperor_Name,
	SUBSTRING(Second_Coemperor_Name, CHARINDEX(' and', Second_Coemperor_Name)+7, LEN(Second_Coemperor_Name)) AS Third_Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%and%C%')

ALTER TABLE RTDatabase..Roman_Emperors
ADD Third_Coemperor_Name nvarchar(255)

UPDATE RTDatabase..Roman_Emperors
SET Third_Coemperor_Name = SUBSTRING(Second_Coemperor_Name, CHARINDEX(' and', Second_Coemperor_Name)+7, LEN(Second_Coemperor_Name))
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%and%C%')

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Name = SUBSTRING(Second_Coemperor_Name, 1, CHARINDEX(' and', Second_Coemperor_Name))
FROM RTDatabase..Roman_Emperors
WHERE (Second_Coemperor_Name IS NOT NULL) AND (Second_Coemperor_Name LIKE '%and%C%')




--Review dataset
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name, Second_Coemperor_Name, Second_Coemperor_Regnal_Name, 
	Third_Coemperor_Name, Empire, Later_Empire, Note
FROM RTDatabase..Roman_Emperors

--Divde up co-emperor names with regnal names still included
SELECT Coemperor_Name, Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%'

SELECT 
	Coemperor_Name, 
	SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1) AS Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = SUBSTRING(Coemperor_Name, 1, CHARINDEX(',', Coemperor_Name)-1)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%,%'




--Clean up co-emperor name with note in parentheses
SELECT Coemperor_Name, Note
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%(%'

--Needed to start at position 4/CHARINDEX '(' +1 and include -8/-31 to account for additional hidden characters 
SELECT 
	Coemperor_Name, 
	SUBSTRING(Coemperor_Name, 4, CHARINDEX('(', Coemperor_Name)-8) AS Coemperor_Name, 
	SUBSTRING(Coemperor_Name, CHARINDEX('(', Coemperor_Name)+1, LEN(Coemperor_Name)-31) AS Note
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%(%'

UPDATE RTDatabase..Roman_Emperors
SET Note = SUBSTRING(Coemperor_Name, CHARINDEX('(', Coemperor_Name)+1, LEN(Coemperor_Name)-31)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%(%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = SUBSTRING(Coemperor_Name, 4, CHARINDEX('(', Coemperor_Name)-8)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name LIKE '%(%'




--Work on dividing up the co-emperor regnal name that still has the second co-emperor with regnal name included
SELECT Coemperor_Regnal_Name, Second_Coemperor_Name, Second_Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%,%'

SELECT 
	Coemperor_Regnal_Name, 
	SUBSTRING(Coemperor_Regnal_Name, 1, CHARINDEX(' and ', Coemperor_Regnal_Name)-1) AS Coemperor_Regnal_Name, 
	SUBSTRING(Coemperor_Regnal_Name, CHARINDEX('Mart', Coemperor_Regnal_Name), CHARINDEX(',', Coemperor_Regnal_Name)-56) AS Second_Coemperor_Name,
	SUBSTRING(Coemperor_Regnal_Name, CHARINDEX(',', Coemperor_Regnal_Name)+2, LEN(Coemperor_Regnal_Name)) AS Second_Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Regnal_Name = SUBSTRING(Coemperor_Regnal_Name, CHARINDEX(',', Coemperor_Regnal_Name)+2, LEN(Coemperor_Regnal_Name))
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Second_Coemperor_Name = SUBSTRING(Coemperor_Regnal_Name, CHARINDEX('Mart', Coemperor_Regnal_Name), CHARINDEX(',', Coemperor_Regnal_Name)-56)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%,%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = SUBSTRING(Coemperor_Regnal_Name, 1, CHARINDEX(' and ', Coemperor_Regnal_Name)-1)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%,%'




--Work on co-emperor regnal names that have extra characters
SELECT Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%and%' OR Coemperor_Regnal_Name LIKE '%[%'

--Query is not pulling name with '['. Try different WHERE criteria
SELECT Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name NOT LIKE '%IMPERATOR%'

SELECT 
	Coemperor_Regnal_Name, 
	SUBSTRING(Coemperor_Regnal_Name, 1, CHARINDEX('STVS', Coemperor_Regnal_Name)+3) AS Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name NOT LIKE '%IMPERATOR%'

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = SUBSTRING(Coemperor_Regnal_Name, 1, CHARINDEX('STVS', Coemperor_Regnal_Name)+3)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name NOT LIKE '%IMPERATOR%'




--Review dataset
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name, Second_Coemperor_Name, Second_Coemperor_Regnal_Name, 
	Third_Coemperor_Name, Empire, Later_Empire, Note
FROM RTDatabase..Roman_Emperors

--Extract year after which an emperor's empire changed
SELECT Names, Empire, Later_Empire
FROM RTDatabase..Roman_Emperors
WHERE Later_Empire IS NOT NULL

SELECT 
	Names, 
	SUBSTRING(SUBSTRING(Names, CHARINDEX('after', Names)+6, CHARINDEX('after', Names)+8), 1, 3) AS Year
FROM RTDatabase..Roman_Emperors
WHERE Later_Empire IS NOT NULL

--Needed to use SUBSTRING within another SUBSTRING to extract the year as CHARINDEX for substring length still kept the characters after the year

ALTER TABLE RTDatabase..Roman_Emperors
ADD Year_After_Which_Empire_Changed INT

UPDATE RTDatabase..Roman_Emperors
SET Year_After_Which_Empire_Changed = SUBSTRING(SUBSTRING(Names, CHARINDEX('after', Names)+6, CHARINDEX('after', Names)+8), 1, 3)
FROM RTDatabase..Roman_Emperors
WHERE Later_Empire IS NOT NULL




--Review dataset
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name, Second_Coemperor_Name, Second_Coemperor_Regnal_Name, 
	Third_Coemperor_Name, Empire, Year_After_Which_Empire_Changed, Later_Empire, Note
FROM RTDatabase..Roman_Emperors

--Remove extra spaces
SELECT 
	Names, 
	TRIM(Names) as Names_Trimmed,
	Name, 
	TRIM(Name) AS Name_Trimmed,
	Regnal_Name, 
	TRIM(Regnal_Name) AS Regnal_Name_Trimmed,
	Coemperor_Name, 
	TRIM(Coemperor_Name) AS Coemperor_Name_Trimmed,
	Coemperor_Regnal_Name, 
	TRIM(Coemperor_Regnal_Name) AS Coemperor_Regnal_Name_Trimmed
FROM RTDatabase..Roman_Emperors

UPDATE RTDatabase..Roman_Emperors
SET Names = TRIM(Names)
FROM RTDatabase..Roman_Emperors

UPDATE RTDatabase..Roman_Emperors
SET Name = TRIM(Name)
FROM RTDatabase..Roman_Emperors

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = TRIM(Regnal_Name)
FROM RTDatabase..Roman_Emperors

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = TRIM(Coemperor_Name)
FROM RTDatabase..Roman_Emperors

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = TRIM(Coemperor_Regnal_Name)
FROM RTDatabase..Roman_Emperors

--Address the names which still have hidden characters at the beginning of the string
--Start with the Coemperor_Name column
SELECT Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Name IS NOT NULL

SELECT Coemperor_Name
FROM RTDatabase..Roman_Emperors
WHERE ((Coemperor_Name LIKE '%Nikephoros%') OR (Coemperor_Name LIKE '%Theophylact%') OR (Coemperor_Name LIKE '%Constantine%') 
	OR (Coemperor_Name LIKE '%Alexios Komnenos%') OR (Coemperor_Name LIKE '%John Komnenos%') OR (Coemperor_Name LIKE '%Matthew Kantakouzenos%')) 
	AND (Coemperor_Name NOT LIKE '%Doukas%')

SELECT Coemperor_Name, LEN(Coemperor_Name)
FROM RTDatabase..Roman_Emperors
WHERE ((Coemperor_Name LIKE '%Nikephoros%') OR (Coemperor_Name LIKE '%Theophylact%') OR (Coemperor_Name LIKE '%Constantine%') 
	OR (Coemperor_Name LIKE '%Alexios Komnenos%') OR (Coemperor_Name LIKE '%John Komnenos%') OR (Coemperor_Name LIKE '%Matthew Kantakouzenos%')) 
	AND (Coemperor_Name NOT LIKE '%Doukas%')

--The names do not have the same number of hidden characters based on the actual length vs. the number of visible characters  

--Use substring to try to trim names as much as possible without removing letters 
SELECT 
	Coemperor_Name, 
	SUBSTRING(Coemperor_Name, 3, LEN(Coemperor_Name)-6) AS Coemperor_Name_Trimmed
FROM RTDatabase..Roman_Emperors
WHERE ((Coemperor_Name LIKE '%Nikephoros%') OR (Coemperor_Name LIKE '%Theophylact%') OR (Coemperor_Name LIKE '%Constantine%') 
	OR (Coemperor_Name LIKE '%Alexios Komnenos%') OR (Coemperor_Name LIKE '%John Komnenos%') OR (Coemperor_Name LIKE '%Matthew Kantakouzenos%')) 
	AND (Coemperor_Name NOT LIKE '%Doukas%')

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Name = SUBSTRING(Coemperor_Name, 3, LEN(Coemperor_Name)-6)
FROM RTDatabase..Roman_Emperors
WHERE ((Coemperor_Name LIKE '%Nikephoros%') OR (Coemperor_Name LIKE '%Theophylact%') OR (Coemperor_Name LIKE '%Constantine%') 
	OR (Coemperor_Name LIKE '%Alexios Komnenos%') OR (Coemperor_Name LIKE '%John Komnenos%') OR (Coemperor_Name LIKE '%Matthew Kantakouzenos%')) 
	AND (Coemperor_Name NOT LIKE '%Doukas%')

--Address the co-emperor regnal name with hidden characters 
SELECT Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name IS NOT NULL

SELECT Coemperor_Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%THEODOSIVS%'

SELECT 
	Coemperor_Regnal_Name, 
	LEN(Coemperor_Regnal_Name) AS Number_of_Total_Characters, 
	LEN('IMPERATOR CAESAR FLAVIVS THEODOSIVS AVGVSTVS') AS Number_of_Visible_Characters
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%THEODOSIVS%'

--Has 6 hidden characters

SELECT 
	Coemperor_Regnal_Name, 
	SUBSTRING(Coemperor_Regnal_Name, 3, 44) AS Coemperor_Regnal_Name_Trimmed, 
	LEN(SUBSTRING(Coemperor_Regnal_Name, 3, 44) ) AS Trimmed_Length
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%THEODOSIVS%'

--Trimmed length matches the number of visible characters

UPDATE RTDatabase..Roman_Emperors
SET Coemperor_Regnal_Name = SUBSTRING(Coemperor_Regnal_Name, 3, 44)
FROM RTDatabase..Roman_Emperors
WHERE Coemperor_Regnal_Name LIKE '%THEODOSIVS%'




--Capitalize 1st letter only of Empire / Later Empire / Note
--Standardize the format of the Empire, Later Empire, and Note columns, which should have been done initially
SELECT Empire, Later_Empire, Note
FROM RTDatabase..Roman_Emperors
WHERE (Empire IS NOT NULL) OR (Note IS NOT NULL)

SELECT 
	Empire,
	CASE
	WHEN Empire = 'EAST AND WEST' THEN 'East and West'
	WHEN Empire = 'WEST' THEN 'West'
	WHEN Empire = 'EAST' THEN 'East'
	WHEN Empire = 'MIDDLE' THEN 'Middle'
	ELSE 'Error'
	END AS Empire_Capitalized
FROM RTDatabase..Roman_Emperors
WHERE Empire IS NOT NULL

UPDATE RTDatabase..Roman_Emperors
SET Empire = 
	CASE
	WHEN Empire = 'EAST AND WEST' THEN 'East and West'
	WHEN Empire = 'WEST' THEN 'West'
	WHEN Empire = 'EAST' THEN 'East'
	WHEN Empire = 'MIDDLE' THEN 'Middle'
	ELSE 'Error'
	END 
FROM RTDatabase..Roman_Emperors
WHERE Empire IS NOT NULL

SELECT 
	Later_Empire,
	CASE
	WHEN Later_Empire = 'EAST AND WEST' THEN 'East and West'
	WHEN Later_Empire = 'WEST' THEN 'West'
	WHEN Later_Empire = 'EAST' THEN 'East'
	ELSE 'Error'
	END AS Later_Empire_Capitalized
FROM RTDatabase..Roman_Emperors
WHERE Later_Empire IS NOT NULL

UPDATE RTDatabase..Roman_Emperors
SET Later_Empire = 
	CASE
	WHEN Later_Empire = 'EAST AND WEST' THEN 'East and West'
	WHEN Later_Empire = 'WEST' THEN 'West'
	WHEN Later_Empire = 'EAST' THEN 'East'
	ELSE 'Error'
	END 
FROM RTDatabase..Roman_Emperors
WHERE Later_Empire IS NOT NULL

SELECT 
	Note,
	CASE	
	WHEN Note = 'second co-emperorship' THEN 'Second co-emperorship'
	WHEN Note LIKE '%second reign%' THEN 'Second reign'
	WHEN Note LIKE '%third reign%' THEN 'Third reign'
	ELSE 'Error'
	END AS 'Note_Capitalized'
FROM RTDatabase..Roman_Emperors
WHERE Note IS NOT NULL

--Needed to use LIKE above as there appears to be hidden characters 

--Confirm if there are hidden characters by checking number of characters vs. actual length 
SELECT Note, LEN(Note)
FROM RTDatabase..Roman_Emperors
WHERE Note IS NOT NULL

UPDATE RTDatabase..Roman_Emperors
SET Note = 
	CASE
	WHEN Note = 'second co-emperorship' THEN 'Second co-emperorship'
	WHEN Note LIKE '%second reign%' THEN 'Second reign'
	WHEN Note LIKE '%third reign%' THEN 'Third reign'
	ELSE 'Error'
	END 
FROM RTDatabase..Roman_Emperors
WHERE Note IS NOT NULL




--Address entry where ',' appears to have been misplaced in original dataset ('Constantine II' was instead 'Constantine, II' in the dataset)
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%, II%'

SELECT 
	Regnal_Name, 
	SUBSTRING(Regnal_Name, 4, LEN(Regnal_Name)) AS Regnal_Name_Corrected
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%, II%'

SELECT 
	Names, 
	REPLACE(Names, ', II', ' II,') AS Names_Corrected
FROM RTDatabase..Roman_Emperors
WHERE Names LIKE '%, II%'

UPDATE RTDatabase..Roman_Emperors
SET Name = 'Constantine II'
WHERE Names LIKE '%, II%'

UPDATE RTDatabase..Roman_Emperors
SET Regnal_Name = SUBSTRING(Regnal_Name, 4, LEN(Regnal_Name)) 
WHERE Names LIKE '%, II%'

UPDATE RTDatabase..Roman_Emperors
SET Names = REPLACE(Names, ', II', ' II,')
WHERE Names LIKE '%, II%'




--Review changes
SELECT Names, Name, Regnal_Name
FROM RTDatabase..Roman_Emperors
WHERE Name = 'Constantine II'

--Final results of data cleaning of the Names column
SELECT Names, Name, Regnal_Name, Coemperor_Name, Coemperor_Regnal_Name, Second_Coemperor_Name, Second_Coemperor_Regnal_Name, Third_Coemperor_Name,
	Empire, Later_Empire, Year_After_Which_Empire_Changed, Note
FROM RTDatabase..Roman_Emperors

