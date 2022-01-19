/*
Queries used for Tableau Project
*/

--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from Portfolio_SQL..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from Portfolio_SQL..CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_SQL..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4  

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_SQL..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

---5
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio_SQL..CovidDeath dea
Join Portfolio_SQL..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3