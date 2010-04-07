%% @author Russell Brown <russell@ossme.net>
%% @copyright 2010 Ossme.
%% @doc Template resource

-module(templates).
-export([init/1, to_html/2, allowed_methods/2, content_types_provided/2, templates/1, to_json/2, get_json/1]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, dict:new()),
    {Out, ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET'], ReqData, Context}.

content_types_provided(ReqData, Context) ->
    {[{"text/html", to_html}, {"application/json", to_json}], ReqData, Context}.

to_json(ReqData, Context) ->
    L = time:list_templates(),
    Ting = get_json( L),
    {mochijson2:encode(Ting), ReqData, Context}.

%%View method called by mustache
templates(_Ctx) ->
    L = time:list_templates(),
    [dict:from_list([{template, binary_to_list(Template)}]) || Template <- L].

get_json(L) ->
   {struct, [{identifier, <<"id">>}, {label, <<"name">>}, {items, [{struct, [{id, T}, {name, T}]} || T <- L ]}]}.
