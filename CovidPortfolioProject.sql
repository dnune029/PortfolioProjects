Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Total cases vs total deaths

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate in comparison to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by 4 desc


--Countries with the highest death rates

Select location, population, MAX(cast(total_deaths as bigint)) as HighestDeathCount, MAX((total_deaths/population))*100 as 
PercentPopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by 3 desc


--Death counts by continent
Select location, MAX(cast(total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by HighestDeathCount desc

--Global Numbers

Select   SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Join Vacs and Deaths

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


	Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating views

Create View PercentPopulationVaccinated as

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	Create View PercentPopulationInfected as 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population

Create View DeathCountPerContinent as 

Select location, MAX(cast(total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location

Create View DeathRatePerCountry as 

Select location, population, MAX(cast(total_deaths as bigint)) as HighestDeathCount, MAX((total_deaths/population))*100 as 
PercentPopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population


