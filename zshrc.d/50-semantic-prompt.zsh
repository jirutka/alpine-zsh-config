# Support for OSC 133 Semantic Prompt Sequences
#
# This script adds hooks for generating semantic zones: marking up the prompt,
# the user input and the command output. This allows terminal features such as
# jumping to the previous/next prompt in the scrollback or opening the output
# of the last command in a pager (supported e.g. in Kitty, WezTerm, iTerm2).

autoload -Uz add-zsh-hook

# 0: No OSC 133 [AC] marks have been written yet.
# 1: The last written OSC 133 C has not been closed with D yet.
# 2: An OSC 133 A mark has been written, i.e. we are in the prompt mode.
declare -gHi _ZSHRC_OSC133_STATE=0

# A precmd hook that marks end of the current command (OSC 133 D), start of a
# new command (OSC 133 A) and adds start/end of prompt marks (OSC 133 P and B)
# into PS1, PS2, and RPROMPT. This hook will be executed before each prompt.
function .zshrc::osc133-precmd-hook() {
	local -i cmd_status=$?

	emulate -L zsh -o no_aliases -o no_glob -o no_warn_create_global

	# If PS1 prompt already includes OSC 133 A or P mark, i.e. there's some
	# other plugin or user script setting the semantic prompt, do nothing.
	if (( _ZSHRC_OSC133_STATE == 0 )) && [[ $PS1 == *$'%{\e]133;'[AP]* ]]; then
		return 0
	fi

	# Add prompt start/end marks to the prompts, unless we are still in the
	# prompt mode (preexec hook has not been executed, so the marks should be
	# still here). Option prompt_percent must be enabled for this to work.
	if (( _ZSHRC_OSC133_STATE != 2 )) && [[ -o prompt_percent ]]; then
		local prefix=$'%{\e]133;P;k=@\a%}'
		local suffix=$'%{\e]133;B\a%}'

		PS1=${prefix/@/i}${PS1}${suffix}
		PS2=${prefix/@/s}${PS2}${suffix}
		[[ -n $RPROMPT ]] && RPROMPT=${prefix/@/r}${RPROMPT}${suffix}
	fi

	# Don't write OSC 133 when our precmd hook is invoked from zle.
	# Some plugins do that to update prompt on cd.
	if ! zle; then
		# NOTE: This code works incorrectly in the presence of a precmd or chpwd hook
		#  that prints. We'll end up writing our OSC 133 D mark too late.
		if (( _ZSHRC_OSC133_STATE == 1 )); then
			# The last written OSC 133 C has not been closed with D yet.
			# Close it and supply status.
			printf '\e]133;D;%s;aid=%s\a' "$cmd_status" "$$"
			_ZSHRC_OSC133_STATE=2

		elif (( _ZSHRC_OSC133_STATE == 2 )); then
			# There might be an unclosed OSC 133 C. Close that.
			printf '\e]133;D;aid=%s\a' "$$"
		fi

		# Do a fresh-line, then start a new command, and enter prompt mode.
		# Also request the terminal to translate clicks in the input area to
		# cursor movement (cl=m).
		printf '\e]133;A;cl=m;aid=%s\a' "$$"
		_ZSHRC_OSC133_STATE=2
	fi

	# If our precmd hook is not the last, we cannot rely on the prompt changes
	# to stick. We try to move our hook to the end, but only once. If there's
	# another precmd hook that wants to take this privileged position,
	# we give up to avoid the loop.
	declare -g precmd_functions
	if (( ! ${+_ZSHRC_OSC133_NOT_AGAIN} )) \
		&& [[ ${precmd_functions[-1]} != .zshrc::osc133-precmd-hook ]]
	then
		autoload -Uz add-zsh-hook

		add-zsh-hook -d precmd .zshrc::osc133-precmd-hook
		add-zsh-hook precmd .zshrc::osc133-precmd-hook

		declare -gHi _ZSHRC_OSC133_NOT_AGAIN=1
	fi
}

# A preexec hook that removes OSC 133 marks added by osc133-precmd-hook to PS1,
# PS2, RPROMPT, and marks end of input (OSC 133 C). This hook will be executed
# just after a command has been read and it's about to be executed.
# NOTE: It's not executed if user didn't type any command and just hit enter.
function .zshrc::osc133-preexec-hook() {
	emulate -L zsh -o no_aliases -o no_glob -o no_warn_create_global

	# If we are not in the prompt mode, do nothing.
	(( _ZSHRC_OSC133_STATE != 2 )) && return 0

	local suffix=$'%{\e]133;B\a%}'

	# Revert our changes to PS1, PS2 and RPROMPT (both reference implementation
	# and Kitty removes OSC 133 marks from prompts in preexec).
	# NOTE: This can potentially break user prompt.
	PS1=${PS1//$'%{\e]133;P;k=i\a%}'}
	PS1=${PS1//${suffix}}
	PS2=${PS2//$'%{\e]133;P;k=s\a%}'}
	PS2=${PS2//${suffix}}
	if [[ -n $RPROMPT ]]; then
		RPROMPT=${RPROMPT//$'%{\e]133;P;k=r\a%}'}
		RPROMPT=${RPROMPT//${suffix}}
	fi

	# Mark end of input and start of output.
	# NOTE: This will work incorrectly in the presence of a preexec hook
	#  that prints.
	print -n '\e]133;C\a'

	_ZSHRC_OSC133_STATE=1
}

# A precmd hook for deferred registration of our OSC 133 hooks. It unregisters
# itself after execution.
function .zshrc::osc133-init() {
	emulate -L zsh -o no_aliases -o no_glob
	autoload -Uz add-zsh-hook

	# Register our hooks, unless PS1 prompt already includes OSC 133 A or P
	# mark, i.e. there's some other plugin or user script setting the
	# semantic prompt.
	if [[ $PS1 != *$'%{\e]133;'[AP]* ]]; then
		add-zsh-hook precmd .zshrc::osc133-precmd-hook
		add-zsh-hook preexec .zshrc::osc133-preexec-hook
	fi

	add-zsh-hook -d precmd .zshrc::osc133-init  # remove self
}
add-zsh-hook precmd .zshrc::osc133-init

# vim: set ts=4 sw=4:
