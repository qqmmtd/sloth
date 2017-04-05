#!/usr/bin/awk

/\r$/ {
    $0 = substr($0, 1, length($0) - 1);
}

/^$/ {
    next;
}

/^total/ {
    next;
}

/^ls:/ {
    next;
}

/^\/.*:$/ {
    dir = substr($0, 1, length($0) - 1);
    if (dir == "/") {
        dir = "";
    }
    next;
}

{
    #$NF = dir "/" $NF;
    #print $0;
    for (i = 1; i < 11; ++i) {
        printf("%c\t", substr($1, i, 1));
    }
    printf("%s", $3);
    printf("\t%s", $4);
    #printf("\t%d", $2);
    #printf("\t%d", $5);
    #printf("\t%s", $6);
    #printf("\t%s", $7);
    if ($(NF - 1) == "->") {
        printf("\t%s/%s\t%s", dir, $(NF - 2), $(NF - 2));
        printf("\t%s", $NF);
    } else {
        printf("\t%s/%s\t%s", dir, $NF, $NF);
    }
    printf("\n");
}
