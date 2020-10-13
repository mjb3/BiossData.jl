-- Male / Female by health authority (I think!)
SELECT m.hlthau
, SUM(g.Male) as male
, SUM(g.Female) as female
FROM lad_population_gender g
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(g.lad19cd = m.laua)
GROUP BY m.hlthau

-- age by the same
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
