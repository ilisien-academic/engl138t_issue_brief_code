using CSV, DataFrames

pop = CSV.read("data/pop_and_death_data/pop.csv",DataFrame)
deaths = CSV.read("data/pop_and_death_data/death.csv",DataFrame)

pop.