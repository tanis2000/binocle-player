#version 300 es
precision mediump float;
precision highp int;

uniform highp sampler2D tex0_smp;

in highp vec2 tcoord;
layout(location = 0) out highp vec4 fragColor;
in highp vec4 color;

void main()
{
    if (texture(tex0_smp, tcoord).w < 0.100000001490116119384765625)
    {
        discard;
    }
    fragColor = vec4(1.0);
}

