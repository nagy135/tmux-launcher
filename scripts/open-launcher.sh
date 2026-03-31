#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

LAUNCHERS_OPTION="@tmux-launchers"
DEFAULT_LAUNCHERS="key=a window=- command=opencode"

getLauncherForKey() {
  local requested_key="$1"

  local launcher
  while IFS= read -r launcher; do
    launcher="$(trim_whitespace "$launcher")"

    if [ -z "$launcher" ]; then
      continue
    fi

    local key
    key="$(get_launcher_field "$launcher" "key")" || continue

    if [ "$key" = "$requested_key" ]; then
      printf '%s\n' "$launcher"
      return 0
    fi
  done <<EOF
$(get_launcher_lines "$LAUNCHERS_OPTION" "$DEFAULT_LAUNCHERS")
EOF

  return 1
}

getWindowIdOption() {
  local launcher_key="$1"
  local sanitized_key
  sanitized_key="$(printf '%s' "$launcher_key" | tr -c '[:alnum:]' '_')"
  printf '@tmux-launcher-window-id-%s\n' "$sanitized_key"
}

getWindowName() {
  local launcher_key="$1"
  printf 'launcher:%s\n' "$launcher_key"
}

getWindowTarget() {
  local session_id="$1"
  local requested_position="$2"

  if [ -z "$requested_position" ]; then
    return 0
  fi

  if ! [[ "$requested_position" =~ ^[0-9]+$ ]]; then
    return 0
  fi

  local occupied_positions
  occupied_positions="$(tmux list-windows -t "$session_id" -F "#{window_index}")"

  local target_position
  target_position="$requested_position"

  while printf '%s\n' "$occupied_positions" | grep -Fxq "$target_position"; do
    target_position="$((target_position + 1))"
  done

  printf '%s:%s' "$session_id" "$target_position"
}

openLauncher() {
  local LAUNCHER_KEY="$1"
  local LAUNCHER
  LAUNCHER="$(getLauncherForKey "$LAUNCHER_KEY")" || exit 0

  local COMMAND
  COMMAND="$(get_launcher_field "$LAUNCHER" "command")" || exit 0

  local WINDOW_POSITION
  WINDOW_POSITION="$(get_launcher_field "$LAUNCHER" "window")"

  if [ "$WINDOW_POSITION" = "-" ]; then
    WINDOW_POSITION=""
  fi

  local ORIGIN_PANE
  ORIGIN_PANE="$(tmux display-message -p "#D")"

  local SESSION_ID
  SESSION_ID="$(tmux display-message -p -t "$ORIGIN_PANE" "#{session_id}")"

  local CURRENT_PATH
  CURRENT_PATH="$(tmux display-message -p -t "$ORIGIN_PANE" "#{pane_current_path}")"

  local WINDOW_ID_OPTION
  WINDOW_ID_OPTION="$(getWindowIdOption "$LAUNCHER_KEY")"

  local WINDOW_ID
  WINDOW_ID="$(tmux show-options -t "$SESSION_ID" -qv "$WINDOW_ID_OPTION")"

  if [ -n "$WINDOW_ID" ] && tmux list-windows -t "$SESSION_ID" -F "#{window_id}" | grep -Fxq "$WINDOW_ID"; then
    tmux select-window -t "$WINDOW_ID"
  else
    local WINDOW_TARGET
    WINDOW_TARGET="$(getWindowTarget "$SESSION_ID" "$WINDOW_POSITION")"

    local WINDOW_NAME
    WINDOW_NAME="$(getWindowName "$LAUNCHER_KEY")"

    if [ -n "$WINDOW_TARGET" ]; then
      WINDOW_ID="$(tmux new-window -P -F "#{window_id}" -t "$WINDOW_TARGET" -n "$WINDOW_NAME" -c "$CURRENT_PATH" "$COMMAND")"
    else
      WINDOW_ID="$(tmux new-window -P -F "#{window_id}" -n "$WINDOW_NAME" -c "$CURRENT_PATH" "$COMMAND")"
    fi

    tmux set-option -t "$SESSION_ID" -q "$WINDOW_ID_OPTION" "$WINDOW_ID"
  fi
}

openLauncher "$1"
