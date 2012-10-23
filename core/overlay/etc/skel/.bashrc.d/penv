# Copyright (c) 2010 Liraz Siri <liraz@turnkeylinux.org> - all rights reserved

PENV_PATH=$HOME/.penv

[ -f $PENV_PATH ] || touch $PENV_PATH
source $PENV_PATH

alias penv-reload="source $PENV_PATH"

function penv-set {
    name=${1%=*}
    if [ "$name" = "$1" ]; then
        val=$2
    else
        val=${1#*=}
    fi

    if [ ! "$name" ] || [ ! "$val" ]; then
        echo syntax: penv-set name val
        echo syntax: penv-set name=val
        return 1
    fi

    penv-unset $name
    echo $name=\"$val\" >> $PENV_PATH
    penv-reload
}

function penv-unset {
    if [ ! "$1" ]; then
        echo syntax: penv-unset name
        return 1
    fi
    unset $1
    sed -i -e "/^$1=/d" $PENV_PATH
}

