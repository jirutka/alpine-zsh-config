# Command not found handler for apk-tools.
#
# TIP: If you want colour output, load 'colors' (autoload -U colors && colors).

function command_not_found_handler() {
	local cmd=$1

	# Skip handler if STDOUT is not a terminal.
	[[ -t 1 ]] || return 127

	emulate -L zsh -o pipefail -o no_aliases

	local fg_grey1= fg_grey2=
	if [[ -n "$reset_color" && -n "${color[red]}" ]]; then
		fg_grey1=$'\e[38;5;243m'
		fg_grey2=$'\e[38;5;250m'
	fi

	print "${fg_grey1}apk: searching $cmd...$reset_color"

	local out
	out=$(apk search -avx --no-network "cmd:$cmd" \
			| sed -En 's/^([^ ]+)-[^-]+-r\d+ - (.*)$/\1|\2/p') \
		&& print -n '\033[F\033[K'  # delete line "apk: searching ..."

	if [[ $? -eq 0 && -n "$out" ]]; then
		local pkgs=(${(fou)out})

		print "${fg_bold[red]}${cmd}$reset_color is not installed, but it can be found in the following packages:"

		local pkg pkgname pkgdesc
		for pkg ($pkgs); do
			pkgname=${pkg%%|*}
			pkgdesc=${pkg#*|}
			print "  $bold_color*${reset_color} ${pkgname}$fg_grey2 - ${pkgdesc}$reset_color"
		done

		(( ${#pkgs} == 1 )) || pkgname='<selected package>'
		print ''
		print "${fg_bold[yellow]}Hint:$reset_color try installing with: ${fg[yellow]}doas apk add ${pkgname}$reset_color"
	else
		print "zsh: command not found: $cmd"
	fi

	return 127
} >&2

# vim: set ts=4 sw=4:
