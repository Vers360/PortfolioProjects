Select * 
From PortofioProject_1..CovidDeaths
Where continent is not null
order by 3,4


--Select * 
--From PortofioProject_1..CovidVacinations
--order by 3,4

--Select Data that is going to be used 

Select
	Location,
	date,
	total_cases,
	new_cases, 
	total_deaths,
	population
From PortofioProject_1..CovidDeaths
Where continent is not null
order by 1,2

-- Looking and Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
Select
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortofioProject_1..CovidDeaths
Where location like '%kingdom%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

Select
Location,
date,
population,
total_cases,
(total_cases/population)*100 as PercentOfPopulationInfected
FROM PortofioProject_1..CovidDeaths
Where location like '%kingdom%'
and continent is not null
order by 1,2

-- Looking at what countries with Highest infection Rate compared to Population

Select
	Location,
	population,
	Max(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortofioProject_1..CovidDeaths
Where continent is not null
Group by 
	location,
	population
order by PercentOfPopulationInfected desc


-- Showing the countries with the Highest Death count per population

Select
	Location,
	Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortofioProject_1..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing the CONTINENTS with the Highest Death count

Select
	location,
	Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortofioProject_1..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population 

Select
	continent,
	Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortofioProject_1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS

--Total number of Cases 

Select
	SUM(new_cases) as Total_Cases,
	SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofioProject_1..CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
order by 1,2

--Total number of Cases per day

Select
	date,
	SUM(new_cases) as Total_Cases,
	SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofioProject_1..CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
Group by date 
order by 1,2


--Looking at Total Population vs Vaccination

Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofioProject_1..CovidDeaths dea
Join PortofioProject_1..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Total Population vs vaccinations

--CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations))
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofioProject_1..CovidDeaths dea
Join PortofioProject_1..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table 

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations))
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofioProject_1..CovidDeaths dea
Join PortofioProject_1..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated
--Where location like '%albania%'

--Creating View to store data for later Visualisations 

Create View PercentagePopulationVaccinated as
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations))
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofioProject_1..CovidDeaths dea
Join PortofioProject_1..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated