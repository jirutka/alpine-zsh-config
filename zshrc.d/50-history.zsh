# History options

if [[ -f ${ZDOTDIR:-$HOME}/.zsh_history ]]; then
	: ${HISTFILE:=${ZDOTDIR:-$HOME}/.zsh_history}
else
	: ${HISTFILE:=${ZSH_DATA_DIR:?}/history}
fi

# Save history on disk (default is 0 - disabled).
[[ "$SAVEHIST" -eq 0 ]] && SAVEHIST="$HISTSIZE"

setopt extended_history        # record timestamp of command in HISTFILE
setopt hist_expire_dups_first  # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_fcntl_lock         # use system's fcntl for locking to increase performance
setopt hist_ignore_dups        # ignore duplicated commands history list
setopt hist_ignore_space       # ignore commands that start with space
setopt hist_verify             # show command with history expansion to user before running it
setopt share_history           # share command history data

# vim: set ts=4:
