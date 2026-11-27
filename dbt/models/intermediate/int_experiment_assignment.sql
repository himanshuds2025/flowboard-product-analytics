WITH assignments AS (
    SELECT
        experiment_id,
        experiment_name,
        user_id,
        variant,
        assigned_at
    FROM {{ ref('stg_experiments') }}
),

experiment_events AS (
    SELECT
        experiment_id,
        user_id,
        variant,
        event_at
    FROM {{ ref('stg_events') }}
    WHERE experiment_id IS NOT NULL
)

SELECT
    -- Assignment table is the primary source
    a.experiment_id,
    a.experiment_name,
    a.user_id,
    a.variant,
    a.assigned_at,

    -- Matching variant events strictly after assignment
    COUNTIF(
        e.variant = a.variant
        AND e.event_at > a.assigned_at
    ) AS matching_variant_events_after_assignment,

    -- Data-quality indicators
    COUNTIF(
        e.experiment_id IS NOT NULL
        AND e.variant IS DISTINCT FROM a.variant
    ) AS variant_mismatch_event_count,

    COUNTIF(
        e.experiment_id IS NOT NULL
        AND e.event_at < a.assigned_at
    ) AS pre_assignment_event_count,

    MIN(
        IF(
            e.variant = a.variant
            AND e.event_at > a.assigned_at,
            e.event_at,
            NULL
        )
    ) AS first_matching_event_at,

    MAX(
        IF(
            e.variant = a.variant
            AND e.event_at > a.assigned_at,
            e.event_at,
            NULL
        )
    ) AS last_matching_event_at

FROM assignments a

LEFT JOIN experiment_events e
    ON a.experiment_id = e.experiment_id
    AND a.user_id = e.user_id

GROUP BY
    a.experiment_id,
    a.experiment_name,
    a.user_id,
    a.variant,
    a.assigned_at