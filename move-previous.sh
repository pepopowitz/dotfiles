#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Move Previous
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⬅️

# Documentation:
# @raycast.description Move to previous desktop
# @raycast.author Steven Hicks
# @raycast.authorURL https://github.com/pepopowitz

yabai -m window --space prev --focus
