//
// Created by Valerio Santinelli on 05/07/21.
//

#ifndef BINOCLE_C_ADVENTURE_GAME_GUI_H
#define BINOCLE_C_ADVENTURE_GAME_GUI_H

#include "kazmath/kazmath.h"

struct lua_State;
struct binocle_inputl;
struct binocle_window;
struct binocle_gd;
struct sg_shader;

void gui_pass_input_to_imgui(struct binocle_input *input);
void gui_draw(struct binocle_window *window, struct binocle_input *input, float dt);
void gui_imgui_to_offscreen_render(float width, float height);
void gui_init_imgui(float width, float height);
void gui_setup_imgui_to_offscreen_pipeline(binocle_gd *gd, const char *binocle_assets_dir);
void gui_render_to_screen(struct binocle_gd *gd, struct binocle_window *window, float design_width, float design_height, kmAABB2 viewport, kmMat4 matrix, float scale);
void gui_setup_screen_pipeline(struct sg_shader display_shader);
void gui_recreate_imgui_render_target(int width, int height);
int l_gui_wrap_new_frame(struct lua_State *L);
int l_gui_wrap_render_frame(struct lua_State *L);
int l_gui_wrap_render_to_screen(struct lua_State *L);
#endif //BINOCLE_C_ADVENTURE_GAME_GUI_H
