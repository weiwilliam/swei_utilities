#!/usr/bin/env python3
import os, sys
import argparse
from pathlib import Path
import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.colors as mpcrs
import cartopy.crs as ccrs
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

from utils import setup_cmap
from plot_utils import set_size

# colorbar control
cb_dict = {'name': 'cmocean_gray',
           'idxmax': 255,
           'ori': 'vertical',
           'frac': 0.025,
           'pad': 0.04,
           'asp': 20,
           'lbl': ''
           }

# Area control
area_dict = {'minlat': -90., # 45.7237,
             'maxlat': 90., # 84.1469,
             'minlon': -180., # 77.9727,
             'maxlon': 180., # 132.7391,
             }

image_spec = {'axe_w': 8,
              'axe_h': 5,
              'axe_l': 0.1,
              'axe_r': 0.9,
              'axe_b': 0.1,
              'axe_t': 0.9,
              'ptsize': 0.001,
              'dpi': 300,
              }

value_range = {'vmin': 0.,
               'vmax': 1.,
               'vint': 0.01,
               }

plot_conf = {'image_spec': image_spec,
             'area': area_dict,
             'colorbar': cb_dict,
             'value_range': value_range,
             }
 
class read_ioda(object):
    def __init__(self, in_dict):
        self.iodafile = in_dict['iodafile']
        self.vargroup = in_dict['group']
        self.varname = in_dict['varname']

        dims_ds = xr.open_dataset(self.iodafile)
        channel = dims_ds.Channel.values

        meta_ds = xr.open_dataset(self.iodafile,group='MetaData')
        lons = meta_ds.longitude
        lats = meta_ds.latitude

        data_ds = xr.open_dataset(self.iodafile,group=self.vargroup)
        data_ds = data_ds.assign_coords(Channel=channel.astype(np.int32))

        if 'dimidx' in in_dict:
            sel_dict = {in_dict['dim']:in_dict['dimidx']}
            print(sel_dict)
            data = data_ds[self.varname].sel(sel_dict)
        else:
            data = data_ds[self.varname]
        
        name = '%s %s' %(self.vargroup, self.varname)
        self.plotdict = {'name':name,
                         'lons':lons,
                         'lats':lats,
                         'data':data,
                         'plotdim':in_dict['dim'],
                         }
        meta_ds.close()
        data_ds.close()

def plot_scatter(data_dict, outpng, conf):
    proj = ccrs.PlateCarree()
    lons = data_dict['lons']
    lats = data_dict['lats']
    data = data_dict['data']
    plotdim = data_dict['plotdim']

    # assign image confs
    minlat = conf['area']['minlat']
    maxlat = conf['area']['maxlat']
    minlon = conf['area']['minlon']
    maxlon = conf['area']['maxlon']
    
    cb_name = conf['colorbar']['name']
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
    ptsize = conf['image_spec']['ptsize']
    pdpi = conf['image_spec']['dpi']

    vmin = conf['value_range']['vmin']
    vmax = conf['value_range']['vmax']
    vint = conf['value_range']['vint']

    cbtcks = np.arange(vmin, vmax, vint)
    lvs = cbtcks
    clridx = []
    for idx in np.linspace(2,conf['colorbar']['idxmax'],cbtcks.size):
        clridx.append(int(idx))
    clrmap = setup_cmap(cb_name,clridx)
    norm = mpcrs.BoundaryNorm(lvs,len(clridx)+1,extend='both')

    for n in data[plotdim].values:
        pltdata = data.sel({plotdim:[n]})
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
        sc = ax.scatter(lons, lats, c=pltdata, s=ptsize, cmap=clrmap, 
                        norm=norm, transform=ccrs.PlateCarree())

        title_str = '%s %s_%i' % (data_dict['name'], plotdim, n)
        ax.set_title(title_str, loc='left')
        cb = plt.colorbar(sc, orientation=cb_ori, # ticks=lvs,
                          fraction=cb_frac,pad=cb_pad,aspect=cb_asp,label=cb_lbl)
        cb.ax.ticklabel_format(axis='y', style='sci', scilimits=(0,0), useMathText=True)
       
        filename = '%s_%s%.2i.png' % (outpng, plotdim, n)
        fig.savefig(filename, dpi=pdpi)
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
        type=str, default='Channel')

    parser.add_argument(
        '-o', '--outpng',
        help="image name ",
        type=str, required=True)

    args = parser.parse_args()
    
    in_dict = {'iodafile': args.iodafile,
               'group': args.group,
               'varname': args.varname,
               }

    if '=' in args.dim:
        dims, idx = args.dim.split('=')
        in_dict['dim'] = dims
        if idx!='all':
            int_idx = []
            for i in idx.split(','):
                int_idx.append(int(i))
            in_dict['dimidx'] = int_idx
    else:
        in_dict['dim'] = args.dim

    print(in_dict)

    pltvar = read_ioda(in_dict) 

    plot_scatter(pltvar.plotdict, args.outpng, plot_conf)
