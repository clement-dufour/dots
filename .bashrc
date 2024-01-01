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
if [ "$OSTYPE" = "linux-android" ] && [ -n "$TERMUX_VERSION" ]; then
    sysname="Termux"
else
    sysname="$(sed -En '/^NAME=/s/^NAME="(.+)"$/\1/p' /etc/*release)" 2>/dev/null || sysname=""
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


case "$XDG_SESSION_TYPE" in
    "wayland")
        command -v wl-copy &>/dev/null && alias copy="wl-copy"
        ;;
    "x11")
        command -v xclip &>/dev/null && alias copy="xclip -selection clipboard"
        ;;
    *)
        command -v termux-clipboard-set &>/dev/null && alias copy="termux-clipboard-set"
        ;;
esac

alias copy &>/dev/null &&
    alias clc="fc -ln -1 | \
        sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        tr -d '\n' | \
        copy"


# Dotfiles management
# https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git
alias dots="git \
    --git-dir=\$HOME/.local/share/dots.git/ \
    --work-tree=\$HOME"

case "$sysname" in
    "Termux")
        if [ -f "$PREFIX"/etc/bash_completion.d/git-completion.bash ]; then
            source "$PREFIX"/etc/bash_completion.d/git-completion.bash
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


# fzf
# https://wiki.archlinux.org/title/Fzf#Bash
case "$sysname" in
    "Termux")
        if [ -f "$PREFIX"/share/fzf/key-bindings.bash ]; then
            source "$PREFIX"/share/fzf/key-bindings.bash
        fi
        if [ -f "$PREFIX"/share/fzf/completion.bash ]; then
            source "$PREFIX"/share/fzf/completion.bash
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


if [ "$(id -u)" -ne 1000 ]; then
    ps1_user="\u"
fi

if [ -n "$SSH_CLIENT" ]; then
    ps1_hostname="@\h"
fi

if [ -f /run/.containerenv ] && [ -f /run/.toolboxenv ]; then
    ps1_toolbox="[$(sed -En 's/^name="(.+)"/\1/p' /run/.containerenv)]"
fi

if [ -z "$ps1_toolbox" ]; then
    ps1_wd="\[\e[01;32m\]\w\[\e[00m\]"
else
    ps1_wd="\[\e[01;35m\]\w\[\e[00m\]"
fi

PS1="${ps1_user:-}${ps1_hostname:-}${ps1_toolbox:-} ${ps1_wd:-} \$? \$ "
