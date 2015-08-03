# HSQL

"Hash (of data) and SQL" is a library that parses `.sql` files with YAML
[front matter](http://jekyllrb.com/docs/frontmatter/). This allows
analysts and other non-developers to write and develop ETLs without
having to write source code but still giving them the power of
specifying variables to interpolate into the SQL and other metadata that
the program executing the SQL can use.

## How to use this

Rather than specifying variables and metadata for a set of database
queries in a .rb or other programming language source file the queries
should be written to a .sql file directly.

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
    USE some_database;
    INSERT INTO {{{output_table}}} SELECT * FROM interesting_information;
    UPDATE summaries_performed SET complete = 1 {{{update_condition}}};

The above is a SQL file and any text editor will allow analysts to use
code completion and syntax highlighting for their queries.
