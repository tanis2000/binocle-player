#version 300 es
precision mediump float;
precision highp int;

uniform highp vec4 fs_params[1];
uniform highp sampler2D tex0_smp;

in highp vec2 tcoord;
layout(location = 0) out highp vec4 fragColor;
in highp vec4 color;

void main()
{
    fragColor = color * texture(tex0_smp, tcoord + ((vec2(((fs_params[0].z * tcoord.x) * tcoord.x) * 0.300000011920928955078125 + cos(fs_params[0].x * 2.0 + (tcoord.y * 10.0)), fs_params[0].y * (1.2000000476837158203125 - tcoord.x) + cos(fs_params[0].x * 2.0 + (tcoord.x * 20.0))) * 0.02999999932944774627685546875) * (1.0 - tcoord.x)));
}

