#!/usr/bin/env python3
import sys
import glob
from pyiodautils.file_merge import fileMerge

filepath = '/data/users/swei/JEDI/save_geoval/output/geovals'
filename = 'geovals.viirs_j1_albedo-70thinned_2021080504'
file_ext = 'nc4'

regex = filepath + '/' + filename + '*.' + file_ext
filenames = sorted(glob.glob(regex))
print(filenames)

outioda = filename + '.' + file_ext
# If more than one file, concatenate each obs file into one file
if len(filenames) > 0:
    ioda = fileMerge(outioda)
    ioda.concat_files(filenames, outioda)

