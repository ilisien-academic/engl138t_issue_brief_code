using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes, Statistics, LinearAlgebra
using Base.Threads

function mean_raster_in_shape(cvg,raster_wo_missings,shape)
    Rasters.coverage!(cvg,shape;scale=25)
    return dot(cvg,raster_wo_missings)/sum(cvg)
end

pa_pm25_emis_tif = Raster("data/pa_pm25_emissions_data.tif")
npy_data = npzread("data/pa_pm25_emissions_data.npy")
pa_pm25_emis = Raster(npy_data, dims(pa_pm25_emis_tif))

pa_census_tracts_up = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")
pa_census_tracts = GeoDataFrames.reproject(pa_census_tracts_up, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))

pa_census_tracts[!,:mean_emis] .= 0.0
cvg = pa_pm25_emis

Threads.@threads for i in eachindex(pa_census_tracts[!,:geometry])
    pa_census_tracts[i,:mean_emis] = mean_raster_in_shape(cvg,pa_pm25_emis,pa_census_tracts[i,:geometry])
end

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

plot!(ax, pa_pm25_emis; colormap = :plasma, colorscale=log10, nan_color = (:white, 0))

poly!(ax, pa_census_tracts.geometry; color=(:white,0), strokecolor=:black,strokewidth=0.5)

fig

#=
fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

valid_emis = filter(isfinite, pa_census_tracts.mean_emis)
clims = (quantile(valid_emis, 0.02), quantile(valid_emis, 0.98))

poly!(ax,
    pa_census_tracts.geometry;
    color = pa_census_tracts.mean_emis,
    colormap = :plasma,
    colorrange = clims,
    strokecolor = :white,
    strokewidth = 0.3
)

Colorbar(fig[1, 2],
    colormap = :plasma,
    colorrange = clims,
)=#