import xarray
import rioxarray
from rasterio.transform import from_origin

def parse_emission_ncf_to_tif(in_path,out_path,voi):
    dataset = xarray.open_dataset(in_path)

    only_voi = dataset["PM25ANN"].isel(TSTEP=0,LAY=0)

    # parameters specific to the CONUS IOAPI format (at least this NEMO dataset) obtained from julia NetCDF's "ncinfo"
    xorig = -2701000.25
    yorig = -1580581.38
    xcell = 1000
    ycell = 1000
    ncols = 5397
    nrows = 3177

    transform = from_origin(xorig,yorig + ycell * nrows, xcell, ycell)

    only_voi = only_voi.rio.write_crs("+proj=lcc +lat_1=38.5 +lat_2=38.5 +lat_0=38.5 +lon_0=-97.5 +datum=WGS84 +units=m")

    only_voi.rio.write_transform(transform, inplace = True)

    only_voi.rio.set_spatial_dims("ROW","COL")
    only_voi.rio.to_raster(out_path)

if __name__ == "__main__":
    parse_emission_ncf_to_tif("data/all_emissions_data.ncf","data/pm25_emissions_data.tif","PM25ANN")