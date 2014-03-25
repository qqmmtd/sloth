#!/usr/bin/awk

/\r$/ {
    $0 = substr($0, 1, length($0) - 1);
}

/:$/ {
    dir = substr($0, 1, length($0) - 1);
}

/^[^l][r-][w-][xsStT-][r-][w-][xsStT-][r-][w-][xsStT-]/ {
    $NF = dir "/" $NF;
    print $0;
}

