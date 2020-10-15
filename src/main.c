//
//  Binocle
//  Copyright(C)2015-2020 Valerio Santinelli
//

#include <stdio.h>
#ifdef __EMSCRIPTEN__
#include "emscripten.h"
#endif
#include "binocle_sdl.h"
#include "binocle_color.h"
#include "binocle_window.h"
#include "binocle_game.h"
#include "binocle_viewport_adapter.h"
#include "binocle_camera.h"
#include <binocle_input.h>
#include <binocle_image.h>
#include <binocle_texture.h>
#include <binocle_sprite.h>
#include <binocle_shader.h>
#include <binocle_material.h>
#include <binocle_lua.h>
#include <binocle_app.h>
#include <binocle_window_wrap.h>
#include <binocle_viewport_adapter_wrap.h>
#include <binocle_camera_wrap.h>
#include <binocle_input_wrap.h>
#include <binocle_gd_wrap.h>

#define BINOCLE_MATH_IMPL
#include "binocle_math.h"
#include "binocle_gd.h"
#include "binocle_log.h"
#include "binocle_bitmapfont.h"

//#define GAMELOOP 1

#define DESIGN_WIDTH 320
#define DESIGN_HEIGHT 240

// TODO: remove after we're done with Lua bindings
binocle_window *window;
binocle_input *input;
binocle_viewport_adapter *adapter;
binocle_camera *camera;
binocle_sprite *player;
kmVec2 player_pos;
binocle_gd *gd;
binocle_bitmapfont *font;
binocle_image *font_image;
binocle_texture *font_texture;
binocle_material *font_material;
binocle_sprite *font_sprite;
kmVec2 font_sprite_pos;
char *binocle_assets_dir;
binocle_lua lua;
binocle_app app;
binocle_sprite_batch sprite_batch;
binocle_shader *shader;
float elapsed_time = 0;
SDL_mutex *lua_mutex;

int lua_set_globals() {
  //lua_pushlightuserdata(lua.L, (void *)&gd);
  //lua_setglobal(lua.L, "gdc");

  lua_pushlightuserdata(lua.L, (void *)&sprite_batch);
  lua_setglobal(lua.L, "sprite_batch");

  //lua_pushlightuserdata(lua.L, (void *)&adapter.viewport);
  //lua_setglobal(lua.L, "viewport");

  /*
  kmAABB2 *p = &adapter.viewport;
  kmAABB2 **my__p = lua_newuserdata(lua.L, sizeof(void *));
  *my__p = p;
  (lua_getfield(lua.L, (-10000), ("KAZMATH{kmAABB2}")));
  lua_setmetatable(lua.L, -2);
  lua_setglobal(lua.L, "viewport");
*/

  //lua_pushlightuserdata(lua.L, (void *)&camera);
  //lua_setglobal(lua.L, "camera");

  //lua_pushlightuserdata(lua.L, (void *)&input);
  //lua_setglobal(lua.L, "input_mgr");

  //lua_pushlightuserdata(lua.L, (void *)&window);
  //lua_setglobal(lua.L, "win");

  if (adapter != NULL) {
    lua_pushnumber(lua.L, adapter->multiplier);
    lua_setglobal(lua.L, "multiplier");

    lua_pushnumber(lua.L, adapter->inverse_multiplier);
    lua_setglobal(lua.L, "inverse_multiplier");
  }

  return 0;
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

/*
  if (binocle_input_is_key_pressed(&input, KEY_RIGHT)) {
    player_pos.x += 50 * (1.0/window->frame_time);
  } else if (binocle_input_is_key_pressed(&input, KEY_LEFT)) {
    player_pos.x -= 50 * (1.0/window->frame_time);
  }

  if (binocle_input_is_key_pressed(&input, KEY_UP)) {
    player_pos.y += 50 * (1.0/window->frame_time);
  } else if (binocle_input_is_key_pressed(&input, KEY_DOWN)) {
    player_pos.y -= 50 * (1.0/window->frame_time);
  }
*/

  //kmMat4 matrix;
  //kmMat4Identity(&matrix);
  //binocle_sprite_batch_begin(&sprite_batch, binocle_camera_get_viewport(camera), BINOCLE_SPRITE_SORT_MODE_DEFERRED, shader, &matrix);

  //binocle_window_clear(window);

  lua_set_globals();
  if (lua_on_update(dt)) {
    input->quit_requested = true;
  }

  //binocle_sprite_batch_end(&sprite_batch, binocle_camera_get_viewport(camera));

  //kmVec2 scale;
  //scale.x = 1.0f;
  //scale.y = 1.0f;
  //binocle_sprite_draw(player, &gd, (uint64_t)player_pos.x, (uint64_t)player_pos.y, &adapter.viewport, 0, &scale, &camera);
  //kmMat4 view_matrix;
  //kmMat4Identity(&view_matrix);
  //binocle_bitmapfont_draw_string(font, "TEST", 12, &gd, 20, 20, adapter.viewport, binocle_color_white(), view_matrix);
  //binocle_sprite_draw(font_sprite, &gd, (uint64_t)font_sprite_pos.x, (uint64_t)font_sprite_pos.y, adapter.viewport);

  /*
  if ((int)elapsed_time % 5 == 0) {
    binocle_lua_check_scripts_modification_time(&lua, "assets");
  }
   */

  binocle_window_refresh(window);
  binocle_window_end_frame(window);
  //binocle_log_info("FPS: %d", binocle_window_get_fps(&window));
}

