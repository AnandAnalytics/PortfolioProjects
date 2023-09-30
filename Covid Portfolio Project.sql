SELECT * 
FROM CovidProject2..CovidDeaths 
where continent is not null
ORDER BY 3,4 

SELECT * 
FROM CovidProject2..CovidVax
ORDER BY 3,4  

--Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths,population
FROM CovidProject2..CovidDeaths
order by 1,2 

--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject2..CovidDeaths 
Where location like '%Canada%'
and continent is not null
order by 1,2 


--Looking at the Total cases  vs Population

SELECT Location, date, Population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM CovidProject2..CovidDeaths 
Where location like '%Canada%'
order by 1,2 


-- Looking at Countries with highest infection rate compared to the population 
SELECT Location, Population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProject2..CovidDeaths 
--Where location like '%Canada%'
Group by Location,Population
order by PercentPopulationInfected desc



--showing Countries with highest death count per population 
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths$ 
--Where location like '%Canada%'
where continent is null
Group by Location
order by TotalDeathCount desc 

--LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing the continents with the highest death counts 
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject2..CovidDeaths 
--Where location like '%Canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc  




-- Global Numbers 

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject2..CovidDeaths 
--Where location like '%Canada%'
where continent is not null
--Group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject2..CovidDeaths dea 
Join CovidProject2..CovidVax vac
	On dea.location = vac.location 
	and dea.date = vac.date  
	where dea.continent is not null
order by 2,3


--USE CTE 

With PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject2..CovidDeaths dea 
Join CovidProject2..CovidVax vac
	On dea.location = vac.location 
	and dea.date = vac.date  
where dea.continent is not null
--order by 2,3
) 
Select* , (RollingPeopleVaccinated/Population)*100
From PopvsVac  



--TEMP TABLE  
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject2..CovidDeaths dea 
Join CovidProject2..CovidVax vac
	On dea.location = vac.location 
	and dea.date = vac.date  
--where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated 


-- Creating view to store data for later visualization. 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject2..CovidDeaths dea 
Join CovidProject2..CovidVax vac
	On dea.location = vac.location 
	and dea.date = vac.date  
where dea.continent is not null
--order by 2,3  

Select* FROM PercentPopulationVaccinated