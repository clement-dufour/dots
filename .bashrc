# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ "$HOME/.pyenv/bin:" ]]; then
    PATH="$HOME/.pyenv/bin:$PATH"
fi
export PATH

# On Fedora, /etc/profile.d/* are run on non-login shells and overwrite the
# PROMPT_COMMAND environnement variable.
if ! [[ "${PROMPT_COMMAND}" =~ "history -a;" ]]; then
    PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"
fi
export PROMPT_COMMAND

if command -v nvim &>/dev/null; then
    EDITOR="nvim"
elif command -v vim &>/dev/null; then
    EDITOR="vim"
elif command -v vi &>/dev/null; then
    EDITOR="vi"
fi
export EDITOR

# User specific aliases and functions

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Detect platform and distribution
if [ "${OSTYPE}" = "linux-android" ] && [ -n "${TERMUX_VERSION}" ]; then
    releaseid="termux"
else
    releaseid="$(sed -En '/^ID=/s/^ID=//p' /etc/*release)" 2>/dev/null ||
        releaseid=
fi

# Misc configuration
shopt -s autocd
shopt -s cdspell
# Do not overwrite any file with output redirection. This may be overridden when
# creating output files by using the redirection operator >| instead of >.
set -o noclobber

# Aliases
unalias -a

# Allow bash completion with sudo
alias sudo="sudo "
# Update the cached credentials before executing a command.
# Removed because it required the password for NOPASSWD users.
# alias sudo="sudo -nv; sudo "

alias mv="mv -i"
alias cp="cp -i"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ls="ls --color=auto --file-type --group-directories-first"
alias ip="ip -color=auto"
alias lsusb="lsusb.py -ciu"
alias trash="gio trash"

alias l="LC_COLLATE='C' ls -1"
# alias l.="LC_COLLATE='C' ls -1 --directory .*"
alias ll="LC_COLLATE='C' ls -1 --almost-all"
alias la="LC_COLLATE='C' ls -l --almost-all --human-readable"
alias t="tree -a"

# alias ipa="ip address show"
alias ip6="ip -6"
alias dc="docker compose"
alias nohistory="unset HISTFILE"

if [ "${XDG_SESSION_TYPE}" = "wayland" ] && command -v wl-copy &>/dev/null;then
    alias clip="wl-copy"
fi

# When connected to a host through sshpp, use embedded vimrc content.
if [ -n "${base64_vimrc}" ]; then
    if command -v nvim &>/dev/null; then
        alias nvim="nvim -u <(printf '%s\n' \"\${base64_vimrc}\" | base64 --decode)"
    else
        alias vim="vim -u <(printf '%s\n' \"\${base64_vimrc}\" | base64 --decode)"
    fi
fi

# Invoke nvim instead of vim if present
if command -v nvim &>/dev/null; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

alias ssh-copy-id="ssh-copy-id -P new"

if command -v emacs &>/dev/null; then
    alias emacs="emacsclient --create-frame --alternate-editor \emacs"
else
    alias emacs="toolbox run --container emacs-toolbox emacsclient --create-frame --alternate-editor \emacs"
fi
if command -v stow &>/dev/null; then
    alias stow="stow --verbose --restow --dir=\"\${HOME}/Projects/dots/\" --target=\"\${HOME}/\" ."
else
    alias stow="toolbox run --container fedora-toolbox stow --verbose --restow --dir=\"\${HOME}/Projects/dots/\" --target=\"\${HOME}/\" ."
fi

# Shortcuts
bind '"\C-xw": "\C-awatch -c -n1 \C-e"'

