//
//  Binocle
//  Copyright(C)2015-2020 Valerio Santinelli
//

#include <stdio.h>
#ifdef __EMSCRIPTEN__
#include "emscripten.h"
#endif
#include "binocle_sdl.h"
#include "binocle_window.h"
#include "binocle_viewport_adapter.h"
#include "binocle_camera.h"
#include <binocle_input.h>
#include <binocle_texture.h>
#include <binocle_sprite.h>
#include <binocle_shader.h>
#include <binocle_lua.h>
#include <binocle_app.h>
#include <binocle_window_wrap.h>
#include <binocle_camera_wrap.h>
#include <binocle_input_wrap.h>
#include <binocle_gd_wrap.h>
#include <binocle_sprite_wrap.h>

#define BINOCLE_MATH_IMPL
#include "binocle_math.h"
#include "binocle_gd.h"
#include "binocle_log.h"
#include "binocle_bitmapfont.h"

#define DESIGN_WIDTH 320
#define DESIGN_HEIGHT 240

binocle_window *window;
binocle_input *input;
binocle_camera *camera;
binocle_gd *gd;
binocle_sprite_batch *sprite_batch;
char *binocle_assets_dir;
binocle_lua lua;
binocle_app app;
float elapsed_time = 0;
SDL_mutex *lua_mutex;

void lua_bridge_window() {
  lua_getglobal(lua.L, "get_window");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the window from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_window_t *win = luaL_checkudata(lua.L, 0, "binocle_window");
  window = win->window;
}

void lua_bridge_camera() {
  lua_getglobal(lua.L, "get_camera");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the camera from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_camera_t *cam = luaL_checkudata(lua.L, 0, "binocle_camera");
  camera = cam->camera;
}

void lua_bridge_input() {
  lua_getglobal(lua.L, "get_input_mgr");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the input_mgr from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_input_t *input_mgr = luaL_checkudata(lua.L, 0, "binocle_input");
  input = input_mgr->input;
}

void lua_bridge_gd() {
  lua_getglobal(lua.L, "get_gd_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the gd_instance from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_gd_t *gd_instance = luaL_checkudata(lua.L, 0, "binocle_gd");
  gd = gd_instance->gd;
}

void lua_bridge_sprite_batch() {
  lua_getglobal(lua.L, "get_sprite_batch_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the sprite_batch_instance from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_sprite_batch_t *sprite_batch_instance = luaL_checkudata(lua.L, 0, "binocle_sprite_batch");
  sprite_batch = sprite_batch_instance->sprite_batch;
}

int lua_on_init() {
  SDL_LockMutex(lua_mutex);
  lua_getglobal(lua.L, "on_init");
  int result = lua_pcall(lua.L, 0, 0, 0);
  if (result) {
    binocle_log_error("Failed to run function on_init: %s\n", lua_tostring(lua.L, -1));
    SDL_UnlockMutex(lua_mutex);
    return 1;
  }
  SDL_UnlockMutex(lua_mutex);
  return 0;
}

int lua_on_update(float dt) {
  SDL_LockMutex(lua_mutex);
  lua_getglobal(lua.L, "on_update");
  lua_pushnumber(lua.L, dt);
  int result = lua_pcall(lua.L, 1, 0, 0);
  if (result) {
    binocle_log_error("Failed to run function on_update: %s\n", lua_tostring(lua.L, -1));
    SDL_UnlockMutex(lua_mutex);
    return 1;
  }
  SDL_UnlockMutex(lua_mutex);
  return 0;
}

void main_loop() {
  binocle_window_begin_frame(window);
  float dt = binocle_window_get_frame_time(window) / 1000.0f;
  elapsed_time += dt;

  binocle_input_update(input);

  if (input->resized) {
    kmVec2 oldWindowSize = {.x = window->width, .y = window->height};
    window->width = input->newWindowSize.x;
    window->height = input->newWindowSize.y;
    // Update the pixel-perfect rescaling viewport adapter
    binocle_viewport_adapter_reset(camera->viewport_adapter, oldWindowSize, input->newWindowSize);
    input->resized = false;
  }

  if (lua_on_update(dt)) {
    input->quit_requested = true;
  }


  /*
  if ((int)elapsed_time % 5 == 0) {
    binocle_lua_check_scripts_modification_time(&lua, "assets");
  }
   */

  binocle_window_refresh(window);
  binocle_window_end_frame(window);
}

int main(int argc, char *argv[])
{
  binocle_assets_dir = binocle_sdl_assets_dir();
  lua_mutex = SDL_CreateMutex();

  app = binocle_app_new();
  binocle_app_init(&app);

  lua = binocle_lua_new();
  binocle_lua_init(&lua);

  char main_lua[1024];
  sprintf(main_lua, "%s%s", binocle_assets_dir, "boot.lua");
  binocle_lua_run_script(&lua, main_lua);

  if (lua_on_init()) {
    binocle_sdl_exit();
    exit(1);
  }

  lua_bridge_window();
  lua_bridge_camera();
  lua_bridge_input();
  lua_bridge_gd();
  lua_bridge_sprite_batch();

#ifdef __EMSCRIPTEN__
  emscripten_set_main_loop(main_loop, 0, 1);
#else
  while (!input->quit_requested) {
    main_loop();
  }
#endif
  binocle_log_info("Quit requested");
  SDL_DestroyMutex(lua_mutex);
  binocle_sdl_exit();
}


