Select *
From ProtfolioProjects..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From ProtfolioProjects..CovidVaccinations
--Order by 3,4


Select Location, date , total_cases, new_cases, total_deaths, population
From ProtfolioProjects..CovidDeaths
Where continent is not null
Order by 1,2


-- looking at total cases vs total deaths
Select Location, date , total_cases, total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
From ProtfolioProjects..CovidDeaths
Where continent is not null
and location like '%states%'
Order by 1,2


-- looking at total cases Vs Population
Select Location, date , total_cases, Population,(total_deaths/population) *100 as DeathPercentage
From ProtfolioProjects..CovidDeaths
Where continent is not null
and location like '%states%'
Order by 1,2



-- looking at countries with highest infection rate  compared to population
Select Location,Population ,Max(total_cases) as HighestInfecctedCount, Max((total_cases/population)) *100 as PercentPopulationInfected
From ProtfolioProjects..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc


-- Showing the countries highest death count per population
Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProjects..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location
Order by TotalDeathCount desc



-- lets break things down by continent

Select continent,Max(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProjects..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc


--Showing continents with the highest death count per populaton

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProjects..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc



-- Global Numbers

Select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(New_Cases) *100 as DeathPercentage
From ProtfolioProjects..CovidDeaths
Where continent is not null
--Where location like '%states%'
--Group by date
Order by 1,2


-- looking at total population vs vacctions

Select dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by  dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac(Continent , Location ,Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by  dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , ( RollingPeopleVaccinated/Population)*100
from PopvsVac




--Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentagePopulationVaccinated
 Select dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by  dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , ( RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated




-- Create View to store data for later visualizations


Create View PercentagePopulationVaccinated as
Select dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by  dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
