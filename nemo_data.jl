ENV["JULIA_PYTHONCALL_EXE"] = "env/scripts/python.exe"

using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes, Statistics, LinearAlgebra, PythonCall, GeoJSON
using Base.Threads
#=
function mean_raster_in_shape(raster,shape)
    #Rasters.coverage!(cvg,shape;scale=1)
    #return dot(cvg,raster_wo_missings)/sum(cvg)
    zonal_avg = Rasters.zonal(x -> mean(skipmissing(x)), raster; of=shape, boundary=:touches)
    if ismissing(zonal_avg)
        return 0.0
    else
        return zonal_avg
    end
end=#

pa_pm25_emis_tif = Raster("data/pa_pm25_emissions_data.tif")
npy_data = npzread("data/pa_pm25_emissions_data.npy")
x_range = range(1.0196644610284471e6, 2.9405851371205086e6, size(npy_data, 2))
y_range = range(1.272233114741428e6, -176652.4464065095, size(npy_data, 1))

pa_pm25_emis = Raster(npy_data,(Y(y_range),X(x_range));crs = crs(pa_pm25_emis_tif))

replace!(pa_pm25_emis, NaN => 0.0)
coalesce.(pa_pm25_emis, 0.0)

pa_census_tracts_up = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")
pa_census_tracts = GeoDataFrames.reproject(pa_census_tracts_up, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))

write("data/tmp_emissions.tif", pa_pm25_emis)
tmp_tracts_string = GeoJSON.write(pa_census_tracts)
PYgpd = pyimport("geopandas")
PYee = pyimport("exactextract")

PY_tracts = gpd.read_file(tmp_tracts_string, driver="GeoJSON")
PY_emis_mean = ee.exact_extract("data/tmp_emissions.tif",PY_tracts, ["mean"])
emis_means = [pyconvert(Float64, em["mean"]) for em in PY_emis_mean]
pa_census_tracts[!,:mean_emis] = emis_means


#geoms = pa_census_tracts.geometry
#pa_census_tracts[!,:mean_emis] .= 0.0

#@threads for i in eachindex(geoms)
#    pa_census_tracts[i,:mean_emis] = mean_raster_in_shape(pa_pm25_emis, geoms[i])
#end

#=plot!(ax, pa_pm25_emis; colormap = :plasma, colorscale=log10, nan_color = (:white, 0))

poly!(ax, pa_census_tracts.geometry; color=(:white,0), strokecolor=:black,strokewidth=0.5)

fig=#


replace!(pa_census_tracts[!,:mean_emis], NaN => 0.0)
coalesce.(pa_census_tracts[!,:mean_emis], 0.0)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())

poly!(ax,
      pa_census_tracts.geometry;
      color = pa_census_tracts.mean_emis,
      colormap = :plasma,
      strokecolor = :white,
      strokewidth = 0.0
)

display(fig)
#=
pa_pm25_emis_nans = npzread("data/pa_pm25_emissions_data.npy")'

pa_pm25_emis = ifelse.(isnan.(pa_pm25_emis_nans), missing, pa_pm25_emis_nans)

fig = Figure()
ax = Axis(fig[1,1],aspect=DataAspect())
ax.yreversed = true

heatmap!(pa_pm25_emis,colorscale=log10)

fig=#