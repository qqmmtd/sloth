#!/usr/bin/env awk -f

BEGIN {
    fixedwidthsplit_test();
}

##
## fixedwidthsplit(w, a [,t])
##
## Splits the target string t into the array a on the width list string w, and
## returns the number of fields. If t is not supplied, $0 is used instead. The
## string w is splited on non-numeric characters. If the width of the last field
## is 0, the rest of t is used.
##
function fixedwidthsplit(w, a, t,     _wa, _wn, _i, _k) {
    _wn = split(w, _wa, /[^[:digit:]]+/);
    if (_wn == 0) {
        return 0;
    }
    if (t == "") {
        t = $0;
    }
    if (_wa[_wn] == "") {
        _wa[_wn] = length(t);
    }
    _i = 1;
    for (_k = 1; _k <= _wn; ++_k) {
        a[_k] = substr(t, _i, _wa[_k]);
        _i += _wa[_k];
    }
    return _wn;
}

function fixedwidthsplit_test(       _wn, _a, _k) {
#-$
#rw-r--r--$
#  1$
# xxxxxxx$
# tctnb$
#   1054524$
#$
# Mar$
# 30$
# 15:26$
# zyja.txt$
    _wn = fixedwidthsplit( \
            "1,9,3;8,6,,10,0,4:3,6,", \
            _a, \
            "-rw-r--r--  1 xxxxxxx tctnb   1054524 Mar 30 15:26 zyja.txt" \
    );
    for (_k = 1; _k <= _wn; ++_k) {
        printf("#%s$\n", _a[_k]);
    }
}
