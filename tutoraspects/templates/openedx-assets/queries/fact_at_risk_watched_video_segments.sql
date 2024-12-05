{% include 'openedx-assets/queries/fact_watched_video_segments.sql' %}
join {{ DBT_PROFILE_TARGET_DATABASE }}.at_risk_learners using (org, course_key, actor_id)