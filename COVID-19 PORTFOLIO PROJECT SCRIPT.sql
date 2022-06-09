Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--1. Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--2. Looking at the Total Cases Vs Total Deaths

--(What is the percentage of people who got infected or who died)
--This shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null   
order by 1,2

--3. looking at Total Cases Vs Population

--Shows what percentage of population got Covid 

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
--Where Location like '%Nigeria%'
Where continent is not null
order by 1,2

--4. Looking at Countries with the Highest Infection Rate compared to their population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc


--5. Showing the countries with the highest death Count from Covid

Select location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
Where continent is not null
Group by location
Order by TotalDeathsCount desc

--6. Showing the countries with the highest death Count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
Where continent is not null
Group by location
Order by TotalDeathsCount desc

--LET'S BREAK THINGS DONW BY CONTINENT

--7. Showing the countries with the highest death Count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc


--8. showing GLOBAL NUMBERS


Select date, SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null   
Group by date
order by 1,2


--9.showing TOTAL WORLD DEATHS

Select SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null   
order by 1,2


--10. Looking at Total Population Vs Vaccination

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as BIGINT)) OVER (Partition by death.location ORDER by death.location)
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null   
order by 2,3



--10a. Looking at Total Population Vs Vaccination

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccianted
--(RollingPeopleVaccianted/population)*100

From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null   
order by 2,3

--USE CTE

With PopulationVsVaccination (Continent, Location, Data, Population,New_Vaccinations, RollingPeopleVaccinated)
as (
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) 
OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccianted


From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null   
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopulationVsVaccination 


--TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) 
OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccianted


From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null   
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated 


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) 
OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccianted


From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null   
--order by 2,3

Select *
from PercentPopulationVaccinated
