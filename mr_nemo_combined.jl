using DataFrames, CSV

mr = CSV.read("data/mortality_rates.csv",Dataframe)
pm = CSV.read("data/pm25s.csv",Dataframe)

mrpm = rightjoin()