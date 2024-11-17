# .bash_profile

# Get the aliases and functions
# Toolboxes are run with a login shell
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export HISTTIMEFORMAT="%F %T "
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignoreboth

export PROMPT_DIRTRIM=2

if command -v nvim &>/dev/null; then
    export EDITOR="nvim"
elif command -v vim &>/dev/null; then
    export EDITOR="vim"
elif command -v vi &>/dev/null; then
    export EDITOR="vi"
fi
