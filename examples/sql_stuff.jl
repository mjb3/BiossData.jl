import SQLite

## CHANGE THIS
DB_PATH = ""

## connect to db
db = SQLite.DB(DB_PATH)

## define a query to run
sql = """SELECT m.hlthau
, SUM(g.Male) as male
, SUM(g.Female) as female
FROM lad_population_gender g
INNER JOIN spatial_map m ON(g.lad19cd = m.laua)
GROUP BY m.hlthau"""

## run query
res = SQLite.DBInterface.execute(db, sql, [cph, dta, dtb]) |> DataFrames.DataFrame
println(res)

## define a query with some parameters
SELECT m.hlthau
, SUM(a.val) as children
, SUM(b.val) as adults
FROM spatial_map m
INNER JOIN lad_population_age a ON(a.lad19cd = m.laua AND a.age < 18)
INNER JOIN lad_population_age b ON(b.lad19cd = m.laua AND b.age >= 18)
GROUP BY m.hlthau;


# get total by HA for
a = 0
b = 10
res = SQLite.DBInterface.execute(db, sql, [a, b]) |> DataFrames.DataFrame
