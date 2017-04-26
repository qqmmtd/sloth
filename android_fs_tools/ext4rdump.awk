#!/usr/bin/gawk -f

BEGIN {
    FS = "/";

    if (ri != "" && od != "") {
        if (0 == system("mkdir -p "od)) {
            ext4_dump(ri, od);
        }
    } else {
        usage();
    }
}

function ext4_dump(ri, od) {
    while ("debugfs -R 'ls -p' "ri | getline) {
        if ($6 != "." && $6 != ".." && $6 != "") {
            system("debugfs -R 'rdump "$6" "od"' "ri);
        }
    }
}

function usage() {
    printf("usage: awk -f ext4rdump.awk -v ri=system.img.raw -v od=ourdir\n");
}
