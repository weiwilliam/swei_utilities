#!/usr/bin/env python3
import netCDF4 as nc
import numpy as np

# Replace 'your_file.nc' with the path to your NetCDF file
file_path = './zero.test.viirs_j1_albedo_geovals_2021082315.nc4'
variables_to_zero = [
        'mass_fraction_of_dust001_in_air',
        'mass_fraction_of_dust002_in_air',
        'mass_fraction_of_dust003_in_air',
        'mass_fraction_of_dust004_in_air',
        'mass_fraction_of_dust005_in_air',
        'mass_fraction_of_sea_salt001_in_air',
        'mass_fraction_of_sea_salt002_in_air',
        'mass_fraction_of_sea_salt003_in_air',
        'mass_fraction_of_sea_salt004_in_air',
        'mass_fraction_of_sea_salt005_in_air',
        'mass_fraction_of_hydrophobic_black_carbon_in_air',
        'mass_fraction_of_hydrophilic_black_carbon_in_air',
        'mass_fraction_of_hydrophobic_organic_carbon_in_air',
        'mass_fraction_of_hydrophilic_organic_carbon_in_air',
        'mass_fraction_of_sulfate_in_air',
        ]

# Open the NetCDF file in 'r+' mode to allow modifications
with nc.Dataset(file_path, 'r+') as dataset:
    for var_name in variables_to_zero:
        variable = dataset.variables[var_name]
        # Create a zero array with the same shape as the variable data
        zeros_array = np.zeros(variable.shape, dtype=variable.dtype)
        # Assign the zero array to the variable
        variable[:] = zeros_array
