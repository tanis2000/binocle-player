//
//  Binocle
//  Copyright(C)2015-2020 Valerio Santinelli
//

#include <stdio.h>
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/fetch.h>
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
#include "curl/curl.h"

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
  uint8_t _pad_24[8];
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
gui_handle_t debug_gui_handle;
struct gui_t *debug_gui;
gui_handle_t game_gui_handle;
struct gui_t *game_gui;

void lua_stack_dump (lua_State *L) {
  int i;
  int top = lua_gettop(L);
  for (i = 1; i <= top; i++) {  /* repeat for each level */
    int t = lua_type(L, i);
    switch (t) {

      case LUA_TSTRING:  /* strings */
        printf("`%s'", lua_tostring(L, i));
        break;

      case LUA_TBOOLEAN:  /* booleans */
        printf(lua_toboolean(L, i) ? "true" : "false");
        break;

      case LUA_TNUMBER:  /* numbers */
        printf("%g", lua_tonumber(L, i));
        break;

      case LUA_TUSERDATA:  /* userdata */
        printf("%#010llx", (uint64_t)lua_touserdata(L, i));
        break;

      case LUA_TTABLE:
        printf("table %s", lua_tostring(L, -2));
        break;

      default:  /* other values */
        printf("%s", lua_typename(L, t));
        break;

    }
    printf("  ");  /* put a separator */
  }
  printf("\n");  /* end the listing */
}

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
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_window");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the window from Lua");
  }
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_window_t *win = luaL_checkudata(lua.L, 0, "binocle_window");
  window = win->window;
}

void lua_bridge_camera() {
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_camera");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the camera from Lua");
  }
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_camera_t *cam = luaL_checkudata(lua.L, 0, "binocle_camera");
  camera = cam->camera;
}

void lua_bridge_input() {
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_input_mgr");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the input_mgr from Lua");
  }
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_input_t *input_mgr = luaL_checkudata(lua.L, 0, "binocle_input");
  input = input_mgr->input;
}

void lua_bridge_gd() {
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_gd_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the gd_instance from Lua");
  }
  int num = lua_gettop(lua.L);
  binocle_log_info("num: %d", num);
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_gd_t *gd_instance = luaL_checkudata(lua.L, 0, "binocle_gd");
  gd = gd_instance->gd;
}

void lua_bridge_sprite_batch() {
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_sprite_batch_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the sprite_batch_instance from Lua: %s", lua_tostring(lua.L, -1));
  }
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, 0)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_sprite_batch_t *sprite_batch_instance = luaL_checkudata(lua.L, 0, "binocle_sprite_batch");
  sprite_batch = sprite_batch_instance->sprite_batch;
}

void lua_bridge_audio() {
  lua_stack_dump(lua.L);
  lua_getglobal(lua.L, "get_audio_instance");
  if (lua_pcall(lua.L, 0, 1, 0) != 0) {
    binocle_log_error("can't get the audio_instance from Lua");
  }
  lua_stack_dump(lua.L);
  if (!lua_isuserdata(lua.L, -1)) {
    binocle_log_error("returned value is not userdata");
  }
  lua_stack_dump(lua.L);
  lua_pop(lua.L, 1);
  l_binocle_audio_t *audio_instance = luaL_checkudata(lua.L, 0, "binocle_audio");
  audio = audio_instance->audio;
}

int lua_on_init() {
  SDL_LockMutex(lua_mutex);
  lua_getglobal(lua.L, "on_init");
  int result = lua_pcall(lua.L, 0, 0, 0);
  binocle_log_info("on_init returned\n");
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

#if defined(__EMSCRIPTEN__)
void download_success(emscripten_fetch_t *fetch) {
  printf("Finished downloading %llu bytes from URL %s.\n", fetch->numBytes, fetch->url);
  // The data is now available at fetch->data[0] through fetch->data[fetch->numBytes-1];
  emscripten_fetch_close(fetch); // Free data associated with the fetch.
}

void download_error(emscripten_fetch_t *fetch) {
  printf("Downloading %s failed, HTTP failure status code: %d.\n", fetch->url, fetch->status);
  emscripten_fetch_close(fetch); // Also free data on failure.
}
#endif

void test_curl() {
#if defined(__EMSCRIPTEN__)
  emscripten_fetch_attr_t attr;
  emscripten_fetch_attr_init(&attr);
  strcpy(attr.requestMethod, "GET");
  attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY;// | EMSCRIPTEN_FETCH_SYNCHRONOUS;
  attr.onsuccess = download_success;
  attr.onerror = download_error;
  emscripten_fetch_t *fetch = emscripten_fetch(&attr, "https://podium.altralogica.it/l/ld53-temp/top/0"); // Blocks here until the operation is complete.
//  if (fetch->status == 200) {
//    printf("Finished downloading %llu bytes from URL %s.\n", fetch->numBytes, fetch->url);
//    // The data is now available at fetch->data[0] through fetch->data[fetch->numBytes-1];
//  } else {
//    printf("Downloading %s failed, HTTP failure status code: %d.\n", fetch->url, fetch->status);
//  }
//  emscripten_fetch_close(fetch);
#else
  CURL *curl;
  CURLcode res;

  curl_global_init(CURL_GLOBAL_ALL);
  curl = curl_easy_init();
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_URL, "https://podium.altralogica.it");
    /* example.com is redirected, so we tell libcurl to follow redirection */
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

    /* Perform the request, res will get the return code */
    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CURLE_OK)
      binocle_log_error("curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));

    /* always cleanup */
    curl_easy_cleanup(curl);
  }
