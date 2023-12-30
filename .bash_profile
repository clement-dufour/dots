# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export HISTTIMEFORMAT="%F %T "
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignoreboth
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
fi
