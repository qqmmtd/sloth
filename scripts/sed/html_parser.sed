#n
/^<!--/{
:nc
	/-->/!{
		N
		s/\n/@HTML_CR/1
		b nc
	}
	s/-->\(.\)/-->@HTML_SEP\n\1/1
	P
	D
}
/^<?/{
:nqm
	/?>/!{
		N
		s/\n/@HTML_CR/1
		b nqm
	}
	s/?>\(.\)/?>@HTML_SEP\n\1/1
	P
	D
}
/^<!/{
:nss
	/>/!{
		N
		s/\n/@HTML_CR/1
		b nss
	}
	s/>\(.\)/>@HTML_SEP\n\1/1
	P
	D
}
/^</{
:nes
	/^[^'"]*>/{
		s/>\(.\)/>@HTML_SEP\n\1/1
		P
		D
	}
	/^[^"']*=[ \t]*"/!b iflqs
	s/"/@HTML_QD/1
:nrqd
	/"/!{
		N
		s/\n/@HTML_CR/1
		b nrqd
	}
	s/"/@HTML_RQD/1
:rqs
	/'.*@HTML_RQD/{
		s/'\(.*@HTML_RQD\)/@HTML_QS\1/1
		b rqs
	}
:rrab
	/>.*@HTML_RQD/{
		s/>\(.*@HTML_RQD\)/@HTML_RAB\1/1
		b rrab
	}
	s/@HTML_RQD/@HTML_QD/1
	b nes
:iflqs
	/^[^"']*=[ \t]*'/!{
		N
		s/\n/@HTML_CR/1
		b nes
	}
	s/'/@HTML_QS/1
:nrqs
	/'/!{
		N
		s/\n/@HTML_CR/1
		b nrqs
	}
	s/'/@HTML_RQS/1
:rqd
	/".*@HTML_RQS/{
		s/"\(.*@HTML_RQS\)/@HTML_QD\1/1
		b rqd
	}
:rrab
	/>.*@HTML_RQS/{
		s/>\(.*@HTML_RQS\)/@HTML_RAB\1/1
		b rrab
	}
	s/@HTML_RQS/@HTML_QS/1
	b nes
}
/</{
	s//@HTML_SEP\n</1
	P
	D
}
p
