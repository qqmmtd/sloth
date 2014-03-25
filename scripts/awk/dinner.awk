#!/usr/bin/awk

BEGIN {
    FS = "\t\t*";
    total = 0;
}

/^\t\t/ {
    if ($7 == "I") {
        print $3, $4, substr($9, 1, 10);
        ++orderI[$3];
        ++total;
    }
}

END {
    for (o in orderI) {
        printf("\n%s: %d\n", o, orderI[o]);
    }
    printf("\ntotal: %d\n", total);
}
