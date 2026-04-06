import netCDF4
import numpy as np

ALL_EMISSIONS_VARIABLES = ['VOCANN', 'NOXANN', 'COANN', 'SO2ANN', 'NH3ANN', 'PM25ANN', 'PECANN', 'POCANN', 'PMCANN']

def parse_emissions(ncf_path,npy_path,emissions_variables=['PM25ANN']):
    