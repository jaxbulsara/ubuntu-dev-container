# Set color variables
YELLOW="\[\033[00;93m\]"
BLUE="\[\033[01;94m\]"
GREY="\[\033[00;37m\]"
DARK_GREY="\[\033[00;90m\]"
CYAN="\[\033[00;96m\]"
GREEN="\[\033[00;92m\]"
RED="\[\033[01;31m\]"
MAGENTA="\[\033[00;95m\]"
DEFAULT="\[\033[00;39m\]"

# Configures the prompt based on the current environment
function create_prompt {
    # Python virtual environment
    local __venv_name=`printf "$DARK_GREY($(echo $VIRTUAL_ENV | awk -F "/" '{print $NF}')) "`
    local __venv=""

    # User and host names
    local __user_and_host="$RED\u@\h"
    local __colon="$DEFAULT: "

    # Working directory
    local __directory="$BLUE\w"

    # Git branch info
    local __git_branch_color="$GREEN"
    local __git_branch="`__git_ps1`"

    # Prompt and input
    local __prompt="$RED\$"
    local __input_color="$DEFAULT";

    # Display activated virtual environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        __venv=$__venv_name
    else
        __venv=""
    fi

    # Change git branch color based on repository state
    if [[ $__git_branch =~ "*" ]]; then     # The repository is dirty
        __git_branch_color="$RED"
    elif [[ $__git_branch =~ "$" ]]; then   # There are stashed files
        __git_branch_color="$YELLOW"
    elif [[ $__git_branch =~ "%" ]]; then   # There are untracked files
        __git_branch_color="$MAGENTA"
    elif [[ $__git_branch =~ "+" ]]; then   # There are staged files
        __git_branch_color="$CYAN"
    fi

    PS1="$__venv$__user_and_host$__colon$__directory$__git_branch_color$__git_branch $__prompt$__input_color "
}

# Set PROMPT_COMMAND which is executed each time before PS1
export PROMPT_COMMAND=create_prompt

# If .git-prompt.sh exists, set options and execute it
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
