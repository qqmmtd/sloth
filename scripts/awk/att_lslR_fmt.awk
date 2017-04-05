#!/usr/bin/awk

##
## usage:
##   adb shell su root ls -l -R > data.txt
##   awk -f att_lslR_fmt.awk data.txt > files.csv
##

BEGIN {
    ## field separators
    FS = "[ \t]*";
}

## remove ending \r
/\r$/ {
    $0 = substr($0, 1, length($0) - 1);
}

## ignore empty lines
/^$/ {
    next;
}

## ignore directory total size lines, e.g.
# total 0
/^total / {
    next;
}

## ignore error lines, e.g.
# ls: vold: Permission denied
/^ls: / {
    next;
}

## save current directory, e.g.
# .:
# ./:
# ./dev:
# /:
# /dev:
# dev:
/:$/ {
    if ($0 ~ /^\./) {
        dir = substr($0, 2, length($0) - 2);
        if (dir == "") {
            dir = "/";
        }
    } else {
        dir = substr($0, 1, length($0) - 1);
    }
    next;
}

{
    #print dir, $0;

    printf("\"%s:\"", dir);

    ## $1: type and permissions, e.g.
    # $1         $2 $3
    # drwxr-xr-x 2  root
    for (i = 1; i <= 10; ++i) {
        printf(",");
        printf("%c", substr($1, i, 1));
    }

    ## $2: stat.st_nlink, ignore

    ## $3, $4: user, group, e.g.
    # $2 $3   $4
    # 2  root system
    printf(",");
    printf("%s", $3);
    printf(",");
    printf("%s", $4);

    ## $5 ~ $7: major/size, minor/date, date/time, e.g.
    # $4     $5     $6         $7
    # system 223,   0          1970-01-07
    # root   1740   1970-01-07 05:21
    if ($5 ~ /,$/) {
        df = 7;
        $5 = substr($5, 1, length($5) - 1);
        printf(",");
        printf("%s", $5);
        printf(",");
        printf("%s", $6);
    } else {
        df = 6;
        printf(",");
        #printf("\"\"");
        printf(",");
        printf("%s", $5);
    }

    ## $df, $(df+1): date, time
    printf(",");
    printf("%s", $df);
    printf(",");
    printf("%s", $(df + 1));

    ## $(df+2) ~ $NF: name, "->", real path, e.g.
    # $df        $(df+1) $(df+2)     $(df+3) $(df+4)
    # 1970-01-01 00:00   bt_firmware
    # 1970-01-01 00:00   mmcblk0     ->      /dev/block/mmcblk0
    printf(",");
    printf("\"");
    printf("%s", $(df + 2));
    if ($(df + 3) == "->") {
        printf("%s%s", $(df + 3), $(df + 4)); 
    }
    printf("\"");

    ## empty column
    printf(",");
    #printf("\"\"");

    ## explanation column
    printf(",");
    #printf("\"\"");

    printf("\n");
}
