create or replace function materialized_view_init(
    _view_name           text,
    _refresh_rate        interval default '1 week'::interval,
    _materialized_suffix text     default '_materialized',
    _original_suffix     text     default '_original'
) returns void as
$CREATE$
declare
    _materialized_view text := quote_ident( _view_name || _materialized_suffix );
    _original_view     text := quote_ident( _view_name || _original_suffix );
    _get_function      text := quote_ident( 'get_' || _view_name || _materialized_suffix );
begin
    _view_name := quote_ident( _view_name );

    execute 'create table '
        || _materialized_view
        || ' as select * from '
        || _view_name;

    execute 'comment on table ' || _materialized_view
        || ' is '  || quote_literal( now( ) );

    execute 'create function ' || _get_function || '( ) '
        || ' returns setof ' || _materialized_view || ' as '
        || ' $GET$ '
        || ' begin '
        || ' perform materialized_view_refresh( '
        || quote_literal( _view_name ) || ', '
        || quote_literal( _refresh_rate ) || '::interval, '
        || quote_literal( _materialized_suffix ) || ', '
        || quote_literal( _original_suffix ) || ' ); '
        || ' return query select * from ' || _materialized_view || '; '
        || ' end; '
        || ' $GET$ language plpgsql; ';

    execute 'alter view ' || _view_name || ' rename to ' || _original_view;
    execute 'create view ' || _view_name || ' as ( '
        || ' select * from get_' || _materialized_view || '( ) '
        || ' ); ';
end;
$CREATE$ language plpgsql
