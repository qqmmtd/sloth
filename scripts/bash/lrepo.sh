#!/bin/bash

## globle variables
REMOTE='git@172.16.11.162'
REPOSITORY_DIR='/media/Ubuntu/repository'
ANDROID_SRC_DIR='LINUX/android'

## functions
_repo ()
{
    mkdir -p $REPOSITORY_DIR/$1

    (
        cd $REPOSITORY_DIR/$1
        echo $'\n\ny' | repo init -u $REMOTE:$1/manifest
        mkdir -p .repo/projects/$ANDROID_SRC_DIR
    )
}

_init ()
{
    local tmp=${3##*:}
    local repository=${tmp%%/*}

    if [[ ! -a .repo ]]; then
        mkdir .repo
        for i in manifests manifests.git projects repo; do
	        ln -s $REPOSITORY_DIR/$repository/.repo/$i .repo/$i
        done
        echo $'\n\ny' | repo "$@"
    fi
}

_fetch ()
{
    if [[ -d .repo ]]; then
        (
            cd .repo/manifests
            git pull
        )
        if [[ ! -a .repo/manifest.xml.bak ]]; then
            mv .repo/manifest.xml .repo/manifest.xml.bak
        fi
        awk '
BEGIN {
    FS = "\"";
    OFS = "\"";
}

/<project/ {
    if ($4 ~ "^v[^/]*/'$ANDROID_SRC_DIR'/") {
        $4 = substr($4, index($4, "/") + 1);
    } else if ($2 ~ "^amss_....$") {
        $4 = $2;
    } else {
        $4 = "'$ANDROID_SRC_DIR'/" $4;
    }
}

/<copyfile/ {
    if ($2 ~ "^v[^/]*/'$ANDROID_SRC_DIR'/") {
        $2 = substr($2, index($2, "/") + 1);
    } else {
        $2 = "'$ANDROID_SRC_DIR'/" $2;
    }
}

/.*/ {
    printf("%s\n", $0);
}
' .repo/manifest.xml.bak > .repo/manifest.xml
    fi
}

_sync ()
{
    if [[ -d .repo ]]; then
        _fetch
        repo sync
    fi
}

## main
cmd=$1
case $cmd in
init)
    _init "$@"
    ;;
fetch)
    _fetch
    ;;
sync)
    _sync
    ;;
repo)
#    _repo "$@"
    ;;
*)
    echo 'help'
    ;;
esac

exit $?
