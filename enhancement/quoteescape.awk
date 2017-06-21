#!/usr/bin/env awk -f

BEGIN {
    quoteescape_test();
}

##
## quoteescape(c, a [,t])
##
## Splits the target string t into the array a on the character c, and returns
## the number of fields. If t is not supplied, $0 is used instead. It can detect
## characters enclosed in double quotes and escape sequence \\, \".
##
function quoteescape(c, a, t,    fn, ta, tfn, i, l) {
    if (c == "") {
        return 0;
    }
    if (t == "") {
        t = $0;
    }
    tfn = split(t, ta, c);
    if (tfn == 0) {
        return 0;
    }
    i = 1;
    fn = 0;
    while (i <= tfn) {
        if (substr(ta[i], 1, 1) == "\"") {
            ++fn;
            a[fn] = ta[i];
            do {
                ++i;
                a[fn] = a[fn] c ta[i];
                l = match(ta[i], /\\*"$/);
                if (l > 0) {
                    l = length(ta[i]) - l;
                    if (int(l / 2) == l / 2) {
                        break;
                    }
                }
            } while (i <= tfn)
        } else {
            ++fn;
            a[fn] = ta[i];
        }
        ++i;
    }
    return fn;
}

function quoteescape_test(      fn, k, a) {
#1,"2,3\",4\\\\",5 ->
#1$
#"2,3\",4\\\\"$
#5$
    fn = quoteescape(",", a, "1,\"2,3\\\",4\\\\\\\\\",5");
    for (k = 1; k <= fn; ++k) {
        printf("#%s$\n", a[k]);
    }
}
