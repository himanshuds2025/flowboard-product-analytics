with users as (
    select 
    u.user_id,
    u.acquisition_channel,
    u.signup_timestamp
    from {{ ref('stg_users') }} as u
),

signup_stage as (
    select 
    u.user_id,
    min(e.event_at) as signup_completed_at
    from users u
left join {{ ref('stg_events') }} as e 
on u.user_id = e.user_id
and e.event_name = 'signup_completed'
and e.event_at >= u.signup_timestamp
group by 1
),

project_stage as (
    select
    s.user_id,
    s.signup_completed_at,
    min(e.event_at) as first_project_created_at
    from signup_stage s
    left join {{ ref('stg_events') }} as e 
    on s.user_id = e.user_id
    and e.event_name = 'project_created'
    and e.event_at >= s.signup_completed_at
group by 1, 2 
),

task_created_stage as (
    select
    p.user_id,
    p.signup_completed_at,
    p.first_project_created_at,
    min(e.event_at) as first_task_created_at
    from project_stage p
    left join {{ ref('stg_events') }} as e 
    on p.user_id = e.user_id
    and e.event_name = 'task_created'
    and e.event_at >= p.first_project_created_at
    group by 1, 2, 3
),

task_completed_stage as (
    select
    t.user_id,
    t.signup_completed_at,
    t.first_project_created_at,
    t.first_task_created_at,
    min(e.event_at) as first_task_completed_at
    from task_created_stage t
    left join {{ ref('stg_events')}} as e 
    on t.user_id = e.user_id
    and e.event_name = 'task_completed'
    and e.event_at >= t.first_task_created_at
    group by 1,2, 3, 4
)

select 
    u.user_id,
    u.acquisition_channel,
    u.signup_timestamp,
    f.signup_completed_at,
    f.first_project_created_at,
    f.first_task_created_at,
    f.first_task_completed_at
from users u
left join task_completed_stage as f 
on u.user_id = f.user_id