#endif
}

void main_loop() {
  binocle_window_begin_frame(window);
  float dt = (float)binocle_window_get_frame_time(window) / 1000.0f;
  elapsed_time += dt;

  binocle_input_update(input);
  gui_pass_input_to_imgui(debug_gui_handle, input);
  gui_pass_input_to_imgui(game_gui_handle, input);

  if (input->resized) {
    kmVec2 oldWindowSize = {.x = window->width, .y = window->height};
    window->width = input->newWindowSize.x;
    window->height = input->newWindowSize.y;
    // Update the pixel-perfect rescaling viewport adapter
    binocle_viewport_adapter_reset(camera->viewport_adapter, oldWindowSize, input->newWindowSize);
    gui_recreate_imgui_render_target(debug_gui_handle, window->width, window->height);
    gui_set_viewport(debug_gui_handle, window->width, window->height);
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
  if (argc > 1) {
    char *path = argv[1];
    app_desc.forced_asset_origin_path = path;
    if (!binocle_sdl_directory_exists(path)) {
      binocle_log_error("Directory %s does not exist. Quitting.", path);
      return -1;
    }
  }
  app = binocle_app_new();
  binocle_app_init(&app, &app_desc);
  binocle_assets_dir = "/assets/";

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
  binocle_fs_load_text_file(vert, &shader_vs_src, &shader_vs_src_size);

  char *shader_fs_src;
  size_t shader_fs_src_size;
  binocle_fs_load_text_file(frag, &shader_fs_src, &shader_fs_src_size);
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
    .fs.images[0] = { .used = true, .image_type = SG_IMAGETYPE_2D},
    .fs.samplers[0] = {.used = true, .sampler_type = SG_SAMPLERTYPE_FILTERING},
    .fs.image_sampler_pairs[0] = {.used = true, .glsl_name = "tex0", .image_slot = 0, .sampler_slot = 0},
  };
  default_shader = sg_make_shader(&default_shader_desc);

#ifdef BINOCLE_GL
  // Screen shader
  sprintf(vert, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "screen_vert.glsl");
  sprintf(frag, "%sshaders/%s/%s", binocle_assets_dir, SHADER_PATH, "screen_frag.glsl");

  char *screen_shader_vs_src;
  size_t screen_shader_vs_src_size;
  binocle_fs_load_text_file(vert, &screen_shader_vs_src, &screen_shader_vs_src_size);

  char *screen_shader_fs_src;
  size_t screen_shader_fs_src_size;
  binocle_fs_load_text_file(frag, &screen_shader_fs_src, &screen_shader_fs_src_size);
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
    .fs.images[0] = { .used = true, .image_type = SG_IMAGETYPE_2D},
    .fs.samplers[0] = {.used = true, .sampler_type = SG_SAMPLERTYPE_FILTERING},
    .fs.image_sampler_pairs[0] = {.used = true, .glsl_name = "tex0", .image_slot = 0, .sampler_slot = 0},
    .fs.uniform_blocks[0] = {
      .size = sizeof(screen_shader_fs_params_t),
      .layout = SG_UNIFORMLAYOUT_STD140,
      .uniforms = {
        [0] = { .name = "resolution", .type = SG_UNIFORMTYPE_FLOAT2 },
        [1] = { .name = "scale", .type = SG_UNIFORMTYPE_FLOAT2 },
        [2] = { .name = "viewport", .type = SG_UNIFORMTYPE_FLOAT2 },
        [3] = { .name = "pad24", .type = SG_UNIFORMTYPE_FLOAT2 },
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

  gui_resources_setup();
  debug_gui_handle = gui_resources_create_gui("debug");
  gui_init_imgui(debug_gui_handle, window->width, window->height, window->width, window->height);
  gui_setup_screen_pipeline(debug_gui_handle, screen_shader, false);

  game_gui_handle = gui_resources_create_gui("game");
  gui_set_apply_scissor(game_gui_handle, true);
  gui_set_viewport_adapter(game_gui_handle, binocle_camera_get_viewport_adapter(*camera));
  gui_init_imgui(game_gui_handle, DESIGN_WIDTH, DESIGN_HEIGHT, window->width, window->height);
  gui_setup_screen_pipeline(game_gui_handle, screen_shader, true);

//  gui_setup_imgui_to_offscreen_pipeline(gd, binocle_assets_dir);

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
  return 0;
}


