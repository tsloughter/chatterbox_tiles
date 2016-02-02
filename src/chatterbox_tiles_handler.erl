-module(chatterbox_tiles_handler).

-include_lib("chatterbox/include/http2.hrl").

-export([spawn_handle/4,
         handle/4]).

-define(WIDTH, 500).
-define(HEIGHT, 414).

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
                #{<<"x">> := X, <<"y">> := Y} ->
                    timer:sleep(1000),
                    [{_, Binary}] = ets:lookup(tiles, {binary_to_integer(X), binary_to_integer(Y)}),
                    http2_connection:send_body(ConnPid, StreamId, Binary);
                _ ->
                    tiles_page(ConnPid, StreamId)
            end;
        _ ->
            tiles_page(ConnPid, StreamId)
    end.

tiles_page(ConnPid, StreamId) ->
    ResponseHeaders = [{<<":status">>,<<"200">>},
                       {<<"content-type">>, <<"text/html">>}],
    http2_connection:send_headers(ConnPid, StreamId, ResponseHeaders),

    CacheBust = os:system_time(nano_seconds),
    Imgs = [[[io_lib:format("<img width=32 height=32 src='/gophertiles?x=~p&y=~p&cachebust=~p'>", [X, Y, CacheBust])
             || X <- lists:seq(0, trunc(?WIDTH / 32))] | "<br/>\n"]
           || Y <- lists:seq(0, trunc(?HEIGHT / 32))],
    Data = <<"<html><body>A grid of 180 tiled images is below. Compare:<br/>\n", (list_to_binary(Imgs))/binary, "</body></html>">>,

    http2_connection:send_body(ConnPid, StreamId, Data).
