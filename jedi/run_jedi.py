#!/usr/bin/env python3
import os,sys
from pathlib import Path
import yaml
import subprocess

control_yaml = sys.argv[1]
conf = yaml.load(open(control_yaml),Loader=yaml.FullLoader)

in_sbatch_tmpl = os.path.join(os.path.dirname(__file__),'jobcard','sbatch_tmpl')

slurm_job = conf['slurm']['jobname']
slurm_nnode = str(conf['slurm']['n_node'])
slurm_ntask = str(conf['slurm']['n_task'])
slurm_acct = conf['slurm']['account']
slurm_part = conf['slurm']['partition']
slurm_qos = conf['slurm']['qos']
slurm_memory = conf['slurm']['memory']
slurm_walltime = conf['slurm']['walltime']
slurm_mpicmd = conf['slurm']['mpicmd']

mainpath = conf['mainpath']
wrkpath = os.path.join(mainpath, 'workdir')
logpath = os.path.join(mainpath, 'logs')
outpath = os.path.join(mainpath, 'output')
rundata = os.path.join(wrkpath, 'Data')

for d in [wrkpath, logpath, outpath]:
    if not os.path.exists(d):
        os.makedirs(d)
wrksbatch = os.path.join(wrkpath,'run_sbatch')

if not os.path.exists(rundata):
    os.makedirs(rundata)

for inpath in conf['input']:
    dirname = inpath.split('/')[-1]
    os.symlink(inpath,os.path.join(rundata,dirname))

wrkexec = conf['jediexec']
wrkyaml = os.path.join(mainpath,conf['jediyaml'])

for chk in [wrkexec, wrkyaml]:
    if not os.path.exists(chk):
        raise Exception('Please check '+chk)

slurm_log = os.path.join(logpath,slurm_job+'_log.%j')

with open(in_sbatch_tmpl, 'r') as file:
    content = file.read()
    new_content = content.replace('%JOBNAME%',slurm_job)
    new_content = new_content.replace('%ACCOUNT%',slurm_acct)
    new_content = new_content.replace('%N_NODE%',slurm_nnode)
    new_content = new_content.replace('%N_TASK%',slurm_ntask)
    new_content = new_content.replace('%PARTITION%',slurm_part)
    new_content = new_content.replace('%QOS%',slurm_qos)
    new_content = new_content.replace('%MEMORY%',slurm_memory)
    new_content = new_content.replace('%WALLTIME%',slurm_walltime)
    new_content = new_content.replace('%LOGFILE%',slurm_log)
with open(wrksbatch,'w') as file:
    file.write(new_content)
with open(wrksbatch,'a') as file:
    file.write('cd '+wrkpath+'\n')

if 'mpirun' in slurm_mpicmd:
    cmd_str = slurm_mpicmd+' -n '+str(slurm_ntask)+' '+wrkexec+' '+wrkyaml
else:
    cmd_str = slurm_mpicmd+' '+wrkexec+' '+wrkyaml
with open(wrksbatch,'a') as f:
    f.write(cmd_str+'\n')

output = subprocess.run(["sbatch", wrksbatch], capture_output=True)
stdout = output.stdout.decode('utf-8')
print(stdout)
