#Look at total_cases vs total_deaths
#Shows how likely you are to die if you contract Covid per country
Select
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_pct
FROM
	covid_deaths
WHERE location = 'United States'
AND continent <> ""
ORDER BY
	location, date;
    
#total_cases vs population
#Shows the percentage of the population that has contracted Covid
Select
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as pct_of_population
FROM
	covid_deaths
WHERE location = 'United States'
AND continent <> ""
ORDER BY
	location, date;
    
#What countries have the highest infection rates compared to the population
Select
	location,
    population,
    MAX(total_cases) as max_infection,
    MAX(total_cases/population)*100 as pct_of_population
FROM
	covid_deaths
WHERE
	continent <> ""
GROUP BY
	location, population
ORDER BY
	pct_of_population DESC;
    
#How many people have died from being infected by Covid by Country
Select
	location,
    MAX(total_deaths) as total_death_cnt
FROM
	covid_deaths
WHERE
	continent <> ""
GROUP BY
	location
ORDER BY
	total_death_cnt DESC;
    
#Find the total deaths per continent
Select
	location,
    MAX(total_deaths) as total_death_cnt
FROM
	covid_deaths
WHERE
	continent = "" /*want to find continents that are blank as the more accurate data is
					in the location column which also lists continents*/
	AND location NOT IN #Removing non locations that were based on income
    ("High income", "Upper middle income", "Lower middle income", "Low income")
GROUP BY
	location
ORDER BY
	total_death_cnt DESC;
    
#Find total cases, total deaths and death percentage by date globally
Select
	date,
    SUM(new_cases) as total_cases, 
    SUM(new_deaths) as total_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 as death_pct
FROM
	covid_deaths
WHERE continent <> ""
GROUP BY
	date
ORDER BY
	date;
    
#Look at the total population vs the amount of people vaccinated
SELECT 
	deaths.continent,
	deaths.location,
    deaths.date,
    deaths.population,
    vac.new_vaccinations as new_vaccinations,
    SUM(vac.new_vaccinations)
		OVER
			(PARTITION BY deaths.location
            ORDER BY deaths.location, deaths.date) as rolling_tot_vac
FROM covid_deaths as deaths
JOIN covid_vaccinations as vac
	ON deaths.location = vac.location
    AND deaths.date = vac.date
WHERE deaths.continent <> ""
ORDER BY deaths.continent, deaths.location, deaths.date;

/*Create a CTE to use the new column rolling_tot_vac to find the rolling percent
of people vaccinated*/
WITH pop_vs_vac 
	(continent, location, date, population, new_vaccinations, rolling_tot_vac)
AS
	(
	SELECT 
		deaths.continent,
		deaths.location,
		deaths.date,
		deaths.population,
		vac.new_vaccinations as new_vaccinations,
		SUM(vac.new_vaccinations)
			OVER
				(PARTITION BY deaths.location
				ORDER BY deaths.location, deaths.date) as rolling_tot_vac
	FROM covid_deaths as deaths
	JOIN covid_vaccinations as vac
		ON deaths.location = vac.location
		AND deaths.date = vac.date
	WHERE deaths.continent <> ""
    )
SELECT *, (rolling_tot_vac/population)*100 as rolling_pct_vac
FROM pop_vs_vac;

#Views for visualizations
CREATE VIEW pct_pop_vac as
SELECT 
		deaths.continent,
		deaths.location,
		deaths.date,
		deaths.population,
		vac.new_vaccinations as new_vaccinations,
		SUM(vac.new_vaccinations)
			OVER
				(PARTITION BY deaths.location
				ORDER BY deaths.location, deaths.date) as rolling_tot_vac
	FROM covid_deaths as deaths
	JOIN covid_vaccinations as vac
		ON deaths.location = vac.location
		AND deaths.date = vac.date
	WHERE deaths.continent <> "";

CREATE VIEW death_pct as
Select
	date,
    SUM(new_cases) as total_cases, 
    SUM(new_deaths) as total_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 as death_pct
FROM
	covid_deaths
WHERE continent <> ""
GROUP BY
	date
ORDER BY
	date;
    
CREATE VIEW total_deaths_per_continent as
Select
	location,
    MAX(total_deaths) as total_death_cnt
FROM
	covid_deaths
WHERE
	continent = "" /*want to find continents that are blank as the more accurate data is
					in the location column which also lists continents*/
	AND location NOT IN #Removing non locations that were based on income
    ("High income", "Upper middle income", "Lower middle income", "Low income")
GROUP BY
	location
ORDER BY
	total_death_cnt DESC;
    
CREATE VIEW total_deaths_per_country as
Select
	location,
    MAX(total_deaths) as total_death_cnt
FROM
	covid_deaths
WHERE
	continent <> ""
GROUP BY
	location
ORDER BY
	total_death_cnt DESC;
    
CREATE VIEW country_inf_rate as
Select
	location,
    population,
    MAX(total_cases) as max_infection,
    MAX(total_cases/population)*100 as pct_of_population
FROM
	covid_deaths
WHERE
	continent <> ""
GROUP BY
	location, population
ORDER BY
	pct_of_population DESC;