int main(int argc, char *argv[])
{
  binocle_assets_dir = binocle_sdl_assets_dir();
  lua_mutex = SDL_CreateMutex();

  app = binocle_app_new();
  binocle_app_init(&app);

  lua = binocle_lua_new();
  binocle_lua_init(&lua);

  lua_set_globals();

  char main_lua[1024];
  sprintf(main_lua, "%s%s", binocle_assets_dir, "boot.lua");
  binocle_lua_run_script(&lua, main_lua);

  if (lua_on_init()) {
    binocle_sdl_exit();
    exit(1);
  }

  lua_getglobal(lua.L, "get_window");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the window from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_window_t *win = luaL_checkudata(lua.L, 0, "binocle_window");
  window = win->window;
  //window = SDL_malloc(sizeof(binocle_window));
  //memcpy(window, win->window, sizeof(binocle_window));

  //adapter = binocle_viewport_adapter_new(*window, BINOCLE_VIEWPORT_ADAPTER_KIND_SCALING, BINOCLE_VIEWPORT_ADAPTER_SCALING_TYPE_PIXEL_PERFECT, window->original_width, window->original_height, window->original_width, window->original_height);
  lua_getglobal(lua.L, "get_adapter");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the adapter from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_viewport_adapter_t *va = luaL_checkudata(lua.L, 0, "binocle_viewport_adapter");
  adapter = va->viewport_adapter;

  //camera = binocle_camera_new(adapter);
  lua_getglobal(lua.L, "get_camera");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the camera from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_camera_t *cam = luaL_checkudata(lua.L, 0, "binocle_camera");
  camera = cam->camera;

  //input = binocle_input_new();
  lua_getglobal(lua.L, "get_input_mgr");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the input_mgr from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_input_t *input_mgr = luaL_checkudata(lua.L, 0, "binocle_input");
  input = input_mgr->input;


  char filename[1024];
  sprintf(filename, "%s%s", binocle_assets_dir, "wabbit_alpha.png");
  binocle_image *image = binocle_image_load(filename);
  binocle_texture *texture = binocle_texture_from_image(image);
  char vert[1024];
  sprintf(vert, "%s%s", binocle_assets_dir, "shaders/default_vert.glsl");
  char frag[1024];
  sprintf(frag, "%s%s", binocle_assets_dir, "shaders/default_frag.glsl");
  shader = binocle_shader_load_from_file(vert, frag);
  binocle_material *material = binocle_material_new();
  material->albedo_texture = texture;
  material->shader = shader;
  player = binocle_sprite_from_material(material);
  player_pos.x = 50;
  player_pos.y = 50;

  char font_filename[1024];
  sprintf(font_filename, "%s%s", binocle_assets_dir, "font.fnt");
  font = binocle_bitmapfont_from_file(font_filename, true);

  char font_image_filename[1024];
  sprintf(font_image_filename, "%s%s", binocle_assets_dir, "font.png");
  font_image = binocle_image_load(font_image_filename);
  font_texture = binocle_texture_from_image(font_image);
  font_material = binocle_material_new();
  font_material->albedo_texture = font_texture;
  font_material->shader = shader;
  font->material = font_material;
  font_sprite = binocle_sprite_from_material(font_material);
  font_sprite_pos.x = 0;
  font_sprite_pos.y = -256;

  //gd = binocle_gd_new();
  //binocle_gd_init(&gd);
  lua_getglobal(lua.L, "get_gd_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the gd_instance from Lua");
  }
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_gd_t *gd_instance = luaL_checkudata(lua.L, 0, "binocle_gd");
  gd = gd_instance->gd;

  sprite_batch = binocle_sprite_batch_new();
  sprite_batch.gd = gd;



#ifdef GAMELOOP
  binocle_game_run(window, input);
#else
#ifdef __EMSCRIPTEN__
  emscripten_set_main_loop(main_loop, 0, 1);
#else
  while (!input->quit_requested) {
    main_loop();
  }
#endif
  binocle_log_info("Quit requested");
#endif
  SDL_DestroyMutex(lua_mutex);
  binocle_sdl_exit();
}


