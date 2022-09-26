# Binocle Player

Binocle Player aims at providing a pre-compiled version of Binocle that can be used to quickly write 2D games in Lua.

## Running your own game

```shell
./binocle-player <path of your game>
```

## Packaging your game

```shell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DBINOCLE_DATA_DIR=<path to your game assets>
```

## ld50 branch disclaimer

This branch contains the source for both the player and the game itself (all the Lua files in the assets folder).
Please feel free to do whatever you want with them. Oh and if you like this project, contributions are welcome! (You probably know that there are a lot of bugs in there)
