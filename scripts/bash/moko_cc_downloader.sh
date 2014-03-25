#! /bin/bash 
#
# Automatically generated by gen_bash_script v1.0
#
# moko_cc_downloader - download jpgs from moko.cc
#
# Copyright (C) 2011 by Zhh
#
# Usage:
#           moko_cc_downloader LINK|FILE
#
#   @LINK: format http://*.moko.cc/*
#   @FILE: file contains LINKs, one LINK each line
#
# Return:
#   0: success
#   1: miss argument or argument unavailable
#   2: file exists or can not be created

# Download jpgs in all moko_cc.jpg.list under DIR
# usage: do_list_jpg DIR
do_list_jpg() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo "$TAG: $1"
	[[ ! -d $1 ]] && return 1

	local prefix=
	local iter=

	for iter in $(find "$1" -type f -name 'moko_cc.jpg.list'); {
		prefix=${iter%/moko_cc.jpg.list}
		$DBG && echo "$TAG: $_prefix"
		$WGET -i "$iter" -P "$prefix"
		mv "$iter" "$iter".done
	}
	
	return $?
}

# Generate moko_cc.jpg.list by HTMLFILE
# gen_list_jpg HTMLFILE
gen_list_jpg() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo "$TAG: $1"
	[[ ! -f $1 ]] && return 1
	
	local prefix="${1%.html}"
	[[ -d $prefix ]] && return 0
	
	mkdir -vp "$prefix"
	local title=$(sed -n '/blog_content/ s;.*>\(.*\)<.*;\1; p' "$1")
	$DBG && echo "$TAG: $title"
	echo "$title" > "$prefix"/title
	local jpglist=$(sed -n -e '/thumb/d' -e '/sTitle/,/formatImages/ s;.*\(http.*jpg\).*;\1;g p' "$1")
	$DBG && echo "$TAG: $jpglist"
	echo "$jpglist" > "$prefix"/moko_cc.jpg.list

	return $?
}

# Download posts in all moko_cc.post.list under DIR
# usage: do_list_post DIR
do_list_post() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo "$TAG: $1"
	[[ ! -d "$1" ]] && return 1
	
	local prefix=
	local iter=
	
	for iter in $(find "$1" -type f -name 'moko_cc.post.list'); {
		prefix=${iter%/moko_cc.post.list}
		$DBG && echo "$TAG: $_prefix"
		$WGET -i "$iter" -P "$prefix"
	}
	
	return $?
}

# Generate moko_cc.post.list by all htmlfile under DIR
# gen_list_jpg DIR
gen_list_post() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo "$TAG: $1"
	[[ ! -d "$1" ]] && return 1
	
	local postlists=$(sed -n '/VIEW MORE/ s;.*href="\(.*html\).*;http://www\.moko\.cc\1; p' "$1"/*.html)
	$DBG && echo "$TAG: $postlists"
	echo "$postlists" > "$1"/moko_cc.post.list
	
	return $?
}


gen_list_class() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo $TAG: "$1"
	[[ -d "$1" ]] || return 1
	
	local _classlist=
	
	_classlist=$(grep '<p class="title">' "$1"/indexpost.html | cut -d\" -f8 | sed 's;^;http://www\.moko\.cc;')
	$DBG && echo $TAG: "$_classlist"
	echo "$_classlist" > "$1"/moko_cc.class.list
	
	return $?
}

do_class() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo $TAG: "$1"
	[[ -d "$1" ]] || return 1

	local _classtitle=
	local _pagenum=
	local _page=
	
	_classtitle=$(grep 'class="title"' "$1"/postclass.html | cut -d\" -f6)
	$DBG && echo $TAG: "$_classtitle"
	echo "$_classtitle" > "$1"/classtitle
	_pagenum=$(grep 'class="page"' "$1"/postclass.html | sed 's;postclass;\n;g' | wc -l)
	for ((_page=2; _page<_pagenum; _page++)); {
		$DBG && echo $TAG: "wget -nv -c http://www.moko.cc/post/$1/$_page/postclass.html"
		wget -nv -c http://www.moko.cc/post/$1/$_page/postclass.html -O "$1/postclass$_page".html
	}

	return $?
}

do_list_class() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo $TAG: "$1"
	[[ -n "$1" ]] || return 1
	
	local _post=
	local _prefix=
	
	_prefix=$(echo "${1##*moko.cc/post/}" | cut -d/ -f-2)
	$DBG && echo $TAG: "$_prefix"
	wget -nv -c "$1" -P "$_prefix"
	do_class "$_prefix"
	gen_list_post "$_prefix"
	do_list_post "$_prefix"
	for _post in $(cat "$_prefix"/moko_cc.post.list); {
		gen_list_jpg "$_prefix/${_post##*/}"
	}

	return $?
}

