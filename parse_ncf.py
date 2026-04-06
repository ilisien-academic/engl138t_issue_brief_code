import xarray
import rioxarray
from rasterio.transform import from_origin

def parse_emission_ncf_to_tif(in_path,out_path,voi):
    dataset = xarray.open_dataset(in_path)

    only_voi = dataset["PM25ANN"].isel(TSTEP=0,LAY=0)

    # parameters specific to the IOAPI format
