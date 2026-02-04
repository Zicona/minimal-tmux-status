#!/usr/bin/env bash

get_tmux_option() {
  # This helper function will get the value of the tmux variable
  # or set it to a given value if it is not set
  local option=$1
  local default_value="$2"

  local option_value
  option_value=$(tmux show-options -gqv "$option")

  if [ "$option_value" != "" ]; then
    echo "$option_value"
    return
  fi
  echo "$default_value"
}

# Most of the variables are prefixed with `@minimal-tmux-` so that tmux has a unique namespace
#
# The variables are:
# - @minimal-tmux-bg: background color of the status line
# - @minimal-tmux-fg: foreground color of the status line
# - @minimal-tmux-bg-active: background color of the status line when prefix is pressed
# - @minimal-tmux-fg-active: foreground color of the status line when prefix is pressed
# - @minimal-tmux-status: position of the status line (top or bottom)
# - @minimal-tmux-justify: justification of the status line (left, centre or right)
# - @minimal-tmux-indicator: whether to show the indicator of the prefix
# - @minimal-tmux-indicator-str: string of the indicator
# - @minimal-tmux-right: whether to show the right side of the status line
# - @minimal-tmux-left: whether to show the left side of the status line
# - @minimal-tmux-status-right: content of the right side of the status line
# - @minimal-tmux-status-left: content of the left side of the status line
# - @minimal-tmux-window-status-format: format of the window status
# - @minimal-tmux-expanded-icon: icon for expanded windows

# Variables
bg=$(get_tmux_option "@minimal-tmux-bg" '#698DDA')
fg=$(get_tmux_option "@minimal-tmux-fg" '#000000')
bg_active=$(get_tmux_option "@minimal-tmux-bg-active" '#ABE9B3')
fg_active=$(get_tmux_option "@minimal-tmux-fg-active" '#000000')

status=$(get_tmux_option "@minimal-tmux-status" "bottom")
justify=$(get_tmux_option "@minimal-tmux-justify" "left")

# Indicator and Left/Right states
indicator_state=$(get_tmux_option "@minimal-tmux-indicator" true)
indicator_str=$(get_tmux_option "@minimal-tmux-indicator-str" " tmux ")
indicator=$([ "$indicator_state" = "true" ] && echo " $indicator_str " || echo "")

right_state=$(get_tmux_option "@minimal-tmux-right" true)
left_state=$(get_tmux_option "@minimal-tmux-left" true)

# Window configuration
window_status_format=$(get_tmux_option "@minimal-tmux-window-status-format" ' #I:#W ')
expanded_icon=$(get_tmux_option "@minimal-tmux-expanded-icon" '󰊓 ')

# --- LOGIC FOR THE BLOCKS ---

# If left_state is false, we set it to empty string to remove the session index block
if [ "$left_state" = "true" ]; then
    status_left=$(get_tmux_option "@minimal-tmux-status-left" "$indicator")
else
    status_left=""
fi

if [ "$right_state" = "true" ]; then
    status_right=$(get_tmux_option "@minimal-tmux-status-right" "#S")
else
    status_right=""
fi

# 3. Setting the options in tmux
tmux set-option -g status-position "$status"
tmux set-option -g status-style "bg=default,fg=default" # Bar is transparent
tmux set-option -g status-justify "$justify"

tmux set-option -g status-left "$status_left"
tmux set-option -g status-right "$status_right"

# Inactive blocks (standard windows)
tmux set-option -g window-status-format "$window_status_format"

# Active block (Current window) with Prefix color toggle
tmux set-option -g window-status-current-format "#{?client_prefix,#[fg=${fg_active} bg=${bg_active}],#[bg=${bg} fg=${fg}]}${window_status_format}#{?window_zoomed_flag,${expanded_icon},}"
