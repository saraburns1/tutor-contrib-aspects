with
    course_data as (
        select
            dim_course_blocks.org as org,
            dim_course_blocks.course_key as course_key,
            count(distinct dim_course_blocks.block_id) video_count,
            dim_course_names.course_name as course_name,
            dim_course_names.course_run as course_run
        from {{ DBT_PROFILE_TARGET_DATABASE }}.dim_course_blocks
        left join
            {{ ASPECTS_EVENT_SINK_DATABASE }}.dim_course_names
            on dim_course_blocks.org = dim_course_names.org
            and dim_course_blocks.course_key = dim_course_names.course_key
        where
            dim_course_blocks.block_type = 'video'
            {% include 'openedx-assets/queries/common_filters.sql' %}
        group by org, course_key, course_name, course_run
    ),
    segments as (
        select
            org,
            course_key,
            actor_id,
            block_id,
            object_id,
            segment_start,
            sum(watch_count) as watched_count,
            video_duration
        from {{ DBT_PROFILE_TARGET_DATABASE }}.fact_video_segments
        group by
            org,
            course_key,
            actor_id,
            object_id,
            block_id,
            watched_segment,
            video_duration
    ), final_results as (
    select
        if(course_data.org = '', segments.org, course_data.org) as org,
        if(
            course_data.course_key = '', segments.course_key, course_data.course_key
        ) as course_key,
        course_data.course_name,
        course_data.course_run,
        course_data.video_count,
        segments.object_id,
        segments.video_duration,
        if(
            segments.video_duration = 0, 0, count(distinct segments.segment_start)
        ) as segment_count,
        if(
            segments.video_duration = 0,
            0,
            count(
                distinct case
                    when segments.watched_count > 1 then segments.segment_start else 0
                end
            )
        ) as segment_count_rewatched,
        arrayStringConcat(
        arrayMap(
            x -> (leftPad(x, 2, char(917768))),
            splitByString(
                ':', splitByString(' - ', blocks.display_name_with_location)[1]
            )
        ),
        ':'
        ) as _object_location,
        concat(
            _object_location,
            ' - ',
            splitByString(' - ', blocks.display_name_with_location)[2]
        ) as video_name_location,
        segments.block_id
    from course_data
    full join segments on segments.course_key = course_data.course_key
    join
        {{ DBT_PROFILE_TARGET_DATABASE }}.dim_course_blocks blocks
        on (
            aggregate.course_key = blocks.course_key
            and aggregate.block_id = blocks.block_id
        )
    where 1 = 1 {% include 'openedx-assets/queries/common_filters.sql' %}
    group by
        org,
        course_key,
        course_name,
        course_run,
        video_count,
        object_id,
        video_duration,
        video_name_location,
        block_id
    )
    select 
        org,
        course_key,
        course_name,
        course_run,
        video_count,
        object_id,
        video_duration,
        segment_count,
        segment_count_rewatched,
        video_name_location,
        block_id
    from final_results