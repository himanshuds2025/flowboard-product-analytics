with user_activation as (
    select
        u.user_id,
        u.acquisition_channel,
        a.activated_d7,
        a.time_to_activate_days
    from {{ ref('stg_users') }} u
    left join {{ ref('int_user_activation') }} a
        on u.user_id = a.user_id
),

activation_metrics as (
    select
        acquisition_channel,

        count(*) as total_signups,

        countif(activated_d7 is not null) as d7_observable_users,
        countif(activated_d7 is true) as activated_d7_users,
        countif(activated_d7 is false) as not_activated_d7_users,

        countif(time_to_activate_days is not null)
            as users_with_observed_activation_time,

        avg(time_to_activate_days) as avg_time_to_activate_days,

        approx_quantiles(time_to_activate_days, 100)[offset(50)]
            as median_time_to_activate_days,

        approx_quantiles(time_to_activate_days, 100)[offset(90)]
            as p90_time_to_activate_days,

        countif(time_to_activate_days < 1) as under_1_day,
        countif(time_to_activate_days >= 1 and time_to_activate_days < 3) as days_1_to_3,
        countif(time_to_activate_days >= 3 and time_to_activate_days < 7) as days_3_to_7,
        countif(time_to_activate_days >= 7 and time_to_activate_days < 14) as days_7_to_14,
        countif(time_to_activate_days >= 14 and time_to_activate_days < 31) as days_14_to_31,
        countif(time_to_activate_days >= 31) as days_31_plus

    from user_activation
    group by 1
)

select
    *,

    round(
        safe_divide(activated_d7_users, d7_observable_users) * 100,
        2
    ) as d7_activation_rate_pct,

    round(safe_divide(under_1_day, users_with_observed_activation_time) * 100, 2)
        as under_1_day_pct,

    round(safe_divide(days_1_to_3, users_with_observed_activation_time) * 100, 2)
        as days_1_to_3_pct,

    round(safe_divide(days_3_to_7, users_with_observed_activation_time) * 100, 2)
        as days_3_to_7_pct,

    round(safe_divide(days_7_to_14, users_with_observed_activation_time) * 100, 2)
        as days_7_to_14_pct,

    round(safe_divide(days_14_to_31, users_with_observed_activation_time) * 100, 2)
        as days_14_to_31_pct,

    round(safe_divide(days_31_plus, users_with_observed_activation_time) * 100, 2)
        as days_31_plus_pct

from activation_metrics