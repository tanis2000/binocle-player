//
// Created by Valerio Santinelli on 28/03/22.
//

#ifndef BINOCLE_PLAYER_IMGUI_LUA_BINDINGS_H
#define BINOCLE_PLAYER_IMGUI_LUA_BINDINGS_H

#if defined __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN
#endif

struct lua_State* lState;
EXTERN void LoadImguiBindings();
#endif //BINOCLE_PLAYER_IMGUI_LUA_BINDINGS_H
