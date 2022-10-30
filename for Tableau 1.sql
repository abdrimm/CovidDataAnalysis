--for Tableau

--1
select sum(try_parse(new_cases as int)) as total_cases, sum(try_parse(new_deaths as int)) as total_deaths,
	(sum(convert(decimal(15,3), new_deaths))/sum(convert(decimal(15,3),new_cases)))*100 as DeathPersentage
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--2
Select location, sum(try_parse(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max(convert(decimal(15,3), total_cases)/convert(decimal(15,3), population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.

select date, total_cases, total_deaths, 
	(convert(decimal(15,3), total_deaths)/convert(decimal(15,3), total_cases))*100 as DeathPersentage
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
and continent is not null 
order by 1,2