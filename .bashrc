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


# On Fedora, /etc/profile.d/* are run on non-login shells and overwrite the
# PROMPT_COMMAND environnement variable.
if ! [[ "${PROMPT_COMMAND}" =~ "history -a;" ]]; then
    PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"
fi
export PROMPT_COMMAND

# User specific aliases and functions

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# Detect platform and distribution
if [ "${OSTYPE}" = "linux-android" ] && [ -n "${TERMUX_VERSION}" ]; then
    releaseid="termux"
else
    releaseid="$(sed -En '/^ID=/s/^ID=//p' /etc/*release)" 2>/dev/null || releaseid=
fi


# Misc configuration
shopt -s autocd
shopt -s cdspell
# Do not overwrite any file with output redirection. This may be overridden when
# creating output files by using the redirection  operator  >|  instead of >.
set -o noclobber


# Aliases
## Override
# Allow completion with sudo and update the cached credentials before executing
# a command.
alias sudo="sudo -nv; sudo "

alias mv="mv -i"
alias cp="cp -i"
alias diff="diff --color=auto"

# Invoke nvim instead of vim if present
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


case "${XDG_SESSION_TYPE}" in
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
            # Termux on Android
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
## Use nvim/bash configuration through SSH
if [ -z "${SSH_CLIENT}" ]; then
    sshpp(){
        if [ -f ~/.config/nvim/init.vim ]; then
            # Encode vimrc content in base64
            base64_vimrc="$(sed -E '/^ *("|$)/d' ~/.config/nvim/init.vim | base64 -w 0)"
        else
            base64_vimrc=""
        fi
        if [ -f ~/.bashrc ]; then
            # Add encoded vimrc at the end of the bashrc content and encode the
            # whole in base 64
            base64_bashrc="$(cat <(sed -E '/^ *(#|$)/d' ~/.bashrc) <(printf '%s\n' "base64_vimrc=\"${base64_vimrc}\"") | base64 -w 0)"
            # Embed the encoded bashrc file locally to the command line and
            # decode on the remote side
            ssh -t "$1" "exec bash --rcfile <(printf '%s\n' \"${base64_bashrc}\" | base64 --decode)"
        else
            printf '%s: %s\n' "${FUNCNAME}" "bashrc file not found" >&2
        fi
    }
    if [ -f /usr/share/bash-completion/completions/ssh ]; then
        source /usr/share/bash-completion/completions/ssh
        if command -v _comp_cmd_ssh &>/dev/null; then
            complete -F _comp_cmd_ssh sshpp
        fi
    fi
else
    if command -v nvim &>/dev/null; then
        # Escape the $ sign here to resolve the variable on the remote side
        alias nvim="nvim -u <(printf '%s\n' \"\${base64_vimrc}\" | base64 --decode)"
    fi
fi

## Archiving and compression
## https://wiki.archlinux.org/title/Archiving_and_compression
## https://wiki.archlinux.org/title/Bash/Functions#Extract
extract() {
    if [ -f "${1}" ]; then
        case "${1}" in
            *.tar.gz)
                tar xzvf "${1}"
                ;;
            *.gz)
                gzip2 -d "${1}"
                ;;
            *.zip)
                unzip "${1}"
                ;;
            *.xz)
                xz --decompress "${1}"
                ;;
            *)
                printf '%s: unrecognized file extension: %s\n' "${0}" "${1}" >&2
                ;;
        esac
    else
        printf '%s: file not found: %s\n' "${0}" "${1}" >&2
    fi
}

## Show most used commands
show_most_used_commands(){
    sed -En '/^(#| |$)/!s/^(sudo )?([^[:space:]]*).*$/\2/p' "${HISTFILE}" |
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


# fzf
# https://wiki.archlinux.org/title/Fzf#Bash
case "${releaseid}" in
    "fedora")
        if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
            source /usr/share/fzf/shell/key-bindings.bash
        fi
        ;;
esac


# PS1 Functions
# https://wiki.archlinux.org/title/git#Git_prompt
case "${releaseid}" in
    "fedora")
        if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
            source /usr/share/git-core/contrib/completion/git-prompt.sh
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
