materialized-view
=================

Some PL/pgSQL functions that facilitate lazily materializing views on an interval.

While recently aggregating the product of large tables, a query was executing in a reasonable 60-70 seconds. The frequency with which this query would be used did not justify materializing its results by crontab. However, since it was likely to be called in succession when in demand, lazily materializing the results made sense.

usage:
------

* `select materialized_view_init( 'existing_view_name', '6 hours'::interval );`
    - No need to update references to `existing_view_name`.
    - Creates a table to store the view's query results -- `existing_view_name_materialized`.
    - Creates a function to refresh, if necesary, materialized results and returns them -- `get_existing_view_name_materialized`.
    - Renames the original view -- `existing_view_name_original`.
    - Replaces `existing_view_name` with call to `get_existing_view_name_materialized`.
* `select materialized_view_undo_init( 'existing_view_name' );`
    - Drops all of the generated init code and reverts to the original view.
* `select materialized_view_refresh( 'existing_view_name', '30 minutes'::interval );`
    - Not necessary to call manually, but can be called with a short interval to force a refresh.

note:
-----

[Materialized Views are coming in PostgreSQL 9.3](http://j.mp/14eAeal "PostgreSQL: Documentation: 9.3: REFRESH MATERIALIZED VIEW")

[![Analytics](https://ga-beacon.appspot.com/UA-46733058-1/materialized-view/README?pixel)]( )
