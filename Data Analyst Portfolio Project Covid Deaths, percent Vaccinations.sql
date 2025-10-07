SELECT location, date, total_cases, total_deaths, population 
FROM coviddeaths
WHERE continent is not null
ORDER BY 1,2;

--Looking at the Total cases Vs Total Deaths
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 
AS DeathPercentage
FROM coviddeaths
WHERE location IN ('United States', 'Mexico', 'Germany')
ORDER BY 1,2;

--Looking at the total cases vs population
--Shows what percetage of population got covid
SELECT location, date,population, total_cases, (total_cases/population)*100 
AS PercentPopulationInfected
FROM coviddeaths
WHERE location IN ('United States', 'Mexico', 'Germany')
ORDER BY 1,2;

-----------------------------------------
-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, 
MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100  AS MaxPercentPopulationInfected
FROM coviddeaths
--WHERE location IN ('United States', 'Mexico', 'Germany')
GROUP BY Location, population
ORDER BY MaxPercentPopulationInfected desc;

-------------------------------------
-- Showing countries with Highest Death counts per population
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM coviddeaths
WHERE location IN ('United States', 'Mexico', 'Germany', 'United Kingdom', 'Canada')
--WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;

------------------------------------
-- BREAKING IT DOWN BY CONTINENT
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM coviddeaths
--WHERE location IN ('United States', 'Mexico', 'Germany', 'United Kingdom', 'Canada')
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--------------------------
--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 
AS DeathPercentage
FROM coviddeaths
--WHERE location IN ('United States', 'Mexico', 'Germany')
WHERE continent is NOT null
--GROUP BY date
ORDER BY 1,2;

--------------------------------------------

-- TOTAL POPULATION VS VACCINATIONS

--SELEC dea.continent, dea.location, dea.date, dea.population, vac.new_vaccionations,
-- SUM(covert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
--FROM PortfolioProject..CovidDeaths dea
--JOIN portfolioProject..CovidVaccinations vac
 --on dea.location = vac.location
 --and dea.date = vac.date
--where dea.continent is not null
--oder by 2,3
-----------------------------------------

-- TOTAL POPULATIONS VS VACCIONATIONS
-- Filling [null] information as 0
-- 1️⃣ Create the temp table and load the transformed data
CREATE TEMP TABLE PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    COALESCE(vac.new_vaccinations, 0) AS new_vaccinations,
    SUM(COALESCE(vac.new_vaccinations, 0)::INT) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac 
    ON dea.location = vac.location 
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- 2️⃣ Query it as many times as you want
SELECT 
    *, 
    ROUND((RollingPeopleVaccinated::NUMERIC / Population) * 100, 2) AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated
ORDER BY location, date;

--CREATE VIEW FOR DATA VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    COALESCE(vac.new_vaccinations, 0) AS new_vaccinations,
    SUM(COALESCE(vac.new_vaccinations, 0)::INT) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac 
    ON dea.location = vac.location 
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--------------

SELECT * 
FROM PercentPopulationVaccinated