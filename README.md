chatterbox_tiles
=====

An Erlang take on [GopherTiles](https://http2.golang.org/gophertiles) http2 example.

Known to work with firefox after following [Chatterbox instructions](https://github.com/joedevivo/chatterbox#setting-up-firefox-go-to-the-url-aboutconfig-and-search-for-the).

Build
-----

```
$ sudo apt-get install imagemagick
$ rebar3 release
$ _build/default/rel/chatterbox_tiles/bin/chatterbox_tiles console
```

Open [https://localhost:8081/](https://localhost:8081/).
