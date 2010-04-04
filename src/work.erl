-module(work).

-export([init/1, to_html/2, from_data/2, resource_exists/2, allowed_methods/2, content_types_accepted/2, rate_period_is_day/1, rate_period_is_hour/1, delete_resource/2, delete_completed/2]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

allowed_methods(ReqData, Context) ->
    {['PUT', 'GET', 'DELETE'], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"text/plain", from_data}, {"text/html", to_html}], ReqData, Context}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, dict:store(key, wrq:path_info(uuid, ReqData), ww_util:time_to_dict(Context))),
    {Out, ReqData, Context}.

resource_exists(ReqData, Context) ->
    UUID = wrq:path_info(uuid, ReqData),
    case UUID of
	undefined ->
	    {false, ReqData, Context};
    _ ->
       case time:get_time(UUID) of 
		undefined ->
		    {false, ReqData, Context};
		T ->
		    {true, ReqData, T}
       end
   end.

from_data(ReqData, Context) ->
    Template = list_to_atom(wrq:path_info(template, ReqData)),
    {ok, Key} = time:today_from_template(Template),
    {true, wrq:append_to_response_body(binary_to_list(Key), ReqData), Context}.

delete_resource(ReqData, Context) ->
    %%%delete it
    case time:delete_time(wrq:path_info(uuid, ReqData)) of
	ok ->
	    {true, ReqData, Context};
	_ ->
	    {false, ReqData, Context}
    end.

delete_completed(ReqData, Context) ->
    {true, wrq:append_to_response_body(<<"true">>, ReqData), Context}.

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

    
    





