using CSV, DataFrames

mr = CSV.read("data/mortality_rates.csv",Dataframe)
pm = CSV.read("data/pm25s.csv",Dataframe)

rename!(pm, :GEOID => :tract)

mrpm = rightjoin(pm, mr, on = :tract)

mrpm