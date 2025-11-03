select
    watches.org as org,
    watches.course_key as course_key,
    watches.video_name_location as video_name_location,
    watches.video_link as video_link,
    watches.actor_id as actor_id,
    watches.video_watched_count as video_watched_count,
    watches.video_rewatched_count as video_rewatched_count,
    watches.watched_entire_video as watched_entire_video,
    watches.section_with_name as section_with_name,
    watches.subsection_with_name as subsection_with_name,
    users.username as username,
    users.email as email,
    users.name as name
from {{ DBT_PROFILE_TARGET_DATABASE }}.fact_video_watches watches
left outer join
    {{ ASPECTS_EVENT_SINK_DATABASE }}.user_pii users
    on (watches.actor_id like 'mailto:%' and SUBSTRING(watches.actor_id, 8) = users.email)
    or watches.actor_id = toString(users.external_user_id)
