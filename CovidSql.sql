SELECT *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Chances of dying if you contract covid in a particular country(Upto 2021)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Percent_Death
FROM PortfolioProject..CovidDeaths
--where location like '%India%' --changes here for desired country
where continent is not null
order by 1,2

-- Total cases vs Population(upto 2021)
SELECT Location, date, total_cases, population, (total_cases/population) * 100 as Percent_Infected
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%India%'
order by 1,2

-- Countries with Most infections with respect to population
SELECT Location, MAX(total_cases) as Infections, Population, (MAX(total_cases/population)) * 100 as Percent_Infected
FROM PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by Location,Population
order by Percent_Infected desc

--Death Count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Death Count progression per cases per day
Select date,sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



