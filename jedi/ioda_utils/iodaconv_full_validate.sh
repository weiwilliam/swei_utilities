#!/usr/bin/env bash
converter=$1
converter_output=$2

pycodestyle -v --config="$JEDI_SRC/iodaconv/.pycodestyle" --filename=*.py,*.py.in "$converter"

$JEDI_BUILD/bin/ioda-validate.x $JEDI_SRC/ioda/share/ioda/yaml/validation/ObsSpace.yaml $converter_output
