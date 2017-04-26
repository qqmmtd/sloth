#!/usr/bin/gawk -f

BEGIN {
    FS = "/";

    if (imgraw != "" && pname != "") {
        system("rm "pname);
        #system("debugfs -R 'stats' "imgraw" >> stat.txt");
        ext4_recursive_ls(imgraw, "", pname, "");
    }
}

function ext4_recursive_ls(imgraw, fname, pname, path) {
    while ("debugfs -R 'ls -p "path"' "imgraw | getline) {
        # not ., .., or last line
        if ($6 != "." && $6 != ".." && $6 != "") {
            system("echo "path"/"$6" >> "pname);
            #EXTENTS:
            system("debugfs -R 'stat "path"/"$6"' "imgraw" >> "pname);
            if ($3 ~ /^04....$/) {
                # print before list sub dir, or $0 will auto set new
                ext4_recursive_ls(imgraw, fname, pname, path"/"$6);
            }
        }
    }
}

