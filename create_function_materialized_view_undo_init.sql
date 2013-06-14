create or replace function materialized_view_undo_init(
    _view_name           text,
    _materialized_suffix text     default '_materialized',
    _original_suffix     text     default '_original'
) returns void as
$$
declare
    _materialized_view text := quote_ident( _view_name || _materialized_suffix );
    _original_view     text := quote_ident( _view_name || _original_suffix );
    _get_function      text := quote_ident( 'get_' || _view_name || _materialized_suffix );
begin
    if _original_view::regclass is not null then
        _view_name := quote_ident( _view_name );
        execute 'drop view if exists ' || _view_name;
        execute 'drop function if exists ' || _get_function || '( )';
        execute 'drop table if exists ' || _materialized_view;
        execute 'alter view ' || _original_view || ' rename to ' || _view_name;
    end if;
end;
$$ language plpgsql
