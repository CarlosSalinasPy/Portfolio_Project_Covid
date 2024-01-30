--- Exploratory Data Analysis
--- SOURCE => https://ourworldindata.org/covid-deaths
Select *
FROM public.covid_deaths
;

ALTER TABLE public.covid_vaccinated ALTER COLUMN tests_units TYPE TEXT;



select *
from public.covid_vaccinated;

SELECT *
FROM covid_deaths
WHERE continent is not null
and continent != ''
Order by 3,4;

select 
	sum(new_tests_smoothed::numeric) as suma
from covid_vaccinated
where new_tests_smoothed is not null and new_tests_smoothed != '';

select tests_units
FROM covid_vaccinated
WHERE tests_units is not null
AND tests_units != ''
;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
where total_cases is not null
Order by 1,2;

--- Looking at Total Cases vs Total Deaths
--- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
FROM covid_deaths
where total_cases is not null
AND location = 'Paraguay'
ORDER BY 1,2;

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
FROM covid_deaths
where total_cases is not null
AND location ilike '%states%'
ORDER BY 1,2;



-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected 
FROM covid_deaths
where total_cases is not null
AND location = 'Paraguay'
AND continent is not null
and continent != ''
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
--- only cases reported--
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,
MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM covid_deaths
WHERE continent is not null
and continent != ''
GROUP BY location, population
ORDER BY Percent_Population_Infected desc;


--- Showing Countries with Highest Death Count per Population

SELECT location,  MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent is not null
and continent != ''
GROUP BY location
ORDER BY Total_Death_Count desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent,  MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent is not null
and continent != ''
GROUP BY continent
ORDER BY Total_Death_Count desc;



--- this is the correct quantity---
SELECT LOCATION,  MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent = ''
GROUP BY location
ORDER BY Total_Death_Count desc;


-- Showing continents with the highest death count per population

SELECT continent,  MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent is not null
and continent != ''
GROUP BY continent
ORDER BY Total_Death_Count desc;

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM covid_deaths
--WHERE location = 'Paraguay'
WHERE continent is not null
and continent != ''
GROUP BY date
Order by 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM covid_deaths
--WHERE location = 'Paraguay'
WHERE continent is not null
and continent != ''
Order by 1,2


--- Looking at Total Population vs Vaccinations
-- the column new_vaccinationes is per day

SELECT *
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
ORDER BY dea.row_id asc;


SELECT COUNT(dea.row_id)
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location,
							    dea.Date) AS Rolling_People_Vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
WHERE continent is not null
AND continent != ''
AND new_vaccinations IS NOT Null
ORDER BY dea.row_id asc;


-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location,
							    dea.Date) AS Rolling_People_Vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
WHERE continent is not null
AND continent != ''
AND new_vaccinations IS NOT Null
--ORDER BY dea.row_id asc
)
SELECT *, (Rolling_People_Vaccinated/population)*100 AS PopvsVac
FROM PopvsVac


--- TEMP TABLE ---

CREATE TEMPORARY TABLE Percent_Population_Vaccinated(
	Continent VARCHAR (255),
	location VARCHAR (255),
	date date,
	population numeric,
	new_baccinations numeric,
	rolling_people_vaccinated numeric);
	
	

INSERT INTO Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location,
							    dea.Date) AS Rolling_People_Vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
WHERE continent is not null
AND continent != ''
AND new_vaccinations IS NOT Null
ORDER BY dea.row_id asc;


SELECT *, (Rolling_People_Vaccinated/population)*100 AS PopvsVac
FROM Percent_Population_Vaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS---

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location,
							    dea.Date) AS Rolling_People_Vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinated AS vac ON (vac.row_id = dea.row_id)
WHERE continent is not null
AND continent != ''
AND new_vaccinations IS NOT Null
--ORDER BY dea.row_id asc;
