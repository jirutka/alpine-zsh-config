# Initialize the completion system with reasonable defaults.

autoload -U compinit

: ${ZSH_COMPDUMP:="${ZSH_CACHE_DIR:?}/zcompdump"}
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR:?}/zcompcache"

# Checking the cached .zcompdump file to see if it must be regenerated adds
# a noticable delay to zsh startup. Thus we try to regenerate it only if it's
# older than one of the directories where completion files are installed or
# it's older than 24 hours.
# https://gist.github.com/ctechols/ca1035271ad134841284
function () {
	setopt extendedglob local_options  # note: we use function to keep this local
	local dir= refresh=0

	# If zcompdump exists and has been modified in less than 24 hours.
	if [[ ! -f "$ZSH_COMPDUMP" || -n "$ZSH_COMPDUMP"(#qNY1.mh+24) ]]; then
		refresh=1
	else
		for dir ('/usr/share/zsh' ${fpath:#/usr/share/zsh/$ZSH_VERSION/*}); do
			if [[ "$ZSH_COMPDUMP" -ot "$dir" ]]; then
				refresh=1
				break
			fi
		done
	fi
	if (( refresh )); then
		compinit -d "$ZSH_COMPDUMP"
		touch "$ZSH_COMPDUMP"
	else
		compinit -d "$ZSH_COMPDUMP" -C
	fi
}

# Allow tab completion in the middle of a word.
setopt complete_in_word

# Complete . and .. special directories.
zstyle ':completion:*' special-dirs true

# Active completion caching layer for any completions which use it.
zstyle ':completion:*' use-cache yes

# Arrow key menu for completions.
zstyle ':completion:*:*:*:*:*' menu select

# Ignore completion functions for commands we don't have and for "private"
# functions (prefixed with a dot).
zstyle ':completion:*:functions' ignored-patterns '_*' '.*'

# vim: set ts=4:
