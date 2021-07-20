SELECT * 
FROM PortfolioProject..coviddeaths
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..covidvaccine
ORDER BY 3,4

-- Select data we are going to be using

SELECT location, date, continent, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
WHERE continent is NOT NULL
ORDER BY 1, 2

-- looking at total cases vs total deaths

SELECT location, continent, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage_affected
FROM PortfolioProject..coviddeaths
WHERE continent is NOT NULL AND location LIKE '%states%'
ORDER BY 1, 2, 3

--looking at the total cases vs population
-- shows the percentage of people affected
SELECT location, date, continent, total_cases, total_deaths, population, (total_cases/population)*100 AS total_affected
FROM PortfolioProject..coviddeaths
WHERE continent is NOT NULL AND location LIKE '%states%'
ORDER BY 1, 2

--highest infection rate countries compared to population

SELECT location,population continent, MAX(total_cases) AS highestInfectionRate, MAX(total_cases/population)*100 AS total_affected
FROM PortfolioProject..coviddeaths
--WHERE location LIKE '%ststes%'
GROUP BY location, population
ORDER BY total_affected DESC

--showing countries with highest death count per population

SELECT location, MAX(CAST (total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Lets break things by continent.
-- showing continets with the highest death count per population


SELECT continent,  MAX(CAST (total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
--WHERE location LIKE '%states%'
WHERE continent is NOT NULL
ORDER BY 1, 2


-- Joining 2 tables
-- looking at total population vs vaccinations

SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
ORDER BY 2, 3

-- USE CTE
WITH  PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
)
SELECT *, (TotalVaccinated/population)*100 AS VaccinatedPercentage
FROM PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentagePopulationvaccinated
CREATE TABLE #PercentagePopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
TotalVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
--ORDER BY 2, 3

SELECT *, (TotalVaccinated/population)*100 AS VaccinatedPercentage
FROM #PercentagePopulationVaccinated


-- create views for later visulization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
--ORDER BY 2, 3






