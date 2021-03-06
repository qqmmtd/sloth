#!/usr/bin/env awk -f

BEGIN {
    if (ARGC < 3) {
        usage();
    }

    # number of slashes is same as fields
    FS = "/";
}

function usage()
{
    print "\
An awk script, can pick out files and copy to target, keep folder tree.\n\
\n\
Usage:\n\
    awk -f pickout.awk <p=PREFIX/> <s=STRIP> [FILES]\n\
    ... | awk -f pickout.awk <p=PREFIX/> <s=STRIP>\n\
\n\
Example:\n\
    files listed in an input file modified_files.txt:\n\
    awk -f pickout.awk p=d/ s=1 modified_files.txt\n\
\n\
    files from a pipe, /a/b/c -> /d/b/c, s=2 means strip 2 slashes (/a/):\n\
    echo /a/b/c | awk -f pickout.awk p=/d/ s=2\
"
    exit 1;
}

{
    nlines++;

    # strip beginning space characters
    sub(/^[[:space:]]*/, "", $0);
    if ($0 ~ /^$/) {
        #print "empty line: " nlines;
        next;
    }
    if ($0 ~ /^#/) {
        #print "comment line: " nlines;
        next;
    }

    # strip beginning with ./
    sub(/^\.\//, "", $0);
    if ($0 !~ /^\//) {
        #print "related path: " nlines;
        $0 = ENVIRON["PWD"] "/" $0;
    }
    #print $0;

    t = p;
    # append / if there is not
    if (p !~ /\/$/) {
        p = p "/";
    }
    r = s;
    # strip fields
	for (i = r + 1; i < NF; ++i) {
		t = t $i "/";
	}
	#print "target folder: " t;
	if (system("mkdir -p " t) == 0) {
		system("cp -vur " $0 " " t $NF);
	}
}
