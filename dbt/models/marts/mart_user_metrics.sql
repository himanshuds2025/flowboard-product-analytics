with users as (
    select
    user_id,
    workspace_id,
    signup_timestamp,
    acquisition_channel,
    country,
    device_type,
    platform,
    industry,
    company_size,
    role,
    signup_plan
    from {{ ref('stg_users')}}
),

activation as (
    select
    user_id,
    first_task_completed_at as activation_first_task_completed_at,
    activated_d7,
    time_to_activate_days
    from {{ref('int_user_activation')}}
),

funnel as (
    select
    user_id,
    signup_completed_at,
    first_project_created_at,
    first_task_created_at,
    first_task_completed_at
    from {{ref('int_funnel_steps')}}
),

activity as (
    select
    user_id,
    count(*) as active_days,
    sum(activity_event_count) as total_activity_events,
    min(first_activity_at) as first_meaningful_activity_at,
    max(last_activity_at) as last_meaningful_activity_at
    from {{ref('int_user_activity_daily')}}
    group by 1
),

sessions as (
    select
    user_id,
    count(*) as total_sessions,
    count(distinct session_date_utc) as session_days,
    sum(session_duration_seconds) as total_session_duration_seconds,
    avg(session_duration_seconds) as avg_session_duration_seconds,
    min(session_start) as first_session_at,
    max(session_end) as last_session_end_at
    from {{ref('int_session_metrics')}}
    group by 1
)

select
    -- user attributes
    u.user_id,
    u.workspace_id,
    u.signup_timestamp,
    u.acquisition_channel,
    u.country,
    u.device_type,
    u.platform,
    u.industry,
    u.company_size,
    u.role,
    u.signup_plan,

    -- activation metrics
    a.activation_first_task_completed_at,
    a.activated_d7,
    a.time_to_activate_days,

    -- funnel metrics
    f.signup_completed_at,
    f.first_project_created_at,
    f.first_task_created_at,
    f.first_task_completed_at,

    -- meaningful activity metrics
    coalesce(act.active_days, 0) as active_days,
    coalesce(act.total_activity_events, 0) as total_activity_events,
    act.first_meaningful_activity_at,
    act.last_meaningful_activity_at,

    -- session metrics
    coalesce(s.total_sessions, 0) as total_sessions,
    coalesce(s.session_days, 0) as session_days,
    coalesce(s.total_session_duration_seconds, 0) as total_session_duration_seconds,
    s.avg_session_duration_seconds,
    s.first_session_at,
    s.last_session_end_at
from users u 
left join activation a on u.user_id = a.user_id
left join funnel f on u.user_id = f.user_id
left join activity act on u.user_id = act.user_id
left join sessions s on u.user_id = s.user_id
