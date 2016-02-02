-module(tiles_callback).

-export([handle/2,
         handle_event/3]).

-behaviour(elli_handler).

handle(Req, _Args) ->
    case elli_request:get_arg(<<"x">>, Req, undefined) of
        undefined ->
            Latency = elli_request:get_arg(<<"latency">>, Req, <<"0">>),
            {ok, #{<<"content-type">> => <<"text/html">>}, tiles:body(Latency)};
        X ->
            Y = elli_request:get_arg(<<"y">>, Req, undefined),
            Latency = elli_request:get_arg(<<"latency">>, Req, <<"0">>),
            Binary = tiles:get_tile(X, Y, Latency),
            {ok, #{}, Binary}
    end.

handle_event(_, _, _) -> ok.
