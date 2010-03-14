-module(template).

-export([init/1, to_html/2, allowed_methods/2, content_types_accepted/2, handle_put/2]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, dict:from_list([{client, wrq:path_info(client, ReqData)}])),
    {Out, ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET', 'PUT'], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"application/x-www-form-urlencoded", handle_put}, {"text/html", to_html}], ReqData, Context}.

handle_put(ReqData, Context) ->
    T =  template_from_form(ReqData),
    {ok, Key} = time:template(binary_to_atom(T#time.client, utf8), T),
    {true, ReqData, Context}.

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

