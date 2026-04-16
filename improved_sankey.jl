using SankeyMakie, CSV, CairoMakie, DataFrames 

sources = CSV.read("data/by_type.csv",DataFrame)

dropmissing!(sources, :pm25)

sources.source_label = [x == 1 ? "Commercial" : "Non-Commercial" for x in sources.commercial_source]

summary = combine(groupby(sources, :source_label), :pm25 => sum => :total_emissions)
println("pollution totals: $summary")

sankey_collate = combine(groupby(sources, [:desc, :source_label]), :pm25 => sum => :value)

# see docs for SankeyPlots.jl
sources = sankey_data.desc 
targets = sankey_data.source_label
values = sankey_data.value

fig = Figure()
ax = Axis(fig[1,1])

sankey!(ax, sources, targets, values)

save("emissions_sankey.svg", fig)