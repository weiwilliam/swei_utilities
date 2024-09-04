#!/usr/bin/env python3
import os, sys
import argparse
from pathlib import Path
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

from plot_utils import set_size

# Area control
#area_dict = {'minlat': 65.,
#             'maxlat': 70.,
#             'minlon': 86.,
#             'maxlon': 91.,
area_dict = {'minlat': 36.5,
             'maxlat': 41.5,
             'minlon': 130.5,
             'maxlon': 135.5,
             }

image_spec = {'axe_w': 8,
              'axe_h': 5,
              'axe_l': 0.1,
              'axe_r': 0.9,
              'axe_b': 0.1,
              'axe_t': 0.9,
              'dpi': 300,
              'x': 'state',
              'y': 'level',
              }

states_name = {'mass_fraction_of_dust001_in_air':'du001',
               'mass_fraction_of_dust002_in_air':'du002',
               'mass_fraction_of_dust003_in_air':'du003',
               'mass_fraction_of_dust004_in_air':'du004',
               'mass_fraction_of_dust005_in_air':'du005',
               'mass_fraction_of_sea_salt001_in_air':'ss001',
               'mass_fraction_of_sea_salt002_in_air':'ss002',
               'mass_fraction_of_sea_salt003_in_air':'ss003',
               'mass_fraction_of_sea_salt004_in_air':'ss004',
               'mass_fraction_of_hydrophobic_black_carbon_in_air':'bc1',
               'mass_fraction_of_hydrophilic_black_carbon_in_air':'bc2',
               'mass_fraction_of_hydrophobic_organic_carbon_in_air':'oc1',
               'mass_fraction_of_hydrophilic_organic_carbon_in_air':'oc2',
               'mass_fraction_of_sulfate_in_air':'sulf',
               }

plot_conf = {'image_spec': image_spec,
             'area': area_dict,
             'states': states_name
             }

class read_ioda(object):
    def __init__(self, in_dict, conf):
        self.iodafile = in_dict['iodafile']
        self.diagfile = in_dict['diagfile']

        print(self.iodafile)

        # area boundary
        minlon = conf['area']['minlon']
        maxlon = conf['area']['maxlon']
        minlat = conf['area']['minlat']
        maxlat = conf['area']['maxlat']

        dim_ds = xr.open_dataset(self.iodafile)
        channel = dim_ds.Channel.values.astype(np.int32)

        meta_ds = xr.open_dataset(self.iodafile,group='MetaData')
        lons = meta_ds.longitude
        lats = meta_ds.latitude
        area_mask = (lons<maxlon)&(lons>minlon)&(lats<maxlat)&(lats>minlat)
        print(area_mask.shape)

        data_dict = {}
        gv_ds = xr.open_dataset(self.diagfile) 
        gv_ds = gv_ds.rename_dims({'nlocs':'Location'})
        gv_ds = gv_ds.sel(Location=area_mask==1)
        nlocs = gv_ds.Location.size
        tmpdim = '%s_nval' % (list(conf['states'].keys())[0])
        nlevs = gv_ds[tmpdim].size
        gv_data = np.zeros((nlocs, nlevs, len(conf['states'])), dtype='float32')
        for v in range(len(conf['states'])):
            gvname = list(conf['states'].keys())[v]
            gv_data[:, :, v] = gv_ds[gvname].values
            print('%i %s, max=%e.3, min=%e.3' %(v, gvname, gv_ds[gvname].values.max(), gv_ds[gvname].values.min() ))
        data_dict['geovals'] = (['Location', 'Level', 'States'], gv_data)

        states = []
        for var in conf['states'].keys():
            states.append(conf['states'][var])
 
        coords_dict = {'Location':range(nlocs), 'Level':range(nlevs), 'States':states}
    
        tmp_ds = xr.Dataset(data_dict, coords=coords_dict)
        print(tmp_ds)
        #tmp_ds.to_netcdf('geovals_'+conf['image_spec']['x']+'.nc')
        #sys.exit()
        self.plotdict = {'varname':'geovals',
                         'dataset':tmp_ds,
                         }

        dim_ds.close()
        meta_ds.close()

def plot_profile(input_dict, outpng, conf):
    varname = input_dict['varname']
    ds = input_dict['dataset']
   
    axe_w = conf['image_spec']['axe_w']
    axe_h = conf['image_spec']['axe_h']
    axe_l = conf['image_spec']['axe_l']
    axe_r = conf['image_spec']['axe_r']
    axe_b = conf['image_spec']['axe_b']
    axe_t = conf['image_spec']['axe_t']
    pdpi = conf['image_spec']['dpi']
    xdimname = conf['image_spec']['x']

    tmpda = ds[varname]
    tmpda = xr.where((tmpda<-1e+15), np.nan, tmpda)
    tmpda = tmpda.mean(dim='Location',skipna=True)

    fig=plt.figure()
    ax=plt.subplot()
    set_size(axe_w, axe_h, l=axe_l, b=axe_b, r=axe_r, t=axe_t)
    tmpda.plot.imshow(cmap='Oranges')

    ax.set_title(input_dict['varname'],loc='left')
    ax.invert_yaxis()
    #cb = plt.colorbar(sc,orientation=cb_ori,fraction=cb_frac,pad=cb_pad,aspect=cb_asp,label=cb_lbl)
    #cb.ax.ticklabel_format(axis='y', style='sci', scilimits=(0,0), useMathText=True)

    pngfile = f'{outpng}.png'
    fig.savefig(pngfile,dpi=pdpi)
    plt.close()

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description=('')
    )
    parser.add_argument(
        '-i', '--iodafile',
        help="path of ioda file",
        type=str, required=True)

    parser.add_argument(
        '-d', '--diagfile',
        help="plotting variable's dimension name and index",
        type=str, required=True)

    parser.add_argument(
        '-o', '--outpng',
        help="image name",
        type=str, required=True)

    args = parser.parse_args()
    
    in_dict = {'iodafile': args.iodafile,
               'diagfile': args.diagfile,
               }

    print(in_dict)

    pltvar = read_ioda(in_dict, plot_conf) 

    plot_profile(pltvar.plotdict, args.outpng, plot_conf)
