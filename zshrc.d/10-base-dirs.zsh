# Prepare XDG-based directories for Zsh data and cache.
#
# TIP: If you want to override these locations, do it in your $ZDOTDIR/.zshenv.

: ${ZSH_DATA_DIR:="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"}
[[ -d "$ZSH_DATA_DIR" ]] || install -d -m700 "$ZSH_DATA_DIR"

: ${ZSH_CACHE_DIR:="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"}
[[ -d "$ZSH_CACHE_DIR" ]] || install -d -m700 "$ZSH_CACHE_DIR"

# vim: set ts=4 sw=4:
