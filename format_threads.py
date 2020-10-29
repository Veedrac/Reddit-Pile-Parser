import datetime
import html
import itertools
import json
import sys

import lm_dataformat

SUBMISSION_KEYS = (
    "subreddit", "id", "all_awardings", "allow_live_comments", "archived", "author", "author_created_utc", "author_flair_background_color",
    "author_flair_css_class", "author_flair_richtext", "author_flair_template_id", "author_flair_text", "author_flair_text_color", "author_flair_type",
    "author_fullname", "author_patreon_flair", "can_gild", "can_mod_post", "category", "content_categories", "contest_mode", "created_utc",
    "discussion_type", "distinguished", "domain", "edited", "event_end", "event_is_live", "event_start", "gilded", "gildings", "hidden", "is_crosspostable",
    "is_meta", "is_original_content", "is_reddit_media_domain", "is_robot_indexable", "is_self", "is_video", "link_flair_background_color",
    "link_flair_css_class", "link_flair_richtext", "link_flair_template_id", "link_flair_text", "link_flair_text_color", "link_flair_type", "locked",
    "media", "media_embed", "media_only", "no_follow", "num_comments", "num_crossposts", "over_18", "parent_whitelist_status", "permalink", "pinned",
    "post_hint", "preview", "pwls", "quarantine", "removal_reason", "retrieved_on", "score", "secure_media", "secure_media_embed", "selftext", "send_replies",
    "spoiler", "stickied", "subreddit_id", "subreddit_name_prefixed", "subreddit_subscribers", "subreddit_type", "suggested_sort", "thumbnail",
    "thumbnail_height", "thumbnail_width", "title", "total_awards_received", "url", "whitelist_status", "wls",
)

COMMENT_KEYS = (
    "subreddit", "link_id", "parent_id", "all_awardings", "associated_award", "author", "author_created_utc", "author_flair_background_color",
    "author_flair_css_class", "author_flair_richtext", "author_flair_template_id", "author_flair_text", "author_flair_text_color", "author_flair_type",
    "author_fullname", "author_patreon_flair", "awarders", "body", "can_gild", "can_mod_post", "collapsed", "collapsed_reason", "controversiality",
    "created_utc", "distinguished", "edited", "gilded", "gildings", "id", "is_submitter", "locked", "no_follow", "permalink", "quarantined",
    "removal_reason", "retrieved_on", "score", "send_replies", "steward_reports", "stickied", "subreddit_id", "subreddit_name_prefixed",
    "subreddit_type", "total_awards_received"
)

def process_thread(thread):
    *comments, submission = sorted(thread, key=lambda post: post[0])
    comments

    if submission[0] != 0:
        # These comments are for an older submission
        return None

    submission = dict(zip(SUBMISSION_KEYS, submission[1:]))

    comments_by_parent = {}
    for comment in comments:
        comment = dict(zip(COMMENT_KEYS, comment[1:]))
        comments_by_parent.setdefault(comment["parent_id"], []).append(("t1_" + comment["id"], comment))

    id_queue = [(submission["id"], submission)]
    while id_queue:
        post_id, post = id_queue.pop()
        children = comments_by_parent.get(post_id, ())
        post["children"] = children
        id_queue.extend(children)

    return submission

fname = sys.argv[1]
print(f"Processing R_{fname}.lines → Processed/, RC_{fname}.remainder.lines")

output = lm_dataformat.Archive(f"Processed")
with open(f"R_{fname}.lines") as finput, \
     open(f"R_{fname}.remainder.lines", "w") as remainder:

    threads = itertools.groupby(
        ((json.loads(line), line) for line in finput),
        lambda jl: jl[0][1]
    )

    for _, thread in threads:
        thread, lines = zip(*thread)
        processed = process_thread(thread)

        if processed is None:
            for line in lines:
                remainder.write(line)
        else:
            output.add_data(processed)

output.commit()
