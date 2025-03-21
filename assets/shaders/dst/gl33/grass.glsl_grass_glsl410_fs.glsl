#version 410

uniform vec4 fs_params[1];
uniform sampler2D tex0_smp;

layout(location = 0) in vec2 tcoord;
layout(location = 0) out vec4 fragColor;
layout(location = 1) in vec4 color;

void main()
{
    fragColor = color * texture(tex0_smp, tcoord + ((vec2(fma((fs_params[0].z * tcoord.x) * tcoord.x, 0.300000011920928955078125, cos(fma(fs_params[0].x, 2.0, tcoord.y * 10.0))), fma(fs_params[0].y, 1.2000000476837158203125 - tcoord.x, cos(fma(fs_params[0].x, 2.0, tcoord.x * 20.0)))) * 0.02999999932944774627685546875) * (1.0 - tcoord.x)));
}

