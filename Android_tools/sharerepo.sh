#!/bin/sh

## global vars ##
SHAREDDIR=${HOME}/repository/shared

## functions ##
usage()
{
    local r
    echo "usage:"
    echo "    $(basename $0) repository"
    echo
    echo "valid repositories:"
    for r in $(ls $SHAREDDIR); do
        if [ -d "${SHAREDDIR}/${r}/.repo" ]; then
            echo "    $r"
        fi
    done
    exit
}

## main ##
case $1 in
    ""|-h|--help|-?) usage;;
esac

REPO=${SHAREDDIR}/${1}/.repo
if [ ! -d "$REPO" ]; then
    echo "error: $REPO is not valid"
    echo
    usage
fi

ln -s ${REPO}/project-objects .repo/
ln -s ${REPO}/projects .repo/

