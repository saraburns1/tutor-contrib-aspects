select
    org,
    course_key,
    success,
    attempt,
    actor_id,
    problem_number,
    problem_name_location,
    block_id_short as block_id
from {{ DBT_PROFILE_TARGET_DATABASE }}.dim_problem_results
