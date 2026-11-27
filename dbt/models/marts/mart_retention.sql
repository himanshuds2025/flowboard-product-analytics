with cohort_users as (
    select
    u.user_id,
    date(u.signup_timestamp, 'UTC') as signup_date,
    date_trunc(date(u.signup_timestamp, 'UTC'), month) as signup_cohort_month,
    case
        when a.activated_d7 is true then 'activated_d7'
        when a.activated_d7 is false then 'not_activated_d7'
        else 'insufficient_observation'
    end as activation_status
    from {{ ref('stg_users') }} u
    left join {{ ref('int_user_activation') }} a
    on u.user_id = a.user_id
),

user_retention as (
    select
    c.user_id,
    c.signup_cohort_month,
    c.activation_status,
    countif(d.activity_date = date_add(c.signup_date, interval 1 day)) > 0 as retained_d1,
    countif(d.activity_date = date_add(c.signup_date, interval 7 day)) > 0 as retained_d7,
    countif(d.activity_date = date_add(c.signup_date, interval 30 day)) > 0 as retained_d30

    from cohort_users c
    left join {{ ref('int_user_activity_daily') }} d
    on d.user_id = c.user_id
    group by 1, 2, 3
)

select
    signup_cohort_month,
    activation_status,
    count(*) as cohort_users,

    countif(retained_d1) as d1_retained_users,
    round(safe_divide(countif(retained_d1), count(*)) * 100, 2) as d1_retention_rate,

    countif(retained_d7) as d7_retained_users,
    round(safe_divide(countif(retained_d7), count(*)) * 100, 2) as d7_retention_rate,

    countif(retained_d30) as d30_retained_users,
    round(safe_divide(countif(retained_d30), count(*)) * 100, 2) as d30_retention_rate

from user_retention
group by 1, 2