using CSV, DataFrames

RR_AP = 1.14 # from Lepeule
PER_HOW_MANY_PEOPLE = 1000

mr = CSV.read("data/mortality_rates.csv",DataFrame)
pm = CSV.read("data/pm25s.csv",DataFrame)

rename!(pm, :GEOID => :tract)

mrpm = rightjoin(pm, mr, on = :tract)

function 