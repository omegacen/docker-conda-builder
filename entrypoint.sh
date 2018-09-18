#!/bin/bash

# Activate the `base` conda environment.
. /opt/conda/bin/activate base

# Run whatever the user wants to.
exec "$@"