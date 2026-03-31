# tmux show-option "q" (quiet) flag does not set return value to 1, even though
# the option does not exist. This function patches that.
get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

trim_whitespace() {
	local value=$1

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"

	printf '%s\n' "$value"
}

get_launcher_lines() {
	local option=$1
	local default_value=$2
	local value
	value=$(get_tmux_option "$option" "$default_value")
	printf '%s\n' "$value"
}

get_launcher_field() {
	local line=$1
	local field_name=$2
	local pattern="(^|[[:space:]])${field_name}="

	if [[ ! $line =~ $pattern ]]; then
		return 1
	fi

	local remainder=${line#*${field_name}=}

	if [ "$field_name" = "command" ]; then
		trim_whitespace "$remainder"
		return 0
	fi

	local value=${remainder%%[[:space:]]*}
	trim_whitespace "$value"
}
