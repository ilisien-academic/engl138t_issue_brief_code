using CSV, DataFrames

DEATHS_AGE_GROUPS = ["Under 1",
                     "1-4",
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

function map_age_group(pop_group)

    if pop_group == POP_PREFIX * "Under 5 years"
        return "Under 1"

    elseif pop_group in [
        POP_PREFIX*"5 to 9 years",
        POP_PREFIX*"10 to 14 years"]
        return "5-14"

    elseif pop_group in [
        POP_PREFIX*"15 to 19 years",
        POP_PREFIX*"20 to 24 years"]
        return "15-24"

    elseif pop_group in [
        POP_PREFIX*"25 to 29 years",
        POP_PREFIX*"30 to 34 years"]
        return "25-34"

    elseif pop_group in [
        POP_PREFIX*"35 to 39 years",
        POP_PREFIX*"40 to 44 years"]
        return "35-44"

    elseif pop_group in [
        POP_PREFIX*"45 to 49 years",
        POP_PREFIX*"50 to 54 years"]
        return "45-54"

    elseif pop_group in [
        POP_PREFIX*"55 to 59 years",
        POP_PREFIX*"60 to 64 years"]
        return "55-64"

    elseif pop_group in [
        POP_PREFIX*"65 to 69 years",
        POP_PREFIX*"70 to 74 years"]
        return "65-74"

    elseif pop_group in [
        POP_PREFIX*"75 to 79 years",
        POP_PREFIX*"80 to 84 years"]
        return "75-84"

    else
        return "85 and older"
    end
end

pop = CSV.read("data/pop_and_death_data/pop.csv",DataFrame)
deaths = CSV.read("data/pop_and_death_data/death.csv",DataFrame)

pop.Geography = [i[2] for i in split.(pop.Geography,"S")]
