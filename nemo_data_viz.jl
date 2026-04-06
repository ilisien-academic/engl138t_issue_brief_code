using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames

pa_pm25_emis_nans = npzread("data/pa_pm25_emissions_data.npy")'
pa_pm25_emis = ifelse.(isnan.(pa_pm25_emis_nans), missing, pa_pm25_emis_nans)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig