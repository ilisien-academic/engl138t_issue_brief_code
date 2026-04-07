using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes, Statistics, LinearAlgebra

pa_pm25_emis = Raster("data/pa_pm25_emissions_data.tif")

pa_census_tracts_up = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")
pa_census_tracts = GeoDataFrames.reproject(pa_census_tracts_up, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))

mean_in_tracts = zonal(mean, pa_pm25_emis; geometrycolumn=:geometry, of=pa_census_tracts, boundary=:touches)

print(mean_in_tracts)

#=
pa_pm25_emis_nans = npzread("data/pa_pm25_emissions_data.npy")'

pa_pm25_emis = ifelse.(isnan.(pa_pm25_emis_nans), missing, pa_pm25_emis_nans)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig=#