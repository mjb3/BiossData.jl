-- Male / Female by health authority (I think!)
SELECT m.hlthau
, SUM(g.Male) as male
, SUM(g.Female) as female
FROM lad_population_gender g
INNER JOIN spatial_map m ON(g.lad19cd = m.laua)
GROUP BY m.hlthau

-- age by the same
SELECT hlthau, age, SUM(val) as val
FROM lad_population_age a
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map) m ON(a.lad19cd = m.laua)
GROUP BY hlthau, age
