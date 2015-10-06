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
should be written into a .sql file directly.

```sql
# filename: daily_summary.sql
owner: jackdanger
schedule: hourly
environments:
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

The above is a `.sql` file and any text editor will allow analysts to use
code completion and syntax highlighting for their queries.

The `data` hash in the YAML front matter lists a set of variables, by
environment, that can be interpolated into the SQL queries. To render
the queries an environment must be provided. The templating system used
for interpolating data is [Mustache](https://mustache.github.io/)
(though theoretically we could use any templating system).

### Rendering SQL on the command line
```bash
$ hsql daily_summary.sql -env development
USE some_database;
INSERT INTO jackdanger_summaries SELECT * FROM interesting_information;
UPDATE summaries_performed SET complete = 1 WHERE 1 <> 1;
```

The `hsql` command-line utility outputs valid Postgres SQL with any
template variables filled in from the YAML data.
To access the metadata directly use the `--yaml` or `--json` flag

```bash
$ hsql daily_summary.sql -env development --json
{"owner":"jackdanger","schedule":"hourly","output_table":"jackdanger_summaries","update_condition":"WHERE 1 <> 1"}
$ hsql daily_summary.sql -env development --yaml
---
owner: jackdanger
schedule: hourly
output_table: jackdanger_summaries
update_condition: WHERE 1 <> 1
```

### Working with times and dates
By default when you run the `hsql` command it will set the template
variable `{{{ now }}}` to the current moment (as per the local
machine's clock). You can modify this by setting a `--timestamp`
command line flag to any Ruby-parseable time or date string and that
will be used to establish the value of `{{{ now }}}`.

To avoid having to do date math in SQL all of the following are also
available in every template, relative to the value of `{{{ now }}}`:

```
                              "now" => "'2015-10-06 12:34:55 -0700'",
                "beginning_of_hour" => "'2015-10-06 12:00:00 -0700'",
                 "beginning_of_day" => "'2015-10-06 00:00:00 -0700'",
                "beginning_of_week" => "'2015-10-05 00:00:00 -0700'",
               "beginning_of_month" => "'2015-10-01 00:00:00 -0700'",
             "beginning_of_quarter" => "'2015-10-01 00:00:00 -0700'",
                "beginning_of_year" => "'2015-01-01 00:00:00 -0800'",
                      "end_of_hour" => "'2015-10-06 12:59:59 -0700'",
                       "end_of_day" => "'2015-10-06 23:59:59 -0700'",
                      "end_of_week" => "'2015-10-11 23:59:59 -0700'",
                     "end_of_month" => "'2015-10-31 23:59:59 -0700'",
                   "end_of_quarter" => "'2015-12-31 23:59:59 -0800'",
                      "end_of_year" => "'2015-12-31 23:59:59 -0800'",
       "beginning_of_previous_hour" => "'2015-10-06 11:00:00 -0700'",
             "end_of_previous_hour" => "'2015-10-06 11:59:59 -0700'",
        "beginning_of_previous_day" => "'2015-10-05 00:00:00 -0700'",
              "end_of_previous_day" => "'2015-10-05 23:59:59 -0700'",
       "beginning_of_previous_week" => "'2015-09-28 00:00:00 -0700'",
             "end_of_previous_week" => "'2015-10-04 23:59:59 -0700'",
      "beginning_of_previous_month" => "'2015-09-01 00:00:00 -0700'",
            "end_of_previous_month" => "'2015-09-30 23:59:59 -0700'",
    "beginning_of_previous_quarter" => "'2015-07-01 00:00:00 -0700'",
          "end_of_previous_quarter" => "'2015-09-30 23:59:59 -0700'",
       "beginning_of_previous_year" => "'2014-01-01 00:00:00 -0800'",
             "end_of_previous_year" => "'2014-12-31 23:59:59 -0800'"
```

### Programmatic Ruby API

If you'd like to manipulate the queries in some advanced way
(e.g. to modify the AST of a parsed query) you can use the gem as a
dependency.

```ruby
>> require 'hsql'
>> file = HSQL::File.parse_file('./simple.sql', 'development')
>> query = file.queries.first;
>> query.to_s
=> "INSERT INTO jackdanger_summaries SELECT count(*) FROM interesting_information"
>> query.ast
=> {
    "INSERT INTO" => {
             "relation" => {
            "RANGEVAR" => {
                    "schemaname" => nil,
                       "relname" => "jackdanger_summaries",
                        "inhOpt" => 2,
                "relpersistence" => "p",
                         "alias" => nil,
                      "location" => 13
            }
        },
                 "cols" => nil,
           "selectStmt" => {
            "SELECT" => {
                "distinctClause" => nil,
                    "intoClause" => nil,
                    "targetList" => [
                    [0] {
                        "RESTARGET" => {
                                   "name" => nil,
                            "indirection" => nil,
                                    "val" => {
                                "FUNCCALL" => {
                                            "funcname" => [
                                        [0] "count"
                                    ],
                                                "args" => nil,
                                           "agg_order" => nil,
                                          "agg_filter" => nil,
                                    "agg_within_group" => false,
                                            "agg_star" => true,
                                        "agg_distinct" => false,
                                       "func_variadic" => false,
                                                "over" => nil,
                                            "location" => 79
                                }
                            },
                               "location" => 79
                        }
                    }
                ],
                    "fromClause" => [
                    [0] {
                        "RANGEVAR" => {
                                "schemaname" => nil,
                                   "relname" => "interesting_information",
                                    "inhOpt" => 2,
                            "relpersistence" => "p",
                                     "alias" => nil,
                                  "location" => 95
                        }
                    }
                ],
                   "whereClause" => nil,
                   "groupClause" => nil,
                  "havingClause" => nil,
                  "windowClause" => nil,
                   "valuesLists" => nil,
                    "sortClause" => nil,
                   "limitOffset" => nil,
                    "limitCount" => nil,
                 "lockingClause" => nil,
                    "withClause" => nil,
                            "op" => 0,
                           "all" => false,
                          "larg" => nil,
                          "rarg" => nil
            }
        },
        "returningList" => nil,
           "withClause" => nil
    }
}
>> query.ast['INSERT INTO']['relation']['RANGEVAR']['relname'] = 'othertable'
=> "othertable"
>> query.to_s
=> "INSERT INTO othertable SELECT count(*) FROM interesting_information"
```

Please don't hesitate to open a PR or issue for any reason. New
contributors and bug fixes are welcome. Forks of this project will be celebrated.
