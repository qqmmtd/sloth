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
    next;
}

{
    #$NF = dir "/" $NF;
    #print $0;
    printf("%s", dir);
    for (i = 1; i < 11; ++i) {
        printf(" %c", substr($1, i, 1));
    }
    printf(" %s", $3);
    printf(" %s", $4);
    printf(" %d", $2);
    printf(" %d", $5);
    printf(" %s", $6);
    printf(" %s", $7);
    printf(" %s", $8);
    printf("\n");
}
