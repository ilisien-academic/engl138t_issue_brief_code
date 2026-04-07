import xarray
from rasterio.transform import from_origin
import geopandas as gpd
import numpy as np
from osgeo import gdal

def parse_emission_ncf(in_path,voi):
    dataset = xarray.open_dataset(in_path)

    only_voi = dataset[voi].isel(TSTEP=0,LAY=0)[::-1, :]

    xorig = -2701000.25
    yorig = -1580581.38
    xcell = 1000
    ycell = 1000
    ncols = 5397
    nrows = 3177

    x_coords = xorig + xcell * (np.arange(only_voi.sizes["COL"]) + 0.5)
    y_coords = yorig + ycell * nrows - ycell * (np.arange(only_voi.sizes["ROW"]) + 0.5)

    only_voi = only_voi.assign_coords(COL=x_coords, ROW=y_coords)
    only_voi = only_voi.rio.write_crs("+proj=lcc +lat_1=38.5 +lat_2=38.5 +lat_0=38.5 +lon_0=-97.5 +datum=WGS84 +units=m")
    only_voi = only_voi.rio.set_spatial_dims("COL","ROW")

    return only_voi

def clip_to_PA(voi_raw):
    states_shp = gpd.read_file("data/tl_2025_us_state.shp")
    pa = states_shp[states_shp["NAME"] == "Pennsylvania"]

    pa = pa.to_crs(voi_raw.rio.crs)
    voi_clipped_to_pa = voi_raw.rio.clip(pa.geometry, pa.crs, drop=True)

    return voi_clipped_to_pa

def reproject_and_export(pa_voi,out_path):
    final_reprojected = pa_voi.rio.reproject("EPSG:2272")
    final_reprojected.rio.to_raster(out_path)

def raster_to_npy(in_path,out_path):
    pa_only_emissions_dataset = gdal.Open(in_path)
    np_array = np.array(pa_only_emissions_dataset.GetRasterBand(1).ReadAsArray())
    np.save(out_path,np_array)

if __name__ == "__main__":
    ds = parse_emission_ncf("data/all_emissions_data.ncf","PM25ANN")
    pa_ds = clip_to_PA(ds)
    reproject_and_export(pa_ds,"data/pa_pm25_emissions_data.tif")
    raster_to_npy("data/pa_pm25_emissions_data.tif","data/pa_pm25_emissions_data.npy")