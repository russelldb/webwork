-module(template).

-export([init/1, to_html/2, allowed_methods/2, content_types_accepted/2, process_post/2, resource_exists/2, rate_period_is_hour/1, rate_period_is_day/1, delete_resource/2, delete_completed/2]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, template_to_dict(Context)),
    {Out, ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET', 'POST', 'DELETE'], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"application/x-www-form-urlencoded", process_post}, {"text/html", to_html}], ReqData, Context}.

delete_resource(ReqData, Context) ->
    %%%delete it
    case time:delete_template(list_to_atom(wrq:path_info(client, ReqData))) of
	ok ->
	    {true, ReqData, Context};
	_ ->
	    {false, ReqData, Context}
    end.

delete_completed(ReqData, Context) ->
    {true, wrq:append_to_response_body(<<"true">>, ReqData), Context}.

process_post(ReqData, Context) ->
    T =  template_util:template_from_form(ReqData),
    {ok, Key} = time:template(list_to_atom(wrq:path_info(client, ReqData)), T),
    {ok, Out} = tempile:render(?MODULE, template_to_dict(T)),
    {true,  wrq:append_to_response_body(Out, ReqData), Context}.

resource_exists(ReqData, Context) ->
    Client = list_to_atom(wrq:path_info(client, ReqData)),
    T = time:get_template(Client),
    case T of
	undefined ->
	    {false, ReqData, Context};
	_ ->
	    {true, ReqData, T}
   end.

template_to_dict(T) when is_record(T, time) ->
    D = dict:new(),
    D1 = dict:store(client, binary_to_list(T#time.client), D),
    D2 = dict:store(rate, T#time.rate, D1),
    D3 = dict:store(rate_period, T#time.rate_period, D2),
    dict:store(units, T#time.units, D3).

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
