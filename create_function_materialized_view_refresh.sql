create or replace function materialized_view_refresh(
    _view_name           text,
    _refresh_rate        interval default '1 week'::interval,
    _materialized_suffix text     default '_materialized',
    _original_suffix     text     default '_original'
) returns void as
$$
declare
    _materialized_view text := quote_ident( _view_name || _materialized_suffix );
    _original_view     text := quote_ident( _view_name || _original_suffix );
    _last_refresh      timestamptz;
begin
    select
        obj_description( _materialized_view::regclass::oid, 'pg_class' )::timestamptz
    into
        _last_refresh;

    if _last_refresh is null or (now( ) - _last_refresh)::interval > _refresh_rate then
        execute 'truncate ' || _materialized_view;
        
        execute 'insert into '
            || _materialized_view
            || ' select * from '
            || _original_view;

        execute 'comment on table ' || _materialized_view
            || ' is '  || quote_literal( now( ) );
    end if;
end;
$$ language plpgsql
