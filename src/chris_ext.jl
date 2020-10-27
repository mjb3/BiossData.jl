##
import SQLite
import DataFrames

## CHANGE THIS
DB_PATH = "/home/martin/AtomProjects/BiossData.jl/db/chrisbits.db"
OUT_PATH = "/home/martin/AtomProjects/BiossData.jl/out/"

## population densities
function fetch_population_data(clm_area::String)
    fpath = string(OUT_PATH, "area_population_by_", clm_area, ".txt")
    db = SQLite.DB(DB_PATH)     # connect to db

    ## SQL mapping
    sql_map = string("INNER JOIN (SELECT DISTINCT laua, ", clm_area, " FROM spatial_map_sm) m ON(g.lad19cd = m.laua)")

    ## by gender
    sql_base = " as area, SUM(g.Male) as male, SUM(g.Female) as female\nFROM lad_population_gender g\n"
    sql = string("SELECT m.", clm_area, sql_base, sql_map, "\nGROUP BY m.", clm_area)
    println("Running SQL:\n", sql)
    # run query
    r1 = SQLite.DBInterface.execute(db, sql) |> DataFrames.DataFrame
    println(" - done: ", size(r1))

    ## by age (NB. should return 91 rows or nothing)
    function fetch_by_age(area_cd)
        sql_base = string(", age, SUM(val) as val\nFROM lad_population_age g\n")
        sql = string("SELECT m.", clm_area, sql_base, sql_map, "\nWHERE m.", clm_area, "=?\nGROUP BY m.", clm_area, ", age ORDER BY age")
        # println("Running SQL:\n", sql)
        r2 = SQLite.DBInterface.execute(db, sql, (area_cd, )) |> DataFrames.DataFrame
        # println(" - done: ", size(r2))
        size(r2)[1] == 91 || println("WARNING ********************")
        return r2
    end

    ## write CSV
    open(fpath, "w") do f
        # print headers
        write(f, "area\tarea_name\tbng_e\tbng_n\tregion\tdensity\tMale\tFemale")
        for a in 0:90
            write(f, string("\tage", a))
        end
        # write data
        for row in eachrow(r1)
            area = row[:area]
            male::Int64 = row[:male]
            female::Int64 = row[:female]
            write(f, "\n$(area)\tna\tna\tna\t$(area)\t$(male + female)\t$(male)\t$(female)")
            # by age
            aa = fetch_by_age(area)
            for row2 in eachrow(aa)
                write(f, "\t$(row2[:val])")
            end
        end
    end
    println(" - density data done.")
    return r1
end

## weekly deaths
function fetch_deaths_data(clm_area::String, ars)
    db = SQLite.DB(DB_PATH)     # connect to db
    fpath = string(OUT_PATH, "area_population_by_", clm_area, ".txt")
    ## get dates
    dts = SQLite.DBInterface.execute(db, "SELECT DISTINCT Week, WC FROM week_key ORDER BY WC") |> DataFrames.DataFrame

    base_sql = """SELECT hlthau AS area, SUM(v4_0) as val
        FROM week_key k
        LEFT OUTER JOIN weekly_deaths w ON(w.week = k.Week)
        LEFT OUTER JOIN (SELECT DISTINCT laua, hlthau FROM spatial_map_sm) m ON(w.admin_geography = m.laua)
        WHERE cause_of_death = 'covid-19' AND k.WC = ? AND hlthau IS NOT NULL\n"""
    sql = string(base_sql, "AND place_of_death = 'hospital' GROUP BY hlthau")
    wd = SQLite.DBInterface.execute(db, sql) |> DataFrames.DataFrame

    ## write frame
    open(fpath, "w") do f
        # print headers (areas)
        write(f, "date_area")
        for a in eachrow(ars)
            write(f, "\t$(a[:area])")
        end
        # each date
        for d in eachrow(ars)
            write(f, "\n$(d[:WC])")
        end
    end

    println(" - deaths data done.")
end

## run
function run_batch(clm_area::String)
    ars = fetch_population_data(clm_area)
    fetch_deaths_data(clm_area, ars)
    println(" - finished.")
end
run_batch("hlthau")
