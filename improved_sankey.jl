using SankeyMakie, CSV, CairoMakie, DataFrames 

sources = CSV.read("data/by_type.csv",DataFrame)

dropmissing!(sources, :"")