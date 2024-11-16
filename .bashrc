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

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# Detect platform and distribution
if [ "$OSTYPE" = "linux-android" ] && [ -n "$TERMUX_VERSION" ]; then
    releaseid="termux"
else
    releaseid="$(sed -En '/^ID=/s/^ID=//p' /etc/*release)" 2>/dev/null || releaseid=
fi


# Misc configuration
shopt -s autocd
shopt -s cdspell
set -o noclobber


# Aliases
## Override
alias sudo="sudo "
#alias sudo="sudo -v; sudo "
alias mv="mv -i"
alias cp="cp -i"
alias diff="diff --color=auto"
if command -v nvim &>/dev/null; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi
alias emacs="toolbox run -c emacs /usr/bin/emacsclient -c --alternate-editor /usr/bin/emacs"

## Shorten
alias l="ls -1 --color=auto --file-type --group-directories-first"
# alias l.="ls -1 --color=auto --file-type --group-directories-first -d .*"
alias ll="ls -1A --color=auto --file-type --group-directories-first"
alias la="ls -lAh --color=auto --file-type --group-directories-first"
alias ipa="ip -color=auto address show"


case "$XDG_SESSION_TYPE" in
    "wayland")
        if command -v wl-copy &>/dev/null; then
            alias clip="wl-copy"
        fi
        ;;
    "x11")
        if command -v xclip &>/dev/null; then
            alias clip="xclip -selection clipboard"
        fi
        ;;
    *)
        if command -v termux-clipboard-set &>/dev/null; then
            # Android Termux
            alias clip="termux-clipboard-set"

        elif command -v clip.exe &>/dev/null; then
            # WSL
            alias clip="clip.exe"
        fi
        ;;
esac


# Shortcuts
bind '"\C-xw": "\C-awatch -n1 \C-e"'


# Functions
## Archiving and compression
## https://wiki.archlinux.org/title/Archiving_and_compression
## https://wiki.archlinux.org/title/Bash/Functions#Extract
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.gz)
                tar xzvf "$1"
                ;;
            *.gz)
                gzip2 -d "$1"
                ;;
            *.zip)
                unzip "$1"
                ;;
            *.xz)
                xz --decompress "$1"
                ;;
            *)
                printf "%s: unrecognized file extension: %s\n" "$0" "$1" >&2
                ;;
        esac
    else
        printf "%s: file not found: %s\n" "$0" "$1" >&2
    fi
}


## SSH with bashrc included
if [ -z "$SSH_CLIENT" ]; then
    sshpp(){
        base64_rcfile="$(base64 -w 0 ~/.bashrc)"
        ssh -t "$1" "exec bash --rcfile <(printf '%s\n' \"$base64_rcfile\" | base64 --decode)"
    }
    if [ -f /usr/share/bash-completion/completions/ssh ]; then
        source /usr/share/bash-completion/completions/ssh
        if command -v _comp_cmd_ssh &>/dev/null; then
            complete -F _comp_cmd_ssh sshpp
        fi
    fi
fi

## Show most used commands
show_most_used_commands(){
    sed -En '/^(#| |$)/!s/^(sudo )?([^[:space:]]*).*$/\2/p' "$HISTFILE" |
        sort |
        uniq -c |
        sort -nr |
        head
}
alias smuc="show_most_used_commands"

## Copy to clipboard
if alias clip &>/dev/null; then
    copy_last_command() {
        fc -ln -1 |
            sed -E 's/(^[[:space:]]*|[[:space:]]*$)//' |
            tr -d '\n' |
            clip
    }
    alias clc="copy_last_command"

    copy_working_directory() {
        pwd |
            tr -d '\n' |
            clip
    }
    alias cwd="copy_working_directory"

    copy_file_path() {
       readlink -fn "$(find . -maxdepth 1 | fzf)" |
           clip
    }
    alias cfp="copy_file_path"
fi

## Vagrant
# https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html
vagrant() {
    podman run -it --rm \
        -e LIBVIRT_DEFAULT_URI \
        -v /var/run/libvirt/:/var/run/libvirt/ \
        -v "${XDG_CONFIG_HOME:-${HOME}/.config}/vagrant.d":/.vagrant.d \
        -v "$(realpath "${PWD}")":"${PWD}" \
        -w "${PWD}" \
        --network host \
        --entrypoint /bin/bash \
        --security-opt label=disable \
        docker.io/vagrantlibvirt/vagrant-libvirt:latest \
        vagrant "$@"
}


# fzf
# https://wiki.archlinux.org/title/Fzf#Bash
case "$releaseid" in
    "fedora")
        if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
            source /usr/share/fzf/shell/key-bindings.bash
        fi
        ;;
esac


# PS1 Functions
# https://wiki.archlinux.org/title/git#Git_prompt
case "$releaseid" in
    "fedora")
        if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
            source /usr/share/git-core/contrib/completion/git-prompt.sh
        fi
        ;;
esac

__ps1_status() {
    exit_code="$?"
    if [ "$exit_code" -ne 0 ]; then
        printf "$exit_code "
    fi
}


# PS1
PS1=

if [ "$(id -u)" -ne 1000 ]; then
    PS1="${PS1}\u"
fi

if [ -n "$SSH_CLIENT" ]; then
    PS1="${PS1}@\h"
fi

if [ -n "$PS1" ]; then
    PS1="${PS1} "
fi

if [ -f /run/.containerenv ] && [ -f /run/.toolboxenv ]; then
    PS1="${PS1}[$(sed -En 's/^name="(.+)"/\1/p' /run/.containerenv)] "
    PS1="${PS1}\[\e[01;35m\]\w\[\e[00m\]"
else
    PS1="${PS1}\[\e[01;32m\]\w\[\e[00m\]"
fi

if command -v __git_ps1 &>/dev/null; then
    PS1="${PS1}\$(__git_ps1)"
fi

PS1="${PS1} \[\e[0;31m\]\$(__ps1_status)\[\e[00m\]\$ "
