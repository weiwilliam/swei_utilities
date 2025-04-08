#!/usr/bin/env python3

import os, sys
import subprocess
import json

outpath='/data/users/swei/Dataset/VIIRS_J1'

jsonfile = sys.argv[1]
with open(jsonfile, 'r') as file:
    query_result = json.load(file)

for key in query_result.keys():
    if key == 'query':
        continue
    # print(query_result[key]['url'])
    src_url = query_result[key]['url']
    srcfile = os.path.basename(src_url)
    datatype = srcfile.split('.')[0]
    yrdaystr = srcfile.split('.')[1]
    datayear = yrdaystr[1:5]
    datajday = yrdaystr[5:8]
    des_path = f'{outpath}/{datatype}/{datayear}/{datajday}'
    if not os.path.exists(des_path):
        os.makedirs(des_path)
    des_file = f'{des_path}/{srcfile}'
 
    subpr_arg_list = [
        "wget",
        "-nc --auth-no-challenge --no-check-certificate", 
        src_url,
        "-O",
        des_file,
    ]

    subprocess.run(subpr_arg_list)


