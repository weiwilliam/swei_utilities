#!/usr/bin/env python3
import os, sys
import argparse
from pathlib import Path
import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

from plot_utils import set_size

# colorbar control
cb_dict = {'ori': 'vertical',
           'frac': 0.025,
           'pad': 0.04,
           'asp': 20,
           'lbl': ''
           }
# Area control
area_dict = {'minlat': -90.,
             'maxlat': 90.,
             'minlon': -180.,
             'maxlon': 180.,
             }

image_spec = {'axe_w': 8,
              'axe_h': 5,
              'axe_l': 0.1,
              'axe_r': 0.9,
              'axe_b': 0.1,
              'axe_t': 0.9,
              'dpi': 300,
              }

plot_conf = {'image_spec': image_spec,
             'area': area_dict,
             'colorbar': cb_dict,
             }
 
class read_ioda(object):
    def __init__(self, in_dict):
        self.iodafile = in_dict['iodafile']
        self.vargroup = in_dict['group']
        self.varname = in_dict['varname']

        print(self.iodafile)

        meta_ds = xr.open_dataset(self.iodafile,group='MetaData')
        lons = meta_ds.longitude
        lats = meta_ds.latitude

        data_ds = xr.open_dataset(self.iodafile,group=self.vargroup)

        if 'dim' in in_dict:
            sel_dict = {in_dict['dim']:in_dict['dimidx']}
            print(sel_dict)
            data = data_ds[self.varname].sel(sel_dict)
        else:
            data = data_ds[self.varname]
        data = data.values.ravel()
        
        name = '%s %s' %(self.vargroup, self.varname)
        self.plotdict = {'name':name,
                         'lons':lons,
                         'lats':lats,
                         'data':data,
                         }
        meta_ds.close()
        data_ds.close()

def plot_scatter(data_dict, outpng, conf):
    proj = ccrs.PlateCarree()
    lons = data_dict['lons']
    lats = data_dict['lats']
    data = data_dict['data']
   
    # assign image confs
    minlat = conf['area']['minlat']
    maxlat = conf['area']['maxlat']
    minlon = conf['area']['minlon']
    maxlon = conf['area']['maxlon']
    
    cb_ori = conf['colorbar']['ori'] 
    cb_frac = conf['colorbar']['frac'] 
    cb_pad = conf['colorbar']['pad'] 
    cb_asp = conf['colorbar']['asp'] 
    cb_lbl = conf['colorbar']['lbl']

    axe_w = conf['image_spec']['axe_w']
    axe_h = conf['image_spec']['axe_h']
    axe_l = conf['image_spec']['axe_l']
    axe_r = conf['image_spec']['axe_r']
    axe_b = conf['image_spec']['axe_b']
    axe_t = conf['image_spec']['axe_t']
    pdpi = conf['image_spec']['dpi']

 
    fig=plt.figure()
    ax=plt.subplot(projection=proj)
    set_size(axe_w, axe_h, l=axe_l, b=axe_b, r=axe_r, t=axe_t)
    ax.set_extent((minlon,maxlon,minlat,maxlat))
    ax.coastlines(resolution='110m')
    gl=ax.gridlines(draw_labels=True,dms=True,x_inline=False, y_inline=False)
    gl.right_labels=False
    gl.top_labels=False
    gl.xformatter=LongitudeFormatter(degree_symbol=u'\u00B0 ')
    gl.yformatter=LatitudeFormatter(degree_symbol=u'\u00B0 ')
    sc = ax.scatter(lons,lats,c=data,s=2,transform=ccrs.PlateCarree())

    #title_str = '%s at %s' %(plot_type,plot_date)
    ax.set_title(data_dict['name'],loc='left')
    cb = plt.colorbar(sc,orientation=cb_ori,fraction=cb_frac,pad=cb_pad,aspect=cb_asp,label=cb_lbl)
    cb.ax.ticklabel_format(axis='y', style='sci', scilimits=(0,0), useMathText=True)
        
    fig.savefig(outpng,dpi=pdpi)
    plt.close()

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description=('Read NASA VIIRS M-band Level 1b file(s) and Converter'
                     ' of native NetCDF format for observations of TOA reflectance'
                     ' from VIIRS to IODA NetCDF format.')
    )
    parser.add_argument(
        '-i', '--iodafile',
        help="path of ioda file",
        type=str, required=True)

    parser.add_argument(
        '-g', '--group',
        help="group name of ioda file",
        type=str, required=True)

    parser.add_argument(
        '-v', '--varname',
        help="variable name of ioda file",
        type=str, required=True)

    parser.add_argument(
        '-d', '--dim',
        help="plotting variable's dimension name and index",
        type=str, default=None)

    parser.add_argument(
        '-o', '--outpng',
        help="image name ",
        type=str, required=True)

    args = parser.parse_args()
    
    in_dict = {'iodafile': args.iodafile,
               'group': args.group,
               'varname': args.varname,
               }

    if args.dim!=None:
        dims, idx = args.dim.split('=')
        int_idx = []
        for i in idx.split(','):
            int_idx.append(int(i))
        in_dict['dim'] = dims
        in_dict['dimidx'] = int_idx

    print(in_dict)

    pltvar = read_ioda(in_dict) 


    plot_scatter(pltvar.plotdict, args.outpng, plot_conf)
