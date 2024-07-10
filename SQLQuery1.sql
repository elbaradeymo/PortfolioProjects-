SELECT location, population, MAX((total_cases/population)*100) as InfectionRate, SUM(new_deaths) as total 
FROM Portofolio.dbo.Deaths where continent is not null group by location, population order by total desc 

SELECT location, population, MAX((total_cases/population)*100) as InfectionRate, MAX(total_deaths) as total 
FROM Portofolio.dbo.Deaths where continent is not null group by location, population order by total desc

-- cases by day 
SELECT date, new_cases, new_deaths 
FROM Portofolio.dbo.Deaths 
where location =  'EGYPT' and new_cases > 0 or new_deaths > 0 
group by date, new_cases, new_deaths 
order by date asc
--GLOBAL DAILY 
SELECT date, SUM(new_cases) as diagnosed , SUM(new_deaths) dead
FROM Portofolio.dbo.Deaths 
where continent is not null 
group by date
order by date asc
SELECT date, SUM(new_cases) as diagnosed , SUM(new_deaths) dead
FROM Portofolio.dbo.Deaths 
where location = 'world'  group by date
order by date asc

--cast to add consecutive new vaccinations for each country 

Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations, 
, SUM(CAST(vac.new_vaccinations as bigint) ) OVER (partition by dea.location order by dea.location, dea.date) as vaccinationCount , vac.total_vaccinations 
from Portofolio.dbo.Vaccinations   vac 
join Portofolio.dbo.Deaths  dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null and vac.new_vaccinations is not null 

---using CTE , percentage of ppl vaccinated 
with vcount (continent , location, date, population, new_vaccination, vaccination_count) as 
( 
Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint) ) OVER (partition by dea.location order by dea.location, dea.date) as vaccinationCount 
from Portofolio.dbo.Vaccinations   vac 
join Portofolio.dbo.Deaths  dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null and vac.new_vaccinations is not null ) 
select * , (vaccination_count/population)*100 as percentage from vcount 


-- using temp TABLE 

create table #VacPercent (
continent nvarchar (255) , 
Location nvarchar (255) , 
date datetime , 
population numeric , 
new_vaccination numeric , 
vaccination_count numeric ) 
insert into #VacPercent 
Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint) ) OVER (partition by dea.location order by dea.location, dea.date) as vaccinationCount 
from Portofolio.dbo.Vaccinations   vac 
join Portofolio.dbo.Deaths  dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null and vac.new_vaccinations is not null

select *, (vaccination_count/population) *100 as percentile  from #VacPercent 

-- or create view  
create view vaccPercentile as 
Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint) ) OVER (partition by dea.location order by dea.location, dea.date) as vaccinationCount 
from Portofolio.dbo.Vaccinations   vac 
join Portofolio.dbo.Deaths  dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null 


