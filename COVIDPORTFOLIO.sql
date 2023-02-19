select * from myportfolioproject..DEATHSCOVID$
order by 4

--looking at total deaths vs total cases

select location, population_density, cast(total_cases as int) as total_cases, cast(total_deaths as float) as total_deaths, cast(total_deaths as float)/ cast(total_cases as int) * 100 as percentage_deaths from myportfolioproject..DEATHSCOVID$
order by percentage_deaths desc

--show percentage of population that got covid in united states

select location, date, population_density, total_cases,  (total_cases/population_density) * 100 as population_percentage_infected from myportfolioproject..DEATHSCOVID$
where location like '%states%'
order by 1, 2

--shows countries with the highest infection rates compared with population

select location, population_density, MAX(cast(total_cases as int))as highest_infection_count, MAX((total_cases / population_density)) * 100 as highest_infection_percentage 
from myportfolioproject..DEATHSCOVID$
group by location, population_density
order by highest_infection_percentage 

-- showing countries with the highest death count per population

select location, population_density, MAX(cast(total_deaths as int))as highest_death_count from myportfolioproject..DEATHSCOVID$
where continent is not null
group by location, population_density
order by 3 desc

--continents with the highest death count

select continent, MAX(cast(total_deaths as int))as highest_death_count from myportfolioproject..DEATHSCOVID$
where continent is not null
group by continent
order by 2 desc

--global numbers

select SUM(cast(new_cases as int)) as total_cases, 
SUM(cast(new_deaths as float)) as total_deaths, 
SUM(cast(new_deaths as float)) /  SUM(cast(new_cases as int)) * 100 as death_percentage 
from myportfolioproject..DEATHSCOVID$

--global numbers according to dates

select date, SUM(cast(new_cases as int)) as total_cases, 
SUM(cast(new_deaths as float)) as total_deaths, 
SUM(cast(new_deaths as float)) /  SUM(cast(new_cases as int)) * 100 as death_percentage 
from myportfolioproject..DEATHSCOVID$
where continent is not null
group by date
order by 1 

select * from myportfolioproject..VACCINATIONSCOVID$
where location like '%canada%'
order by 4

--Total pop vs vaccinations

select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as Rolling_people_vaccinated from myportfolioproject..DEATHSCOVID$ dea
join myportfolioproject..VACCINATIONSCOVID$ vac on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2, 3 

--looking at total population vs vaccinations using a CTE

With PopVSvac (continent, location, date, population_density, new_vaccinations, Rolling_people_vaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as Rolling_people_vaccinated from myportfolioproject..DEATHSCOVID$ dea
join myportfolioproject..VACCINATIONSCOVID$ vac on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2, 3 
)
select *, (Rolling_people_vaccinated/population_density) * 100 from PopVSvac

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population_density numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as Rolling_people_vaccinated from myportfolioproject..DEATHSCOVID$ dea
join myportfolioproject..VACCINATIONSCOVID$ vac on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2, 3 
select *, (Rolling_people_vaccinated/population_density) * 100 from #PercentPopulationVaccinated

--creating view to store data for later visualisation

CREATE VIEW

PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as Rolling_people_vaccinated from myportfolioproject..DEATHSCOVID$ dea
join myportfolioproject..VACCINATIONSCOVID$ vac on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2, 3 