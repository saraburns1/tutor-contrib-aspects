select
    watched_segments.org as org,
    watched_segments.course_key as course_key,
    watched_segments.block_id as block_id,
    watched_segments.watched_segment as segment_start,
    watched_segments.watch_count as watched_count,
    formatDateTime(
        toDate(now()) + toIntervalSecond(watched_segments.watched_segment), '%T'
    ) as time_stamp,
    users.username as username,
    users.name as name,
    users.email as email
from {{ DBT_PROFILE_TARGET_DATABASE }}.fact_video_segments watched_segments
left outer join
    {{ ASPECTS_EVENT_SINK_DATABASE }}.user_pii users
    on (watched_segments.actor_id like 'mailto:%' and SUBSTRING(actor_id, 8) = users.email)
    or watched_segments.actor_id = toString(users.external_user_id)
where 1 = 1 {% include 'openedx-assets/queries/common_filters.sql' %}