clean_html() {

	local DBG=false
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	$DBG && echo $TAG: "$1"
	[[ -d "$1" ]] || return 1
	
	echo -n "$TAG: clean html..."
	$DBG && find "$1" -type f -name '*.html'
	$DBG || find "$1" -type f -name '*.html' -print0 | xargs -0 rm -f
	echo -e "\033[3D, done."
	
	return $?
}

# Download jpgs from moko.cc
# usage: moko_cc_downloader LINK|FILE
moko_cc_downloader() {

	# Debug switcher & local TAG
	# example: $DBG && echo $TAG:...
	local DBG=true
	local TAG=${TAG:-${FUNCNAME[0]}}

	[[ $1 == --* ]] && { 
		echo "$PRO: version $VER"
		echo "$PRO: $PRO LINK|FILE"
		return 0
	}
	
	[[ -n "$1" ]] || return 1 

	local _links=
	local _link=
	local _prefix=
	local _pagenum=
	local _page=
	local _post=
	local _class=
	
	if [[ -f "$1" ]]; then
		_links=$(cat "$1")
	else
		_links=$1
	fi

	for _link in $_links
	do
		$DBG && echo $TAG: "$_link"
		echo "$_link" | grep 'moko.cc/' > /dev/null || continue
		
		if echo "$_link" | grep 'postclass.html' > /dev/null; then
			do_list_class "$_link"
		elif echo "$_link" | grep '/post/' > /dev/null; then
			_prefix=$(echo "$_link" | sed -e 's;^.*moko.cc/post/;;' -e 's;/1/;/;' -e 's;\.html$;;')
			$DBG && echo $TAG: "$_prefix"
			wget -nv -c "$_link" -P "${_prefix%/*}"
			gen_list_jpg "$_prefix".html
		else
			_prefix=$(echo "${_link##*moko.cc/}" | cut -d/ -f1)
			$DBG && echo $TAG: "$_prefix"
			wget -nv -c http://www.moko.cc/post/"$_prefix"/indexpost.html -P "$_prefix"
			if [[ -n $(grep 'class="page"' "$_prefix"/indexpost.html) ]]; then
				_pagenum=$(sed -n '/indexpage/ s;indexpage;\n;g p' "$_prefix"/indexpost.html | wc -l)
				$DBG && echo $TAG: "$_pagenum"
				_page=2
				while [[ $_page -lt $_pagenum ]]
				do
					wget -nv -c http://www.moko.cc/post/"$_prefix"/indexpage/"$_page".html -P "$_prefix"
					_page=$((_page+1))
				done
				gen_list_post "$_prefix"
				do_list_post "$_prefix"
				for _post in $(cat "$_prefix"/moko_cc.post.list)
				do
					gen_list_jpg "$_prefix/${_post##*/}"
				done
			else
				gen_list_class "$_prefix"
				for _class in $(cat "$_prefix"/moko_cc.class.list)
				do
					do_list_class "$_class"
				done
			fi
		fi
	done
	
	do_list_jpg .
	clean_html .
	
	return $?
}

# Script can be used as a program or a function
if echo $0 | grep -v -E '^[-]?bash' &> /dev/null; then

	# Global VARs
	PRO=$(basename "$0")
	VER=1.0
	TAG=$PRO
	WGET='wget -c -nv'

	# Main
	moko_cc_downloader "$@"
fi
