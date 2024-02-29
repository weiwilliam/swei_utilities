#!/usr/bin/env bash

converter=$1
converter_output=$2
IODA_BUNDLE=$3
IODABUILD=$4

pycodestyle -v --config="$IODA_BUNDLE/iodaconv/.pycodestyle" --filename="$converter"

$IODABUILD/bin/ioda-validate.x $IODA_BUNDLE/ioda/share/ioda/yaml/validation/ObsSpace.yaml $converter_output
