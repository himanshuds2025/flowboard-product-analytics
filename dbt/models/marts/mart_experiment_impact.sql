with outcome_definitions as (
    select
        'EXP001' as experiment_id,
        'onboarding_step_completed' as outcome_event

    union all

    select
        'EXP002',
        'invite_sent'

    union all

    select
        'EXP002',
        'invite_accepted'
),

assignments as (
    select
        experiment_id,
        experiment_name,
        user_id,
        variant,
        assigned_at
    from {{ ref('int_experiment_assignment') }}
),

user_outcomes as (
    select
        a.experiment_id,
        a.experiment_name,
        a.variant,
        a.user_id,
        o.outcome_event,

        countif(e.event_at is not null) > 0 as converted_within_7d

    from assignments a

    inner join outcome_definitions o
        on a.experiment_id = o.experiment_id

    left join {{ ref('stg_events') }} e
        on a.user_id = e.user_id
        and e.event_name = o.outcome_event
        and e.event_at > a.assigned_at
        and e.event_at < timestamp_add(a.assigned_at, interval 7 day)

    group by 1, 2, 3, 4, 5
)

select
    experiment_id,
    experiment_name,
    variant,
    outcome_event,

    count(*) as assigned_users,

    countif(converted_within_7d) as users_with_outcome_7d,

    round(
        safe_divide(
            countif(converted_within_7d),
            count(*)
        ) * 100,
        2
    ) as outcome_rate_pct

from user_outcomes

group by 1, 2, 3, 4