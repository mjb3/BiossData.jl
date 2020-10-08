# Population data
This repo contains:

- A SQLite database with population densities, ready to query.
- SQLite commands and DDL scripts for initialising the database from scratch for reference.
- Julia code for fetching some data (see examples folder)
- Sample queries (see the SQL folder)

## Database: db/chrisbits.db
### Tables
- `spatial_map_sm`  various different geographical groupings
- `areadata_gender` population density by LAD / gender
- `areadata_age`    population density by LAD / age (year)

### Using the database
SQLite databases are files. One way to access them is by using the command line tool. Open a terminal and `cd` to the database directory, then run:

```
cmd> sqlite3 chrisbits.db
```

Use `.help` to find information on commands such as `.tables` which lists the tables in the database. You can also run queries:

```
sqlite> .headers on
sqlite> SELECT * FROM spatial_map_sm LIMIT 10;
```

The [SQLite documentation][sqlite_docs] has useful information about writing queries and other things. 

### Querying from Julia, R, etc
The command line tool can also be used to call scripts and save the results to a CSV file but it is often easier to query directly from software you are using to analyse the results.  An example in Julia, which imports the data from the queries below is given in the `examples` folder - more to come in other languages.

### Sample queries

These queries return population density by HA/gender and HA/age respectively:

```
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
```

[sqlite_docs]: https://www.sqlite.org/docs.html
