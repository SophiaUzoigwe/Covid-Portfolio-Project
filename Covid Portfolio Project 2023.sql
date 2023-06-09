/*
PORTFOLIO PROJECT
*/

--SELECTING EVERYTHING TO SEE CONTENTS OF TABLE
SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
Order by 3,4

-- SELECTING SPECIFIC COLUMNS FOR THE PROJECT
SELECT Location, date, total_cases, total_deaths,  new_cases, population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- CACULATING DEATH PERCENTAGE 
SELECT Location, date, total_cases, total_deaths, (total_deaths/ Nullif (total_cases,0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- CACULATING DEATH PERCENTAGE IN NIGERIA
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT Location, date, total_cases, total_deaths, (total_deaths/ Nullif (total_cases,0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE Location like '%nigeria%'
ORDER BY 1,2

-- CALCULATING PERCENTAGE OF POPULATION WITH COVID
SELECT Location, date, total_cases, population, (total_cases/ population)*100 as CovidPopulationPercentage
FROM PortfolioProject..CovidDeath
WHERE Location like '%nigeria%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, population, MAX(total_cases) As HighestInfectionCount, Max(total_cases/ population)*100 as CovidPopulationPercentage
FROM PortfolioProject..CovidDeath
GROUP BY location, Population
ORDER BY HighestInfectionCount desc


--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, population, MAX(total_deaths) As HighestDeathsCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location, Population
ORDER BY HighestDeathsCount desc


--CONTINENT WITH HIGHEST DEATH COUNT
SELECT Continent, MAX(total_deaths) As HighestDeathsCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY Continent
ORDER BY HighestDeathsCount desc

-- GLOBAL NUMBERS
SELECT Location, date, SUM(new_cases) As TotalCases, sum(new_deaths) As NewDeaths, sum(new_deaths)/ Nullif (SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
GROUP BY location, date
ORDER BY 1,2


--TOTAL POPULATION against VACCINATION RATE

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
From PortfolioProject..CovidDeath Dea
Join PortfolioProject..CovidVaccinations Vac
     on Dea.Location = Vac.Location
	 and dea.date = Vac.date
Where Dea.Continent is not null
Order by 2,3


--ROLLINGPEOPLEVACCINATED VS POPULATION using CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       Sum (Vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingCount
From PortfolioProject..CovidDeath Dea
Join PortfolioProject..CovidVaccinations Vac
     on Dea.Location = Vac.Location
	 and dea.date = Vac.date
Where Dea.Continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


--USING TEMP TABLE FOR ROLLINGPEOPLEVACCINATED VS POPULATION


Drop Table if exists #PercentPolutionVaccinated
Create Table #PercentPolutionVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
date datetime,
Population numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric,
)

insert into #PercentPolutionVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       Sum (Vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingCount
From PortfolioProject..CovidDeath Dea
Join PortfolioProject..CovidVaccinations Vac
     on Dea.Location = Vac.Location
	 and dea.date = Vac.date
Where Dea.Continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPolutionVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPolutionVaccinated As
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       Sum (Vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath Dea
Join PortfolioProject..CovidVaccinations Vac
     on Dea.Location = Vac.Location
	 and dea.date = Vac.date
Where Dea.Continent is not null
--Order by 2,3
