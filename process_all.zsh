#!/usr/bin/env zsh
set -euo pipefail

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM


mkdir -p "Reddit Data"

function run {
    EXT="$1"
    FNAME="$2"
    REMAINDER="$3"
    echo wget "https://files.pushshift.io/reddit/comments/RS_$FNAME.$EXT" -O "Reddit Data/RS_$FNAME.$EXT"
    echo wget "https://files.pushshift.io/reddit/comments/RC_$FNAME.$EXT" -O "Reddit Data/RC_$FNAME.$EXT"
    echo zsh decompress.zsh zst "$FNAME" "$REMAINDER"
    echo python3 format_threads.py "$FNAME"
    echo rm "R_$FNAME".lines "R_$REMAINDER.remainder.lines"
}

touch R_empty.remainder.lines

DATES=(empty 2019-{12..1} 2018-{12..10})
echo ${#DATES[@]}
for i ({1..${#DATES[@]}-1}) run zst "$DATES[$i+1]" "$DATES[$i]"

DATES=(2018-10 2018-{9..1} 2017-12)
echo ${#DATES[@]}
for i ({1..${#DATES[@]}-1}) run xz "$DATES[$i+1]" "$DATES[$i]"

DATES=(2017-{12..1} 2016-{12..1} 2015-{12..1} 2014-{12..1} 2013-{12..1} 2012-{12..1} 2011-{12..1} 2010-{12..1} 2009-{12..1} 2008-{12..1} 2007-{12..1} 2006-{12..1} 2005-12)
echo ${#DATES[@]}
for i ({1..${#DATES[@]}-1}) run bz2 "$DATES[$i+1]" "$DATES[$i]"
