# System clipboard integration - copy the kill (cut) buffer to the system
# clipboard on each change (e.g. on Ctrl+Insert, Ctrl+W, ...).
#
# NOTE: It must be loaded after the main keymap is selected, i.e. after
# 50-key-bindings.zsh.

# The clipboard to synchronize the cut buffer with.
# Allowed values: "primary" (selection), or "clipboard" (regular clipboard).
# TIP: If you want to override this, do it in your $ZDOTDIR/.zshenv.
: ${ZSH_CUTBUFFER_CLIPBOARD:=primary}

# An array of $TERM values that identify terminals with OSC 52 support (access
# to system clipboard). This is just a shortcut to skip dynamic detection using
# `tty-copy --test` for known terminals.
if (( ! ${+osc52_supported_terms} )); then
	osc52_supported_terms=('alacritty' 'foot' 'xterm-kitty')
fi

function () {
	emulate -L zsh

	if [[ -n "${WAYLAND_DISPLAY-}" ]] && (( ${+commands[wl-copy]} )); then
		function zshrc::clip-copy() {
			local opts=
			[[ "$ZSH_CUTBUFFER_CLIPBOARD" = 'primary' ]] && opts='--primary'
			wl-copy $opts "$@"
		}
	elif [[ -n "${DISPLAY-}" ]] && (( ${+commands[xclip]} )); then
		function zshrc::clip-copy() {
			printf '%s' "$*" | xclip -in -selection ${ZSH_CUTBUFFER_CLIPBOARD:-primary}
		}
	elif (( ${+commands[tty-copy]} )) \
		&& { (( ${osc52_supported_terms[(Ie)$TERM]} )) || tty-copy --test; };
	then
		function zshrc::clip-copy() {
			local opts=
			[[ "$ZSH_CUTBUFFER_CLIPBOARD" = 'primary' ]] && opts='--primary'
			tty-copy $opts "$@"
		}
	else
		return
	fi

	autoload -Uz add-zle-hook-widget

	declare -gH _ZSHRC_CUTBUFFER_LAST=''

	function zshrc::sync-cutbuffer-with-clipboard() {
		if [[ "$CUTBUFFER" != "$_ZSHRC_CUTBUFFER_LAST" ]]; then
			zshrc::clip-copy "$CUTBUFFER"
			_ZSHRC_CUTBUFFER_LAST=$CUTBUFFER
		fi
	}
	add-zle-hook-widget line-pre-redraw zshrc::sync-cutbuffer-with-clipboard
}

# vim: set ts=4:
