# Global key bindings mainly for consistency with /etc/inputrc
# (and thus with busybox ash, bash and any other program using readline).

# Use emacs key bindings.
bindkey -e

# Load widgets that are not loaded by default.
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

function () {
	emulate -L zsh

	# Make sure that the terminal is in application mode when zle is active,
	# since only then values from $terminfo are valid.
	if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
		autoload -U add-zle-hook-widget

		function .zshrc::term-application-mode() {
			echoti smkx
		}
		add-zle-hook-widget zle-line-init .zshrc::term-application-mode

		function .zshrc::term-normal-mode() {
			echoti rmkx
		}
		add-zle-hook-widget zle-line-finish .zshrc::term-normal-mode
	fi

	# `seq` is a fallback for the case when terminfo is not available.
	local kcap seq widget
	for	kcap   seq        widget (                       # key name
		khome  '^[[H'     beginning-of-line              # Home
		khome  '^[OH'     beginning-of-line              # Home (in app mode)
		kend   '^[[F'     end-of-line                    # End
		kend   '^[OF'     end-of-line                    # End (in app mode)
		kdch1  '^[[3~'    delete-char                    # Delete
		kpp    '^[[5~'    up-line-or-history             # PageUp
		knp    '^[[6~'    down-line-or-history           # PageDown
		kcuu1  '^[[A'     up-line-or-beginning-search    # UpArrow - fuzzy find history backward
		kcuu1  '^[OA'     up-line-or-beginning-search    # UpArrow - fuzzy find history backward (in app mode)
		kcud1  '^[[B'     down-line-or-beginning-search  # DownArrow - fuzzy find history forward
		kcud1  '^[OB'     down-line-or-beginning-search  # DownArrow - fuzzy find history forward (in app mode)
		kcbt   '^[[Z'     reverse-menu-complete          # Shift + Tab
		x      '^[[2;5~'  copy-region-as-kill            # Ctrl + Insert
		kDC5   '^[[3;5~'  kill-word                      # Ctrl + Delete
		kRIT5  '^[[1;5C'  forward-word                   # Ctrl + RightArrow
		kLFT5  '^[[1;5D'  backward-word                  # Ctrl + LeftArrow
	); do
		bindkey -M emacs ${terminfo[$kcap]:-$seq} $widget
		bindkey -M viins ${terminfo[$kcap]:-$seq} $widget
		bindkey -M vicmd ${terminfo[$kcap]:-$seq} $widget
	done
}

# vim: set ts=4 sw=4:
