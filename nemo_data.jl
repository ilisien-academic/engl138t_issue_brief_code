using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes, Statistics, LinearAlgebra
using Base.Threads

function mean_raster_in_shape(raster, shape)
    cropped = crop(raster; to=shape, pad=true)
    cvg = Rasters.coverage(shape; to=cropped, scale=10)
    masked_raster = mask(cropped; with=shape)
    return sum(skipmissing(cvg .* masked_raster)) / sum(skipmissing(cvg))
end

pa_pm25_emis_tif = Raster("data/pa_pm25_emissions_data.tif")
npy_data = npzread("data/pa_pm25_emissions_data.npy")
x_range = range(1.0196644610284471e6, 2.9405851371205086e6, size(npy_data, 2))
y_range = range(1.272233114741428e6, -176652.4464065095, size(npy_data, 1))

pa_pm25_emis = Raster(npy_data,(Y(y_range),X(x_range));crs = crs(pa_pm25_emis_tif))

replace_missing!(pa_pm25_emis, 0.0)
replace!(pa_pm25_emis, NaN => 0.0)

pa_census_tracts_up = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")
pa_census_tracts = GeoDataFrames.reproject(pa_census_tracts_up, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))

pa_census_tracts[!,:mean_emis] .= 0.0
geoms = pa_census_tracts.geometry

@threads for i in eachindex(geoms)
    pa_census_tracts[i, :mean_emis] = mean_raster_in_shape(pa_pm25_emis, geoms[i])
end

#=plot!(ax, pa_pm25_emis; colormap = :plasma, colorscale=log10, nan_color = (:white, 0))

poly!(ax, pa_census_tracts.geometry; color=(:white,0), strokecolor=:black,strokewidth=0.5)

fig=#


fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

poly!(ax,
      pa_census_tracts.geometry;
      color = pa_census_tracts.mean_emis,
      colormap = :plasma,
      strokecolor = :white,
      strokewidth = 0.0
)

fig

#=
pa_pm25_emis_nans = npzread("data/pa_pm25_emissions_data.npy")'

pa_pm25_emis = ifelse.(isnan.(pa_pm25_emis_nans), missing, pa_pm25_emis_nans)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig=#