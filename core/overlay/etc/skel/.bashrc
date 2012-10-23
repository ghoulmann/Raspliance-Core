# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

function realpath()
{
    f=$@

    if [ -d "$f" ]; then
        base=""
        dir="$f"
    else
        base="/$(basename "$f")"
        dir=$(dirname "$f")
    fi

    dir=$(cd "$dir" && /bin/pwd)

    echo "$dir$base"
}

# Set prompt path to max 2 levels for best compromise of readability and usefulness
promptpath () {
    realpwd=$(realpath $PWD)
    realhome=$(realpath $HOME)

    # if we are in the home directory
    if echo $realpwd | grep -q "^$realhome"; then
        path=$(echo $realpwd | sed "s|^$realhome|\~|")
        if [ "$path" = "~" ] || [ "$(dirname "$path")" = "~" ]; then
            echo $path
        else
            echo $(basename $(dirname "$path"))/$(basename "$path")
        fi
        return
    fi

    path_dir=$(dirname $PWD)
    # if our parent dir is a top-level directory, don't mangle it
    if [ $(dirname $path_dir) = "/" ]; then
        echo $PWD
    else
        path_parent=$(basename "$path_dir")
        path_base=$(basename "$PWD")

        echo $path_parent/$path_base
    fi
}

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # Set a terminal prompt style (default is fancy color prompt)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h \[\033[01;34m\]$(promptpath)\[\033[00m\]\$ '
else
    alias ls="ls -F"
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    PS1='${debian_chroot:+($debian_chroot)}\u@\h $(promptpath)\$ '
fi

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

run_scripts()
{
    for script in $1/*; do
        [ -x "$script" ] || continue
        . $script
    done
}

run_scripts $HOME/.bashrc.d

