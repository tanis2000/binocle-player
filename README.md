# Binocle Player

Binocle Player aims at providing a pre-compiled version of Binocle that can be used to quickly write 2D games in Lua.

The core philosophy  is somewhat similar to Love2D. Binocle Player comes as a pre-compiled binary for macOS and Windows and can run games from the command line.

On the other hand, if you compile it from sources you can embed your game with the executable and make it run on all the platforms supported by Binocle.

## Running your own game

```shell
./binocle-player <path of your game>
```

## Packaging your game

### Windows/macOS

```shell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DBINOCLE_DATA_DIR=<path to your game assets>
```

### Browser

```shell
emcmake cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DASSETS_DIR=<full path to your game assets ending with a slash>
```

As an example

```shell
emcmake cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DASSETS_DIR=/Users/tanis/Documents/binocle-player-games/simple/
```

## HTTP support

HTTP support is disabled by default. If you want to enable the HTTP module, you have to add `-DBINOCLE_HTTP=1` to cmake's command line.

## Samples

Some example games are available in the [Bincole Player Games](https://github.com/tanis2000/binocle-player-games) repository.
