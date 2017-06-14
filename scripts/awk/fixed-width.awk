#!/usr/bin/env awk

BEGIN {
    fixedwidth_test("1,9,3,8,6,10,4,3,6,",
            "-rw-r--r--  1 zhanghe tctnb   1054524 Mar 30 15:26 zyja.txt");
}

function fixedwidth(w, r, ra,    _wa, _wn, _i, _k) {
    _wn = split(w, _wa, ",");
    if (_wn == 0) {
        return 0;
    }
    _i = 1;
    for (_k = 1; _k < _wn; ++_k) {
        if (_wa[_k] > 0) {
            ra[_k] = substr(r, _i, _wa[_k]);
            _i += _wa[_k];
        } else {
            return 0;
        }
    }
    if (_wa[_wn] == "") {
        ra[_wn] = substr(r, _i);
    } else {
        ra[_wn] = substr(r, _i, _wa[_k]);
    }
    return _wn;
}

function fixedwidth_test(w, r,   _wn, _ra, _k) {
    _wn = fixedwidth(w, r, _ra);
    for (_k = 1; _k <= _wn; ++_k) {
        print _k, _ra[_k];
    }
}
