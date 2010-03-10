%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the webwork application.

-module(webwork_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for webwork.
start(_Type, _StartArgs) ->
    webwork_deps:ensure(),
    webwork_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for webwork.
stop(_State) ->
    ok.
