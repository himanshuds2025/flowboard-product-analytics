WITH users AS (
    SELECT
        user_id,
        signup_timestamp
    FROM {{ ref('stg_users') }}
),

task_completion_events AS (
    SELECT
        user_id,
        event_at
    FROM {{ ref('stg_events') }}
    WHERE event_name = 'task_completed'
),

user_first_task_completion AS (
    SELECT
        u.user_id,
        u.signup_timestamp,
        MIN(e.event_at) AS first_task_completed_at

    FROM users AS u

    LEFT JOIN task_completion_events AS e
        ON u.user_id = e.user_id
        AND e.event_at >= u.signup_timestamp

    GROUP BY
        u.user_id,
        u.signup_timestamp
),

data_observation AS (
    SELECT MAX(event_at) AS data_through_timestamp
    FROM {{ ref('stg_events') }}
)

SELECT
    a.user_id,
    a.signup_timestamp,
    a.first_task_completed_at,

    CASE
        WHEN TIMESTAMP_ADD(a.signup_timestamp, INTERVAL 7 DAY)
             > d.data_through_timestamp THEN NULL
        WHEN a.first_task_completed_at <
             TIMESTAMP_ADD(a.signup_timestamp, INTERVAL 7 DAY)
             THEN TRUE
        ELSE FALSE
    END AS activated_d7,

    CASE
        WHEN a.first_task_completed_at IS NOT NULL
        THEN SAFE_DIVIDE(
            TIMESTAMP_DIFF(
                a.first_task_completed_at,
                a.signup_timestamp,
                SECOND
            ),
            86400.0
        )
    END AS time_to_activate_days

FROM user_first_task_completion AS a
CROSS JOIN data_observation AS d