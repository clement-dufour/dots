# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ "$OS_TYPE" = "linux-android" ] && [ -z "$TERMUX_VERSION" ]; then
    SYSNAME="Termux"
else
    SYSNAME="$(sed -En '/^NAME=/s/^NAME="(.+)"$/\1/p' /etc/*release)" || SYSNAME=""
fi

shopt -s autocd
shopt -s cdspell

set -o noclobber

alias sudo="sudo -v; sudo "
alias vim="nvim"

alias l="ls -1h --color=auto --file-type --group-directories-first"
alias l.="ls -1h --color=auto --file-type --group-directories-first -d .*"
alias ll="ls -1Ah --color=auto --file-type --group-directories-first"
alias la="ls -lAh --color=auto --file-type --group-directories-first"
alias diffc="diff --color=auto"
alias ipa="ip -color=auto address show"

alias smuc="sed -E '/^(#| |$)/d;s/^(sudo )?([^[:space:]]*).*$/\2/' \$HISTFILE | \
    sort | \
    uniq -c | \
    sort -nr | \
    head"

alias clc="fc -ln -1 | \
    sed -E 's/^[[:space:]]*//' | \
    tr -d '\n' | \
    wl-copy"

# https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git
alias dots="git \
    --git-dir=\$HOME/.local/share/dots.git/ \
    --work-tree=\$HOME"

case "$SYSNAME" in
    "Termux")
        if [ -f $PREFIX/usr/etc/bash-completion.d/git-completion.bash ]; then
            source $PREFIX/usr/etc/bash-completion.d/git-completion.bash
            __git_complete dots __git_main
        fi
        ;;
    *)
        if [ -f /usr/share/bash-completion/completions/git ]; then
            source /usr/share/bash-completion/completions/git
            __git_complete dots __git_main
        fi
        ;;
esac


case "$SYSNAME" in
    "Termux")
        if [ -f $PREFIX/usr/share/fzf/key-bindings.bash ]; then
            source /usr/share/fzf/key-bindings.bash
        fi
        if [ -f $PREFIX/usr/share/fzf/completion.bash ]; then
            source $PREFIX/usr/share/fzf/completion.bash
        fi
        ;;
    "Fedora Linux")
        if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
            source /usr/share/fzf/shell/key-bindings.bash
        fi
        ;;
    "Arch Linux")
        if [ -f /usr/share/fzf/key-bindings.bash ]; then
            source /usr/share/fzf/key-bindings.bash
        fi
        if [ -f /usr/share/fzf/completion.bash ]; then
            source /usr/share/fzf/completion.bash
        fi
        ;;
esac

if [ -f /run/.containerenv ] && [ -f /run/.toolboxenv ]; then
    TOOLBOX_NAME="$(sed -En 's/^name="(.+)"/\1/p' /run/.containerenv)"
    PS1="\u@\h[${TOOLBOX_NAME}] \[\e[01;35m\]\w\[\e[00m\] \$? \$ "
else
    PS1="\u@\h \[\e[01;32m\]\w\[\e[00m\] \$? \$ "
fi
