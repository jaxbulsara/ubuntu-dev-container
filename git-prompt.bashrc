# store colors
MAGENTA="\[\033[00;35m\]"
YELLOW="\[\033[01;33m\]"
BLUE="\[\033[01;34m\]"
LIGHT_GRAY="\[\033[00;37m\]"
CYAN="\[\033[00;36m\]"
GREEN="\[\033[00;32m\]"
RED="\[\033[00;31m\]"
LIGHT_RED="\[\033[01;31m\]"
VIOLET="\[\033[01;35m\]"
DEFAULT="\[\033[00;39m\]"

function color_my_prompt {
  local __user_and_host="$LIGHT_RED\u@\h"
  local __cur_location="$BLUE\W"           # capital 'W': current directory, small 'w': full file path
  local __prompt_tail="$DEFAULT$" 
  local __user_input_color="$DEFAULT"
  local __git_branch="$GREEN`__git_ps1`" 
 
  # colour branch name depending on state
  if [[ "${__git_branch}" =~ "*" ]]; then     # if repository is dirty
      __git_branch_color="$RED"
  elif [[ "${__git_branch}" =~ "$" ]]; then   # if there is something stashed
      __git_branch_color="$YELLOW"
  elif [[ "${__git_branch}" =~ "%" ]]; then   # if there are only untracked files
      __git_branch_color="$LIGHT_GRAY"
  elif [[ "${__git_branch}" =~ "+" ]]; then   # if there are staged files
      __git_branch_color="$CYAN"
  fi
  
  # Build the PS1 (Prompt String)
  PS1="$__user_and_host $__cur_location$__git_branch $__prompt_tail$__user_input_color "
}

# configure PROMPT_COMMAND which is executed each time before PS1
export PROMPT_COMMAND=color_my_prompt

# if .git-prompt.sh exists, set options and execute it
if [ -f ~/.git-prompt.sh ]; then
  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWSTASHSTATE=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  GIT_PS1_SHOWUPSTREAM="auto"
  GIT_PS1_HIDE_IF_PWD_IGNORED=true
  GIT_PS1_SHOWCOLORHINTS=true
  . ~/.git-prompt.sh
fi

# Execute git completion
if ! shopt -oq posix; then
  if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
  fi
fi