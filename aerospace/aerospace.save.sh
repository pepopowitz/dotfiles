#!/bin/bash

$(brew --prefix)/bin/aerospace list-windows --all --format "%{window-id}%{workspace}%{app-bundle-id}%{window-title}" --json > ~/.aerospace/.aerospace.windows.json 

terminal-notifier -message "Window layout saved" -title "Aerospace" -sound "Submarine"