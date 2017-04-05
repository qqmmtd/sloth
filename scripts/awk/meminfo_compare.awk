#!/usr/bin/awk -f

BEGIN {
	FS = " ";
}

/^Total PSS by process:/ {
	fa[FILENAME] = "m";
	while (getline && $0 ~ /\(pid/) {
		i = 0;
		pn = $3;
		while (va[FILENAME, pn] != "") {
			++i;
			pn = $3"["i"]";
		}
		pa[pn] = "m";
		va[FILENAME, pn] = $1;
	}
}

END {
	for (v in fa) {
		printf("%8s ", v);
	}
	printf("\n");

	for (v in pa) {
		for (u in fa) {
			if (va[u, v] == "") {
				printf("%8d ", 0);
			} else {
				printf("%8d ", va[u, v]);
			}
		}
		printf("%s\n", v);
	}
}
