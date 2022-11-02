SELECT *
FROM covid
WHERE continent IS NOT null 
ORDER BY 3,4;

--Let's select the data we are going to be starting with 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid
    Where continent IS NOT null 
        ORDER BY 1,2
        
--Here we will make a comparasion of Total cases vs Total Deaths, 
--the idea is to show the likelihood of dying if you get covid in your country, 
--let's use 'Colombia' as an example.

SELECT location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM covid
WHERE location = 'Colombia'
      AND continent IS NOT null 
ORDER BY 2 DESC;

--Now let's make the same exercise but with population, Cases Vs Population

SELECT location, date, Population, total_cases,  ROUND((total_cases/population)*100,2) as Percent_PopulationInfected
FROM covid
    WHERE location = 'Colombia'
        ORDER BY 2 DESC;

SELECT location, date, Population, total_cases,  ROUND((total_cases/population)*100,2) as Percent_PopulationInfected
FROM covid
    WHERE location = 'Colombia'
        ORDER BY 2 DESC;
        
--Countries with Highest Infection Rate compared to Population

SELECT  location, 
        Population, 
        MAX(total_cases) as HighestInfectionCount,  
        ROUND(MAX((total_cases/population))*100,2) AS Percent_PopulationInfected

FROM covid
    GROUP BY Location, Population
        HAVING Percent_PopulationInfected != 'nan'
ORDER BY Percent_PopulationInfected DESC;

--Now i want to know the countries with the highest death count per population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From covid

WHERE continent IS NOT null  
    GROUP BY location
        ORDER BY TotalDeathCount DESC
        OFFSET 28;  --if you don't want to exclude the values you can skip them with this.

--Now let's do the same thing but i want to break it down by continent


SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM covid

WHERE continent IS NOT null  
    GROUP BY continent
        ORDER BY TotalDeathCount DESC;

-- Yeah yeah...i know, i'm also bothered that this dataset states that america has 2 continents.

--Now lets's check the Total Population vs Vaccinations
-- and include the percentage of Population that has recieved at least one Covid Vaccine

SELECT a.continent, 
        a.location, 
        a.date, 
        a.population, 
        vac.new_Vaccinations,
        SUM(vac.new_vaccinations) OVER (Partition by a.Location ORDER BY a.location, a.date) AS RollingPeopleVaccinated,
        --(RollingPeopleVaccinated/population)*100 AS percentig
FROM covid AS a
    JOIN vaccines AS vac ON a.location = vac.location
	AND a.date = vac.date

WHERE a.continent IS NOT null 
ORDER BY 2,3, RollingPeopleVaccinated DESC;

--Here we use a CTE to perform a calculation from the previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select a.continent, a.location, a.date, a.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid AS a
Join vaccines AS vac
	On a.location = vac.location
	and a.date = vac.date
where a.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Now let´s just create a view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From covid AS dea
Join Vaccines AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



