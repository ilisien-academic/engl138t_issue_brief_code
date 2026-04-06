import xarray
import rioxarray
from rasterio.transform import from_origin

def parse_ncf_to_tif(in_path,out_path,variable_of):
    dataset = xarray.open_dataset(in_path)

