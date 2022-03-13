# Miscellaneous options

# Changing Directories
setopt auto_cd                 # allow to change to a directory by entering it as a command
setopt auto_pushd              # make cd push the old directory onto the directory stack
setopt pushd_ignore_dups       # don't push the same dir twice
setopt pushd_minus             # exchange meanings of '+' and '-' operators

# Input/Output
setopt interactive_comments    # allow comments even in interactive shells

# Zle
setopt nobeep                  # do not beep, never ever

# A list of non-alphanum chars considered part of a word by the line editor.
# Zsh's default is "*?_-.[]~=/&;!#$%^(){}<>", Oh My Zsh's default is "" (empty)
# which is more consistent with Bash. I find "_-" more useful.
WORDCHARS='_-'

# vim: set ts=4:
