#!/usr/bin/env bash

get_tmux_option() {
  # Helper function to get tmux options
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

# Set up some default colors and configurations
default_color="#[bg=default,fg=default,bold]"
bg=$(get_tmux_option "@minimal-tmux-bg" '#698DDA')
fg=$(get_tmux_option "@minimal-tmux-fg" '#000000')

# Use arrow symbols if enabled
use_arrow=$(get_tmux_option "@minimal-tmux-use-arrow" false)
larrow="$("$use_arrow" && get_tmux_option "@minimal-tmux-left-arrow" "")"
rarrow="$("$use_arrow" && get_tmux_option "@minimal-tmux-right-arrow" "")"

# Indicator settings
indicator_state=$(get_tmux_option "@minimal-tmux-indicator" true)
indicator_str=$(get_tmux_option "@minimal-tmux-indicator-str" " tmux ")
indicator=$("$indicator_state" && echo " $indicator_str ")

# Status settings
status=$(get_tmux_option "@minimal-tmux-status" "bottom")
justify=$(get_tmux_option "@minimal-tmux-justify" "centre")

right_state=$(get_tmux_option "@minimal-tmux-right" true)
left_state=$(get_tmux_option "@minimal-tmux-left" true)

# New option to enable changing the color of the current working pane when the prefix is pressed
use_pane_color_indicator=$(get_tmux_option "@minimal-tmux-use-pane-color" false)

# Default indicator logic
indicator_color="${default_color}"
status_right=$("$right_state" && get_tmux_option "@minimal-tmux-status-right" "#S")
status_left=$("$left_state" && get_tmux_option "@minimal-tmux-status-left" "${default_color}#{?client_prefix,,${indicator}}#[bg=${bg},fg=${fg},bold]#{?client_prefix,${indicator},}${indicator_color}")
status_right_extra="$status_right$(get_tmux_option "@minimal-tmux-status-right-extra" "")"
status_left_extra="$status_left$(get_tmux_option "@minimal-tmux-status-left-extra" "")"

# Window status format
window_status_format=$(get_tmux_option "@minimal-tmux-window-status-format" ' #I:#W ')

expanded_icon=$(get_tmux_option "@minimal-tmux-expanded-icon" '󰊓 ')
show_expanded_icon_for_all_tabs=$(get_tmux_option "@minimal-tmux-show-expanded-icon-for-all-tabs" false)

# tmux options for the status line
tmux set-option -g status-position "$status"
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-justify "$justify"
tmux set-option -g status-left "$status_left_extra"
tmux set-option -g status-right "$status_right_extra"
tmux set-option -g window-status-format "$window_status_format"
"$show_expanded_icon_for_all_tabs" && tmux set-option -g window-status-format " ${window_status_format}#{?window_zoomed_flag,${expanded_icon},}"

tmux set-option -g window-status-current-format "#[fg=${bg}]$larrow#[bg=${bg},fg=${fg}]${window_status_format}#{?window_zoomed_flag,${expanded_icon},}#[fg=${bg},bg=default]$rarrow"


# New tmux keybinding to change the current pane's color when prefix is pressed
if [[ "$use_pane_color_indicator" == "true" ]]; then
    # Define a new keybinding for the prefix key
    tmux bind-key C-b run-shell "tmux set-option -g pane-border-fg '#FF0000'; tmux set-option -g pane-active-border-fg '#00FF00'"
    tmux bind-key -n C-b run-shell "tmux set-option -g pane-border-fg '#000000'; tmux set-option -g pane-active-border-fg '#FFFFFF'"
fi
