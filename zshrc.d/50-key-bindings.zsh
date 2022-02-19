# Global key bindings mainly for consistency with /etc/inputrc
# (and thus with busybox ash, bash and any other program using readline).

# Use emacs key bindings.
bindkey -e

# Load widgets that are not loaded by default.
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# Make sure that the terminal is in application mode when zle is active,
# since only then values from $terminfo are valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init() {
		echoti smkx
	}
	function zle-line-finish() {
		echoti rmkx
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi

# `seq` is a fallback for the case when terminfo is not available.
for	kcap   seq        widget (                       # key name
	khome  '^[[H'     beginning-of-line              # Home
	khome  '^[OH'     beginning-of-line              # Home (in app mode)
	kend   '^[[F'     end-of-line                    # End
	kend   '^[OF'     end-of-line                    # End (in app mode)
	kdch1  '^[[3~'    delete-char                    # Delete
	kpp    '^[[5~'    up-line-or-history             # PageUp
	knp    '^[[6~'    down-line-or-history           # PageDown
	kcuu1  '^[[A'     up-line-or-beginning-search    # UpArrow - fuzzy find history forward
	kcuu1  '^[OA'     up-line-or-beginning-search    # UpArrow - fuzzy find history forward (in app mode)
	kcud1  '^[[B'     down-line-or-beginning-search  # DownArrow - fuzzy find history backward
	kcud1  '^[OB'     down-line-or-beginning-search  # DownArrow - fuzzy find history backward (in app mode)
	kcbt   '^[[Z'     reverse-menu-complete          # Shift + Tab
	kDC5   '^[[3;5~'  kill-word                      # Ctrl + Delete
	kRIT5  '^[[1;5C'  forward-word                   # Ctrl + RightArrow
	kLFT5  '^[[1;5D'  backward-word                  # Ctrl + LeftArrow
); do
	bindkey -M emacs ${terminfo[$kcap]:-$seq} $widget
	bindkey -M viins ${terminfo[$kcap]:-$seq} $widget
	bindkey -M vicmd ${terminfo[$kcap]:-$seq} $widget
done

# vim: set ts=4:
