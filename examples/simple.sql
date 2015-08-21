# filename: daily_summary.sql
owner: jackdanger
schedule: hourly
requires:
  - daily_payments
  - hourly_users
  - some_other_value
data:
  production:
    output_table: summaries
    update_condition:
  development:
    output_table: jackdanger_summaries
    update_condition: WHERE 1 <> 1
---
INSERT INTO {{{output_table}}} -- this query is joined to one line
  SELECT COUNT(*)
  FROM interesting_information; -- and the comments get stripped
UPDATE summaries_performed SET complete = 1 {{{update_condition}}};
