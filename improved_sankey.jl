using CSV
using DataFrames
using CairoMakie
using SankeyMakie

# 1. Load and clean the data
df = CSV.read("data/by_type.csv", DataFrame)
dropmissing!(df, :pm25)

# 2. Summarize total emissions by Commercial vs Non-Commercial
# Map 1 -> Commercial, 0 -> Non-Commercial
df.source_type = [x == 1 ? "Commercial" : "Non-Commercial" for x in df.commercial_source]

summary = combine(groupby(df, :source_type), :pm25 => sum => :total)
println("Total PM2.5 Emissions by Source Type:")
println(summary)

# 3. Prepare labels for the Sankey Plot
# We want to show flows from Major Groupings (desc) to Source Type
# First, let's identify which 'desc' are Industrial for clearer grouping
industrial_keywords = ["Industrial", "Mfg", "Processing", "Petroleum"]
df.is_industrial = [any(occursin.(industrial_keywords, row.desc)) for row in eachrow(df)]

# Create a refined grouping label: e.g., "Industrial (Metals Processing)"
df.major_group = [row.is_industrial ? "Ind: $(row.desc)" : row.desc for row in eachrow(df)]

# Aggregate data for the flow: Major Group -> Source Type
flow_df = combine(groupby(df, [:major_group, :source_type]), :pm25 => sum => :value)

# 4. Create Nodes and Connections
# To use the connections syntax (src_idx, dst_idx, value), we need unique labels
all_major_groups = unique(flow_df.major_group)
all_source_types = unique(flow_df.source_type)

labels = [all_major_groups; all_source_types]
label_to_idx = Dict(name => i for (i, name) in enumerate(labels))

# Build the connections vector of tuples (Source index, Target index, Value)
connections = [
    (label_to_idx[row.major_group], label_to_idx[row.source_type], row.value)
    for row in eachrow(flow_df)
]

# 5. Plot using SankeyMakie
# We define colors: Industrial groups in blue-tones, others in greens, targets in orange/gray
node_colors = [i <= length(all_major_groups) ? :teal : :orange for i in 1:length(labels)]

fig = sankey(connections,
    nodelabels = labels,
    nodecolor = node_colors,
    linkcolor = SankeyMakie.Gradient(0.5), # Creates a gradient flow from source to target
    axis = (title = "Pollution Flow: Major Industrial/Commercial Groupings",),
    figure = (; size = (1200, 800))
)

# Save the resulting visualization
save("pollution_sankey_final.png", fig)