-- DATA EXPLORATION https://github.com/IainLC/COVIDDataExploration
/* 
Data sourced from https://ourworldindata.org/covid-deaths 
CSV split into two separate Excel sheets COVIDDeaths & COVIDVaccinations
Data Imported to MSSMS via SQL Sever Import / Export Wizard into project directory

Data Cleaning Observations:
1. some data types are nvarchar and can cause unexpected results when aggregate functions are used - Solution was to recast the data type
2. Location and Continent columns have innacuracy which is not helpful in some circumstances. for example Asia, South america and Europe are in the contienent column with Null location data int he original table. Solution: ues "IS NOT NULL"
*/ 

--CREATING VIEWS TO STORE DATA FOR VISUALISATION Thisis continuation of the DATA EXPLORATION FOUND HERE: https://github.com/IainLC/COVIDDataExploration
-- OPTIONAL Include the Philippines only.


-- 1. The death percentage per continent. can be tweaked for other locations.
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%lippines%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

/*checking data veracity- number are close to actual*/

-- Contains international locations
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%lippines%'
 WHERE location = 'World'
--GROUP BY date
ORDER BY 1,2

--2. 
/*Data does not exist in other queries*/

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCOUNT
FROM  PortfolioProject..COVIDDeaths
--WHERE location LIKE '%lippines%'
WHERE continent IS NULL
	AND location NOT IN ('World', 'European Union', 'International') -- European union includes europe
GROUP BY location
ORDER BY TotalDeathCount

--3.

SELECT population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%lippines%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--4. 
SELECT population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..COVIDDeaths
--WHERE location LIKE '%lippines%'
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected DESC

--5.
--SELECT SUM(new_cases) AS TotalCases, SUM(CAST(NewDeaths AS INT)) AS TotalDeaths, SUM(CAST(NewDeaths AS INT))/SUM(NewCases)*100 AS DeathPercentage
--FROM PortfolioProject..COVIDDeaths
----WHERE location LIKE '%lippines%'
--WHERE continent IS NOT NULL
----GROUP BY date
--ORDER BY 1,2

--EXAMPLE FROM number 2  but adjusted to include population.
SELECT location, date, population, total_cases,total_deaths 
FROM PortfolioProject..COVIDDeaths
----WHERE location LIKE '%lippines%'
WHERE continent IS NOT NULL
ORDER BY 1,2

--6.
WITH PopVsVac (conintent, location, Date, Population, new_vacinations, CumilativePeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS CumilativePeopleVaccinated
-- (CumilativePeopleVaccinated/population)*100
FROM PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (CumilativePeopleVaccinated/population) *100 AS PercentageOfPeopleVaccinated
FROM PopVsVac

--7.
SELECT location, population, MAX(total_cases) AS HighestInfectioinCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths
----WHERE location LIKE '%lippines%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected