using CSV, DataFrames

RR_AP # from Lepeule

mr = CSV.read("data/mortality_rates.csv",DataFrame)
pm = CSV.read("data/pm25s.csv",DataFrame)

rename!(pm, :GEOID => :tract)

mrpm = rightjoin(pm, mr, on = :tract)

