#!/usr/bin/env awk -f

##
## usage:
##   awk -f att_lslR_exp.awk files.csv > files_2.csv
##

BEGIN {
    ## field separator
    FS = ",";

    ## explanations
    exp1 = "Unchanged Android files or direcories with default permissions."
    exp2 = "Unchanged Kernel proc files with default permissions."
}

/^"\/config\/sdcardfs\// && $18 == "\"appid\"" {
    printf("%s\"%s\"\n", $0, exp1);
    next;
}

/^"\/proc\/[0-9]*:"/ && $18 == "\"sched_group_id\"" {
    printf("%s\"%s\"\n", $0, exp2);
    next;
}

/^"\/proc\/[0-9]*\/attr:"/ {
    if ($18 == "\"current\"" ||
        $18 == "\"exec\"" ||
        $18 == "\"fscreate\"" ||
        $18 == "\"keycreate\"" ||
        $18 == "\"sockcreate\"") {
        printf("%s\"%s\"\n", $0, exp2);
        next;
    }
}

/^"\/proc\/[0-9]*\/net\/xt_qtaguid:"/ && $18 == "\"ctrl\"" {
    printf("%s\"%s\"\n", $0, exp2);
    next;
}

/^"\/proc\/[0-9]*\/task\/[0-9]*\/attr:"/ {
    if ($18 == "\"current\"" ||
        $18 == "\"exec\"" ||
        $18 == "\"fscreate\"" ||
        $18 == "\"keycreate\"" ||
        $18 == "\"sockcreate\"") {
        printf("%s\"%s\"\n", $0, exp2);
        next;
    }
}

/^"\/proc\/[0-9]*\/task\/[0-9]*\/net\/xt_qtaguid:"/ && $18 == "\"ctrl\"" {
    printf("%s\"%s\"\n", $0, exp2);
    next;
}

{
    printf("%s\n", $0);
}
