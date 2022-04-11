//
//  Binocle
//  Copyright(C)2015-2020 Valerio Santinelli
//

#include <stdio.h>
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif
#include "binocle_sdl.h"
#include "binocle_window.h"
#include "binocle_viewport_adapter.h"
#include "binocle_camera.h"
#include <binocle_input.h>
#include <binocle_sprite.h>
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
#include "binocle_ttfont.h"
#include "binocle_audio.h"
#include "binocle_audio_wrap.h"
#include "gui.h"
#include "imgui_lua_bindings.h"

#define DESIGN_WIDTH 320
#define DESIGN_HEIGHT 240

#if defined(BINOCLE_MACOS) && defined(BINOCLE_METAL)
#include "../../assets/shaders/metal/default-metal-macosx.h"
#include "../../assets/shaders/metal/screen-metal-macosx.h"
#endif

#if defined(__IPHONEOS__) || defined(__ANDROID__) || defined(__EMSCRIPTEN__)
#define SHADER_PATH "gles"
#else
#define SHADER_PATH "gl33"
#endif

typedef struct default_shader_params_t {
  float projectionMatrix[16];
  float modelMatrix[16];
  float viewMatrix[16];
} default_shader_params_t;

typedef struct screen_shader_fs_params_t {
  float resolution[2];
  float scale[2];
  float viewport[2];
} screen_shader_fs_params_t;

typedef struct screen_shader_vs_params_t {
  float transform[16];
} screen_shader_vs_params_t;

binocle_window *window;
binocle_input *input;
binocle_camera *camera;
binocle_gd *gd;
binocle_sprite_batch *sprite_batch;
binocle_audio *audio;
char *binocle_assets_dir;
binocle_lua lua;
binocle_app app;
float elapsed_time = 0;
SDL_mutex *lua_mutex;
sg_shader default_shader;
sg_shader screen_shader;

int l_default_shader(lua_State *L) {
  sg_shader *a = lua_newuserdata(L, sizeof(default_shader));
  SDL_memcpy(a, &default_shader, sizeof(default_shader));
  return 1;
}
int l_screen_shader(lua_State *L) {
  sg_shader *a = lua_newuserdata(L, sizeof(screen_shader));
  SDL_memcpy(a, &screen_shader, sizeof(screen_shader));
  return 1;
}

void lua_inject_shaders() {
  static const struct luaL_Reg lib [] = {
    {"defaultShader", l_default_shader},
    {"screenShader", l_screen_shader},
    {NULL, NULL}
  };
  luaL_openlib(lua.L, "shader", lib, 0);
}

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

void lua_bridge_audio() {
  lua_getglobal(lua.L, "get_audio_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the audio_instance from Lua");
  }
  if (!lua_isuserdata(lua.L, -1)) {
    binocle_log_error("returned value is not userdata");
  }
  l_binocle_audio_t *audio_instance = luaL_checkudata(lua.L, -1, "binocle_audio");
  audio = audio_instance->audio;
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

int lua_on_destroy() {
  SDL_LockMutex(lua_mutex);
  lua_getglobal(lua.L, "on_destroy");
  int result = lua_pcall(lua.L, 0, 0, 0);
  if (result) {
    binocle_log_error("Failed to run function on_destroy: %s\n", lua_tostring(lua.L, -1));
    SDL_UnlockMutex(lua_mutex);
    return 1;
  }
  SDL_UnlockMutex(lua_mutex);
  return 0;
}

void main_loop() {
  binocle_window_begin_frame(window);
  float dt = (float)binocle_window_get_frame_time(window) / 1000.0f;
  elapsed_time += dt;

  binocle_input_update(input);
  gui_pass_input_to_imgui(input);

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

  // Render all drawables to the offscreen RT
  binocle_gd_render_offscreen(gd);

  // Render all flat shaded instances (rect, circle, etc..)
  binocle_gd_render_flat(gd);

  // Render imgui to its own render target
  //gui_draw(window, input, dt);

  // Gets the viewport calculated by the adapter
  kmAABB2 vp = binocle_viewport_adapter_get_viewport(*camera->viewport_adapter);

  // Render the game to screen
//  binocle_gd_render_screen(gd, window, DESIGN_WIDTH, DESIGN_HEIGHT, vp, camera->viewport_adapter->scale_matrix, camera->viewport_adapter->inverse_multiplier);

  // Render the editor UI imgui render target to the screen
//  gui_render_to_screen(gd, window, window->width, window->height, vp, camera->viewport_adapter->scale_matrix, 1);

  binocle_window_refresh(window);
  binocle_window_end_frame(window);
}

int main(int argc, char *argv[])
{
  binocle_app_desc_t app_desc = {0};
  app = binocle_app_new();
  binocle_app_init(&app, &app_desc);
  binocle_assets_dir = binocle_sdl_assets_dir();

  lua_mutex = SDL_CreateMutex();

  lua = binocle_lua_new();
  binocle_lua_init(&lua);

  char main_lua[1024];
  sprintf(main_lua, "%s%s", binocle_assets_dir, "boot.lua");
  binocle_lua_run_script(&lua, main_lua);


  if (lua_on_init()) {
    binocle_sdl_exit();
    exit(1);
  }


#ifdef BINOCLE_GL
  // Default shader
  char vert[1024];
  sprintf(vert, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "default_vert.glsl");
  char frag[1024];
  sprintf(frag, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "default_frag.glsl");

  char *shader_vs_src;
  size_t shader_vs_src_size;
  binocle_sdl_load_text_file(vert, &shader_vs_src, &shader_vs_src_size);

  char *shader_fs_src;
  size_t shader_fs_src_size;
  binocle_sdl_load_text_file(frag, &shader_fs_src, &shader_fs_src_size);
#endif

  sg_shader_desc default_shader_desc = {
#ifdef BINOCLE_GL
    .vs.source = shader_vs_src,
#else
    .vs.byte_code = default_vs_bytecode,
    .vs.byte_code_size = sizeof(default_vs_bytecode),
#endif
    .attrs = {
      [0].name = "vertexPosition",
      [1].name = "vertexColor",
      [2].name = "vertexTCoord",
    },
    .vs.uniform_blocks[0] = {
      .size = sizeof(default_shader_params_t),
      .uniforms = {
        [0] = { .name = "projectionMatrix", .type = SG_UNIFORMTYPE_MAT4},
        [1] = { .name = "viewMatrix", .type = SG_UNIFORMTYPE_MAT4},
        [2] = { .name = "modelMatrix", .type = SG_UNIFORMTYPE_MAT4},
      }
    },
#ifdef BINOCLE_GL
    .fs.source = shader_fs_src,
#else
    .fs.byte_code = default_fs_bytecode,
    .fs.byte_code_size = sizeof(default_fs_bytecode),
#endif
    .fs.images[0] = { .name = "tex0", .image_type = SG_IMAGETYPE_2D},
  };
  default_shader = sg_make_shader(&default_shader_desc);

#ifdef BINOCLE_GL
  // Screen shader
  sprintf(vert, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "screen_vert.glsl");
  sprintf(frag, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "screen_frag.glsl");

  char *screen_shader_vs_src;
  size_t screen_shader_vs_src_size;
  binocle_sdl_load_text_file(vert, &screen_shader_vs_src, &screen_shader_vs_src_size);

  char *screen_shader_fs_src;
  size_t screen_shader_fs_src_size;
  binocle_sdl_load_text_file(frag, &screen_shader_fs_src, &screen_shader_fs_src_size);
#endif

  sg_shader_desc screen_shader_desc = {
#ifdef BINOCLE_GL
    .vs.source = screen_shader_vs_src,
#else
    .vs.byte_code = screen_vs_bytecode,
    .vs.byte_code_size = sizeof(screen_vs_bytecode),
#endif
    .attrs = {
      [0].name = "position"
    },
    .vs.uniform_blocks[0] = {
      .size = sizeof(screen_shader_vs_params_t),
      .uniforms = {
        [0] = { .name = "transform", .type = SG_UNIFORMTYPE_MAT4},
      },
    },
#ifdef BINOCLE_GL
    .fs.source = screen_shader_fs_src,
#else
    .fs.byte_code = screen_fs_bytecode,
    .fs.byte_code_size = sizeof(screen_fs_bytecode),
#endif
    .fs.images[0] = { .name = "tex0", .image_type = SG_IMAGETYPE_2D},
    .fs.uniform_blocks[0] = {
      .size = sizeof(screen_shader_fs_params_t),
      .uniforms = {
        [0] = { .name = "resolution", .type = SG_UNIFORMTYPE_FLOAT2 },
        [1] = { .name = "scale", .type = SG_UNIFORMTYPE_FLOAT2 },
        [2] = { .name = "viewport", .type = SG_UNIFORMTYPE_FLOAT2 },
      },
    },
  };
  screen_shader = sg_make_shader(&screen_shader_desc);

  lua_inject_shaders();

  lua_bridge_window();
  lua_bridge_camera();
  lua_bridge_input();
  lua_bridge_gd();
  lua_bridge_sprite_batch();
  lua_bridge_audio();

  SetLuaState(lua.L);
  LoadImguiBindings();

  binocle_gd_setup_default_pipeline(gd, DESIGN_WIDTH, DESIGN_HEIGHT, default_shader, screen_shader);
  binocle_gd_setup_flat_pipeline(gd);

  gui_init_imgui(window->width, window->height);
//  gui_setup_imgui_to_offscreen_pipeline(gd, binocle_assets_dir);
  gui_setup_screen_pipeline(screen_shader);
#ifdef __EMSCRIPTEN__
  emscripten_set_main_loop(main_loop, 0, 1);
#else
  while (!input->quit_requested) {
    main_loop();
  }
#endif
  binocle_log_info("Quit requested");
  lua_on_destroy();
  binocle_lua_destroy(&lua);
  SDL_DestroyMutex(lua_mutex);
  binocle_app_destroy(&app);
  binocle_sdl_exit();
}


