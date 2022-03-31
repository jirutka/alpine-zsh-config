# Command not found handler for apk-tools.
#
# TIP: If you want colour output, load 'colors' (autoload -U colors && colors).

command_not_found_handler() {
	local cmd=$1

	# Skip handler if STDOUT is not a terminal.
	[[ -t 1 ]] || return 127

	emulate -L zsh
	setopt pipefail local_options

	local fg_grey1= fg_grey2=
	if [[ -n "$reset_color" && -n "${color[red]}" ]]; then
		fg_grey1=$'\e[38;5;243m'
		fg_grey2=$'\e[38;5;250m'
	fi

	echo "${fg_grey1}apk: searching $cmd...$reset_color"  # <1>

	local out
	out=$(apk search -avx --no-network "cmd:$cmd" \
			| sed -En 's/^([^ ]+)-[^-]+-r\d+ - (.*)$/\1|\2/p') \
		&& printf '\033[F\033[K'  # delete line "apk: searching ..."

	if [[ $? -eq 0 && -n "$out" ]]; then
		local pkgs=(${(fou)out})

		echo "${fg_bold[red]}${cmd}$reset_color is not installed, but it can be found in the following packages:"

		local pkg pkgname pkgdesc
		for pkg ($pkgs); do
			pkgname=${pkg%%|*}
			pkgdesc=${pkg#*|}
			echo "  $bold_color*${reset_color} ${pkgname}$fg_grey2 - ${pkgdesc}$reset_color"
		done

		[[ ${#pkgs} -eq 1 ]] || pkgname='<selected package>'
		echo ''
		echo "${fg_bold[yellow]}Hint:$reset_color try installing with: ${fg[yellow]}doas apk add ${pkgname}$reset_color"
	else
		echo "zsh: command not found: $cmd"
	fi

	return 127
} >&2

# vim: set ts=4:
