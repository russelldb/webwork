%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(fuckit).
-export([init/1, to_html/2, value/1, title/1]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, State) ->
     {ok, Out} = tempile:render(?MODULE, dict:from_list([{planet, "World!"}])),
     {Out, ReqData, State}.


value(Ctx) ->
    {ok, Val} =  dict:find(planet, Ctx),
    Val.

title(Ctx)->
    case dict:find(title, Ctx) of
	{ok, Title} ->
	    Title;
	_ ->
	    "Oh fuck off!"
    end.
