using CSV, DataFrames

DEATHS_AGE_GROUPS= ["Under 1","1-4","5-14", "15-24", "25-34", "35-44", "45-54", "55-64", "65-74", "75-84", "85 and older"]
POP_PREFIX = [""]

pop = CSV.read("data/pop_and_death_data/pop.csv",DataFrame)
deaths = CSV.read("data/pop_and_death_data/death.csv",DataFrame)

pop.Geography = [i[2] for i in split.(pop.Geography,"S")]
