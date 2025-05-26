-- US household income government data. Data cleaning and EDA done using SQL. EDA was done to understand land and water distribution
-- in different US states and income distribution across different US states.
-- 


-- QUERY TO FIND OUT DUPLICATES IN THE USHOUSEHOLDINCOME TABLE
SELECT id, COUNT(id) FROM ushouseholdincome 
GROUP BY id
having COUNT(id)>1
;


-- deleting duplicate rows in the dataset ushousehold income
DELETE FROM ushouseholdincome 
WHERE row_id IN
 (
SELECT row_id FROM (
SELECT row_id, id , 
ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS rownumbers
FROM ushouseholdincome 
) AS subquery 
WHERE rownumbers>1
)

-- STANDARDIZING STATE NAMES

-- checking how many distinct states we have
-- output shows duplication of only one state which is Georgia, displayed as 'georia' in one instance.
SELECT DISTINCT State_Name FROM ushouseholdincome;

-- Checking the row_id where the spelling mistake has happened. row id number - 7833
SELECT row_id ,State_Name FROM ushouseholdincome
WHERE State_Name = 'georia';

-- updating the name 'georia' into Georgia
UPDATE ushouseholdincome 
SET State_Name = 'Georgia'
WHERE row_id = 7833




-- CHECKING FOR MISSING/NULL VALUES IN THE PLACE COLUMN
SELECT * FROM ushouseholdincome WHERE County = 'Autauga County'

-- retrieving row id which contains the null value. row id = 32
SELECT * FROM ushouseholdincome
WHERE Place IS NULL;

UPDATE ushouseholdincome 
SET Place='Autaugaville'
WHERE row_id = 32

-- CHECKING COLUMN TYPE FOR ANY DUPLICATIONS OR TYPOS

-- we find 128 records of'borough' and 1 record of 'boroughs'. since these can be considered the same we can update 
-- 'boroughs' to 'borough'
SELECT TYPE, COUNT(TYPE) 
FROM ushouseholdincome
GROUP BY TYPE

-- After updation , count of 'Borough' type changes to 129.
UPDATE ushouseholdincome
SET TYPE = 'Borough'
WHERE TYPE = 'Boroughs'



-- EXPLORATORY DATA ANALYSIS

-- exploring states which have the highest number of water sources ( top 10)
-- from the output we can see that Alaska and Michigan are the landmasses having the highest water sources which is confirmed by checking online.
-- Same could be checked for States having the highest land area. The 2 states having the highest land area are Alaska and Texas. 
-- Alaska is more than twice the size of Texas

SELECT State_Name, SUM(ALand), SUM(AWater), ROUND((SUM(ALand)*100/(SUM(ALand)+SUM(AWater))),2) AS Land_percentage,
ROUND((SUM(AWater)*100/(SUM(ALand)+SUM(AWater))),2) AS Water_percentage
FROM ushouseholdincome
GROUP BY State_Name
HAVING Land_percentage>95
ORDER BY 2 desc
LIMIT 10; 

-- New Mexico is widely considered the driest state in the US in terms of water resources. It has the lowest ratio of surface water to land area (0.22%) compared to all other states. 
-- The state is largely arid, with an average annual precipitation of around 13.7 inches. 2nd state with lowest water % - Arizona (0.27%)
SELECT State_Name, SUM(ALand) AS land_area, SUM(AWater) AS water_area, ROUND((SUM(ALand)*100/(SUM(ALand)+SUM(AWater))),2) AS Land_percentage,
ROUND((SUM(AWater)*100/(SUM(ALand)+SUM(AWater))),2) AS Water_percentage
FROM ushouseholdincome
GROUP BY State_Name
HAVING Land_percentage>95
ORDER BY 4 desc
; 

-- States having the highest surface water to Land ratio >0.2
-- Hawaii and Michigan are the top 2 states with highest ratios. 
SELECT State_Name, SUM(ALand), SUM(AWater), ROUND((SUM(ALand)*100/(SUM(ALand)+SUM(AWater))),2) AS Land_percentage,
ROUND((SUM(AWater)*100/(SUM(ALand)+SUM(AWater))),2) AS Water_percentage
FROM ushouseholdincome
GROUP BY State_Name
HAVING Water_percentage>20
ORDER BY 5 DESC;
 

-- columns - State_Name, County, Primary, TYPE, Mean, Median , ALand, AWater

-- Mean/Median ratio gives a value < 1 for All US states. This suggests that the incomes are very close to eachother 
-- or are very low and no outliers to pull the mean upwards to raise the ratio. 
-- This means this is a left skewed data
-- This is problematic as typical us household income pattern is right skewed. Meaning there are more moderate earners
-- but a group of people earn very high income such that it pushes the ratio to more than 1.

-- This problem could be due to missing data , as while cleaning the data, lot of cities in several states had values 0 for mean or
-- median. This means the councils in these states failed to report the average household income and median in these states.

WITH State_Info AS
 (
SELECT u.State_Name , County, `Primary` , TYPE , Mean , MEDIAN , ALand, AWater FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us ON
u.id = us.id 
WHERE Mean <> 0 )


SELECT State_Name, AVG(Mean), AVG(MEDIAN), AVG(Mean)/AVG(MEDIAN) AS income_inequality FROM State_Info
GROUP BY State_Name
ORDER BY 4 desc;

-- 








