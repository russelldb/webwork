-module(template).

-export([init/1, to_html/2, allowed_methods/2, content_types_accepted/2, handle_put/2, resource_exists/2, rate_period_is_hour/1, rate_period_is_day/1]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, template_to_dict(Context)),
    {Out, ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET', 'PUT'], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"application/x-www-form-urlencoded", handle_put}, {"text/html", to_html}], ReqData, Context}.

handle_put(ReqData, Context) ->
    T =  template_from_form(ReqData),
    {ok, Key} = time:template(binary_to_atom(T#time.client, utf8), T),
    {true, ReqData, Context}.


resource_exists(ReqData, Context) ->
    Client = list_to_atom(wrq:path_info(client, ReqData)),
    T = time:get_template(Client),
    case T of
	undefined ->
	    {false, ReqData, Context};
	_ ->
	    {true, ReqData, T}
   end.

template_from_form(ReqData) ->
    L = mochiweb_util:parse_qs(wrq:req_body(ReqData)),
    Client = get_field(client, L, fun(X) -> X end),
    #time{client=list_to_binary(Client), rate=get_field(rate, L, fun(X) -> as_number(X) end), rate_period=get_field(rate_period, L, fun(X) -> list_to_atom(X) end), units=get_field(units, L, fun(X) ->  as_number(X) end)}.

get_field(Field, L, Converter) ->
    Converter(proplists:get_value(atom_to_list(Field), L)).

template_to_dict(T) when is_record(T, time) ->
    D = dict:new(),
    D1 = dict:store(client, binary_to_list(T#time.client), D),
    D2 = dict:store(rate, T#time.rate, D1),
    D3 = dict:store(rate_period, T#time.rate_period, D2),
    dict:store(units, T#time.units, D3).
    
as_number(Value) ->
    try X = list_to_integer(Value), X catch
					  _:_ ->
					      try Y = list_to_float(Value), Y catch
										  _:_ -> Value
									      end
				      end.
%%% Template methods
rate_period_is_day(Ctx) ->
    case dict:fetch(rate_period, Ctx) of
	day ->
	    true;
	_ ->
	    false
    end.

rate_period_is_hour(Ctx) ->
    rate_period_is_day(Ctx) == false.
