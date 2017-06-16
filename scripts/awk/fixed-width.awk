#!/usr/bin/env awk -f

BEGIN {
    fixedwidth_test();
}

##
## fixedwidth(s, a, w [, r])
##
## Splits the string s into the array a on the width list string w, and returns
## the number of fields. If r is omitted, the first non-numeric character is
## used as separator of the string w. If last width is 0, the rest of s is used
## as last field.
##
function fixedwidth(s, a, w, r,     _wa, _wn, _i, _k) {
    if (r == "") {
        for (_i = 1; _i <= length(w); ++_i) {
            _k = substr(w, _i, 1);
            if (_k !~ /^[[:digit:]]$/) {
                r = _k;
                break;
            }
        }
        if (r == "") {
            r = ",";
        }
    }
    _wn = split(w, _wa, r);
    if (_wn == 0) {
        return 0;
    }
    _i = 1;
    for (_k = 1; _k < _wn; ++_k) {
        if (_wa[_k] > 0) {
            a[_k] = substr(s, _i, _wa[_k]);
            _i += _wa[_k];
        } else {
            return 0;
        }
    }
    if (_wa[_wn] == "" || _wa[_wn] == 0) {
        a[_wn] = substr(s, _i);
    } else {
        a[_wn] = substr(s, _i, _wa[_k]);
    }
    return _wn;
}

function fixedwidth_test(_wn, _a, _k) {
#-$
#rw-r--r--$
#  1$
# xxxxxxx$
# tctnb$
#   1054524$
# Mar$
# 30$
# 15:26$
# zyja.txt$
    _wn = fixedwidth( \
            "-rw-r--r--  1 xxxxxxx tctnb   1054524 Mar 30 15:26 zyja.txt", \
            _a, \
            "1,9,3,8,6,10,4,3,6," \
    );
    for (_k = 1; _k <= _wn; ++_k) {
        printf("#%s$\n", _a[_k]);
    }

#/dev/sda8      $
# 785G $
# 652G $
#  93G $
# 88% $
#/home$
    _wn = fixedwidth( \
            "/dev/sda8       785G  652G   93G  88% /home", \
            _a, \
            "15 6 6 6 5 0", \
            " " \
    );
    for (_k = 1; _k <= _wn; ++_k) {
        printf("#%s$\n", _a[_k]);
    }
}
