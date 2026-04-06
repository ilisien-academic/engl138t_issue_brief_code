using CairoMakie
using NPZ 

pa_pm25_emis = npzread("data/pa_pm25_emissions_data.npy")'
pa_pm25_emis .= ifelse.(isnan.(pa_pm25_emis), missing, pa_pm25_emis)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig