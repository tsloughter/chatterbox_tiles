%%%-------------------------------------------------------------------
%% @doc chatterbox_tiles public API
%% @end
%%%-------------------------------------------------------------------

-module(chatterbox_tiles_app).

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    setup_tiles(),
    CertFile = filename:join(code:priv_dir(chatterbox_tiles), "localhost.crt"),
    KeyFile = filename:join(code:priv_dir(chatterbox_tiles), "localhost.key"),
    elli_chatterbox:start_link([{ssl, false}, {port, 8080}, {handler, tiles_callback}]),
    elli_chatterbox:start_link([{ssl, true},
                                {port, 8081},
                                {certfile, CertFile},
                                {keyfile, KeyFile},
                                {handler, tiles_callback}]),
    chatterbox_tiles_sup:start_link().
%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

setup_tiles() ->
    ets:new(tiles, [public, named_table]),
    {ok, Img} = file:read_file(filename:join(code:priv_dir(chatterbox_tiles), "rebar3.png")),
    TileSize = 32,
    lists:map(fun(Y) ->
                      lists:map(fun(X) ->
                                        Crop = [32, 32, 32 * X, 32 * Y],
                                        Opts = [{crop, iolist_to_binary(io_lib:fwrite("~Bx~B+~B+~B\\!", Crop))}],
                                        {ok, [Img1]} = emagick:convert(Img, png, png, Opts),
                                        ets:insert(tiles, {{X, Y}, Img1})
                                end, lists:seq(0, trunc(500 / TileSize)))
              end, lists:seq(0, trunc(438 / TileSize))).
