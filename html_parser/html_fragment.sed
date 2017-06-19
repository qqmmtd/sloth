#n
/^[ \t]*<!--/{
:nc
	/-->/!{
		N
		b nc
	}
	s/\n/@HTML_END/g
	s/-->\(.\)/-->@HTML_SEP\n\1/1
	P
	D
}
/^[ \t]*</{
:nt
	/>/!{
		N
		b nt
	}
	s/\n/@HTML_END/g
	s/>\(.\)/>@HTML_SEP\n\1/1
	P
	D
}
/</{
	s/</@HTML_SEP\n&/1
	P
	D
}
p
