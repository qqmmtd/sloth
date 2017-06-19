#n
/^[ \t]*<[^!/?]/{
	s/^[ \t][ \t]*//
	s/"/'/g
	s/[ \t][ \t]*/@HTML_ATT/1
:lr
	s/'/@HTML_LQ/1
	s/=[ \t][ \t]*\(@HTML_LQ\)/=\1/1
	s/[ \t][ \t]*\(=@HTML_LQ\)/\1/1
	s/'/@HTML_RQ/1
	s/\(@HTML_RQ\)[ \t][ \t]*/\1 /1
	/'/b lr
	s/@HTML_LQ/'/g
	s/@HTML_RQ/'/g
	s/@HTML_ATT/ /1
}
s/@HTML_END//g
s/@HTML_SEP$//
p
