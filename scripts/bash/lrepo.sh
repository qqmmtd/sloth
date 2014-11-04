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
        echo $'\n\ny' | repo init -u $REMOTE:$1/manifest -m $2
        mkdir -p .repo/projects/$ANDROID_SRC_DIR
        _sync -j4
        rm .repo/manifest.xml
        rm .repo/manifest.xml.bak
        rm -rf *
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

/[ \t]*<project/ {
    iname = 0;
    ipath = 0;
    irevision = 0;
    for (i = 0; i < NF; ++i) {
        if ($i ~ "name=$") {
            iname = i + 1;
        } else if ($i ~ "path=$") {
            ipath = i + 1;
        } else if ($i ~ "revision=$") {
            irevision = i + 1;
        } else {
            # other tag
        }
    }
    if (ipath == 0) {
        if ($iname !~ "^amss_") {
            $(iname + 1) = " path=\""ANDROID_SRC_DIR"/"$(iname)"\""$(iname + 1);
        }
    } else if (ipath > 0) {
        if ($iname ~ "^amss_") {
            $ipath = "";
        } else if ($ipath ~ "^v[^/]*/"ANDROID_SRC_DIR"/") {
            $ipath = substr($ipath, index($ipath, "/") + 1);
        } else {
            $ipath = ANDROID_SRC_DIR"/"$ipath;
        }
    }
}

/[ \t]*<copyfile/ {
    idest = 0;
    isrc = 0;
    for (i = 0; i < NF; ++i) {
        if ($i ~ "dest=$") {
            idest = i + 1;
        } else if ($i ~ "src=$") {
            isrc = i + 1;
        } else {
            # other tag
        }
    }
    if (idest > 0) {
        if ($idest ~ "^v[^/]*/"ANDROID_SRC_DIR"/") {
            $idest = substr($idest, index($idest, "/") + 1);
        } else {
            $idest = ANDROID_SRC_DIR"/"$idest;
        }
    }
}

/.*/ {
    printf("%s\n", $0);
}
' ANDROID_SRC_DIR=$ANDROID_SRC_DIR .repo/manifest.xml.bak > .repo/manifest.xml
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
    shift
    _repo "$@"
    ;;
*)
    echo 'help'
    ;;
esac

exit $?
