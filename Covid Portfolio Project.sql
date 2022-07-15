
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data That we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location Like '%states%'
order by 1,2


-- Looking at the total cases vs Population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases,  (Total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where Location Like '%states%'
order by 1,2

-- Looking at countries with highest infection Rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount,  Max(Total_cases/population)*100 as PercentagePopulationInfecte
From PortfolioProject..CovidDeaths
--Where Location Like '%states%'
Group by Location, population
order by PercentagePopulationInfecte desc

-- Showing countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location Like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let`s Break Things Down by Continent
--Showing the contintents with the higest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location Like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select Sum( new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPersentage
From PortfolioProject..CovidDeaths
--Where Location Like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location =	vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Use CTE
with PopvsVac (Continent, location, DAte, Population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location =	vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Rollingpeoplevaccinated/Population)*100
From PopvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location =	vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (Rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated



--create view to store data for later visualizations

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location =	vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated

create view PercentagePopulationInfecte as
Select Location, Population, Max(total_cases) as HighestInfectionCount,  Max(Total_cases/population)*100 as PercentagePopulationInfecte
From PortfolioProject..CovidDeaths
Where Location Like '%states%'
Group by Location, population
--order by PercentagePopulationInfecte desc

Select*
From PercentagePopulationInfecte