select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


--EXPLORING DATA TO BE USED
---COVID DEATHS EXPLORATION

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in the UK.
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND continent is not null
order by 1,2



--Looking at the total cases vs population
--shows the  percentage of the population that got covid
select location,date,population,total_cases,(total_cases/population)*100 AS InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
select location,population,MAX(total_cases) as Highest_Infection_count,MAX((total_cases/population))*100 AS InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage DESC

--showing the countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count DESC


--BREAKING THINGS DOWN BY CONTINENT

--showing the continents with the highest death count
select continent,MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count DESC



--GLOBAL NUMBERS
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by date
order by 1,2

--across the world
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
order by 1,2


---COVID VACINATIONS

select *
from PortfolioProject..CovidVaccinations

--Joining both tables

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING CTE
with PopvsVac(continent, location, date,population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR OTHER PURPOSES LIKE VISUALIZATION

Create View PercentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated