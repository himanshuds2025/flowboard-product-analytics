# Flowboard Product Analytics

An end-to-end product analytics project investigating user activation, engagement, retention, conversion, and experimentation for a fictional B2B SaaS collaboration platform.

## 1. Business Context

Flowboard is a fictional SaaS collaboration platform designed around workspaces, projects, tasks, and team collaboration.

The central business concern is that acquiring new users does not necessarily translate into sustained product usage. Users may complete signup but fail to create projects, create tasks, collaborate with teammates, or return to the product consistently.

This project investigates that problem through behavioural event data.

The objective is not simply to calculate product metrics. It is to identify where users drop off, understand which user characteristics and acquisition channels are associated with activation, examine retention patterns, evaluate product experiments, and translate the findings into product decisions.

## 2. Project Objectives

The analysis addresses five main questions:

1. **Activation:** How many users reach the activation milestone, how long does it take, and does activation vary across acquisition channels or user segments?
2. **Engagement:** How does product usage differ between activated and non-activated users?
3. **Retention:** Do activated users demonstrate stronger subsequent retention?
4. **Conversion:** Where does the largest drop-off occur between signup and meaningful product activity?
5. **Experimentation:** Did onboarding and collaboration changes produce measurable improvements in user behaviour?

A further objective is to establish a consistent product health metric that can be monitored over time.

## 3. Dataset

The project uses a synthetic B2B SaaS dataset containing five connected tables.

| Table | Rows | Purpose |
|---|---:|---|
| Events | 1,473,869 | User actions and product interactions |
| Sessions | 207,855 | Session activity and duration |
| Experiments | 70,926 | Experiment assignments and variants |
| Users | 50,000 | User attributes and acquisition information |
| Product changes | 5 | Product release and change records |

The dataset contains user attributes such as acquisition channel, company size, role, industry, device type, and signup information.

Event records capture behaviours including signup, onboarding, project creation, task creation and completion, invitations, subscriptions, and other product interactions.

The tables are connected through user, session, workspace, and experiment identifiers where applicable.

## 4. Technical Stack

- **SQL:** Analytical transformations and metric calculations
- **Python:** Data analysis and statistical evaluation
- **BigQuery:** Cloud data warehouse
- **dbt Core:** Data transformation, modelling, and testing
- **Pandas:** Data manipulation
- **Matplotlib:** Data visualization
- **Jupyter Notebook:** Exploratory and analytical workflow
- **Git and GitHub:** Version control and project documentation

## 5. Data Architecture

The project uses a layered dbt modelling structure.

### Staging

Raw source tables are standardized into staging models. This layer handles column selection, timestamp casting, and basic data preparation.

### Intermediate

Reusable behavioural logic is developed in intermediate models. This includes user activation, funnel progression, daily activity, session metrics, and experiment assignments.

### Marts

Final analytical models are built for specific business questions:

- User-level metrics
- Activation analysis
- Retention analysis
- Funnel conversion
- Experiment impact
- Weekly task-completing users

The separation between staging, intermediate, and marts keeps source cleanup, reusable logic, and business-facing outputs distinct.

The dbt project also includes data tests to validate model assumptions and data quality.

## 6. Analytical Approach

### Activation Analysis

Activation is defined as completing at least one task within seven days of signup.

The analysis examines:

- Overall D7 activation rate
- Time taken to activate
- Activation by acquisition channel
- Activation by company size, role, device type, and industry
- Statistical association between user attributes and activation

### Engagement Analysis

Activated and non-activated users are compared across:

- Active days
- Activity events
- Number of sessions
- Average session duration

This helps determine whether reaching the activation milestone is associated with differences in subsequent product usage.

### Retention Analysis

Retention is evaluated at D1, D7, and D30.

The analysis compares activated and non-activated user groups using eligible cohorts for each retention horizon.

### Funnel Analysis

The funnel tracks progression from signup completion to project creation and task creation.

It identifies conversion rates and the largest user drop-off between consecutive stages.

### North Star Metric

Weekly Task-Completing Users (WTCU) is used as the product's North Star metric.

It measures distinct users who complete at least one task during a calendar week, using Monday-to-Sunday UTC weeks.

This metric focuses on actual product usage rather than signups or passive activity.

### A/B Experiment Evaluation

Two product experiments are evaluated:

- Onboarding changes
- A collaboration prompt intended to encourage invitations

The evaluation uses two-proportion tests, confidence intervals, and Holm correction for multiple comparisons.

The analysis examines the measured outcomes rather than assuming that a product change was successful simply because treatment performance was higher.

## 7. Key Findings

### Activation

- Overall D7 activation rate: **36.33%**
- 18,165 of 50,000 users completed a task within seven days.
- Referral had the highest D7 activation rate at **43.70%**.
- Paid search had the lowest rate at **27.92%**.
- The difference between the highest and lowest acquisition channels suggests that acquisition source is worth investigating further.

