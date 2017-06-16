#!/usr/bin/env awk -f

BEGIN {
    FS = "[[:blank:]]+";
    fn = 0;
}

/^Total PSS by process:/ {
    ++fn;
    while (getline && $0 != "") {
        i = 0;
        p = $3;
        while (ma[fn, p] != "") {
            ++i;
            p = $3"["i"]";
        }
        ps[p] = "E";
        gsub(/,/, "", $2);
        gsub(/K:/, "", $2);
        ma[fn, p] = $2;
    }
    nextfile;
}

END {
    for (p in ps) {
        for (f = 1; f <= fn; ++f) {
            printf("%10d, ", ma[f, p]);
        }
        printf("%s\n", p);
    }
}
