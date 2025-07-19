#!/bin/bash

# Get number of connected monitors
monitor_count=$(hyprctl monitors | grep 'Monitor' | wc -l)

# Compute max valid workspace ID
max_workspace=$((monitor_count * 10))

# Get all windows and their workspaces
mapfile -t windows < <(hyprctl clients -j | jq -r '.[] | "\(.address) \(.workspace.id)"')

# Track remapped windows for notification
migrated_windows=0

for win in "${windows[@]}"; do
    win_addr=$(echo "$win" | awk '{print $1}')
    ws_id=$(echo "$win" | awk '{print $2}')

    if [ "$ws_id" -gt "$max_workspace" ]; then
        # Compute destination workspace
        # Wrap to same relative position in the last available monitor
        relative_pos=$(( (ws_id - 1) % 10 + 1 ))
        target_ws=$(( (monitor_count - 1) * 10 + relative_pos ))

        # Move window
        hyprctl dispatch movetoworkspace "$target_ws,address:$win_addr"
        ((migrated_windows++))
    fi
done

if [ "$migrated_windows" -gt 0 ]; then
    notify-send "Hyprland Workspace Cleanup" "$migrated_windows window(s) migrated to valid workspaces"
else
    notify-send "Hyprland Workspace Cleanup" "No migration needed"
fi
