
Select *
From Covid19Data.dbo.CovidDeaths
ORDER BY 3,4


Select *
From Covid19Data.dbo.CovidVaccinations
ORDER BY 3,4


UPDATE dbo.CovidDeaths
SET continent = NULL WHERE continent = ''

Select *
From Covid19Data.dbo.CovidVaccinations
ORDER BY 3,4

UPDATE dbo.CovidVaccinations
SET continent = NULL WHERE continent = ''

Select 
	DISTINCT location
From Covid19Data.dbo.CovidVaccinations
ORDER BY location

--Lower middle income, low income, Upper middle income in location

DELETE
FROM CovidVaccinations
WHERE location = 'Lower middle income' OR location = 'Low income' OR location = 'Upper middle income' OR location = 'High income' 

Select *
from CovidVaccinations
WHERE location = 'Lower middle income' OR location = 'Low income' OR location = 'Upper middle income' OR location = 'High income'

Select
	DISTINCT continent
FROM CovidVaccinations

UPDATE dbo.CovidVaccinations
SET continent = 'North America' WHERE location = 'North America'

UPDATE dbo.CovidVaccinations
SET continent = 'South America' WHERE location = 'South America'


UPDATE dbo.CovidVaccinations
SET continent = 'Asia' WHERE location = 'Asia'


UPDATE dbo.CovidVaccinations
SET continent = 'Africa' WHERE location = 'Africa'


UPDATE dbo.CovidVaccinations
SET continent = 'Oceania' WHERE location = 'Oceania'


UPDATE dbo.CovidVaccinations
SET continent = 'Europe' WHERE location = 'Europe'


Select *
FROM CovidVaccinations
WHERE continent IS NULL

Select *
FROM CovidVaccinations


--Cleaning CovidDeaths table

UPDATE dbo.CovidDeaths
SET continent = NULL WHERE continent = ''

DELETE
FROM CovidDeaths
WHERE location = 'Lower middle income' OR location = 'Low income' OR location = 'Upper middle income' OR location = 'High income';

Select *
FROM CovidDeaths
WHERE location = 'Lower middle income' OR location = 'Low income' OR location = 'Upper middle income' OR location = 'High income'

Select
	DISTINCT continent
FROM CovidDeaths


UPDATE CovidDeaths
SET continent = 'North America' WHERE location = 'North America'

UPDATE CovidDeaths
SET continent = 'South America' WHERE location = 'South America'

UPDATE CovidDeaths
SET continent = 'Asia' WHERE location = 'Asia'

UPDATE CovidDeaths
SET continent = 'Africa' WHERE location = 'Africa'

UPDATE CovidDeaths
SET continent = 'Oceania' WHERE location = 'Oceania'

UPDATE CovidDeaths
SET continent = 'Europe' WHERE location = 'Europe'

SELECT *
FROM CovidDeaths


--Select the data we will need

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULl
ORDER BY location, date


ALTER TABLE CovidDeaths
ADD total_deathsInt int

UPDATE CovidDeaths
SET total_deathsInt = CONVERT(int,total_deaths)

ALTER TABLE CovidDeaths
ADD total_casesInt int

UPDATE CovidDeaths
SET total_casesInt = CONVERT(bigint,total_cases)



--Checking for dublicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY location, date, total_cases, new_cases, total_deaths
	ORDER BY location ) row_num
FROM Covid19Data.dbo.CovidDeaths )
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY location


--VIZ


--GLOBAL deaths%
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)*1.0/SUM(new_cases)*100 as DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL


-- deaths Per Continent
SELECT location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
FROM CovidDeaths
WHERE location  NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


--Pop Infected
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--Pop infected timeline
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC


SELECT det.continent, det.location, det.date, det.population
, MAX(vac.total_vaccinations) as PeopleVaccinated
FROM CovidDeaths det
JOIN CovidVaccinations vac
	ON det.location = vac.location
	and det.date = vac.date
WHERE det.continent is not null 
GROUP BY det.continent, det.location, det.date, det.population
ORDER BY det.continent, det.location, det.date


-- Total Pop Vs Vacc

WITH PopVsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS PeopleVaccinated
FROM CovidDeaths deaths
JOIN CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
)

SELECT*, (PeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopVsVac
ORDER BY date


ALTER TABLE dbo.CovidDeaths
ALTER COLUMN date DATE;