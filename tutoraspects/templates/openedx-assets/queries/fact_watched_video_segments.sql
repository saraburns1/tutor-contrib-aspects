{% include 'openedx-assets/queries/course_key_from_filters.sql' %}
select *
from
    {{ DBT_PROFILE_TARGET_DATABASE }}.fact_watched_video_segments(
        {% raw -%} org_filter = coalesce({{ filter_values("org") }}, []),
        course_key_filter = coalesce(
            (select array_concat_agg(course_key) from course_keys), []
        ) {%- endraw %}
    )
