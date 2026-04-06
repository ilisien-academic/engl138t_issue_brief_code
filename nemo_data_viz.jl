using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes

pa_pm25_emis = Raster("data/pa_pm25_emissions_data.tif")

pa_census_tracts = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")

pa_census_tracts = GeoFormatTypes.reproject(pa_census_tracts, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))


pa_pm25_emis_nans = npzread("data/pa_pm25_emissions_data.npy")'

pa_pm25_emis = ifelse.(isnan.(pa_pm25_emis_nans), missing, pa_pm25_emis_nans)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig