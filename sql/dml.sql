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
