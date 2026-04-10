using CSV, DataFrames, CairoMakie, GeoDataFrames, GeometryBasics

RR_AP = 1.14 # hardcoded from Lepeule
PER_HOW_MANY_PEOPLE = 1000

mr = CSV.read("data/mortality_rates.csv",DataFrame)
pm = GeoDataFrames.read("data/pm25s.gpkg")
pm.geometry = [polygon(g) for g in pm.geometry]

rename!(pm, :GEOID => :tract)
transform!(mr, :tract => (x -> string.(x)) => :tract)

mrpm = rightjoin(pm, mr; on = :tract)

function annual_ap_deaths_per_x_people(pm, mr)
    return PER_HOW_MANY_PEOPLE ./ (1 .- (RR_AP .* mr .* pm))
end

transform!(mrpm, [:mean_emis,:mortality_rate] => annual_ap_deaths_per_x_people => :expected_ann_deaths_per_1000)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

poly!(ax,
      mrpm.geometry;
      color = mrpm.expected_ann_deaths_per_1000,
      colormap = :plasma,
)

fig
