-module(chatterbox_tiles_handler).

-include_lib("chatterbox/include/http2.hrl").

-export([spawn_handle/4,
         handle/4]).

spawn_handle(Pid, StreamId, Headers, ReqBody) ->
    Handler = fun() ->
        handle(Pid, StreamId, Headers, ReqBody)
    end,
    spawn_link(Handler).

handle(ConnPid, StreamId, Headers, _ReqBody) ->
    lager:debug("handle(~p, ~p, ~p, _)", [ConnPid, StreamId, Headers]),
    Path = proplists:get_value(<<":path">>, Headers),
    case binary:split(Path, <<"?">>) of
        [_, EncodedQS] ->
            case qsp:decode(EncodedQS) of
                #{<<"x">> := X, <<"y">> := Y} = DecodedQS ->
                    Latency = maps:get(<<"latency">>, DecodedQS, <<"0">>),
                    Binary = tiles:get_tile(X, Y, Latency),
                    ResponseHeaders = [{<<":status">>,<<"200">>},
                                       {<<"content-type">>, <<"image/png">>}],
                    http2_connection:send_headers(ConnPid, StreamId, ResponseHeaders),
                    http2_connection:send_body(ConnPid, StreamId, Binary);
                DecodedQS ->
                    Latency = maps:get(<<"latency">>, DecodedQS, <<"0">>),
                    tiles_page(ConnPid, StreamId, Latency)
            end;
        _ ->
            tiles_page(ConnPid, StreamId, <<"0">>)
    end.

tiles_page(ConnPid, StreamId, Latency) ->
    ResponseHeaders = [{<<":status">>,<<"200">>},
                       {<<"content-type">>, <<"text/html">>}],
    http2_connection:send_headers(ConnPid, StreamId, ResponseHeaders),
    Data = tiles:body(Latency),
    http2_connection:send_body(ConnPid, StreamId, Data).
