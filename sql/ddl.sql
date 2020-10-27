-- staging table
CREATE TABLE spatial_map_stg (
	pcd	TEXT,
	pcd2	TEXT,
	pcds	TEXT,
	dointr	INTEGER,
	doterm	INTEGER,
	usertype	INTEGER,
	oseast1m	INTEGER,
	osnrth1m	INTEGER,
	osgrdind	INTEGER,
	oa11	TEXT,
	cty	TEXT,
	ced	TEXT,
	laua	TEXT,
	ward	TEXT,
	hlthau	TEXT,
	nhser	TEXT,
	ctry	TEXT,
	rgn	TEXT,
	pcon	TEXT,
	eer	TEXT,
	teclec	TEXT,
	ttwa	TEXT,
	pct	TEXT,
	nuts	TEXT,
	park	TEXT,
	lsoa11	TEXT,
	msoa11	TEXT,
	wz11	TEXT,
	ccg	TEXT,
	bua11	TEXT,
	buasd11	TEXT,
	ru11ind	INTEGER,
	oac11	TEXT,
	lat	TEXT,
	long	TEXT,
	lep1	TEXT,
	lep2	TEXT,
	pfa	TEXT,
	imd	TEXT,
	calncv	TEXT,
	stp	TEXT
);

-- map
CREATE TABLE spatial_map AS
SELECT DISTINCT oa11, cty, ced, laua, ward, hlthau, nhser
, ctry, rgn, pcon, eer, teclec, ttwa, pct, nuts, park
, lsoa11, msoa11, wz11, ccg, bua11, buasd11, ru11ind
, oac11, lep1, lep2, pfa, imd, calncv, stp
FROM spatial_map_stg;
-- smaller ~ 30k
CREATE TABLE spatial_map_sm AS
SELECT DISTINCT cty, ced, laua, ward, hlthau, nhser
, ctry, rgn, pcon, eer, teclec, ttwa, pct, nuts, park
, msoa11, ccg, bua11, buasd11, ru11ind
, lep1, lep2, pfa, calncv, stp
FROM spatial_map;
-- nb. can now delete _stg if post code data not required
DROP TABLE spatial_map_stg;
DROP TABLE spatial_map;

-- population density
CREATE TABLE lad_population_gender (
	lad19cd	TEXT,
	lad19nm	TEXT,
	bng_e	INTEGER,
	bng_n	INTEGER,
	Male	INTEGER,
	Female	INTEGER
);
CREATE TABLE lad_population_age (
	lad19cd	TEXT,
	age	INTEGER,
	val	INTEGER
);

-- for faster queries
CREATE INDEX idx_lp_age ON lad_population_age(lad19cd);
CREATE INDEX idx_sm_laua ON spatial_map(laua);

-- weekly deaths
CREATE TABLE weekly_deaths (
	v4_0	INTEGER,
	calendar_years	INTEGER,
	time	INTEGER,
	admin_geography	TEXT,
	geography	TEXT,
	week_number	TEXT,
	week	TEXT,
	cause_of_death	TEXT,
	causeofdeath	TEXT,
	place_of_death	TEXT,
	placeofdeath	TEXT,
	registration_or_occurrence	TEXT,
	registrationoroccurrence	TEXT
);
