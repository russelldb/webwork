%%% @author Russell Brown <russell@pango.lan>
%%% @copyright (C) 2010, Russell Brown
%%% @doc
%%%
%%% @end
%%% Created : 16 Mar 2010 by Russell Brown <russell@pango.lan>
-module(ww_util).

-export([time_from_form/1, get_field/3, time_to_dict/1]).

-include_lib("time/include/time.hrl").

time_from_form(ReqData) ->
    L = mochiweb_util:parse_qs(wrq:req_body(ReqData)),
    Client = get_field(client, L, fun(X) -> X end),
    #time{client=list_to_binary(Client), rate=get_field(rate, L, fun(X) -> as_number(X) end), rate_period=get_field(rate_period, L, fun(X) -> list_to_atom(X) end), units=get_field(units, L, fun(X) ->  as_number(X) end)}.

get_field(Field, L, Converter) ->
    Converter(proplists:get_value(atom_to_list(Field), L)).

as_number(Value) ->
    try X = list_to_integer(Value), X catch
					  _:_ ->
					      try Y = list_to_float(Value), Y catch
										  _:_ -> Value
									      end
				      end.

time_to_dict(T) when is_record(T, time) ->
    D = dict:new(),
    D1 = dict:store(client, binary_to_list(T#time.client), D),
    D2 = dict:store(rate, T#time.rate, D1),
    D3 = dict:store(rate_period, T#time.rate_period, D2),
    D4 = dict:store(date, date_format(T#time.date), D3),
    dict:store(units, T#time.units, D4).

date_format(undefined) ->
    "";
date_format({Year, Month, Day}) ->
    io_lib:format("~2.10.0B/~2.10.0B/~4.10.0B",
        [Day, Month, Year]).
