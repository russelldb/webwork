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
    Client = get_field(client, mochiweb_util:parse_qs(wrq:req_body(ReqData)), fun(X) -> X end),
    {"/template/"++Client, ReqData, Context}.

handle_post(ReqData, Context) ->
    error_logger:info_msg("~p ~p ~p~n", [wrq:disp_path(ReqData), null, template_from_form(ReqData)]),
    T =  template_from_form(ReqData),
    {ok, Key} = time:template(binary_to_atom(T#time.client, utf8), T),
    {ok, Out} = tempile:render(?MODULE, dict:new()),
    {true, wrq:append_to_response_body(Out, ReqData), Context}.

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

%%View method called by mustache
templates(_Ctx) ->
    L = time:list_templates(),
    [dict:from_list([{template, binary_to_list(Template)}]) || Template <- L].
