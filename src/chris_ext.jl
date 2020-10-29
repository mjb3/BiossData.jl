##
import SQLite
import DataFrames

## CHANGE THIS
DB_PATH = "/home/martin/AtomProjects/BiossData.jl/db/chrisbits.db"
OUT_PATH = "/home/martin/AtomProjects/BiossData.jl/out/"

### to enable easy switching between mappings:
## E&W:
# SQL_MAP_TABLE = "spatial_map_sm"
# SQL_MAP_LADCOL = "laua"
## ENGLAND ONLY
SQL_MAP_TABLE = "spatial_map_england_view"
SQL_MAP_LADCOL = "lad19_cd"
# - WARNING: THIS IS A HACK. IF THERE ARE MISSING LAD'S IN THE WEEKLY CASES FILE THEY'RE DROPPED

## population densities
function fetch_population_data(db, clm_area::String)
    fpath = string(OUT_PATH, "area_population_by_", clm_area, "2.txt")

    ## SQL area mapping
    sql_map = string("INNER JOIN (SELECT DISTINCT ", SQL_MAP_LADCOL, " AS lad, ", clm_area, " as area FROM ", SQL_MAP_TABLE, ") m ON(g.lad19cd = m.lad)")

    ## by gender
    sql_base = ", SUM(g.Male) as male, SUM(g.Female) as female\nFROM lad_population_gender g\n"
    sql = string("SELECT m.area", sql_base, sql_map, "\nGROUP BY m.area")
    println("Running SQL:\n", sql)
    # run query
    r1 = SQLite.DBInterface.execute(db, sql) |> DataFrames.DataFrame
    println(" - done: ", size(r1))

    ## by age (NB. should return 91 rows or nothing)
    function fetch_by_age(area_cd)
        sql_base = string(", age, SUM(val) as val\nFROM lad_population_age g\n")
        sql = string("SELECT m.area", sql_base, sql_map, "\nWHERE m.area=?\nGROUP BY m.area, age ORDER BY age")
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
    # return r1
end

## weekly deaths
function fetch_deaths_data(db, clm_area::String, in_hospital::Bool)
    fpath = string(OUT_PATH, "covid_", in_hospital ? "" : "non", "h_deaths_weekly_by_", clm_area, ".txt")
    ## get areas
    ar_sql = string("SELECT DISTINCT ", clm_area, " as area FROM ", SQL_MAP_TABLE, " WHERE ", clm_area, "!=''")
    ars = SQLite.DBInterface.execute(db, string(ar_sql, " ORDER BY area")) |> DataFrames.DataFrame
    ## get dates
    dts = SQLite.DBInterface.execute(db, "SELECT DISTINCT Week, WC FROM week_key_view WHERE date(WC) < date('2020-09-22') ORDER BY date(WC)") |> DataFrames.DataFrame
    ## get wd
    function fetch_deaths_by_week(wc::String)
        base_sql = string("SELECT a.area, SUM(w.val) as val\nFROM (", ar_sql, ") a")
        map_sql = string("\nINNER JOIN (SELECT DISTINCT ", SQL_MAP_LADCOL, " as lad, ", clm_area, " AS area FROM ", SQL_MAP_TABLE, ") m ON(a.area = m.area)")
        wd_sql = string("\nLEFT OUTER JOIN weekly_deaths_view w ON(w.admin_geography = m.lad AND cause_of_death = 'covid-19' AND place_of_death", in_hospital ? "" : "!", "='hospital' AND WC = ?)")
        sql = string(base_sql, map_sql, wd_sql, "\nWHERE a.area != '' GROUP BY a.area ORDER BY a.area")
        # println(sql)
        wd = SQLite.DBInterface.execute(db, sql, (wc, )) |> DataFrames.DataFrame
        return wd
    end
    ## write frame
    open(fpath, "w") do f
        # print headers (areas)
        write(f, "date_area")
        for a in eachrow(ars)
            write(f, "\t$(a[:area])")
        end
        # each date
        for d in eachrow(dts)
            write(f, "\n$(d[:WC])")
            dd = fetch_deaths_by_week(d[:WC])
            for a in eachrow(dd)
                write(f, "\t$(a[:val])")
            end
        end
    end
    println(" - deaths data done.")
end

## daily cases (specimen)
# - src: https://coronavirus.data.gov.uk/about-data#downloads (ENGLAND ONLY)
# - FOR WALES, see: https://public.tableau.com/profile/public.health.wales.health.protection#!/vizhome/RapidCOVID-19virology-Public/Headlinesummary
function fetch_cases_data(db, clm_area::String)
    fpath = string(OUT_PATH, "covid_cases_daily_by_", clm_area, ".txt")       ### DIFF*
    ## get areas
    # ar_sql = string("SELECT DISTINCT ", clm_area, " as area FROM ", SQL_MAP_TABLE)
    ar_sql = string("SELECT DISTINCT ", clm_area, " as area FROM ", SQL_MAP_TABLE, " WHERE ", clm_area, "!=''")
    ars = SQLite.DBInterface.execute(db, string(ar_sql, " ORDER BY area")) |> DataFrames.DataFrame
    ## get dates    ### DIFF*
    dts = SQLite.DBInterface.execute(db, "SELECT DISTINCT sp_date FROM daily_cases") |> DataFrames.DataFrame # WHERE areaType=?
    ## get wd
    function fetch_cases_by_day(dt::String)
        base_sql = string("SELECT a.area, SUM(d.val) as val\nFROM (", ar_sql, ") a")
        map_sql = string("\nINNER JOIN (SELECT DISTINCT ", SQL_MAP_LADCOL, " as lad, ", clm_area, " AS area FROM ", SQL_MAP_TABLE, ") m ON(a.area = m.area)")
        wd_sql = string("\nLEFT OUTER JOIN daily_cases_view d ON(d.lad = m.lad AND d.sp_date = ?)")
        sql = string(base_sql, map_sql, wd_sql, "\nWHERE a.area != '' GROUP BY a.area ORDER BY a.area")
        # println(sql)
        wd = SQLite.DBInterface.execute(db, sql, (dt, )) |> DataFrames.DataFrame
        return wd
    end
    ## write frame
    open(fpath, "w") do f
        # print headers (areas)
        write(f, "date_area")
        for a in eachrow(ars)
            write(f, "\t$(a[:area])")
        end
        # each date
        for d in eachrow(dts)
            write(f, "\n$(d[:sp_date])")
            dd = fetch_cases_by_day(d[:sp_date])
            for a in eachrow(dd)
                write(f, "\t$(a[:val])")
            end
        end
    end
    println(" - cases data done.")
end

## run
function run_batch(clm_area::String)
    db = SQLite.DB(DB_PATH)     # connect to db
    fetch_population_data(db, clm_area)
    fetch_deaths_data(db, clm_area, true)
    fetch_deaths_data(db, clm_area, false)
    fetch_cases_data(db, clm_area)
    println(" - finished.")
end

## E&W
# run_batch("hlthau")
# run_batch("pct")
# run_batch("laua")

## ENGLAND ONLY
run_batch("rgn19_cd")
run_batch("utla19_cd")
run_batch("lad19_cd")
