
-- load from staging tables
INSERT INTO sam_lad SELECT * FROM sam_lad_stg;

-- load cases data from staging
INSERT INTO daily_cases(areaCode, areaName, areaType, sp_date, unassigned, age60_plus, age0_59)
SELECT areaCode, areaName, areaType, date, unassigned, "60+", "0_59"
FROM daily_cases_stg

-- fix commas in population data
UPDATE lad_population_gender
SET male = replace(male,',',''), female = replace(female,',','');

-- run AFTER import
CREATE VIEW week_key_view AS
SELECT DISTINCT Week
, substr(WC,7)||'-'||substr(WC,4,2)||'-'||substr(WC,1,2) as WC
, substr(WE,7)||'-'||substr(WE,4,2)||'-'||substr(WE,1,2) as WE
FROM week_key;

-- occurrences ONLY ***
CREATE VIEW weekly_deaths_view AS
SELECT w.week, k.WC, w.admin_geography, w.geography
, w.cause_of_death, w.place_of_death, w.v4_0 as val
FROM weekly_deaths w
INNER JOIN week_key_view k ON(w.week = k.Week)
WHERE w.registration_or_occurrence='occurrences'

-- ad hoc mapping for ENGLAND ONLY based on weekly cases data
-- NB. ADJUST FOR NULL LADs? fixed directly in query for now
CREATE VIEW spatial_map_england_view AS
SELECT DISTINCT rgn19_cd,rgn19_nm,utla19_cd,utla19_nm,lad19_cd,lad19_nm
FROM weekly_cases_stg;

-- WORK IN PROGESS
CREATE VIEW spatial_map_england_view2 AS
SELECT e.*, s.laua
FROM spatial_map_england_view e
INNER JOIN spatial_map_sm s ON(e.lad19_cd = s.laua)
GROUP BY lad19_cd
-- JUST IN CASE IT BECOMES NECESSARY TO LINK THE TWO SPACIAL MAPS
-- NB. INNER JOIN drops 6 LADs: 318 -> 312

-- daily cases by LAD
CREATE VIEW daily_cases_view AS
SELECT areaCode AS lad, sp_date, SUM(unassigned + age60_plus + age0_59) AS val
FROM daily_cases c WHERE areaType = 'ltla' GROUP BY areaCode, sp_date;