Company size showed a statistically significant association with activation, but the effect was weak. Role, device type, and industry did not show statistically significant associations after multiple-testing correction.

### Engagement

Activated users demonstrated higher average usage:

| Metric | Activated | Non-activated |
|---|---:|---:|
| Active days | 4.23 | 2.86 |
| Activity events | 15.71 | 8.37 |
| Sessions | 4.85 | 3.76 |
| Session duration (seconds) | 777.62 | 777.29 |

The difference is visible in activity frequency, not average session duration.

### Retention

User-weighted retention rates across eligible cohorts:

| Retention | Activated | Non-activated |
|---|---:|---:|
| D1 | 11.45% | 3.24% |
| D7 | 8.59% | 4.25% |
| D30 | 2.43% | 1.76% |

Activated users showed higher retention at all three measured horizons. These are descriptive comparisons and should not be interpreted as proof that activation causes retention.

### Funnel Conversion

The largest absolute drop-off occurred between project creation and task creation, with approximately **6,569 users** lost at this transition.

Overall signup-to-task-completion conversion varied by acquisition channel:

- Referral: **77.36%**
- Paid search: **57.07%**

This identifies the transition from project setup to actual task creation as an important area for product investigation.

### Weekly Product Usage

Weekly Task-Completing Users declined from a peak of **2,922** to **1,980**, a decrease of **32.2%**.

The decline indicates weakening task-completion activity in the observed period. The available data does not establish the cause of this decline.

### Experiment Results

**Onboarding experiment**

- Control onboarding-step completion: 67.33%
- Treatment onboarding-step completion: 67.55%
- Difference: +0.225 percentage points
- Result: Not statistically significant

The new onboarding experience did not demonstrate a measurable improvement in onboarding-step completion.

**Collaboration prompt experiment**

- Invite acceptance in control: 8.65%
- Invite acceptance in treatment: 10.44%
- Difference: +1.787 percentage points
- Relative increase: approximately 20.66%
- Result: Statistically significant after multiple-testing correction

The collaboration prompt showed a statistically significant increase in invite acceptance per assigned user. Invite sending itself did not show a statistically significant improvement.

## 8. Business Recommendations

Based on the observed findings:

1. **Investigate project-to-task drop-off.** Examine friction between creating a project and completing the first task.
2. **Investigate paid search acquisition quality.** Its activation and overall funnel conversion rates were the weakest among the measured channels.
3. **Continue testing the collaboration prompt.** The increase in invite acceptance is promising and warrants further evaluation.
4. **Investigate declining existing-user activity.** The fall in weekly task-completing users requires further analysis to identify its cause.
5. **Monitor WTCU alongside activation and retention.** Signups alone do not adequately represent ongoing product usage.

## 9. What This Project Demonstrates

This project demonstrates an end-to-end product analytics workflow:

- Transforming raw event data into structured analytical models using dbt
- Defining behavioural metrics with explicit business logic
- Building activation, engagement, retention, and funnel analyses
- Segmenting users by acquisition and demographic attributes
- Applying statistical tests to categorical associations
- Evaluating A/B experiments using confidence intervals and multiple-testing correction
- Establishing a North Star metric for ongoing product monitoring
- Translating analytical results into practical product recommendations
- Organizing analytical work into a reproducible GitHub repository

The emphasis is on connecting data engineering, analytical reasoning, statistical evaluation, and business interpretation.

## 10. Limitations

- The dataset is synthetic; findings describe the constructed dataset, not a real company's customers.
- Observed relationships do not establish causation.
- Retention comparisons are descriptive and depend on cohort eligibility.
- Experiment assignment does not independently establish actual exposure or verify randomization.
- The observed decline in weekly task-completing users does not identify its underlying cause.
- Findings should be interpreted within the available observation period and dataset boundaries.

## 11. Repository Deliverables

- Tested dbt transformation pipeline
- Staging, intermediate, and mart models
- Analytical Jupyter notebook
- Activation, retention, funnel, and experiment analysis
- Metric definitions
- Business decision memo
- Data model documentation and project assets

Raw datasets are maintained in BigQuery rather than committed to the repository.

## 12. Project Structure

The repository is organized around the dbt transformation project, analytical notebook, and business documentation.

- `dbt/` — dbt project, configuration, and SQL models
- `analysis/` — analytical Jupyter notebooks
- `DAG.png` — dbt model dependency diagram
- `metric_definitions.md` — metric definitions and calculation logic
- `decision_memo.md` — findings and business recommendations

---

**Project:** Flowboard Product Analytics  
**Focus:** Product Analytics | SQL | Python | BigQuery | dbt | Experimentation  
**Data:** Synthetic B2B SaaS product usage data
