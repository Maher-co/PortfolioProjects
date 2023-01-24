SELECT *
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order by 3,4

---SELECT *
---From PortfolioProject..CovidVaccinations
---Order by 3,4

---Select Data tha we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order by 1,2

---Looking at Total Cases vs Total Deaths
---Likelihood of dying when you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
WHERE Location like'%states%'
Order by 1,2

---Looking at the total cases vs the population
---shows what percentage of population got covid

SELECT Location, date, total_cases,population, (total_cases/population)*100 As PercentagePopulationInfected
From PortfolioProject..CovidDeaths
---WHERE Location like'%states%'
Order by 1,2

---country with highest infection rate compared to population

SELECT Location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 As 
PercentagePopulationInfected
From PortfolioProject..CovidDeaths
---WHERE Location like'%states%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
Order by PercentagePopulationInfected DESC

---showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
---WHERE Location like'%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER by TotalDeathCount DESC

---LETS BREAK IT DOWN BY CONTINET

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
---WHERE Location like'%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC


---Global Numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
---WHERE Location like'%states%'
where continent is not NULL
GROUP BY date
Order by 1,2

--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
---Rollingpeoplevaccinated/population\0* 100
FROM PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3


---USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoplevaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
---Rollingpeoplevaccinated/population\0* 100
FROM PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)

select *, (RollingPeoplevaccinated/Population*100)
from PopvsVac



---TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
---Rollingpeoplevaccinated/population\0* 100
FROM PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
---order by 2,3


select *, (RollingPeoplevaccinated/Population*100)
from #PercentPopulationVaccinated

---Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
---Rollingpeoplevaccinated/population\0* 100
FROM PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
---order by 2,3

---work table

SELECT *
FROM PercentPopulationVaccinated