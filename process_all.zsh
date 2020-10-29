#!/usr/bin/env zsh
set -euo pipefail

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM


mkdir -p "Reddit Data"

function run {
    EXT_S="$1"
    EXT_C="$2"
    V2="$3"

    FNAME="$4"
    REMAINDER="$5"

    wget "https://files.pushshift.io/reddit/submissions/RS_$V2$FNAME.$EXT_S" -O "Reddit Data/RS_$FNAME.$EXT_S"
    wget "https://files.pushshift.io/reddit/comments/RC_$FNAME.$EXT_C" -O "Reddit Data/RC_$FNAME.$EXT_C"
    zsh decompress.zsh "$EXT_S" "$EXT_C" "$FNAME" "$REMAINDER"
    python3 format_threads.py "$FNAME"
    rm "R_$FNAME".lines "R_$REMAINDER.remainder.lines"
}

touch R_empty.remainder.lines

DATES=(empty 2019-{12..01} 2018-{12..11})
for i ({1..$((${#DATES[@]}-1))}) run zst zst "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2018-{11..10})
for i ({1..$((${#DATES[@]}-1))}) run xz zst "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2018-{10..01} 2017-12)
for i ({1..$((${#DATES[@]}-1))}) run xz xz "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2017-{12..11})
for i ({1..$((${#DATES[@]}-1))}) run xz bz2 "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2017-{11..01})
for i ({1..$((${#DATES[@]}-1))}) run bz2 bz2 "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2017-01 2016-{12..01} 2015-{12..01})
for i ({1..$((${#DATES[@]}-1))}) run zst bz2 "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2015-01 2014-{12..01} 2013-{12..01} 2012-{12..01} 2011-{12..01})
for i ({1..$((${#DATES[@]}-1))}) run bz2 bz2 "" "$DATES[$i+1]" "$DATES[$i]"

DATES=(2011-01 2010-{12..01} 2009-{12..01} 2008-{12..01} 2007-{12..01} 2006-{12..01} 2005-12)
for i ({1..$((${#DATES[@]}-1))}) run xz bz2 "v2_" "$DATES[$i+1]" "$DATES[$i]"
