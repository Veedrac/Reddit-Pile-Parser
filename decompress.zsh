#!/usr/bin/env zsh
set -euo pipefail

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM


EXT_S="$1"
EXT_C="$2"

FNAME="$3"
REMAINDER="$4"

function decompress {
    case "$2" in
        zst) pzstd -d "$1.$2" --stdout ;;
        xz) xzcat "$1.$2" ;;
        bz2) bzcat "$1.$2" ;;
        *) echo "invalid extension $2" >&2; false ;;
    esac
}

SUMBISSIONS_JQ='[.subreddit,"t3_"+.id,.all_awardings,.allow_live_comments,.archived,.author,.author_created_utc,.author_flair_background_color,.author_flair_css_class,.author_flair_richtext,.author_flair_template_id,.author_flair_text,.author_flair_text_color,.author_flair_type,.author_fullname,.author_patreon_flair,.can_gild,.can_mod_post,.category,.content_categories,.contest_mode,.created_utc,.discussion_type,.distinguished,.domain,.edited,.event_end,.event_is_live,.event_start,.gilded,.gildings,.hidden,.is_crosspostable,.is_meta,.is_original_content,.is_reddit_media_domain,.is_robot_indexable,.is_self,.is_video,.link_flair_background_color,.link_flair_css_class,.link_flair_richtext,.link_flair_template_id,.link_flair_text,.link_flair_text_color,.link_flair_type,.locked,.media,.media_embed,.media_only,.no_follow,.num_comments,.num_crossposts,.over_18,.parent_whitelist_status,.permalink,.pinned,.post_hint,.preview,.pwls,.quarantine,.removal_reason,.retrieved_on,.score,.secure_media,.secure_media_embed,.selftext,.send_replies,.spoiler,.stickied,.subreddit_id,.subreddit_name_prefixed,.subreddit_subscribers,.subreddit_type,.suggested_sort,.thumbnail,.thumbnail_height,.thumbnail_width,.title,.total_awards_received,.url,.whitelist_status,.wls]'

COMMENTS_JQ='[.subreddit,.link_id,.parent_id,.all_awardings,.associated_award,.author,.author_created_utc,.author_flair_background_color,.author_flair_css_class,.author_flair_richtext,.author_flair_template_id,.author_flair_text,.author_flair_text_color,.author_flair_type,.author_fullname,.author_patreon_flair,.awarders,.body,.can_gild,.can_mod_post,.collapsed,.collapsed_reason,.controversiality,.created_utc,.distinguished,.edited,.gilded,.gildings,.id,.is_submitter,.locked,.no_follow,.permalink,.quarantined,.removal_reason,.retrieved_on,.score,.send_replies,.steward_reports,.stickied,.subreddit_id,.subreddit_name_prefixed,.subreddit_type,.total_awards_received]'

echo "Processing RS_$FNAME.$EXT_S → RS_$FNAME.lines"
decompress "Reddit Data/RS_$FNAME" "$EXT_S" | jq -c "$SUMBISSIONS_JQ" > "RS_$FNAME.lines" &

echo "Processing RC_$FNAME.$EXT_C → RC_$FNAME.lines"
decompress "Reddit Data/RC_$FNAME" "$EXT_C" | jq -c "$COMMENTS_JQ" > "RC_$FNAME.lines" &

wait

echo "Sorting RS_$FNAME.lines + RC_$FNAME.lines + R_$REMAINDER.remainder.lines → R_$FNAME.lines"
sort --parallel=4 -T . "RS_$FNAME.lines" "RC_$FNAME.lines" "R_$REMAINDER.remainder.lines" -o "R_$FNAME.lines"

echo "Removing RS_$FNAME.lines, RC_$FNAME.lines"
rm "RS_$FNAME.lines" "RC_$FNAME.lines"