# Functions
## Use vim/bash configuration through SSH
sshpp() {
    # base64_bashrc and base64_vimrc are not defined on the initial host but are
    # defined on a remote one.

    # If true, we are on the initial host.
    if [ -z "${base64_bashrc+x}" ] && [ -f "${HOME}/.bashrc" ]; then
        local base64_bashrc
        if [ -z "${base64_vimrc+x}" ] && [ -f "${HOME}/.vim/vimrc" ]; then
            local base64_vimrc
            # Encode vimrc file content in base64.
            base64_vimrc="$(sed -E '/^ *("|$)/d' "${HOME}/.vim/vimrc" | base64 -w 0)"
            # Add encoded vimrc before the bashrc file content and encode
            # everything in base64.
            base64_bashrc="$(cat <(printf 'base64_vimrc="%s"\n' "${base64_vimrc}") <(sed -E '/^ *(#|$)/d' "${HOME}/.bashrc") | base64 -w 0)"
        else
            base64_bashrc="$(sed -E '/^ *(#|$)/d' "${HOME}/.bashrc" | base64 -w 0)"
        fi
    fi
    # base64_bashrc should not be empty at this point but check anyway.
    if [ -n "${base64_bashrc}" ]; then
        local base64_rcfile
        base64_rcfile="$(cat <(printf 'base64_bashrc="%s"\n' "${base64_bashrc}" | base64 -w 0) <(printf '%s\n' "${base64_bashrc}"))"
        # Embed the encoded rcfile locally to the command line and decode on the
        # remote side.
        ssh -t "$1" "exec bash --rcfile <(printf '%s\n' \"${base64_rcfile}\" | base64 --decode)"
    fi
}
if [ -f /usr/share/bash-completion/completions/ssh ]; then
    # HACK Raises an error on Debian, redirect output to /dev/null
    source /usr/share/bash-completion/completions/ssh 2>/dev/null
    if command -v _comp_cmd_ssh &>/dev/null; then
        complete -F _comp_cmd_ssh sshpp
    fi
fi

## Archiving and compression
## https://wiki.archlinux.org/title/Archiving_and_compression
## https://wiki.archlinux.org/title/Bash/Functions#Extract
extract() {
    if [ -n "${1}" ]; then
        if [ -f "${1}" ]; then
            case "${1}" in
            *.tar | *.tar.gz | *.tgz | *.tar.xz | *.txz)
                tar --extract --file "${1}"
                ;;
            *.gz)
                gzip --decompress "${1}"
                ;;
            *.zip)
                unzip "${1}"
                ;;
            *.xz)
                xz --decompress "${1}"
                ;;
            *)
                printf '%s: unrecognized file extension: %s\n' \
                    "${FUNCNAME[0]}" "${1}" >&2
                ;;
            esac
        else
            printf '%s: file not found: %s\n' "${FUNCNAME[0]}" "${1}" >&2
        fi
    else
        printf '%s: no filename given\n' "${FUNCNAME[0]}" >&2
    fi
}

## Copy to clipboard
if alias clip &>/dev/null; then
    copy_last_command() {
        fc -ln -1 |
            sed -E 's/(^[[:space:]]*|[[:space:]]*$)//' |
            tr -d '\n' |
            clip
    }
    alias clc="copy_last_command"

    copy_file_path() {
        readlink -fn "$(find . -maxdepth 1 | fzf)" |
            clip
    }
    alias cfp="copy_file_path"
fi

## Create a backup file (.bak)
backup() {
    if [[ ${#} -ne 1 ]]; then
        printf "Usage : %s <filename>\n" "${0}"
        return
    fi
    cp -- "${1}"{,.bak}
}

## Restore a backup file (.bak)
restore() {
    if [[ ${#} -ne 1 ]]; then
        printf "Usage : %s <filename>\n" "${0}"
        return
    fi
    cp -- "${1}"{.bak,}
}

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

# bash_completion
# shellcheck shell=sh disable=SC1091,SC2166,SC2268,SC3028,SC3044,SC3054
# Check for interactive bash and that we haven't already been sourced.
if [ "x${BASH_VERSION-}" != x -a "x${PS1-}" != x -a "x${BASH_COMPLETION_VERSINFO-}" = x ]; then

    # Check for recent enough version of bash.
    if [ "${BASH_VERSINFO[0]}" -gt 4 ] ||
        [ "${BASH_VERSINFO[0]}" -eq 4 -a "${BASH_VERSINFO[1]}" -ge 2 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] &&
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
            # Source completion code.
            . /usr/share/bash-completion/bash_completion
        fi
    fi

fi


# PS1 Functions
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

__ps1_status() {
    exit_code="${?}"
    if [ "${exit_code}" -ne 0 ]; then
        printf '%s ' "${exit_code}"
    fi
}

# PS1 Definition
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
