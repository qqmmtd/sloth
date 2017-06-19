#!/usr/bin/env awk -f

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

function ext4_dump(ri, od,      _cmd) {
    _cmd = "debugfs -R 'ls -p' "ri
    while (_cmd | getline) {
        if ($6 != "." && $6 != ".." && $6 != "") {
            system("debugfs -R 'rdump "$6" "od"' "ri);
        }
    }
    close(_cmd)
}

function usage() {
    printf("usage: awk -f ext4rdump.awk -v ri=system.img.raw -v od=ourdir\n");
}
