%%% @author Russell Brown <russell@pango.lan>
%%% @copyright (C) 2010, Russell Brown
%%% @doc
%%%
%%% @end
%%% Created : 16 Mar 2010 by Russell Brown <russell@pango.lan>
-module(template_util).

-export([template_from_form/1, get_field/3]).

-include_lib("time/include/time.hrl").

template_from_form(ReqData) ->
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
