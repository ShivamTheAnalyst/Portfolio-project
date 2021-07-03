--select *
--from [portfolio project]..[Covid Deaths]
--order by 3,4

--select *
--from [portfolio project]..[Covid Vaccinations]
--order by 3,4

select Location, Date , Total_cases , new_cases , total_deaths , population	
from [portfolio project]..[Covid Deaths]
order by location, date;

-- Looking at total cases vs total deaths.
--likelihood of dying if you have covid in your country.
select Location, Date , Total_cases , total_deaths , (total_deaths /total_cases)*100 as DeathPercentage
from [portfolio project]..[Covid Deaths]
where location  = 'India'
order by location, date;

--looking at the total cases vs the population.
--Showing what percentage of people got covid infected.
select Location, Date , population , Total_cases , (total_cases /population)*100 as InfectedPercentage
from [portfolio project]..[Covid Deaths]
where location  = 'India'
order by location, date;

--Looking at countries with Highest Infection rate compared to Population.
Select Location, Population , Max(total_cases) as HighestInfectionCount , Max((total_cases/Population))*100 as InfectedPercentage
from [portfolio project]..[Covid Deaths]
where location='India'
Group by location,Population
order by InfectedPercentage Desc;

--COUNTREIS WITH HIGHEST DEATH COUNT PER POPULATION.
select location , Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..[Covid Deaths]
where continent is not null
group by Location
order by TotalDeathCount Desc ;

--LET'S BREAK THINGS BY CONTINENT.(INSTEAD OF LOCATION)
select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..[Covid Deaths]
where continent is not null
group by continent
order by TotalDeathCount Desc ;

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION.
select continent , Max(cast(total_deaths as int)) as DeathCount
from [portfolio project]..[Covid Deaths]
where continent is not null
group by continent
order by DeathCount asc;

--GLOBAL NUMBERS (ACROSS THE WORLD)
SELECT Date ,SUM(new_cases) as Total_cases , Sum(cast(new_deaths as int)) as Total_deaths , Sum(cast(new_deaths as int))/SUM(new_cases) as PercentageDeath
from [portfolio project]..[Covid Deaths]
where continent is not null
Group by date
order by 1,2;

--GLOBAL NUMBERS -TOTAL CASES ACROSS THE WORLD
SELECT SUM(new_cases) as Total_cases , Sum(cast(new_deaths as int)) as Total_deaths , Sum(cast(new_deaths as int))/SUM(new_cases) as PercentageDeath
from [portfolio project]..[Covid Deaths]
where continent is not null
--Group by date
--order by 1,2;

Select *
from [portfolio project]..[Covid Vaccinations];

--Joining Covid deaths with Covid Vaccinations file on some common grounds.
Select *
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date ;

 --LOOKING AT TOTAL POPILATION VS VACCINATIONS
 Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day 
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
 Where Dea.continent is not null
 Order by DEa.location , DEa.date ;


 Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day 
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
 Where Dea.continent is not null
 Order by DEa.location , Dea.date ;

 --Cumulative frequecy of vaccinated_people.
Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day , Sum(CAST(Vac.new_vaccinations as int )) OVER (Partition by Dea.Location  Order by Dea.Location , Dea.date) as Cumulative_frequency_vaccinations
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
 Where Dea.continent is not null
 Order by DEa.location , Dea.date ;
 

--With CTE
 With PopvsVac (Continent , Location , Date , Population , New_vaccinations , Cumulative_frequency_vaccinations)
 as
(
Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day , Sum(CAST(Vac.new_vaccinations as int )) OVER (Partition by Dea.Location  Order by Dea.Location , Dea.date) as Cumulative_frequency_vaccinations
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
 Where Dea.continent is not null 
	)
Select * , (Cumulative_frequency_vaccinations/Population )*100 as Percntage_people_vaccinated
From PopvsVac ;

--TEMP TABLE                
--Drop table if exists #PercentagePopulationVaccianted  -IF you plan on making any alterations -must add this
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), --specifying the column and type of column.
Location Nvarchar (255),
Date Datetime,
Population numeric,
new_vaccinations numeric,
Cumulative_frequency_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day , Sum(CAST(Vac.new_vaccinations as int )) OVER (Partition by Dea.Location  Order by Dea.Location , Dea.date) as Cumulative_frequency_vaccinations
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
Where continent is not null 
	
Select * , (Cumulative_frequency_vaccinations/Population )*100 as Percntage_people_vaccinated
From #PercentPopulationVaccinated;


--Creating view to store data for later Visualizations 
Create View PouplationvsVaccinations as 
Select Dea.location , Dea.continent, Dea.date, dea.population , Vac.new_vaccinations as New_Vaccinations_per_day 
From [portfolio project]..[Covid Deaths] as Dea
join [portfolio project]..[Covid Vaccinations] as Vac
 On Dea.location = Vac.location
 and Dea.date = Vac.date 
 Where Dea.continent is not null
--rder by DEa.location , DEa.date ;





















	

