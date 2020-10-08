# Population data
This repo contains:

- A database with population densities, ready to query.
- SQLite commands and DDL scripts for initialising the database from scratch for reference.
- Julia examples (WIP - more to come)
- Sample queries (see the SQL folder)

## db/chrisbits.db
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

### Querying from R
The command line tool can also be used to call scripts and save the results to a CSV file but it is often easier to query directly from software you are using to analyse the results.  An example which imports the data from the query above is in the `examples` folder.

### Sample queries

This query returns the number of traders (i.e. counterparties), trades and animals by Location for 2006:

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
