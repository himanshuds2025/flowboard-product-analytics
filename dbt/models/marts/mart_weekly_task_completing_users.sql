with date_bounds as (
    select
        date(min(event_at), 'UTC') as first_observed_date,
        date(max(event_at), 'UTC') as latest_observed_date
    from {{ ref('stg_events') }}
    where event_at is not null
),

weeks as (
    select
        week_start_date,
        date_add(week_start_date, interval 6 day) as week_end_date,
        first_observed_date,
        latest_observed_date
    from date_bounds
    cross join unnest(
        generate_date_array(
            date_trunc(first_observed_date, week(monday)),
            date_trunc(latest_observed_date, week(monday)),
            interval 7 day
        )
    ) as week_start_date
),

weekly_metrics as (
    select
        date_trunc(activity_date, week(monday)) as week_start_date,

        count(distinct case
            when task_completion_event_count > 0 then user_id
        end) as weekly_task_completing_users,

        sum(task_completion_event_count) as task_completion_events

    from {{ ref('int_user_activity_daily') }}
    group by 1
)

select
    w.week_start_date,
    w.week_end_date,

    coalesce(m.weekly_task_completing_users, 0)
        as weekly_task_completing_users,

    coalesce(m.task_completion_events, 0)
        as task_completion_events,

    w.week_start_date >= w.first_observed_date
    and w.week_end_date <= w.latest_observed_date
        as is_complete_week

from weeks w

left join weekly_metrics m
    on w.week_start_date = m.week_start_date