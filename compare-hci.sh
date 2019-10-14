#!/bin/bash

matlab -nodisplay -r "addpath('./eval');evaluate($1, $2, $3);exit"
