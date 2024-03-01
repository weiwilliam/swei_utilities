#!/usr/bin/env bash

IODA_BUNDLE=$1
converter=$2
converter_output=$3
IODABUILD=$4

pycodestyle -v --config="$IODA_BUNDLE/iodaconv/.pycodestyle" --filename=*.py,*.py.in "$IODA_BUNDLE/iodaconv/src/$converter"

$IODABUILD/bin/ioda-validate.x $IODA_BUNDLE/ioda/share/ioda/yaml/validation/ObsSpace.yaml $IODA_BUNDLE/iodaconv/test/testoutput/$converter_output
