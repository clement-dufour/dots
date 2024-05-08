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

## Shorten
alias l="ls -1 --color=auto --file-type --group-directories-first"
alias l.="ls -1 --color=auto --file-type --group-directories-first -d .*"
alias ll="ls -1A --color=auto --file-type --group-directories-first"
alias la="ls -lAh --color=auto --file-type --group-directories-first"
alias ipa="ip -color=auto address show"
alias dcud="docker compose up -d"
alias dcudf="docker compose up -d --force-recreate"
alias dcd="docker compose down"
alias dcp="docker compose pull"


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
        complete -F _ssh sshpp
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

## Snippets
if [ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/bash" ]; then
    snippets="${XDG_DATA_HOME:-${HOME}/.local/share}/bash/snippets.txt"

    select_snippet() {
        if [ -f "$snippets" ]; then
            local snippet opts
            opts="--tac --height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m"
            snippet="$(sed -E '/^(#| )/d' "$snippets" | FZF_DEFAULT_OPTS="$opts" fzf --query "$READLINE_LINE")"
            # READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$snippet${READLINE_LINE:$READLINE_POINT}"
            READLINE_LINE="$snippet"
            READLINE_POINT=$(( READLINE_POINT + ${#snippet} ))
        else
            echo "No snippet found."
        fi
    }
    bind -x '"\C-xs": select_snippet'

    save_history_command_as_snippet() {
        local opts
        opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m"
        fc -lnr -2147483648 |
            sed -E 's/(^[[:space:]]*|[[:space:]]*$)//' |
            FZF_DEFAULT_OPTS="$opts" fzf |
            tee --append "$snippets"
    }
    alias shc="save_history_command_as_snippet"

    save_last_command_as_snippet() {
        fc -ln -1 |
            sed -E 's/(^[[:space:]]*|[[:space:]]*$)//' |
            tee --append "$snippets"
    }
    alias slc="save_last_command_as_snippet"

    if alias clip &>/dev/null; then
        copy_snippet() {
            if [ -f "$snippets" ]; then
                local snippet opts
                opts="--tac --height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m"
                sed -E '/^(#| )/d' "$snippets" |
                    FZF_DEFAULT_OPTS="$opts" fzf |
                    tr -d '\n' |
                    clip
            else
                echo "No snippet found."
            fi
        }
    fi
fi

## Dotfiles
# https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git
alias dots="git --git-dir=\$HOME/.local/share/dots.git/ --work-tree=\$HOME"

case "$releaseid" in
    "termux")
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
