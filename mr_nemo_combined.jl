using CSV, DataFrames

RR_AP = 1.14 # from Lepeule
PER_HOW_MANY_PEOPLE = 1000

mr = CSV.read("data/mortality_rates.csv",DataFrame)
pm = CSV.read("data/pm25s.csv",DataFrame)

rename!(pm, :GEOID => :tract)

mrpm = rightjoin(pm, mr; on = :tract)

function annual_ap_deaths_per_x_people(pm, mr, rr_ap, how_many_people)
    return how_many_people * (1 - (mr * rr_ap * pm)^-(1))
end

adpxp = DataFrames.combine(groupby(mrpm, :tract), [:rate, :population] => get_mr => :mortality_rate)