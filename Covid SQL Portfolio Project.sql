select *
from PortfolioProject..CovidVaccinations


select * 
from PortfolioProject..CovidDeaths 
where continent is not null

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

--Looking at Total Cases vs Total Deaths
--die Sterbewahrscheinlichkeit nach Corona-Infektion in Europa zeigen 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%europe'

--Looking at the Total Cases vs Population
--zeigt, wie viel Prozent der Bevölkerung Corona hatte
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where Location like '%europe'

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected DESC


--Showing the country with the highest death count for population
Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount DESC


--global numbers
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
--group by date 

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 
from PopVsVac
GO

--Temp Table
drop table if EXISTS #PercentPopulationVacciated
Create table #PercentPopulationVacciated
(continent nvarchar(255),
 location nvarchar(255),
 date date,
 population numeric, 
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVacciated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVacciated
GO

--Create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated
