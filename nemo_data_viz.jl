using CairoMakie
using NPZ 

pa_pm25_emis = npzread("data/pa_pm25_emissions_data.npy")'

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yaxis

heatmap!(pa_pm25_emis)

fig