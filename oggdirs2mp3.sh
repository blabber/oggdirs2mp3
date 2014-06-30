#!/bin/sh

# "THE BEER-WARE LICENSE" (Revision 42):
# <tobias.rehbein@web.de> wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff. If we meet some day, and you
# think this stuff is worth it, you can buy me a beer in return.
#                                                              Tobias Rehbein

check_executables() {
	local _exec
	for _exec in "$@"; do
		if ! which "$_exec" >/dev/null 2>&1; then
			printf "E: \"%s\" not in PATH. Abort.\n" "$_exec" >&2
			exit 1
		fi
	done
}

normalize_path() {
	echo "$@" | sed -E 's:/+:/:g'
}

check_executables ogg2mp3 mp3gain

MP3GAIN_FLAGS='-r -k -d 9'
OUTBASE='.'
DO_GAIN=false

while getopts 'd:g' OPT; do
	case $OPT in
	'd')	OUTBASE="$OPTARG"
		;;
	'g')	DO_GAIN=true
		;;
	esac
done
shift $(($OPTIND-1))

if [ ! -d "$OUTBASE" ]; then
	printf "E: directory \"%s\" not found. Abort.\n" "$OUTBASE" >&2
	exit 1
fi

for DIR in "$@"; do
	if [ ! -d "$DIR" ]; then
		printf "W: directory \"%s\" not found. Skip.\n" "$DIR" >&2
		continue
	fi

	OUTPATH=$(normalize_path "$OUTBASE/$DIR")
	mkdir -m 755 -p "$OUTPATH"

	for FILE in "$DIR"/*.ogg; do
		OGG=$(basename "$FILE")
		OGGPATH=$(normalize_path "$OUTPATH/$OGG")

		MP3="${OGG%%.ogg}.mp3"
		MP3PATH=$(normalize_path "$OUTPATH/$MP3")

		cp "$FILE" "$OUTPATH"
		chmod 644 "$OGGPATH"
		( cd "$OUTPATH" &&
			ogg2mp3 --delete "$OGG" &&
			$DO_GAIN &&
			mp3gain $MP3GAIN_FLAGS "$MP3" )
	done

done
