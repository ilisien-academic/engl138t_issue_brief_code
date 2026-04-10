using CSV, DataFrames, CairoMakie, GeoDataFrames

RR_AP = 1.14 # hardcoded from Lepeule
PER_HOW_MANY_PEOPLE = 1000

real_pop = CSV.read("data/real_pop.csv",DataFrame)
real_pop.tract = [i[2] for i in split.(real_pop.tract, "S")]

mr = CSV.read("data/mortality_rates.csv",DataFrame)
pm = GeoDataFrames.read("data/pm25s.gpkg")

rename!(pm, :GEOID => :tract)
transform!(mr, :tract => (x -> string.(x)) => :tract)

pm = rightjoin(pm, real_pop; on = :tract)

mrpm = rightjoin(pm, mr; on = :tract)

function annual_ap_deaths_per_x_people(pm, mr)
    MR_0 = mr ./ (RR_AP.^(pm ./ 10))
    return PER_HOW_MANY_PEOPLE .* (mr .- MR_0)
end

transform!(mrpm, [:mean_emis,:mortality_rate] => annual_ap_deaths_per_x_people => :expected_ann_deaths_per_1000)
dropmissing!(mrpm)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

hidespines!(ax)
hidedecorations!(ax)

poly!(ax,
      mrpm.geometry;
      color = mrpm.expected_ann_deaths_per_1000,
      colormap = :magma,
)

save("figs/fig1.svg",fig)

transform!(mrpm, [:mortality_rate,:population] => ((x,y) -> x .* y) => :expected_ann_deaths)