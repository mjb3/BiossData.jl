-- fix commas in population data
UPDATE lad_population_gender
SET male = replace(male,',',''), female = replace(female,',','');
