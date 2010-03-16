%% @author Russell Brown <russell@ossme.net>
%% @copyright 2010 Ossme.
%% @doc Template resource

-module(add_template).
-export([init/1, to_html/2, allowed_methods/2, content_types_accepted/2, post_is_create/2, create_path/2, handle_post/2, templates/1]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("time/include/time.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, Context) ->
    {ok, Out} = tempile:render(?MODULE, dict:new()),
    {Out, ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['GET', 'POST'], ReqData, Context}.

post_is_create(ReqData, Context) ->
    {true, ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"application/x-www-form-urlencoded", handle_post}, {"text/html", to_html}], ReqData, Context}.

create_path(ReqData, Context) ->
    Client = template_util:get_field(client, mochiweb_util:parse_qs(wrq:req_body(ReqData)), fun(X) -> X end),
    {"/template/"++Client, ReqData, Context}.

handle_post(ReqData, Context) ->
    T =  template_util:template_from_form(ReqData),
    {ok, Key} = time:template(binary_to_atom(T#time.client, utf8), T),
    {ok, Out} = tempile:render(?MODULE, dict:new()),
    {true, wrq:append_to_response_body(Out, ReqData), Context}.

%%View method called by mustache
templates(_Ctx) ->
    L = time:list_templates(),
    [dict:from_list([{template, binary_to_list(Template)}]) || Template <- L].
