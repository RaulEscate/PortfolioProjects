SELECT *
FROM PortfolioProject..CovidD$
Where continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidV$
--ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidD$
Where continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if Covid contracted in US


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidD$
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidD$
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidD$
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Showing countries with highest death count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidD$
-- WHERE location LIKE '%states%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Broken down by continent
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidD$
-- WHERE location LIKE '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidD$
--WHERE location LIKE '%states%'
where continent is not null
Group by date
ORDER BY 1,2


--death percentage globally

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidD$
--WHERE location LIKE '%states%'
where continent is not null
--Group by date
ORDER BY 1,2




--Looking at total population vs vaccinations using a CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidD$ dea
Join PortfolioProject..CovidV$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as Population_Percentage
From PopvsVac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidD$ dea
Join PortfolioProject..CovidV$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Population_Percentage
From #PercentPopulationVaccinated




-- Create view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidD$ dea
Join PortfolioProject..CovidV$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated