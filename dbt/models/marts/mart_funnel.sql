with user_funnel as (
    select
        user_id,
        acquisition_channel,
        signup_timestamp,
        signup_completed_at,
        first_project_created_at,
        first_task_created_at,
        first_task_completed_at
    from {{ ref('int_funnel_steps') }}
),

funnel_counts as (
    select
        acquisition_channel,
        count(*) as total_signups,
        countif(signup_completed_at is not null) as signup_completed_users,
        countif(first_project_created_at is not null) as project_created_users,
        countif(first_task_created_at is not null) as task_created_users,
        countif(first_task_completed_at is not null) as task_completed_users
    from user_funnel
    group by 1
)

select
    acquisition_channel,
    total_signups,

    signup_completed_users,
    total_signups - signup_completed_users as signup_completion_dropoff_users,
    round(safe_divide(signup_completed_users, total_signups) * 100, 2)
        as signup_completion_conversion_rate_pct,

    project_created_users,
    signup_completed_users - project_created_users as project_creation_dropoff_users,
    round(safe_divide(project_created_users, signup_completed_users) * 100, 2)
        as project_creation_conversion_rate_pct,

    task_created_users,
    project_created_users - task_created_users as task_creation_dropoff_users,
    round(safe_divide(task_created_users, project_created_users) * 100, 2)
        as task_creation_conversion_rate_pct,

    task_completed_users,
    task_created_users - task_completed_users as task_completion_dropoff_users,
    round(safe_divide(task_completed_users, task_created_users) * 100, 2)
        as task_completion_conversion_rate_pct,

    round(safe_divide(task_completed_users, total_signups) * 100, 2)
        as overall_signup_to_task_completion_rate_pct

from funnel_counts