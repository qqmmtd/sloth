#!/usr/bin/awk -f

##
## Used to statistics avc logs, usage:
##   adb logcat -ball -d > a.txt
##   awk -f avc_statistics.awk a.txt
## 

BEGIN {
    OFS = ",";
}

# avc: denied { read } for comm="com.bbm" ...
/avc: denied/ {
    for (i = 1; i <= NF; ++i) {
        if ($i == "{") {
            break;
        }
    }
    i += 1;
    perm = $i;
    scontext = "";
    tcontext = "";
    tclass = "";
    comm = "";
    name = "";
    dev = "";
    ino = "";
    path = "";
    ioctlcmd = "";
    capability = "";
    i += 3;
    for (; i <= NF; ++i) {
        if ($i ~ /comm=/) {
            split($i, a, /=/);
            comm = a[2];
        } else if ($i ~ /name=/) {
            split($i, a, /=/);
            name = a[2];
        } else if ($i ~ /dev=/) {
            split($i, a, /=/);
            dev = a[2];
        } else if ($i ~ /ino=/) {
            split($i, a, /=/);
            ino = a[2];
        } else if ($i ~ /scontext=/) {
            split($i, a, /=/);
            scontext = a[2];
        } else if ($i ~ /tcontext=/) {
            split($i, a, /=/);
            tcontext = a[2];
        } else if ($i ~ /tclass=/) {
            split($i, a, /=/);
            tclass = a[2];
        } else if ($i ~ /permissive=/) {
            split($i, a, /=/);
            permissive = a[2];
        } else if ($i ~ /path=/) {
            split($i, a, /=/);
            path = a[2];
        } else if ($i ~ /ioctlcmd=/) {
            split($i, a, /=/);
            ioctlcmd = a[2];
        } else if ($i ~ /capability=/) {
            split($i, a, /=/);
            capability = a[2];
        } else {
#            print $i;
        }

    }
#    print scontext, tcontext, tclass, perm, comm, path;
    ++scontexts[scontext];
    ++tcontexts[tcontext];
    ++tclasses[tclass];
    ++perms[perm];
    if (comm != "") {
        ++comms[comm];
    }
    if (path != "") {
        ++paths[path];
    }
    if (name != "") {
        ++names[name];
    }
}

# insert_sort(a, s)
function insert_sort(a, s,    v, i, n, tmp) {
    delete s;
    n = 0;
    for (v in a) {
        ++n;
        s[n] = v;
        for (i = n; i > 1; --i) {
            if (a[s[i]] > a[s[i - 1]]) {
                tmp = s[i];
                s[i] = s[i - 1];
                s[i - 1] = tmp;
            }
        }
    }
    return n;
}

END {
    n = insert_sort(scontexts, s);
    printf("\nscontext:\n");
    for (i = 1; i < n; ++i) {
        printf("%4d %s\n", scontexts[s[i]], s[i]);
    }

    n = insert_sort(tcontexts, s);
    printf("\ntcontexts:\n");
    for (i = 1; i < n; ++i) {
        printf("%4d %s\n", tcontexts[s[i]], s[i]);
    }

    n = insert_sort(comms, s);
    printf("\ncomm:\n");
    for (i = 1; i < n; ++i) {
        printf("%4d %s\n", comms[s[i]], s[i]);
    }
}
