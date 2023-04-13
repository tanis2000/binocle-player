# Binocle Player

Binocle Player aims at providing a pre-compiled version of Binocle that can be used to quickly write 2D games in Lua.

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
