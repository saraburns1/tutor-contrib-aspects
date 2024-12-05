with watches as ({% include 'openedx-assets/queries/fact_video_watches.sql' %})
select watches.*
from watches
join {{ DBT_PROFILE_TARGET_DATABASE }}.at_risk_learners using (org, course_key, actor_id)