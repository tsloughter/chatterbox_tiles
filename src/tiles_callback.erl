-module(tiles_callback).

-export([handle/3]).

-include_lib("elli_chatterbox/include/elli_chatterbox.hrl").

handle(_Method, _Path, _Req=#ec_req{args=Args, stream_id=StreamId}) ->
    case proplists:get_value(<<"x">>, Args, undefined) of
        undefined ->
            Latency = proplists:get_value(<<"latency">>, Args, <<"0">>),
            {200, [{<<"content-type">>, <<"text/html">>}], tiles:body(Latency)};
        X ->
            Y = proplists:get_value(<<"y">>, Args, undefined),
            Latency = proplists:get_value(<<"latency">>, Args, <<"0">>),
            Binary = tiles:get_tile(X, Y, Latency),
            {200, [], Binary}
    end.
