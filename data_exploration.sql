--select * from PortfolioProject..CovidDeaths
--order by 3,4
--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, 
	(convert(decimal(15,3), total_deaths)/convert(decimal(15,3), total_cases))*100 as DeathPersentage
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
and continent is not null 
order by 1,2

--Looking at total cases vs population
--show what percentage of population got covid
select location, date, population, total_cases, 
	(convert(decimal(15,3), total_cases)/convert(decimal(15,3), population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max(convert(decimal(15,3), total_cases)/convert(decimal(15,3), population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

--looking at the countries with the highest death count compared to population
Select Location, 
	MAX(try_parse(total_deaths as int)) as HighestDeathCount ,  
	Max(convert(decimal(15,3), total_deaths)/convert(decimal(15,3), population))*100 as PercentDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
Group by Location 
order by HighestDeathCount desc

--same but by continent
Select continent, 
	MAX(try_parse(total_deaths as int)) as HighestDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent 
order by HighestDeathCount desc


--Global numbers
select  date, sum(try_parse(new_cases as int)) as total_cases, sum(try_parse(new_deaths as int)) as total_deaths,
	(sum(convert(decimal(15,3), new_deaths))/sum(convert(decimal(15,3),new_cases)))*100 as DeathPersentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2


--looking at total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	SUM(try_parse(vac.new_vaccinations as int)) OVER 
	(Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as PeopleVaccinatedUpdated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE

with PopulationVsVaccination (Continent, location, date, population, new_vaccinations, PeopleVaccinatedUpdated)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	SUM(try_parse(vac.new_vaccinations as bigint)) OVER 
	(Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as PeopleVaccinatedUpdated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null
)

select *, (CONVERT(decimal(11,0), PeopleVaccinatedUpdated)/CONVERT(decimal(11,0), population))*100 as VaccinatedPercentage
from PopulationVsVaccination
where location = 'Kazakhstan'


-- Using Temp Table the same thing

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population nvarchar(255),
New_vaccinations nvarchar(255),
PeopleVaccinatedUpdated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	SUM(try_parse(vac.new_vaccinations as bigint)) OVER 
	(Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as PeopleVaccinatedUpdated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null

select *, (CONVERT(decimal(11,0), PeopleVaccinatedUpdated)/CONVERT(decimal(11,0), population))*100 as VaccinatedPercentage
from #PercentPopulationVaccinated
where location = 'Kazakhstan'


-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	SUM(try_parse(vac.new_vaccinations as bigint)) OVER 
	(Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as PeopleVaccinatedUpdated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
