#!/bin/sh

# GitLab runner doesn't source .bashrc, so we do it ourselves.
. ~/.bashrc

# Run whatever the user wants to.
exec "$@"