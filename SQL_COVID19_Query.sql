--Looking at Total Population vs Vaccination


SELECT dea.continent, dea.location,dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Culmulative_Vacc
FROM  covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location  = vac.location
	AND dea.date = vac.date
WHERE dea.location NOT LIKE '%income%' AND dea.location NOT LIKE '%World%' AND dea.continent IS NOT NULL
ORDER BY 2,3

-- To show the Maximum Vaccinations per location

-- Using CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, Culmulative_Vacc) AS
(
SELECT dea.continent, dea.location,dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Culmulative_Vacc
FROM  covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location  = vac.location
	AND dea.date = vac.date
WHERE dea.location NOT LIKE '%income%' AND dea.location NOT LIKE '%World%' AND dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, Culmulative_Vacc/population*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccination numeric,
Culmulative_Vacc numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Culmulative_Vacc
FROM  covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location  = vac.location
	AND dea.date = vac.date
WHERE dea.location NOT LIKE '%income%' AND dea.location NOT LIKE '%World%' AND dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, Culmulative_Vacc/population*100 AS Percentage_Vacc_Of_Population
FROM #PercentPopulationVaccinated

/*ALTER TABLE covid_vaccinations
ALTER COLUMN new_vaccinations float*/


-- CREATING A VIEW FOR STORING DATA FOR LATER VISUALISATIONS

CREATE VIEW 
PercentPopulationVaccinated AS

SELECT dea.continent, dea.location,dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Culmulative_Vacc
FROM  covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location  = vac.location
	AND dea.date = vac.date
WHERE dea.location NOT LIKE '%income%' AND dea.location NOT LIKE '%World%' AND dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated AS


CREATE VIEW CovidProgression AS
SELECT
    date,
    location,
    SUM(new_cases) AS SumofNewCases,
    SUM(CAST(new_deaths AS INT)) AS SumofNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100
    END AS DeathPercentage
FROM
    covid_deaths
WHERE
    location NOT LIKE '%income%'
    AND location NOT LIKE '%World%'
    AND continent IS NOT NULL
GROUP BY
    date,
    location;
