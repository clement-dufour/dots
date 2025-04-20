# .bash_profile

# Get the aliases and functions
# Toolboxes are run with a login shell
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export HISTCONTROL=ignoreboth
export HISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/bash/history"
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTTIMEFORMAT="%F %T "

export PROMPT_DIRTRIM=2

export PYTHON_HISTORY="${XDG_DATA_HOME:-${HOME}/.local/share}/python/history"
