SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%south korea%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population get covid

SELECT Location, date, total_cases, Population, (total_cases/Population) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%south korea%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population

SELECT Location,  MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's Break Things Dwon By Continent
-- Across the continents
-- showing continents with the highest death count per population
SELECT Continent,  MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
-- showing daily new cases, new deaths, death percentage across the world
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

-- showing total_cases, total_deaths and the death rate for the whole time
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Joining Vaccination and Deaths
SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Looking at Total pop vs vaccintations
-- Using CTE
WITH PopVsVac (Continent, Location, Date, Population,New_Vaccinations, RollingCountOfPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingCountOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingCountOfPeopleVaccinated/Population)*100
FROM PopVsVac

-- Looking at Total pop vs vaccintations
-- Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingCountOfPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingCountOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingCountOfPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating views for further visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingCountOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

--check
SELECT *
FROM PercentPopulationVaccinated
