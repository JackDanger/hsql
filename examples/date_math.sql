/*
Demonstrating use of the builtin time and date variables.
No YAML front matter was necessary for this file to work.

To see all possible variables you can use run:

    $ hsql --help

To see yourself how this file works run:

    $ hsql examples/date_math.sql

To change the values of the times just pass a --date or --timestamp argument:

    $ hsql examples/date_math.sql --timestamp '1986-01-12 17:12:00'

*/

SELECT * FROM users WHERE created_at = {{{now}}};
/* Becomes:
SELECT * FROM users WHERE created_at = '2015-08-19 21:13:82 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_hour}}} AND {{{end_of_hour}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-19 21:00:00 -0700' AND created_at <= '2015-08-19 21:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_hour}}} AND {{{end_of_previous_hour}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-19 20:00:00 -0700' AND created_at <= '2015-08-19 20:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_day}}} AND {{{end_of_day}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-19 00:00:00 -0700' AND created_at <= '2015-08-19 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_day}}} AND {{{end_of_previous_day}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-18 00:00:00 -0700' AND created_at <= '2015-08-18 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_week}}} AND {{{end_of_week}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-17 00:00:00 -0700' AND created_at <= '2015-08-23 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_week}}} AND {{{end_of_previous_week}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-10 00:00:00 -0700' AND created_at <= '2015-08-16 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_month}}} AND {{{end_of_month}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-08-01 00:00:00 -0700' AND created_at <= '2015-08-31 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_month}}} AND {{{end_of_previous_month}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-07-01 00:00:00 -0700' AND created_at <= '2015-07-31 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_quarter}}} AND {{{end_of_quarter}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-07-01 00:00:00 -0700' AND created_at <= '2015-09-30 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_quarter}}} AND {{{end_of_previous_quarter}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-04-01 00:00:00 -0700' AND created_at <= '2015-06-30 23:59:59 -0700' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_year}}} AND {{{end_of_year}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2015-01-01 00:00:00 -0800' AND created_at <= '2015-12-31 23:59:59 -0800' */

SELECT * FROM users WHERE created_at BETWEEN {{{beginning_of_previous_year}}} AND {{{end_of_previous_year}}};
/* Becomes:
SELECT * FROM users WHERE created_at >= '2014-01-01 00:00:00 -0800' AND created_at <= '2014-12-31 23:59:59 -0800' */
