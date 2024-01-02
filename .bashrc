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
    releaseid="termux"
else
    releaseid="$(sed -En '/^ID=/s/^ID=//p' /etc/*release)" 2>/dev/null || releaseid=
fi


shopt -s autocd
shopt -s cdspell
set -o noclobber


alias sudo="sudo -v; sudo "
alias vim="nvim"

alias l="ls -1 --color=auto --file-type --group-directories-first"
alias l.="ls -1 --color=auto --file-type --group-directories-first -d .*"
alias ll="ls -1A --color=auto --file-type --group-directories-first"
alias la="ls -lA --color=auto --file-type --group-directories-first"
alias diffc="diff --color=auto"
alias ipa="ip -color=auto address show"

alias smuc="sed -E '/^(#| |$)/d;s/^(sudo )?([^[:space:]]*).*$/\2/' \$HISTFILE | sort | uniq -c | sort -nr | head"


case "$XDG_SESSION_TYPE" in
    "wayland")
        command -v wl-copy &>/dev/null && alias clip="wl-copy"
        ;;
    "x11")
        command -v xclip &>/dev/null && alias clip="xclip -selection clipboard"
        ;;
    *)
        if command -v termux-clipboard-set &>/dev/null; then
            alias clip="termux-clipboard-set"
        elif command -v clip.exe &>/dev/null; then
            alias clip="clip.exe"
	fi
        ;;
esac

if alias clip &>/dev/null; then
    alias clc="fc -ln -1 | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\n' | clip"
    alias cpwd="pwd | clip"
    alias cfp="readlink -fn \"\$(LC_COLLATE=C ls -1A --color=always --group-directories-first | fzf --ansi)\" | clip"
fi


# Dotfiles management
# https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git
alias dots="git --git-dir=\$HOME/.local/share/dots.git/ --work-tree=\$HOME"

case "$releaseid" in
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
case "$releaseid" in
    "termux")
        if [ -f "$PREFIX"/share/fzf/key-bindings.bash ]; then
            source "$PREFIX"/share/fzf/key-bindings.bash
        fi
        if [ -f "$PREFIX"/share/fzf/completion.bash ]; then
            source "$PREFIX"/share/fzf/completion.bash
        fi
        ;;
    "fedora")
        if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
            source /usr/share/fzf/shell/key-bindings.bash
        fi
        ;;
    "arch")
        if [ -f /usr/share/fzf/key-bindings.bash ]; then
            source /usr/share/fzf/key-bindings.bash
        fi
        if [ -f /usr/share/fzf/completion.bash ]; then
            source /usr/share/fzf/completion.bash
        fi
        ;;
    "debian")
        if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
	    source /usr/share/doc/fzf/examples/key-bindings.bash
	fi
	if [ -f /usr/share/bash-completion/completions/fzf ]; then
	    source /usr/share/bash-completion/completions/fzf
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
    ps1_toolbox="[$(sed -En 's/^name="(.+)"/\1/p' /run/.containerenv)] "
fi

if [ -z "$ps1_toolbox" ]; then
    ps1_wd="\[\e[01;32m\]\w\[\e[00m\]"
else
    ps1_wd="\[\e[01;35m\]\w\[\e[00m\]"
fi

# https://wiki.archlinux.org/title/git#Git_prompt
case "$releaseid" in
    "fedora")
        if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
            source /usr/share/git-core/contrib/completion/git-prompt.sh
        fi
        ;;
    "arch")
        if [ -f /usr/share/git/completion/git-prompt.sh ]; then
            source /usr/share/git/completion/git-prompt.sh
        fi
        ;;
esac

if command -v __git_ps1 &>/dev/null; then
    PS1="${ps1_user:-}${ps1_hostname:-} ${ps1_toolbox:-}${ps1_wd:-}\$(__git_ps1) \$? \$ "
else
    PS1="${ps1_user:-}${ps1_hostname:-} ${ps1_toolbox:-}${ps1_wd:-} \$? \$ "
fi
