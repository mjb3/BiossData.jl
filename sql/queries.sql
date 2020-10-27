-- population: Male / Female by health authority (I think!)
SELECT m.hlthau
, SUM(g.Male) as male
, SUM(g.Female) as female
FROM lad_population_gender g
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(g.lad19cd = m.laua)
GROUP BY m.hlthau

-- population: age by the same
SELECT hlthau, age, SUM(val) as val
FROM lad_population_age a
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(a.lad19cd = m.laua)
GROUP BY hlthau, age

-- weekly COVID deaths by HA / week
SELECT hlthau, k.Week, k.WC, SUM(v4_0) as val
FROM weekly_deaths w
INNER JOIN week_key k ON(w.week = k.Week)
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(w.admin_geography = m.laua)
WHERE cause_of_death = 'covid-19'
GROUP BY hlthau, w.week

SELECT admin_geography, k.Week, k.WC, SUM(v4_0) as val
FROM weekly_deaths w
INNER JOIN week_key k ON(w.week = k.Week)
--INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(w.admin_geography = m.laua)
WHERE cause_of_death = 'covid-19'
--WHERE cause_of_death = 'all-causes'
GROUP BY admin_geography, w.week

-- mapping distinct value count
SELECT COUNT(DISTINCT cty), COUNT(DISTINCT ced), COUNT(DISTINCT laua)
, COUNT(DISTINCT ward), COUNT(DISTINCT hlthau), COUNT(DISTINCT nhser)
, COUNT(DISTINCT ctry), COUNT(DISTINCT rgn), COUNT(DISTINCT pcon)
, COUNT(DISTINCT eer), COUNT(DISTINCT teclec), COUNT(DISTINCT ttwa)
, COUNT(DISTINCT pct), COUNT(DISTINCT nuts), COUNT(DISTINCT park)
, COUNT(DISTINCT msoa11), COUNT(DISTINCT ccg), COUNT(DISTINCT bua11)
, COUNT(DISTINCT ru11ind), COUNT(DISTINCT lep1), COUNT(DISTINCT lep2)
, COUNT(DISTINCT pfa), COUNT(DISTINCT calncv), COUNT(DISTINCT stp)
FROM spatial_map_sm
