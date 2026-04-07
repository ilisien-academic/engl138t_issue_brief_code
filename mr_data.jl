using CSV, DataFrames

DEATHS_AGE_GROUPS = [
    "Under 5",
    "5-14",
    "15-24",
    "25-34",
    "35-44",
    "45-54",
    "55-64",
    "65-74",
    "75-84",
    "85 and older"
]

POP_PREFIX = "Total!!Estimate!!AGE!!"
POP_AGE_GROUPS = POP_PREFIX .* [
    "Under 5 years",
    "5 to 9 years",
    "10 to 14 years",
    "15 to 19 years",
    "20 to 24 years",
    "25 to 29 years",
    "30 to 34 years",
    "35 to 39 years",
    "40 to 44 years",
    "45 to 49 years",
    "50 to 54 years",
    "55 to 59 years",
    "60 to 64 years",
    "65 to 69 years",
    "70 to 74 years",
    "75 to 79 years",
    "80 to 84 years",
    "85 years and over"
]

pop = CSV.read("data/pop_and_death_data/pop.csv",DataFrame)
deaths = CSV.read("data/pop_and_death_data/death.csv",DataFrame)

pop.Geography = [i[2] for i in split.(pop.Geography,"S")]

pop_tall = DataFrames.stack(pop, POP_AGE_GROUPS; variable_name = :age_group, value_name = :population)

rename!(pop_tall, :Geography => :tract)

function map_pop_group(g)
    if occursin("Under 5", g)
        return "Under 5"
    elseif occursin("5 to 9", g) || occursin("10 to 14", g)
        return "5-14"
    elseif occursin("15 to 19", g) || occursin("20 to 24", g)
        return "15-24"
    elseif occursin("25 to 29", g) || occursin("30 to 34", g)
        return "25-34"
    elseif occursin("35 to 39", g) || occursin("40 to 44", g)
        return "35-44"
    elseif occursin("45 to 49", g) || occursin("50 to 54", g)
        return "45-54"
    elseif occursin("55 to 59", g) || occursin("60 to 64", g)
        return "55-64"
    elseif occursin("65 to 69", g) || occursin("70 to 74", g)
        return "65-74"
    elseif occursin("75 to 79", g) || occursin("80 to 84", g)
        return "75-84"
    else
        return "85 and older"
    end
end

pop_tall.age_group = map_pop_group.(pop_tall.age_group)
pop_tall.population = isa.(pop_tall.population
deaths.rate = tryparse.(Float64,deaths.rate)

pop_grouped = DataFrames.combine(groupby(pop_tall,[:tract,:age_group]), :population => sum => :population)

pop_and_deaths = innerjoin(deaths, pop_grouped, on=[:tract, :age_group])

CSV.write("data/pop_and_death_data/pop_and_deaths.csv",pop_and_deaths)