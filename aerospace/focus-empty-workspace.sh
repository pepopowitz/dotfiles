#!/bin/bash

# This intermediate shell script exists so that we wait for the
#   results of the first empty workspace before exiting.

# I suspect there is a better way to do this, 
#  but the session needs to know what `node` is.
source ~/.zprofile

# Get the first empty workspace
empty_workspace=$(~/.aerospace/first-empty-workspace.js)

if [ -n "$empty_workspace" ]; then
  aerospace workspace "$empty_workspace"
fi