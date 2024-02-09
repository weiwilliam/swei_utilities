#!/usr/bin/env python3
import os,sys
from pathlib import Path
import yaml
import subprocess

control_yaml = sys.argv[1]
conf = yaml.load(open(yaml_file),Loader=yaml.FullLoader)

in_sbatch_tmpl = os.path.join(os.path.dirname(__file__),'..','jobcard','')

slurm_job = conf['slurm']['jobname']
slurm_nnode = conf['slurm']['n_node']
slurm_ntask = conf['slurm']['n_task']
slurm_acct = conf['slurm']['account']
slurm_part = conf['slurm']['partition']
slurm_qos = conf['slurm']['qos']

wrkpath = conf['wrkpath']
logpath = conf['logpath']

for d in [wrkpath,logpath]:
    if not os.path.exists(d):
        raise Exception('Please create '+d+' before running')

wrkexec = conf['jediexec']
wrkyaml = conf['jediyaml']

for chk in [wrkexec, wrkyaml]:
    if not os.path.exists(chk):
        raise Exception('Please check '+chk)

slurm_log = os.path.join(logpath,slurm_job+'_log.%%')

with open(in_sbatch_tmpl, 'r') as file:
    content = file.read()
    new_content = content.replace('%JOBNAME%',slurm_job)
    new_content = new_content.replace('%ACCOUNT%',slurm_acct)
    new_content = new_content.replace('%PARTITION%',slurm_part)
    new_content = new_content.replace('%QOS%',slurm_qos)
    new_content = new_content.replace('%LOGFILE%',slurm_log)
with open(wrksbatch,'w') as file:
    file.write(new_content)

cmd_str = 'srun --cpu_bind=core '+wrkexec+' '+wrkyaml #+' 2> stderr.$$.log 1> stdout.$$.log'
with open(wrksbatch,'a') as f:
    f.write(cmd_str)

subprocess.check_output(["sbatch", wrksbatch]).decode('utf-8')
