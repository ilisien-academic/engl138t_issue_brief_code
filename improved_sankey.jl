using SankeyMakie, CSV, CairoMakie, DataFrames 

sources = CSV.read("data/by_type.csv",DataFrame)

dropmissing!(sources, :pm25)

sources.source_label = [x == 1 ? "Commercial" : "Non-Commercial" for x in sources.commercial_source]

summary = combine(groupby(sources, :source_label), :pm25 => sum => :total_emissions)
println("pollution totals: $summary")

sankey_collate = combine(groupby(sources, [:desc, :source_label]), :pm25 => sum => :value)

