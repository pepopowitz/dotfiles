#!/bin/bash

# Get the workspace name from the argument
WORKSPACE="$1"

# Default colors
BG_COLOR="#000000"
FG_COLOR="#FFFFFF"

# Map workspace names to colors
case "$WORKSPACE" in
    "1(JunkDrawer)")
        BG_COLOR="#3E2723"  # Dark oak
        FG_COLOR="#FAE5D3"  # Light sandalwood
        ;;
    "2(Comms)")
        BG_COLOR="#007AFF"  # Blue
        FG_COLOR="#FFFFFF"  # White
        ;;
    "3(TODOs)")
        BG_COLOR="#23ab37"  # Green
        FG_COLOR="#FFFFFF"  # White
        ;;
    "AliceBlue")
        BG_COLOR="#1E3A8A"  # Dark Blue
        FG_COLOR="#F0F8FF"  # Alice Blue
        ;;
    "Bisque")
        BG_COLOR="#8B4513"  # Saddle brown
        FG_COLOR="#FFE4C4"  # Bisque
        ;;
    "Cornsilk")
        BG_COLOR="#654321"  # Dark Brown
        FG_COLOR="#FFF8DC"  # Cornsilk
        ;;
    "DeepSkyBlue")
        FG_COLOR="#00BFFF"  # Deep Sky Blue
        BG_COLOR="#06047a"  # Dark blue
        ;;
    "Emerald")
        BG_COLOR="#0d6c0a"  # Emerald
        FG_COLOR="#FFFFFF"  # White
        ;;
    "FireBrick")
        BG_COLOR="#B22222"  # Fire Brick
        FG_COLOR="#FFFFFF"  # White
        ;;
    *)
        # Unknown workspace, use default colors
        BG_COLOR="#000000"
        FG_COLOR="#FFFFFF"
        ;;
esac

# Call hud with the workspace name and colors
~/bin/hud "$WORKSPACE" -bg "$BG_COLOR" -fg "$FG_COLOR"
