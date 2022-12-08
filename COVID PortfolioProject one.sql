
--COVID 19 Data Analysis - started on 10/29/2022, completed on 11/2/2022 

Select * 
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4 

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2 

--Looking at Total Cases vs Total Deaths
--Shows the liklihood of dying if you were to contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%' 
order by 1,2

--Looking at Total Cases vs Population
--This will display the percentage of population got Covid-- 

Select location, date, population, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
order by 1,2


--Looking at countries with the Highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
group by location, population 
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
group by location 
order by TotalDeathCount desc 

--Break data down by Continent

--Will use this query for creating a Visualization 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
group by continent 
order by TotalDeathCount desc 

--Please note that this query is the correct one, but we will use the 1st one with continent to create Tableau Visualization--
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is null
group by location 
order by TotalDeathCount desc 


--Showing the continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
group by continent 
order by TotalDeathCount desc 


--Global Numbers

Select date, SUM(new_cases) -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
group by date 
order by 1,2 


Select date, SUM(new_cases) as 'New Cases', SUM(cast(total_deaths as int)) as 'Total Deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
group by date 
order by 1,2 



--Join the Covid Deaths table with Covid Vaccinations table 

--Looking at Total Population vs Vaccinations 

Select * 
From PortfolioProject.dbo.CovidDeaths dea 
Join PortfolioProject.dbo.CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date 

--Total people in world who are vaccinated 
--Note that "convert (int," is same as "cast as int"

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea 
Join PortfolioProject.dbo.CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null --and vac.new_vaccinations is not null 
order by 2,3

--USE a CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea 
Join PortfolioProject.dbo.CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
Select * 
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVac 
Create Table #PercentPopulationVac 
(
Continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric,
PercentPopulationVac numeric
)

Insert into #PercentPopulationVac   --#PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea 
Join PortfolioProject.dbo.CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVac 



--Creating View to store data for visualizations 

Create View PercentPopulationVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea 
Join PortfolioProject.dbo.CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3 

--Table for view query above is not displaying in Views folder on the left panel, however, the below query is returning results for the PercentPopulationVac table 
Select * 
From PercentPopulationVac
