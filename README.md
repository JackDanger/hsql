# HSQL

"Hash (of data) and SQL" is a library that parses `.sql` files with YAML
[front matter](http://jekyllrb.com/docs/frontmatter/). This allows
analysts and other non-developers to write and develop ETLs without
having to write source code but still giving them the power of
specifying variables to interpolate into the SQL and other metadata that
the program executing the SQL can use.

## How to use this

Rather than specifying variables and metadata for a set of database
queries in a `.rb`,`.py` or other programming language source file the queries
should be written to a .sql file directly.

```sql
# filename: daily_summary.sql
owner: jackdanger
schedule: hourly
data:
  production:
    output_table: summaries
    update_condition:
  development:
    output_table: jackdanger_summaries
    update_condition: WHERE 1 <> 1
---
INSERT INTO {{{output_table}}} SELECT * FROM interesting_information;
UPDATE summaries_performed SET complete = 1 {{{update_condition}}};
```

The above is a SQL file and any text editor will allow analysts to use
code completion and syntax highlighting for their queries.

The `data` hash in the YAML front matter lists a set of variables, by
environment, that can be interpolated into the SQL queries. To render
the queries an environment must be provided.

```bash
$ hsql daily_summary.sql development
USE some_database;
INSERT INTO jackdanger_summaries SELECT * FROM interesting_information;
UPDATE summaries_performed SET complete = 1 WHERE 1 <> 1;
```

The `hsql` command-line utility allows these SQL source files to be
easily run in the context of some other application that understands
when and where to execute the queries.

To access the metadata directly there is a simple programmatic API:

```ruby
>> file = HSQL.parse_file('./daily_summary.sql', 'development')
>> file.queries
=> [
  "USE some_database;",
  "INSERT INTO jackdanger_summaries SELECT * FROM interesting_information;",
  "UPDATE summaries_performed SET complete = 1 WHERE 1 <> 1;"
]
```

The object returned from `HSQL.parse_file` provides you access to both
the rendered queries and the data specified in the front matter. You can
use this to schedule the queries, to run them and send failure notices
to a list of watchers. It's a general-purpose store of data for the
query author to configure whatever system you use to run ETL queries.

```ruby
>> file = HSQL.parse_file('./daily_summary.sql', 'development')
>> file.yaml
=> {
  'owner' => 'jackdanger',
  'schedule' => 'hourly',
  'data' => {
    'production' => {
      'output_table' => 'summaries',
      'update_condition' => nil,
    },
    'development' => {
      'output_table' => 'jackdanger_summaries',
      'update_condition' => 'WHERE 1 <> 1',
    },
  }
}
```
