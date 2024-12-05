{% include 'openedx-assets/queries/fact_video_plays.sql' %}
join {{ DBT_PROFILE_TARGET_DATABASE }}.at_risk_learners using (org, course_key, actor_id)
