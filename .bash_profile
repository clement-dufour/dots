# .bash_profile

# Get the aliases and functions
# Toolboxes are run with a login shell
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export HISTCONTROL=ignoreboth
if [ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/bash/history" ]; then
   export HISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/bash/history"
fi
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTTIMEFORMAT="%F %T "

export PROMPT_DIRTRIM=2

if [ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/python/history" ]; then
    export PYTHON_HISTORY="${XDG_DATA_HOME:-${HOME}/.local/share}/python/history"
fi

export GOPATH="${XDG_CACHE_HOME:-${HOME}/.cache}/go"
