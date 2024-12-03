{% include 'openedx-assets/queries/course_key_from_filters.sql' %}
select watches.*
from
    {{ DBT_PROFILE_TARGET_DATABASE }}.fact_watched_video_segments(
        {% raw -%}org_filter = coalesce({{ filter_values("org") }}, []),
        course_key_filter = coalesce(
            (select array_concat_agg(course_key) from course_keys), []
        ) {%- endraw %}
    ) watches
join
    (
        {% include 'openedx-assets/queries/at_risk_learner_filter.sql' %}
    ) as at_risk_learners using (org, course_key, actor_id)
where 1 = 1 {% include 'openedx-assets/queries/common_filters.sql' %}
