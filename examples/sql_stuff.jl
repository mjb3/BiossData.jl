import SQLite
import DataFrames

## CHANGE THIS
DB_PATH = "/home/martin/AtomProjects/BiossData.jl/db/chrisbits.db"

## connect to db
db = SQLite.DB(DB_PATH)

## define a query to run
sql = """SELECT m.hlthau
, SUM(g.Male) as male
, SUM(g.Female) as female
FROM lad_population_gender g
INNER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(g.lad19cd = m.laua)
GROUP BY m.hlthau"""

## run query
res = SQLite.DBInterface.execute(db, sql) |> DataFrames.DataFrame
println(res)

## define a query with some parameters
sql = """SELECT m.hlthau
, SUM(a.val) as age_group
FROM (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m
INNER JOIN lad_population_age a ON(a.lad19cd = m.laua AND a.age >= ? AND a.age < ?)
GROUP BY m.hlthau"""

# get total by HA for 0-9 age group
a = 0
b = 10
res = SQLite.DBInterface.execute(db, sql, [a, b]) |> DataFrames.DataFrame
println(res)
