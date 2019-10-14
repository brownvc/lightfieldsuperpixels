#!/bin/bash

lightfields="'$*'"
matlab -nodisplay -r "runOnLightFields(strsplit($lightfields));exit"

