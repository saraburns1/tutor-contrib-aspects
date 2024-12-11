{% raw -%}
with
    course_keys as (
        select [] as course_key
        {% if filter_values("course_name") != [] %}
            union all
            select array(course_key) as course_key
            from {% endraw -%} {{ ASPECTS_EVENT_SINK_DATABASE }}.course_names {% raw -%}
            where course_name in {{ filter_values("course_name") | where_in }}
        {% endif %}

        {% if filter_values("tag") != [] %}
            union distinct
            select array(course_key) as course_key
            from
                {% endraw -%} {{ DBT_PROFILE_TARGET_DATABASE }}.most_recent_course_tags {% raw -%}
            where
                tag
                in (select replaceAll(arrayJoin({{ filter_values("tag") }}), '- ', ''))
        {% endif %}
    ) {%- endraw %}