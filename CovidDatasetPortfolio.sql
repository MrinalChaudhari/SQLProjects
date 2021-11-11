

select * 
from Portfolio_SQL..CovidDeath
WHERE continent is not NULL
order by 3,4 

--select * 
--from Portfolio_SQL..CovidVaccination
--WHERE continent is not NULL
--order by 3,4 
 
 --select dataset
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_SQL..CovidDeath
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_SQL..CovidDeath
Where location like '%india%'
and continent is not null 
order by 1,2

--Total cases vs Population
--Shows how many people infected due to covid
select location, date, total_cases, population,(total_cases/population)*100 as PercentPolulationInfected
from Portfolio_SQL..CovidDeath
--Where location like '%india%'
order by 1,2


--countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectioncount,max((total_cases/population))*100 as PercentPolulationInfected
from Portfolio_SQL..CovidDeath
--WHERE location like '%india%'
Group by location,population
order by PercentPolulationInfected desc


--countries with highest Death count per population

select location,population,max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as PercentDeath
from Portfolio_SQL..CovidDeath
--WHERE location like '%india%'
Where continent is not null 
Group by location,population
order by PercentDeath desc

select location,population, max(cast(total_deaths as int)) as HighestDeathCount
from Portfolio_SQL..CovidDeath
--WHERE location like '%india%'
Where continent is not null 
Group by location,population
order by HighestDeathCount desc


select location, max(cast(total_deaths as int)) as HighestDeathCount
from Portfolio_SQL..CovidDeath
--WHERE location like '%india%'
Where continent is null 
Group by location
order by HighestDeathCount desc

--continents with highest death count per population

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from Portfolio_SQL..CovidDeath
--WHERE location like '%india%'
Where continent is not null 
Group by continent
order by HighestDeathCount desc


--Global Numbers
select sum(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_SQL..CovidDeath
--Where location like '%india%'
Where continent is not null 
--Group By date
order by 1,2

-------------------------------------------------------
--vaccination_Table
select * 
from Portfolio_SQL..CovidVaccination
WHERE continent is not NULL
order by 3,4 

---Join two table covidDeaths and CovidVaccination

Select * 
From Portfolio_SQL..CovidDeath d
Join Portfolio_SQL..CovidVaccination v
on d.location=v.location
and d.date=v.date

--total vaccination vs total population

Select d.continent, d.location, d.date, d.population,v.new_vaccinations
,SUM(Convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order By d.location, d.date) as people_Vaccinated, (people_Vaccinated/population)*100 as totalVaccinated
From Portfolio_SQL..CovidDeath d
Join Portfolio_SQL..CovidVaccination v
on d.location=v.location
and d.date=v.date
WHERE d.continent is not NULL
order by 2,3 desc

--CTE for calculation on partition by in previous query

with PopvsVac (continent, location, date, population, new_vaccinations,people_Vaccinated)
as
(
Select d.continent, d.location, d.date, d.population,v.new_vaccinations
,SUM(Convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order By d.location, d.date) as people_Vaccinated
From Portfolio_SQL..CovidDeath d
Join Portfolio_SQL..CovidVaccination v
on d.location=v.location
and d.date=v.date
WHERE d.continent is not NULL
--order by 2,3 desc
)
select *, (people_Vaccinated/population)*100 as totalVaccinated
from PopvsVac 

----Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
people_Vaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population,v.new_vaccinations
,SUM(Convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order By d.location, d.date) as people_Vaccinated
From Portfolio_SQL..CovidDeath d
Join Portfolio_SQL..CovidVaccination v
on d.location=v.location
and d.date=v.date
WHERE d.continent is not NULL
--order by 2,3 desc

select *, (people_Vaccinated/population)*100 as totalVaccinated
from #PercentPopulationVaccinated 

-------
----creating view to store data

create view PercentPopulationVaccinated as 
Select d.continent, d.location, d.date, d.population,v.new_vaccinations
,SUM(Convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order By d.location, d.date) as people_Vaccinated
From Portfolio_SQL..CovidDeath d
Join Portfolio_SQL..CovidVaccination v
on d.location=v.location
and d.date=v.date
WHERE d.continent is not NULL
--order by 2,3 desc

select * 
From PercentPopulationVaccinated