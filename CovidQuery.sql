Select *
from PortforlioProject..covidDeaths
Where continent != ''
order by 3,4


--Select *
--from PortforlioProject..covidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortforlioProject..covidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows the likelohood of dying if you contract Covid in Denmark

Create View DeathPercentage as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortforlioProject..covidDeaths
Where continent != ''
--order by 1,2


-- Looking at the total cases vs the population
-- Shows what perceentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as CasePercentage
From PortforlioProject..covidDeaths
order by 1,2


-- Kiijubg at countries with highest ifection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortforlioProject..covidDeaths
Group By Location, Population
order by PercentPopulationInfected desc


-- Showing the Countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortforlioProject..covidDeaths
--Where location like '%denmark%'
Where continent != ''
Group By Location
order by TotalDeathCount desc


-- Lets Break Things Down By Continent



--Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortforlioProject..covidDeaths
--Where location like '%denmark%'
--Where continent = ''
--Group By Location
--order by TotalDeathCount desc



-- Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortforlioProject..covidDeaths
--Where location like '%denmark%'
Where continent != ''
Group By continent
order by TotalDeathCount desc


-- Global Numbers



Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deahts, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortforlioProject..covidDeaths
--Where location like '%Denmark%'
Where continent != ''
--Group By date
order by 1,2


--Looking at total population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, cast(FLOOR(vac.new_vaccinations) as int) as new_vaccinations, SUM(cast (FLOOR(vac.new_vaccinations) as int)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..covidDeaths dea
Join PortforlioProject..covidVaccinations vac
	On dea.location = vac. location
	and dea.date = vac.date
where (dea.continent != '')
order by 2,3


--USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (int, FLOOR(vac.new_vaccinations))) OVER (Partition by dea.Location Order by dea.Location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..covidDeaths dea
Join PortforlioProject..covidVaccinations vac
	On dea.location = vac. location
	and dea.date = vac.date
where (dea.continent != '')
--order by dea.date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, FLOOR(vac.new_vaccinations), SUM(CONVERT (BIGINT, FLOOR(vac.new_vaccinations))) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..covidDeaths dea
Join PortforlioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where (dea.continent != '')
--order by dea.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3



--Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, FLOOR(vac.new_vaccinations) as new_vaccinations, SUM(CONVERT (BIGINT, FLOOR(vac.new_vaccinations))) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..covidDeaths dea
Join PortforlioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where (dea.continent != '')
--order by 2,3

Select *
From PercentPopulationVaccinated