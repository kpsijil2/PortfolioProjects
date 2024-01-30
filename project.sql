
SELECT *
FROM PortfoliProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfoliProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfoliProject..CovidDeaths
ORDER BY 1,2

-- Looking at total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfoliProject..CovidDeaths
WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking at total_cases vs population
-- Show what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfoliProject..CovidDeaths
--WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfoliProject..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCounts
FROM PortfoliProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCounts DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCounts
FROM PortfoliProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCounts DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfoliProject..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfoliProject..CovidDeaths dea
JOIN PortfoliProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1, 2, 3