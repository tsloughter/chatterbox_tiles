-module(tiles).

-export([get_tile/3,
         body/1]).

-define(WIDTH, 500).
-define(HEIGHT, 414).

get_tile(X, Y, Latency) ->
    timer:sleep(binary_to_integer(Latency)),
    [{_, Binary}] = ets:lookup(tiles, {binary_to_integer(X), binary_to_integer(Y)}),
    Binary.

body(Latency) ->
    CacheBust = os:system_time(nano_seconds),
    Imgs = [[[io_lib:format("<img width=32 height=32 src='/gophertiles?x=~p&y=~p&cachebust=~p&latency=~s'>", [X, Y, CacheBust, Latency])
             || X <- lists:seq(0, trunc(?WIDTH / 32))] | "<br/>\n"]
           || Y <- lists:seq(0, trunc(?HEIGHT / 32))],
    <<"<html><body>A grid of 180 tiled images is below. Compare:<br/>\n", (links())/binary, "<br/>\n", (list_to_binary(Imgs))/binary, "</body></html>">>.

links() ->
    <<"<br/>[<a href='https://localhost:8081?latency=0'>HTTP/2, 0 latency</a>] [<a href='http://localhost:8080?latency=0'>HTTP/1, 0 latency</a>]<br>[<a href='https://localhost:8081?latency=30'>HTTP/2, 30ms latency</a>] [<a href='http://localhost:8080?latency=30'>HTTP/1, 30ms latency</a>]<br>[<a href='https://localhost:8081?latency=200'>HTTP/2, 200ms latency</a>] [<a href='http://localhost:8080?latency=200'>HTTP/1, 200ms latency</a>]<br>[<a href='https://localhost:8081?latency=1000'>HTTP/2, 1s latency</a>] [<a href='http://localhost:8080?latency=1000'>HTTP/1, 1s latency</a>]<br>">>.
