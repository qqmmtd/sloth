#!/usr/bin/awk -f

BEGIN {
    FS = "/";

    if (imgraw != "" && dumpdir != "") {
        printf("\nimgraw=%s\ndumpdir=%s\n\n", imgraw, dumpdir);
        if (0 == system("mkdir -p "dumpdir)) {
            ext4_dump(imgraw, dumpdir);
        }
    } else {
        printf("usage: parse_ext4 -v imgraw=IMAGE -v dumpdir=DIR\n");
    }
}

function ext4_dump(imgraw, dumpdir) {
    while ("debugfs -R 'ls -p' "imgraw | getline) {
        if ($6 != "." && $6 != ".." && $6 != "") {
            # recursive dump all files
            if (0 != system("debugfs -R 'rdump "$6" "dumpdir"' "imgraw)) {
                printf("%s/rdump fail: (%s)\n", $6);
                exit 1;
            }
        }
    }
}
