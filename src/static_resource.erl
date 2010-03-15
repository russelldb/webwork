%% @author sunneach http://bitbuckets.com/sunneach
%% @copyright 2009 sunneach
%% @doc Example webmachine_resource.

-module(static_resource).
-export([init/1, content_types_provided/2, provide_content/2, resource_exists/2]).

-include_lib("webmachine/include/webmachine.hrl").

-record(context, {docroot,fullpath}).

init([DocRoot]) -> {ok, #context{docroot=DocRoot}};
init([Cfg,DocRoot]) -> 
    {trace_dir,Dir} = Cfg,
    AbsDir =filename:absname(Dir), 
    {{trace,AbsDir}, #context{docroot=DocRoot}}.

content_types_provided(ReqProps, Context) ->
    Path = wrq:path(ReqProps), 
    case Path of
        "/" -> {[{"text/html", provide_content}], ReqProps, Context};
        _ -> {[{webmachine_util:guess_mime(Path), provide_content}], ReqProps, Context}
    end.

provide_content(ReqProps, Context) ->
    {ok, Value} = file:read_file(Context#context.fullpath),
    {Value, ReqProps, Context}.

resource_exists(ReqProps, Context) ->
    case wrq:path(ReqProps) of
        "/" -> {true, ReqProps, Context#context{fullpath=
						    filename:join([Context#context.docroot, "index.html"])}};
        Path ->
            case mochiweb_util:safe_relative_path(tl(Path)) of
                undefined -> {false, ReqProps, Context};
                SafePath ->
                    FPath = filename:join([Context#context.docroot, SafePath]),
                    case filelib:is_regular(FPath) of
                        true -> {true, ReqProps, Context#context{fullpath=FPath}};
                        _ -> {false, ReqProps, Context}
                    end
            end
    end.
