#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

default_launchers="key=a window=- command=opencode"
tmux_option_launchers="@tmux-launchers"

set_launcher_key_bindings () {
	local launcher
	while IFS= read -r launcher; do
		launcher=$(trim_whitespace "$launcher")

		if [ -z "$launcher" ]; then
			continue
		fi

		local key
		key=$(get_launcher_field "$launcher" "key") || continue

		if [ -z "$key" ]; then
			continue
		fi

		tmux bind "$key" run-shell "$CURRENT_DIR/scripts/open-launcher.sh $(printf '%q' "$key")"
	done <<EOF
$(get_launcher_lines "$tmux_option_launchers" "$default_launchers")
EOF
}

main () {
	set_launcher_key_bindings
}

main
