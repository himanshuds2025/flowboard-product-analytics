# Flowboard Product Analytics
## Metric Definitions

---

## 1. Measurement Standards

| Standard | Definition |
|---|---|
| Timezone | UTC |
| User identifier | `user_id` |
| Counting method | Distinct users |
| Signup cohort | Calendar month of signup |
| Activity source | `int_user_activity_daily` |
| Activation event | `task_completed` |
| Retention method | Exact calendar-day activity |

Count users rather than raw event rows unless a metric specifically measures events.

## 2. North Star Metric

### Weekly Task-Completing Users (WTCU)

**Definition:** Number of distinct users who complete at least one task during a calendar week.

| Component | Definition |
|---|---|
| Measure | Distinct users |
| Event | `task_completed` |
| Time window | Monday to Sunday |
| Timezone | UTC |
| Counting rule | Each user counts once per week |

Task completion is the available behavioural indicator most closely associated with users receiving practical value from Flowboard.

**Limitation:** Task completion does not establish task quality or business impact.

## 3. Input Metrics

| Metric | Numerator | Denominator |
|---|---|---|
| D7 Activation Rate | Users completing their first task within 7 days | Eligible signups |
| Signup Completion Rate | Users completing signup | Total signups |
| Project Creation Conversion | Users creating a project | Users completing signup |
| Task Creation Conversion | Users creating a task | Users creating a project |
| Task Completion Conversion | Users completing a task | Users creating a task |

**Funnel ordering:**

1. Signup before signup completion.
2. Signup completion before project creation.
3. Project creation before task creation.
4. Task creation before task completion.

**Limitation:** The current funnel establishes event ordering at user level. It does not verify that the completed task is the same task previously created.

## 4. Guardrail Metrics

### Retention

| Metric | Numerator | Denominator | Measurement window |
|---|---|---|---|
| D7 Retention | Users with meaningful activity on day 7 | Eligible signups | Exact day 7 |
| D30 Retention | Users with meaningful activity on day 30 | Eligible signups | Exact day 30 |

Meaningful activity is defined by the event list in `int_user_activity_daily`.

### Activation Time

| Metric | Purpose |
|---|---|
| Median time to activation | Typical time taken to activate |
| P90 time to activation | Time within which 90% of observed activators complete their first task |

These measures help track whether users are taking longer to experience product value.

## 5. Activation Definition

A user is considered activated when they complete their first task within seven days after signup.

**Condition:**

`signup_timestamp <= first_task_completed_at < signup_timestamp + 7 days`

| Rule | Treatment |
|---|---|
| First task completed after signup | Eligible |
| Completion before signup | Excluded |
| Completion exactly 7 days after signup | Excluded |
| No qualifying task completion | Not activated |
| Insufficient observation time | Not classified as non-activated |

**Activation event:** `task_completed`

This is the project's operational definition of activation.

## 6. Retention Definition

Retention measures whether users return and perform meaningful product activity on a specific calendar day.

| Metric | Definition |
|---|---|
| D1 | Activity on signup date + 1 day |
| D7 | Activity on signup date + 7 days |
| D30 | Activity on signup date + 30 days |

**Measurement rules:**
- Use UTC calendar dates.
- Count distinct users.
- Measure activity on the exact day.
- Do not count activity anywhere within the period as retention.

## 7. Experiment Outcome Definitions

All experiment comparisons use assigned users as their treatment and control groups.

### EXP001: Onboarding Redesign

| Component | Definition |
|---|---|
| Control | `old_onboarding` |
| Treatment | `new_onboarding` |
| Outcome | At least one `onboarding_step_completed` event |
| Measurement window | 7 days after assignment |

### EXP002: Collaboration Prompt

| Component | Definition |
|---|---|
| Control | `no_prompt` |
| Treatment | `prompt_shown` |
| Outcome 1 | At least one `invite_sent` event |
| Outcome 2 | At least one `invite_accepted` event |
| Measurement window | 7 days after assignment |

**Common measurement rules:**

| Component | Definition |
|---|---|
| Numerator | Distinct assigned users with at least one qualifying event |
| Denominator | All users assigned to the relevant variant |
| Start boundary | Strictly after assignment |
| End boundary | Strictly before assignment timestamp + 7 days |

Comparisons are based on assigned variants, not confirmed exposure.

Actual exposure and randomized assignment have not yet been independently verified.

## 8. Supporting Metrics

### Time to Activation

Elapsed time between signup and the first qualifying task completion.

| Metric | Purpose |
|---|---|
| Average | Mean time to activation |
| Median | Typical time to activation |
| P90 | Time taken by 90% of observed activators |
| Activation buckets | Distribution across time ranges |

**Activation buckets:**

- Under 1 day
- 1 to 3 days
- 3 to 7 days
- 7 to 14 days
- 14 to 31 days
- 31+ days

These statistics include only users with an observed task completion.

## 9. Measurement Limitations

| Area | Limitation |
|---|---|
| North Star | Task completion does not measure task quality or business outcomes |
| Funnel | Event ordering is user-level, not task-object-level |
| Experiments | Assignment does not prove actual exposure |
| Randomization | Random assignment has not been verified |
| Subscription | Cancellation has not been included because its measurement definition has not been validated |
| Timezone | Calendar-based measurements use UTC |