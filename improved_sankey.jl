using SankeyMakie, CSV, CairoMakie, DataFrames 

sources = CSV.read("data/by_type.csv",DataFrame)

dropmissing!(sources, :pm25)

sources.source_label = [x == 1 ? "Commercial": "Non-Commercial" for x in sources.]