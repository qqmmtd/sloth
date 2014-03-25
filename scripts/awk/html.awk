function append() {
	if (getline) {
		remain = remain RS $0;
		printf("remain: %s\n", remain);
	} else {
		printf("EOF\n");
		exit;
	}
}

function in_section(sec_bg, sec_ed) {
	if (remain !~ "^" sec_bg)
		return 0;
	while (remain !~ sec_ed "$") {
		append();
	}
	printf("in section\n");
	printf("<%s>\n", remain);
	return 1;
}

function begin_with_a_tag(str) {
	
	return 1;
}

BEGIN {
	RS = ">";
	FS = "";
	ptag = "";
	remain = "";
	contain = "";
	
	while (getline) {
		remain = $0;
		before = "";
		printf("remain: %s\n", remain);

		while (index(remain, "<") == 0) {
			append();
		}
		lab = index(remain, "<");
		if (begin_with_a_tag(substr(remain, lab))) {
		
		} else {
			if (before != "") {
				before = before
			
		sub("^[^<]*<", "", remain);
		printf("remain: %s\n", remain);
		printf("before: %s\n", before);
		continue;
		########
	
		
		printf("remain: %s\n", remain);

		if (in_section("!--", "--") ||
		    in_section("!", "") ||
		    in_section("?", "?"))
			continue;

		tag = remain;
		sub("[ \t\n\r][ \t\n\r]*.*$", "", tag);
		printf("tag: %s\n", tag);
		if (substr(tag, 1, 1) == "/") {
			tag = substr(tag, 2);
			printf("tag: %s\n", tag);
			printf("ptag: %s\n", ptag);
			sli = index(ptag, "/");
			while (sli > 1 && substr(ptag, 1, sli - 1) != tag) {
				ptag = substr(ptag, sli + 1);
				printf("ptag: %s\n", ptag);
				sli = index(ptag, "/");
			}
			if (sli > 1) {
				if (before !~ "^[ \t\n\r]*$")
					printf("%s\n", before);
				printf("TAG_ED: %s\n", ptag);
				ptag = substr(ptag, sli + 1);
			} else {
				printf("no match\n");
				exit;
			}
		} else {
			if (tag != "")
				ptag = tag "/" ptag;
			printf("TAG_BG: %s\n", ptag);
		}
		
		sub("[^ \t\n\r][^ \t\n\r]*[ \t\n\r]*", "", remain);
		printf("remain: %s\n", remain);
		#system("echo " remain " | od -a -b");
		if (remain == "") {
			printf("continue\n");
			continue;
		}

		while (remain != "") {
			if (remain ~ /[A-Za-z][^"]*=[ \t\n\r]*"/) {
				att = remain;
				sub("[ \t\n\r]*=.*$", "", att);
				#printf("att: %s\n", att);
				remain = substr(remain, index(remain, "\"") + 1);
				#printf("remain: %s\n", remain);

				rqd = index(remain, "\"");
				while (rqd == 0) {
					if (getline)
						remain = remain ">" $0;
					else
						exit;
					rqd = index(remain, "\"");
				}
				quo = substr(remain, 1, rqd - 1);
				printf("  TAG_AT: %s='%s'\n", att, quo);
				sub(/[^"]*"[ \t\n\r]*/, "", remain);
				#printf("remain: %s\n", remain);
			} else if (remain ~ /[A-Za-z][^']*=[ \t\n\r]*'/) {
				att = remain;
				sub("[ \t\n\r]*=.*$", "", att);
				#printf("att: %s\n", att);
				remain = substr(remain, index(remain, "'") + 1);
				#printf("remain: %s\n", remain);

				rqd = index(remain, "'");
				while (rqd == 0) {
					if (getline)
						remain = remain ">" $0;
					else
						exit;
					rqd = index(remain, "'");
				}
				quo = substr(remain, 1, rqd - 1);
				printf("  TAG_AT: %s='%s'\n", att, quo);
				sub(/[^']*'[ \t\n\r]*/, "", remain);
				#printf("remain: %s\n", remain);
			} else {
				remain = "";
				#printf("why\n");
			}
		}
	}
	printf("EOF\n");
}

