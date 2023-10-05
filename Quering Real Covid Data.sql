--SELECT * 
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT * 
--FROM Vaccinations
--ORDER BY 3,4


-- Select the data I'll use 

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1,2

-- Death Percentage in Egypt 

SELECT 
	location, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 Death_Percentage
FROM 
	CovidDeaths
WHERE 
	location like '%Egypt%' AND
	continent IS NOT NULL
ORDER BY 1,2


--Total Cases vs Population 

SELECT
	location, date, population, total_cases, (total_cases/population)*100 as Death_Percentage
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2

-- Countries with the Highest Infection Rate

SELECT 
	location, population, 
	MAX(total_cases) Highest_Infection_count, 
	MAX(total_cases/population)*100 Percentage_Population_Infected
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY 
	Percentage_Population_Infected DESC

-- Countries with the Highest Death Cout

SELECT 
	location, 
	MAX(CAST(total_deaths AS INT)) Highest_Deaths_Count
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	Highest_Deaths_Count DESC

-- Continents with the Highest Death Cout

SELECT 
	continent, MAX(CAST(total_deaths AS INT)) Highest_Death_Count
FROM
	CovidDeaths
WHERE 
	continent IS NOT NULL 
GROUP BY 
	continent
ORDER BY 
	Highest_Death_Count DESC

-- New Cases and New Deaths 

SELECT 
	date, 
	SUM(new_cases) Total_New_Cases, 
	SUM(CAST(new_deaths AS INT)) Total_New_Deaths
FROM
	CovidDeaths
GROUP BY 
	date 
ORDER BY 
	date DESC

-- Total Cases and Deaths around the World 

SELECT 
	SUM(CAST(new_cases AS INT)) AS Total_Cases, 
	SUM(CAST(new_deaths AS INT)) AS Total_Deaths 
FROM 
	CovidDeaths

-- How many people around the world got vaccinated ? 

SELECT 
	DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations,
	SUM(CONVERT(int, VA.new_vaccinations)) OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) Rolling_People_Vaccinated
FROM 
	CovidDeaths DEA
JOIN 
	Vaccinations VA 
	ON DEA.location = VA.location
	AND DEA.date = DEA.date
WHERE 
	DEA.continent IS NOT NULL

-- CTE

WITH PopvsVac (Continent, Location, Date, Population,new_vaccinations,Rolling_People_Vaccinated) 
AS 
(
SELECT	DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations,
	SUM(CONVERT(int, VA.new_vaccinations)) OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) Rolling_People_Vaccinated
FROM 
	CovidDeaths DEA
JOIN 
	Vaccinations VA 
	ON DEA.location = VA.location
	AND DEA.date = VA.date
WHERE 
	DEA.continent IS NOT NULL)

-- Creating View to Store Data and Catch later 

CREATE VIEW Deaths_Per_Country
AS 
SELECT 
	location, 
	MAX(CAST(total_deaths AS INT)) Highest_Deaths_Count
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location

SELECT * 
FROM Deaths_Per_Country
ORDER BY Highest_Deaths_Count DESC