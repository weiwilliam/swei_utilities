#!/usr/bin/env bash
# Define my useful functions and alias crossing all platforms
#
# SLURM system: Orion, S4,
alias showmyslurm='sacctmgr show User $USER --associations'
alias slurmlist='squeue -u ${USER} -o "%.10i %.9P %.6q %.35j %.8u %.8T %.10M %.10L %.3D %R"'
alias slurmdel='scancel'

# PBS system: NCAR machine
alias pbslist='qstat -w -u $USER'
alias pbsdel='qdel'
alias rda='cd /glade/campaign/collections/rda/data'
alias gocr='ssh cron.hpc.ucar.edu'

# Other alias
alias ftpds='sftp swei@data-access.ucar.edu:/glade/work/swei'
alias ftpor='sftp shihwei@Orion-dtn.hpc.msstate.edu:/work2/noaa/jcsda/shihwei'
alias psu='ps -ef | grep ^${USER}'
alias killstop='kill -9 `jobs -ps`'
alias ls='ls --color'
alias la='ls -a'
alias lt='ls -lrt'

#
# slurm allocate
#
echo "alloc_a_node is available for following platforms:"
echo "ds, s4, or, dr"
alloc_a_node(){
export HDF5_USE_FILE_LOCKING=FALSE
export OOPS_TRACE=1
export OOPS_DEBUG=1
export VALIDATE_PARAMETERS=1
case $1 in
'ds')
  salloc --partition=compute --qos=debug --account=s2127 --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=1:00:00 ;;
's4')
  salloc --partition=s4 --account=star --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=2:00:00 ;;
'or')
  salloc --partition=orion --qos=debug --account=da-cpu --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=0:30:00 ;;
'dr')
  qinteractive -V --ntasks $3 --mem ${4}GB -A $2 -q develop -l walltime=04:00:00 -l job_priority=economy @derecho ;;
*) 
  echo "Not supported platform";;
esac
}

#
# AWS token setup
#
generate_token(){
  COOKIEJAR=cookie.txt
  rm -f $COOKIEJAR
  CUMULUS_DISTRIBUTION_URL="https://data.asdc.earthdata.nasa.gov/"
  # Get earthdata login information from .netrc
  EARTHDATA_USERNAME=`cat ~/.netrc | grep earthdata | cut -d' ' -f4`
  EARTHDATA_PASSWORD=`cat ~/.netrc | grep earthdata | cut -d' ' -f6 | sed 's/.*"\(.*\)".*/\1/g'`
  ORIGIN=$(dirname $CUMULUS_DISTRIBUTION_URL)
  CREDENTIALS_URL="$CUMULUS_DISTRIBUTION_URL/s3credentials"
  # Create a base64 hash of your login credentials
  AUTH=$(printf "$EARTHDATA_USERNAME:$EARTHDATA_PASSWORD" | base64)
  # Request the Earthdata url with client id and redirect uri to use with Cumulus
  AUTHORIZE_URL=$(curl -s -i ${CREDENTIALS_URL} | grep location | sed -e "s/^location: //");
  # Request an authorization grant code
  REDIRECT_URL=$(curl -s -i -X POST \
  -F "credentials=${AUTH}" \
  -H "Origin: ${ORIGIN}" \
  ${AUTHORIZE_URL%$'\r'} | grep Location | sed -e "s/^Location: //")
  # Set the correct cookie via the redirect endpoint with grant code
  curl -i -c ${COOKIEJAR} -s ${REDIRECT_URL%$'\r'} | grep location | sed -e "s/^location: //" &> /dev/null
  # Call the s3credentials endpoint with correct cookies
  CREDS=$(curl -i -b ${COOKIEJAR} -s $CREDENTIALS_URL)
}

set_aws_env(){
  # Use temporary credentials for aws s3
  ACCESS=`echo ${CREDS} | sed 's/.*{\(.*\)}.*/\1/g'`
  ACCESS_KEY_ID=`echo $ACCESS | cut -d',' -f1 | cut -d'"' -f4`
  SECRET=`echo $ACCESS | cut -d',' -f2 | cut -d'"' -f4`
  TOKEN=`echo $ACCESS | cut -d',' -f3 | cut -d'"' -f4`
  export AWS_REGION=us-west-2
  export AWS_ACCESS_KEY_ID=${ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${SECRET}
  export AWS_SESSION_TOKEN=${TOKEN}
}

compnc(){
  nccmp $1 $2 -d -m -g -f -S -T 0.0
}
