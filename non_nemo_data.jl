ENV["JULIA_PYTHONCALL_EXE"] = "env/scripts/python.exe"

using CairoMakie, NPZ, Rasters, Shapefile, GeoDataFrames, GeoFormatTypes, Statistics, LinearAlgebra, PythonCall, GeoJSON, DataFrames, CSV
using Base.Threads

pa_pm25_emis = Raster("data/pa_pm25_emissions_data_v2.tif")
#npy_data = npzread("data/pa_pm25_emissions_data.npy")
#x_range = range(1.0196644610284471e6, 2.9405851371205086e6, size(npy_data, 2))
#y_range = range(1.272233114741428e6, -176652.4464065095, size(npy_data, 1))

#pa_pm25_emis = Raster(npy_data,(Y(y_range),X(x_range));crs = crs(pa_pm25_emis_tif))

replace!(pa_pm25_emis, NaN => 0.0)
coalesce.(pa_pm25_emis, 0.0)

pa_census_tracts_up = GeoDataFrames.read("data/census_tracts/cb_2015_42_tract_500k.shp")
pa_census_tracts = GeoDataFrames.reproject(pa_census_tracts_up, GeoFormatTypes.EPSG(4269), GeoFormatTypes.EPSG(2272))

# horrendous workaround but it works!
Rasters.write("data/tmp_emissions.tiff", pa_pm25_emis; driver="GTiff", force=true)
tmp_tracts_string = GeoJSON.write(pa_census_tracts)
PYgpd = pyimport("geopandas")
PYee = pyimport("exactextract")

PY_tracts = PYgpd.read_file(tmp_tracts_string, driver="GeoJSON")
PY_emis_mean = PYee.exact_extract("data/tmp_emissions.tiff",PY_tracts, pylist(["mean"]))
emis_means = [pyconvert(Float64, em["properties"]["mean"]) for em in PY_emis_mean]
pa_census_tracts[!,:mean_emis] = emis_means

replace!(pa_census_tracts[!,:mean_emis], NaN => 0.0)
coalesce.(pa_census_tracts[!,:mean_emis], 0.0)

fig = Figure(size=(1000,500))
ax = Axis(fig[1,1],aspect=DataAspect())

hidespines!(ax)
hidedecorations!(ax)

plt = poly!(ax,
      pa_census_tracts.geometry;
      color = pa_census_tracts.mean_emis,
      colormap = :magma,
)

cb = Colorbar(fig[1,2], plt, label = "Emissions", width=20, tickalign=1)

colsize!(fig.layout, 1, Relative(0.85)) 
colgap!(fig.layout, 15)


GeoDataFrames.write("data/pm25s.gpkg", pa_census_tracts[:,[:GEOID, :geometry, :mean_emis]])

save("figs/fig0.svg",fig)
