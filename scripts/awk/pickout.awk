#!/usr/bin/awk -f

BEGIN {
	if (ARGC < 2) {
		printf("usage: pickout d=DIR [s=STRIP] [FILE]\n");
		exit 1;
	}
	FS = "/";
}

$0 !~ /^[ \t]*#/ {
	t = d;
	## git status -s
	if ($0 ~ /^ M /) {
		$0 = substr($0, 4);
	} else if ($0 ~ /^\?\? /) {
		$0 = substr($0, 4);
	}
	## git status -s 
	else if ($0 !~ /^\//) {
		$0 = ENVIRON["PWD"] "/" $0;
	}
	for (i = s + 1; i < NF; ++i) {
		t = t "/" $i;
	}
	if (system("mkdir -vp " t) == 0) {
		system("cp -vur " $0 " " t "/" $NF);
	}
}

