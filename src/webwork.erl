%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(webwork).
-author('author <author@example.com>').
-export([start/0, start_link/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
	ok ->
	    ok;
	{error, {already_started, App}} ->
	    ok
    end.

%% @spec start_link() -> {ok,Pid::pid()}
%% @doc Starts the app for inclusion in a supervisor tree
start_link() ->
    webwork_deps:ensure(),
    ensure_started(crypto),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    ensure_started(webmachine),
    ensure_started(tempile),
    ensure_started(time),
    webwork_sup:start_link().

%% @spec start() -> ok
%% @doc Start the webwork server.
start() ->
    webwork_deps:ensure(),
    ensure_started(crypto),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    ensure_started(webmachine),
    ensure_started(tempile),
    ensure_started(time),
    application:start(webwork).

%% @spec stop() -> ok
%% @doc Stop the webwork server.
stop() ->
    Res = application:stop(webwork),
    application:stop(webmachine),
    application:stop(tempile),
    application:stop(crypto),
    Res.
