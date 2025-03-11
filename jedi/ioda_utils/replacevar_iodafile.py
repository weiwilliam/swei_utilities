#!/usr/bin/env python3
import sys, re
import argparse
from datetime import datetime
import netCDF4 as nc
import numpy as np
import os
from refdict import ops

class replacevar(object):
    def __init__(self, input, output, opr_dict):
        src = nc.Dataset(input, 'r')
        if src.dimensions['Location'].size == 0:
            raise Exception('no obs available')

        operate_grp = opr_dict['group']
        operate_var = opr_dict['varname']
        operate_opr = opr_dict['operator']
        operate_val = opr_dict['value']
      
        dst = nc.Dataset(output, 'w')
        dst.setncatts(src.__dict__)

        for name, dimension in src.dimensions.items():
            dst.createDimension(name, len(dimension) if not dimension.isunlimited() else None)

        for name, variable in src.variables.items():
            print(f'Processing {name}')
            # Define the variable in the new file
            dst_var = dst.createVariable(name, variable.datatype, variable.dimensions)
            # Copy variable attributes
            dst_var.setncatts(variable.__dict__)
            dst_var[:] = variable[:]

        for grp, group in src.groups.items():
            dst_grp = dst.createGroup(grp)
            for var, variable in src.groups[grp].variables.items():
                print(f'Processing {grp} / {var}')
                dst_var = dst_grp.createVariable(var, variable.datatype, variable.dimensions)
                dst_var.setncatts(variable.__dict__)
                if grp==operate_grp and var==operate_var:
                    dst_var[:] = operate_opr(variable[:], operate_val)
                    print(f'{variable[0]} => {dst_var[0]}')
                else:
                    dst_var[:] = variable[:]
                
def main():

    parser = argparse.ArgumentParser(
        description=('Read an IODA file and crop based on lat/lon')
    )
    parser.add_argument(
        '-i', '--input',
        help="path of input ioda file",
        type=str, required=True)
    parser.add_argument(
        '-o', '--output',
        help="name of output ioda file",
        type=str, required=True)
    parser.add_argument(
        '--operation',
        help="operation on /group/variable[-=|+=|*=|/=]",
        type=str, required=True)

    args = parser.parse_args()

    ops_dict = {}
    pattern = r"/([^/]+)/([^=]+)(-=)(\d+)"
    match = re.match(pattern, args.operation)
    ops_dict['group'] = str(match.group(1))
    ops_dict['varname'] = str(match.group(2))
    ops_dict['operator'] = ops[match.group(3)]
    ops_dict['value'] = int(match.group(4))

    # Read in the AOD data
    replaced = replacevar(args.input, args.output, ops_dict)

if __name__ == '__main__':
    main()
